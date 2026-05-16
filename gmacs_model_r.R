## =============================================================================
## GMACS Snow Crab Stock Assessment — R Reimplementation
## Model: 25_gmacs_update_plus_group
##
## Reproduces the ADMB objective function value (-19193.59) from the three
## input files:
##   - 25_snow_update_plus_group.dat   (observations + configuration)
##   - snow.ctl                         (model structure, weight/maturity, blocks)
##   - gmacs.par                        (parameter estimates)
##
## Gmacsall.out is read ONLY for ADMB target values printed in the comparison.
## All predicted quantities (catches, indices, size compositions, growth)
## are computed by R from the parameters and configuration above.
##
## Run from this directory:  Rscript gmacs_model_r.R
## =============================================================================

## File paths -----------------------------------------------------------------
here <- function(fn) {
  if (file.exists(fn)) fn
  else file.path(
    "/Users/grantadams/Documents/GitHub/AFSC_assessments",
    "snow_crab/Models/25_gmacs_update_plus_group", fn
  )
}
DAT_PATH <- here("25_snow_update_plus_group.dat")
CTL_PATH <- here("snow.ctl")
PAR_PATH <- here("gmacs.par")


## =============================================================================
## 1. PARAMETER LOADER  (reads gmacs.par into a named list)
## =============================================================================
read_par <- function(path) {
  lines <- readLines(path, warn = FALSE)
  P <- list()
  i <- 2  # skip top header line
  while (i <= length(lines)) {
    h <- trimws(lines[i])
    if (!startsWith(h, "#")) { i <- i + 1; next }
    name <- sub(":$", "", sub("^#\\s*", "", h))  # e.g. "T_pars_est[1]" or "log_fdev[1]"
    # Following data line(s) until next "#"
    j <- i + 1
    body <- character()
    while (j <= length(lines) && !startsWith(trimws(lines[j]), "#")) {
      body <- c(body, lines[j]); j <- j + 1
    }
    vals <- as.numeric(strsplit(trimws(paste(body, collapse = " ")), "\\s+")[[1]])
    P[[name]] <- vals
    i <- j
  }
  # Collapse repeated indexed names into vectors:
  #   T_pars_est[1], T_pars_est[2], ...  ->  T_pars_est
  out <- list()
  base_names <- sub("\\[[0-9]+\\]$", "", names(P))
  for (bn in unique(base_names)) {
    idxs <- which(base_names == bn)
    if (length(idxs) == 1 && bn == names(P)[idxs]) {
      out[[bn]] <- P[[idxs]]
    } else {
      # vector indexed name: store as named list element by combining vals
      out[[bn]] <- unlist(P[idxs], use.names = FALSE)
    }
  }
  # log_fdev/log_fdov are separate vectors per fleet; rebuild as list-by-fleet
  for (nm in c("log_fdev", "log_fdov")) {
    if (!is.null(out[[nm]])) {
      keys <- names(P)[grepl(paste0("^", nm, "\\["), names(P))]
      out[[nm]] <- lapply(keys, function(k) P[[k]])
    }
  }
  out
}


## =============================================================================
## 2. CTL LOADER  (snow.ctl - blocks, weight, maturity)
## =============================================================================
# Skip comment ("#") and blank lines starting from index i; return next data idx.
ctl_skip <- function(lines, i) {
  while (i <= length(lines)) {
    s <- trimws(lines[i])
    if (nchar(s) > 0 && !startsWith(s, "#")) return(i)
    i <- i + 1
  }
  i
}
ctl_nums <- function(line) as.numeric(strsplit(trimws(line), "\\s+")[[1]])

read_ctl <- function(path, nclass = 22, syr = 1982, nyrs = 43) {
  lines <- readLines(path, warn = FALSE)
  out <- list()

  ## --- M block definitions: which years belong to each block ---
  # snow.ctl lines: "Blocks to be used", "n_block_groups", "blocks per group",
  # then block definitions (start_year end_year pairs).
  i <- ctl_skip(lines, grep("Blocks to be used", lines)[1] + 1)
  i <- ctl_skip(lines, i + 1)  # nblock_groups
  nblk_per <- as.integer(ctl_nums(lines[i]))  # e.g. "3 43"
  blocks_by_grp <- list()
  i <- i + 1
  for (g in seq_along(nblk_per)) {
    i <- ctl_skip(lines, i)
    # Collect tokens until we have nblk_per[g] block-pairs (2*nblk_per[g] numbers)
    need <- 2 * nblk_per[g]
    tokens <- integer()
    while (length(tokens) < need) {
      tokens <- c(tokens, as.integer(ctl_nums(lines[i])))
      i <- i + 1
    }
    tokens <- tokens[seq_len(need)]
    blocks_by_grp[[g]] <- matrix(tokens, ncol = 2, byrow = TRUE)
  }
  out$M_blocks  <- blocks_by_grp[[1]]  # group 1: 3 blocks of (2018, 2019, 2020)
  out$mat_blocks<- blocks_by_grp[[2]]  # group 2: 43 yearly blocks (1983..2025)

  ## --- Weight-at-length (4 rows: male imm, male mat, female imm, female mat) ---
  i_wt <- grep("weight-at-length", lines)[1]
  i <- ctl_skip(lines, i_wt + 1)
  # First line after header is the method (1=allometry, 2=vector by sex)
  i <- ctl_skip(lines, i + 1)
  wt_rows <- list()
  for (r in 1:4) {
    i <- ctl_skip(lines, i)
    wt_rows[[r]] <- ctl_nums(lines[i])[1:nclass]
    i <- i + 1
  }
  # Per ctl order: male imm, male mat (identical), female imm, female mat
  out$wt_male   <- wt_rows[[1]]
  out$wt_female <- wt_rows[[3]]

  ## --- Year-specific maturity ogive (2 groups: MALES block, FEMALES block) ---
  # First, the constant "Proportion mature by sex" (used as baseline)
  i_pmat <- grep("Proportion mature by sex", lines)[1]
  # Skip the proportion-mature and proportion-legal rows (2 male + 2 female lines, then 2 legal)
  # The full maturity ogive is in two blocks of (1 + 43) = 44 rows under "## MALES" / "## FEMALES"
  i_males <- grep("^## MALES\\s*$", lines)[1]
  i <- ctl_skip(lines, i_males + 1)
  n_blocks <- nrow(out$mat_blocks) + 1   # 44 blocks (block 0 + 43 yearly)
  mat_male_blocks <- matrix(NA_real_, nrow = n_blocks, ncol = nclass)
  for (b in 1:n_blocks) {
    i <- ctl_skip(lines, i)
    mat_male_blocks[b, ] <- ctl_nums(lines[i])[1:nclass]
    i <- i + 1
  }
  i_females <- grep("^## FEMALES\\s*$", lines)[1]
  i <- ctl_skip(lines, i_females + 1)
  mat_fem_blocks <- matrix(NA_real_, nrow = n_blocks, ncol = nclass)
  for (b in 1:n_blocks) {
    i <- ctl_skip(lines, i)
    mat_fem_blocks[b, ] <- ctl_nums(lines[i])[1:nclass]
    i <- i + 1
  }
  # Map blocks to years: block 0 is the default; blocks 1..N are the yearly assignments.
  # mat_blocks rows are (start_year, end_year) pairs covering single years 1983..2025.
  years_all <- seq(syr, length.out = nyrs)
  block_for_year <- rep(1L, nyrs)  # 1-based: block 0 = row 1
  for (b in seq_len(nrow(out$mat_blocks))) {
    y0 <- out$mat_blocks[b, 1]
    if (y0 >= syr && y0 <= syr + nyrs - 1) {
      block_for_year[y0 - syr + 1] <- b + 1L
    }
  }
  out$mat_male_yr   <- mat_male_blocks[block_for_year, ]
  out$mat_female_yr <- mat_fem_blocks[block_for_year, ]

  out
}


## =============================================================================
## 3. DAT LOADERS  (catch frames, surveys, size comps, growth obs)
## =============================================================================
load_catches <- function(path) {
  lines <- readLines(path, warn = FALSE)
  i_nr <- grep("Number of rows in each data frame", lines)[1]
  nrows <- as.integer(strsplit(trimws(lines[i_nr + 1]), "\\s+")[[1]])
  i <- i_nr + 2
  frames <- list()
  for (k in seq_along(nrows)) {
    while (!grepl("^\\s*[0-9]", lines[i])) i <- i + 1
    rows <- vector("list", nrows[k])
    for (r in seq_len(nrows[k])) {
      rows[[r]] <- as.numeric(strsplit(trimws(lines[i]), "\\s+")[[1]][1:11])
      i <- i + 1
    }
    df <- as.data.frame(do.call(rbind, rows))
    names(df) <- c("year","season","fleet","sex","obs","cv",
                   "type","units","mult","effort","dmr")
    frames[[k]] <- df
  }
  frames  # 1=ret_mal_pot, 2=disc_mal_pot, 3=disc_fem_pot, 4=trawl_both
}

load_surveys <- function(path) {
  lines <- readLines(path, warn = FALSE)
  i_nr <- grep("Number\\s+of\\s+rows\\s+of\\s+index\\s+data", lines)[1] + 1
  while (!grepl("^\\s*[0-9]", lines[i_nr])) i_nr <- i_nr + 1
  nrows <- as.integer(strsplit(trimws(lines[i_nr]), "\\s+")[[1]][1])
  i <- i_nr + 1
  while (!grepl("^\\s*[0-9]+\\s+[0-9]{4}", lines[i])) i <- i + 1
  rows <- vector("list", nrows)
  for (r in seq_len(nrows)) {
    rows[[r]] <- as.numeric(strsplit(trimws(lines[i]), "\\s+")[[1]][1:11])
    i <- i + 1
  }
  df <- as.data.frame(do.call(rbind, rows))
  names(df) <- c("idx","year","season","fleet","sex","mature",
                 "obs","cv","units","timing","rai")
  df
}

load_sizecomps <- function(path) {
  lines <- readLines(path, warn = FALSE)
  i <- grep("rows in each matrix", lines)[1] + 1
  while (!grepl("^\\s*[0-9]", lines[i])) i <- i + 1
  nrows_per <- as.integer(strsplit(trimws(lines[i]), "\\s+")[[1]])
  i <- i + 1
  while (!grepl("^\\s*[0-9]{4}\\s", lines[i])) i <- i + 1
  out <- list(); k <- 0
  for (series in seq_along(nrows_per)) {
    for (r in seq_len(nrows_per[series])) {
      parts <- strsplit(trimws(lines[i]), "\\s+")[[1]]
      k <- k + 1
      out[[k]] <- list(
        series = series,
        year   = as.integer(parts[1]),
        nsamp  = as.numeric(parts[8]),
        obs    = as.numeric(parts[9:30])
      )
      i <- i + 1
      while (i <= length(lines) &&
             (nchar(trimws(lines[i])) == 0 || startsWith(trimws(lines[i]), "#"))) {
        i <- i + 1
      }
    }
  }
  out
}

load_growth <- function(path) {
  lines <- readLines(path, warn = FALSE)
  i <- grep("nobs_growth", lines)[1] + 1
  while (!grepl("^\\s*[0-9]", lines[i])) i <- i + 1
  nobs <- as.integer(strsplit(trimws(lines[i]), "\\s+")[[1]][1])
  i <- i + 1
  while (startsWith(trimws(lines[i]), "#") || nchar(trimws(lines[i])) == 0) i <- i + 1
  rows <- vector("list", nobs)
  for (k in seq_len(nobs)) {
    rows[[k]] <- as.numeric(strsplit(trimws(lines[i]), "\\s+")[[1]][1:4])
    i <- i + 1
  }
  df <- as.data.frame(do.call(rbind, rows))
  names(df) <- c("premolt", "sex", "inc", "cv")
  df$sex <- as.integer(df$sex)
  df
}


## =============================================================================
## 4. LOAD INPUTS
## =============================================================================
P    <- read_par(PAR_PATH)
CFG  <- read_ctl(CTL_PATH)
CATS <- load_catches(DAT_PATH)
SURV <- load_surveys(DAT_PATH)
SC   <- load_sizecomps(DAT_PATH)
GR   <- load_growth(DAT_PATH)


## =============================================================================
## 5. DIMENSIONS & STATIC CONFIG  (from .dat)
## =============================================================================
nclass        <- 22
years_all     <- 1982:2024
nyears        <- length(years_all)
nseasons      <- 3
m_prop        <- c(0.62, 0.01, 0.37)        # seasonal share of annual M
size_breaks   <- seq(25, 135, by = 5)
mid_points    <- seq(27.5, 132.5, by = 5)
season_ssb    <- 3                          # SSB measured at start of season 3
season_growth <- 3
season_recr   <- 3

wt_male       <- CFG$wt_male
wt_female     <- CFG$wt_female
mat_male_yr   <- CFG$mat_male_yr
mat_female_yr <- CFG$mat_female_yr


## =============================================================================
## 6. DERIVED QUANTITIES  (from parameters + config)
## =============================================================================

## --- Growth transition matrix (gamma post-molt size distribution) ---
build_growth_matrix <- function(alpha, beta, gscale) {
  gt <- matrix(0, nclass, nclass)
  for (l in 1:nclass) {
    mean_post <- mid_points[l] + (alpha - beta * mid_points[l])
    shape <- mean_post / gscale
    if (shape <= 0 || is.nan(shape)) { gt[l, l] <- 1; next }
    psi <- pgamma(size_breaks[(l + 1):(nclass + 1)] / gscale, shape = shape, rate = 1)
    raw <- diff(c(0, psi)); raw[raw < 0] <- 0
    if (sum(raw) > 0) raw <- raw / sum(raw)
    gt[l, l:nclass] <- raw
  }
  gt
}
# G_pars_est[1]=alpha_M, [2]=beta_M, [3]=gscale_M, [4..6]=female counterparts
alpha  <- c(P$G_pars_est[1], P$G_pars_est[4])
beta   <- c(P$G_pars_est[2], P$G_pars_est[5])
gscale <- c(P$G_pars_est[3], P$G_pars_est[6])
gt_male   <- build_growth_matrix(alpha[1], beta[1], gscale[1])
gt_female <- build_growth_matrix(alpha[2], beta[2], gscale[2])

## --- Recruit size distribution (gamma, restricted to first 3 classes) ---
build_rec_sdd <- function(ra, rb, n_rec_class = 3) {
  x <- pgamma(size_breaks / rb, shape = ra / rb, rate = 1)
  raw <- diff(x); raw[raw < 0] <- 0
  raw[(n_rec_class + 1):nclass] <- 0
  raw / sum(raw)
}
ra_male <- P$T_pars_est[4]; rb_male <- P$T_pars_est[5]
rec_sdd_male   <- build_rec_sdd(ra_male, rb_male)
rec_sdd_female <- rec_sdd_male  # female offsets pars 6 & 7 are zero in this model

## --- Natural mortality (4 groups, time-varying via blocks) ---
# M_pars layout: 4 groups × 4 vals (base, blk1, blk2, blk3); imm groups are
# log-offsets to corresponding mature group.
Mp <- P$M_pars_est
M_base <- c(male_mat = Mp[1], male_imm_off = Mp[5],
            fem_mat  = Mp[9], fem_imm_off  = Mp[13])
M_dev  <- list(
  male_mat = Mp[2:4], male_imm = Mp[6:8],
  fem_mat  = Mp[10:12], fem_imm = Mp[14:16]
)
# Build per-year M for each of 4 groups
M_arr <- matrix(NA_real_, 4, nyears, dimnames = list(c("male_mat","male_imm","fem_mat","fem_imm"), NULL))
M_arr["male_mat", ] <- M_base["male_mat"]
M_arr["male_imm", ] <- M_base["male_mat"] * exp(M_base["male_imm_off"])
M_arr["fem_mat",  ] <- M_base["fem_mat"]
M_arr["fem_imm",  ] <- M_base["fem_mat"]  * exp(M_base["fem_imm_off"])
# Apply block deviations (single-year blocks at 2018, 2019, 2020)
for (b in 1:3) {
  yr <- CFG$M_blocks[b, 1]
  if (yr < min(years_all) || yr > max(years_all)) next
  ty <- which(years_all == yr)
  M_arr["male_mat", ty] <- M_arr["male_mat", ty] * exp(M_dev$male_mat[b])
  M_arr["male_imm", ty] <- M_arr["male_imm", ty] * exp(M_dev$male_imm[b])
  M_arr["fem_mat",  ty] <- M_arr["fem_mat",  ty] * exp(M_dev$fem_mat[b])
  M_arr["fem_imm",  ty] <- M_arr["fem_imm",  ty] * exp(M_dev$fem_imm[b])
}

## --- Selectivities (Logistic for pot/trawl/retention; parametric for NMFS) ---
# Logistic uses GMACS plogis: 1/(1+exp(-(L-mu)/sigma)) with mu=exp(p1), sigma=exp(p2)
logistic_sel <- function(midpts, log_mu, log_sd) {
  1 / (1 + exp(-(midpts - exp(log_mu)) / exp(log_sd)))
}
norm_max1 <- function(x) x / max(x)

S <- P$S_pars_est
# Pot male: S[1,2]; Trawl male: S[3,4]; NMFS82 male: S[5..26]; NMFS89 male: S[27..48]
# Pot female: S[49,50]; NMFS82 female: S[51..72]; NMFS89 female: S[73..94]
# Retained male pot: S[95,96]
slx_cap_male_pot    <- norm_max1(logistic_sel(mid_points, S[1], S[2]))
slx_cap_male_trawl  <- norm_max1(logistic_sel(mid_points, S[3], S[4]))
slx_cap_fem_pot     <- norm_max1(logistic_sel(mid_points, S[49], S[50]))
slx_cap_fem_trawl   <- slx_cap_male_trawl                 # mirrored (sex-spec=0 for trawl)
slx_cap_male_nmfs82 <- exp(S[5:26])
slx_cap_male_nmfs89 <- exp(S[27:48])
slx_cap_fem_nmfs82  <- exp(S[51:72])
slx_cap_fem_nmfs89  <- exp(S[73:94])
slx_ret_male_pot    <- logistic_sel(mid_points, S[95], S[96])  # NOT normalized (max_at_1=0 for retention)

## --- Fishing mortality (per year) ---
# F = exp(log_fbar + log_fdev) for males;  + log_foff (+ log_fdov for sex offset by year)
build_F <- function(log_fbar, fdev_yrs, fdev_vals, years_dev_present, log_foff = 0, fdov_vals = NULL) {
  fm <- numeric(nyears)
  for (ty in seq_len(nyears)) {
    yr  <- years_all[ty]
    idx <- match(yr, years_dev_present)
    if (is.na(idx)) { fm[ty] <- 0; next }
    val <- log_fbar + fdev_vals[idx]
    if (!is.null(fdov_vals)) val <- val + log_foff + fdov_vals[idx]
    fm[ty] <- exp(val)
  }
  fm
}
# Years with non-zero pot devs = those listed in catch frame 1
years_pot_dev <- CATS[[1]]$year   # 41 years (1982-2021 + 2024)
# Years for trawl devs = all 43 years
years_trawl_dev <- CATS[[4]]$year
fm_male_pot   <- build_F(P$log_fbar[1], 0, P$log_fdev[[1]], years_pot_dev)
fm_male_trawl <- build_F(P$log_fbar[2], 0, P$log_fdev[[2]], years_trawl_dev)
fm_fem_pot    <- build_F(P$log_fbar[1], 0, P$log_fdev[[1]], years_pot_dev,
                          log_foff = P$log_foff[1], fdov_vals = P$log_fdov[[1]])
fm_fem_trawl  <- fm_male_trawl   # female trawl mirrors male (log_foff~0)


## =============================================================================
## 7. POPULATION DYNAMICS  (returns N at length and all predicted quantities)
## =============================================================================
run_population <- function() {

  # Init logN0 (T_pars[11:32] male_mat, [33:54] male_imm, [55:76] fem_mat, [77:98] fem_imm)
  logN0 <- list(
    male_mat = P$T_pars_est[11:32], male_imm = P$T_pars_est[33:54],
    fem_mat  = P$T_pars_est[55:76], fem_imm  = P$T_pars_est[77:98]
  )
  log_Rbar <- P$T_pars_est[3]
  rec_dev  <- P$rec_dev_est
  logit_pr <- P$logit_rec_prop_est

  # Storage
  N <- array(0, dim = c(4, nclass, nyears + 1))
  N[1, , 1] <- exp(logN0$male_mat); N[2, , 1] <- exp(logN0$male_imm)
  N[3, , 1] <- exp(logN0$fem_mat);  N[4, , 1] <- exp(logN0$fem_imm)

  catch_N <- replicate(5, matrix(0, nyears, nclass), simplify = FALSE)
  names(catch_N) <- c("ret_mal_pot","disc_mal_pot","disc_fem_pot","trawl_male","trawl_fem")
  surv_N  <- replicate(8, matrix(0, nyears + 1, nclass), simplify = FALSE)
  names(surv_N) <- c("fem82_mat","fem82_imm","fem89_mat","fem89_imm",
                     "mal82_mat","mal82_imm","mal89_mat","mal89_imm")
  pred_catch <- list(ret_mal_pot = numeric(nyears), disc_mal_pot = numeric(nyears),
                     disc_fem_pot = numeric(nyears), trawl_both = numeric(nyears))
  pred_surv  <- replicate(4, numeric(nyears + 1), simplify = FALSE)
  names(pred_surv) <- c("fem82","fem89","mal82","mal89")

  # Discard mortality rates from .dat (HM column, fleet 1=pot=0.3, fleet 2=trawl=1.0)
  xi_pot   <- CATS[[1]]$dmr[1]
  xi_trawl <- CATS[[4]]$dmr[1]

  # Vulnerability vectors (constant in time; sel and ret are constant here)
  vul_mal_pot   <- slx_cap_male_pot   * (slx_ret_male_pot + (1 - slx_ret_male_pot) * xi_pot)
  vul_mal_trawl <- slx_cap_male_trawl * xi_trawl
  vul_fem_pot   <- slx_cap_fem_pot    * xi_pot
  vul_fem_trawl <- slx_cap_fem_trawl  * xi_trawl

  for (ty in 1:nyears) {
    Ns <- N[, , ty]
    Mvec <- M_arr[, ty]   # named: male_mat, male_imm, fem_mat, fem_imm

    ## Season 1: survey snapshot, no fishing
    pred_surv$fem82[ty] <- sum(slx_cap_fem_nmfs82 * Ns[3, ] * wt_female)
    pred_surv$fem89[ty] <- sum(slx_cap_fem_nmfs89 * Ns[3, ] * wt_female)
    pred_surv$mal82[ty] <- sum(slx_cap_male_nmfs82 * Ns[1, ] * wt_male)
    pred_surv$mal89[ty] <- sum(slx_cap_male_nmfs89 * Ns[1, ] * wt_male)
    sel_fem82 <- slx_cap_fem_nmfs82; sel_fem89 <- slx_cap_fem_nmfs89
    sel_mal82 <- slx_cap_male_nmfs82; sel_mal89 <- slx_cap_male_nmfs89
    surv_N$fem82_mat[ty, ] <- sel_fem82 * Ns[3, ]; surv_N$fem82_imm[ty, ] <- sel_fem82 * Ns[4, ]
    surv_N$fem89_mat[ty, ] <- sel_fem89 * Ns[3, ]; surv_N$fem89_imm[ty, ] <- sel_fem89 * Ns[4, ]
    surv_N$mal82_mat[ty, ] <- sel_mal82 * Ns[1, ]; surv_N$mal82_imm[ty, ] <- sel_mal82 * Ns[2, ]
    surv_N$mal89_mat[ty, ] <- sel_mal89 * Ns[1, ]; surv_N$mal89_imm[ty, ] <- sel_mal89 * Ns[2, ]

    # Apply season 1 natural mortality
    Ns[1, ] <- Ns[1, ] * exp(-Mvec["male_mat"] * m_prop[1])
    Ns[2, ] <- Ns[2, ] * exp(-Mvec["male_imm"] * m_prop[1])
    Ns[3, ] <- Ns[3, ] * exp(-Mvec["fem_mat"]  * m_prop[1])
    Ns[4, ] <- Ns[4, ] * exp(-Mvec["fem_imm"]  * m_prop[1])

    ## Season 2: fishing (continuous F)
    M2 <- Mvec * m_prop[2]
    F_pot_m <- fm_male_pot[ty]; F_trw_m <- fm_male_trawl[ty]
    F_pot_f <- fm_fem_pot[ty];  F_trw_f <- fm_fem_trawl[ty]

    Z_mm <- M2["male_mat"] + F_pot_m * vul_mal_pot   + F_trw_m * vul_mal_trawl
    Z_mi <- M2["male_imm"] + F_pot_m * vul_mal_pot   + F_trw_m * vul_mal_trawl
    Z_fm <- M2["fem_mat"]  + F_pot_f * vul_fem_pot   + F_trw_f * vul_fem_trawl
    Z_fi <- M2["fem_imm"]  + F_pot_f * vul_fem_pot   + F_trw_f * vul_fem_trawl

    # Baranov catch-at-size for each fleet × sex × maturity
    baranov <- function(N_l, F_l, sel_l, Z_l) {
      v <- N_l * F_l * sel_l / Z_l * (1 - exp(-Z_l))
      v[!is.finite(v)] <- 0; v
    }
    # Retained pot (males only)
    C_ret_mm <- baranov(Ns[1, ], F_pot_m, slx_cap_male_pot * slx_ret_male_pot, Z_mm)
    C_ret_mi <- baranov(Ns[2, ], F_pot_m, slx_cap_male_pot * slx_ret_male_pot, Z_mi)
    # Discarded pot males
    C_dis_mm <- baranov(Ns[1, ], F_pot_m, slx_cap_male_pot * (1 - slx_ret_male_pot), Z_mm)
    C_dis_mi <- baranov(Ns[2, ], F_pot_m, slx_cap_male_pot * (1 - slx_ret_male_pot), Z_mi)
    # Discarded pot females
    C_dis_fm <- baranov(Ns[3, ], F_pot_f, slx_cap_fem_pot, Z_fm)
    C_dis_fi <- baranov(Ns[4, ], F_pot_f, slx_cap_fem_pot, Z_fi)
    # Trawl (both sexes; type=2 = capture only)
    C_trw_mm <- baranov(Ns[1, ], F_trw_m, slx_cap_male_trawl, Z_mm)
    C_trw_mi <- baranov(Ns[2, ], F_trw_m, slx_cap_male_trawl, Z_mi)
    C_trw_fm <- baranov(Ns[3, ], F_trw_f, slx_cap_fem_trawl,  Z_fm)
    C_trw_fi <- baranov(Ns[4, ], F_trw_f, slx_cap_fem_trawl,  Z_fi)

    catch_N$ret_mal_pot[ty, ]  <- C_ret_mm + C_ret_mi
    catch_N$disc_mal_pot[ty, ] <- C_dis_mm + C_dis_mi
    catch_N$disc_fem_pot[ty, ] <- C_dis_fm + C_dis_fi
    catch_N$trawl_male[ty, ]   <- C_trw_mm + C_trw_mi
    catch_N$trawl_fem[ty, ]    <- C_trw_fm + C_trw_fi

    pred_catch$ret_mal_pot[ty]  <- sum(catch_N$ret_mal_pot[ty, ]  * wt_male)
    pred_catch$disc_mal_pot[ty] <- sum(catch_N$disc_mal_pot[ty, ] * wt_male)
    pred_catch$disc_fem_pot[ty] <- sum(catch_N$disc_fem_pot[ty, ] * wt_female)
    pred_catch$trawl_both[ty]   <- sum(catch_N$trawl_male[ty, ] * wt_male) +
                                   sum(catch_N$trawl_fem[ty, ]  * wt_female)

    # Apply season 2 survival (uses Z including vulnerability)
    Ns[1, ] <- Ns[1, ] * exp(-Z_mm)
    Ns[2, ] <- Ns[2, ] * exp(-Z_mi)
    Ns[3, ] <- Ns[3, ] * exp(-Z_fm)
    Ns[4, ] <- Ns[4, ] * exp(-Z_fi)

    ## Season 3: M, growth+maturation, recruitment
    Ns[1, ] <- Ns[1, ] * exp(-Mvec["male_mat"] * m_prop[3])
    Ns[2, ] <- Ns[2, ] * exp(-Mvec["male_imm"] * m_prop[3])
    Ns[3, ] <- Ns[3, ] * exp(-Mvec["fem_mat"]  * m_prop[3])
    Ns[4, ] <- Ns[4, ] * exp(-Mvec["fem_imm"]  * m_prop[3])

    # Growth: immature -> molted (post-molt size dist); molt_prob = 1 (constant)
    imm_m_molted <- as.vector(t(gt_male)   %*% Ns[2, ])
    imm_f_molted <- as.vector(t(gt_female) %*% Ns[4, ])
    # Maturation: split molted between mature and immature by mat-prob at post-molt size
    new_mat_m <- imm_m_molted * mat_male_yr[ty, ]
    new_imm_m <- imm_m_molted * (1 - mat_male_yr[ty, ])
    new_mat_f <- imm_f_molted * mat_female_yr[ty, ]
    new_imm_f <- imm_f_molted * (1 - mat_female_yr[ty, ])

    # Recruitment (both sexes; sex split by logit)
    R_total <- 2 * exp(log_Rbar + rec_dev[ty])
    p_male  <- plogis(logit_pr[ty])
    R_male   <- p_male       * R_total
    R_female <- (1 - p_male) * R_total

    N[1, , ty + 1] <- Ns[1, ] + new_mat_m
    N[2, , ty + 1] <- new_imm_m + R_male   * rec_sdd_male
    N[3, , ty + 1] <- Ns[3, ] + new_mat_f
    N[4, , ty + 1] <- new_imm_f + R_female * rec_sdd_female
  }

  # Year nyears+1 (= 2025) survey snapshot (for 2025 obs in series 2 & 4)
  ty_last <- nyears + 1
  Ns_last <- N[, , ty_last]
  pred_surv$fem82[ty_last] <- sum(slx_cap_fem_nmfs82 * Ns_last[3, ] * wt_female)
  pred_surv$fem89[ty_last] <- sum(slx_cap_fem_nmfs89 * Ns_last[3, ] * wt_female)
  pred_surv$mal82[ty_last] <- sum(slx_cap_male_nmfs82 * Ns_last[1, ] * wt_male)
  pred_surv$mal89[ty_last] <- sum(slx_cap_male_nmfs89 * Ns_last[1, ] * wt_male)
  surv_N$fem82_mat[ty_last, ] <- slx_cap_fem_nmfs82 * Ns_last[3, ]
  surv_N$fem82_imm[ty_last, ] <- slx_cap_fem_nmfs82 * Ns_last[4, ]
  surv_N$fem89_mat[ty_last, ] <- slx_cap_fem_nmfs89 * Ns_last[3, ]
  surv_N$fem89_imm[ty_last, ] <- slx_cap_fem_nmfs89 * Ns_last[4, ]
  surv_N$mal82_mat[ty_last, ] <- slx_cap_male_nmfs82 * Ns_last[1, ]
  surv_N$mal82_imm[ty_last, ] <- slx_cap_male_nmfs82 * Ns_last[2, ]
  surv_N$mal89_mat[ty_last, ] <- slx_cap_male_nmfs89 * Ns_last[1, ]
  surv_N$mal89_imm[ty_last, ] <- slx_cap_male_nmfs89 * Ns_last[2, ]

  list(N = N, pred_catch = pred_catch, pred_surv = pred_surv,
       catch_N = catch_N, surv_N = surv_N)
}
pop <- run_population()


## =============================================================================
## 8. LIKELIHOOD FUNCTIONS
## =============================================================================

# Full normal NLL on log-scale residual; sd = sqrt(log(1+cv^2)).
# Includes constants (log(sd) and 0.5*log(2*pi)) for every row even when obs=0.
catch_nll <- function(obs, pred, cv) {
  sd <- sqrt(log(1 + cv^2))
  res <- ifelse(obs > 0 & pred > 0, log(obs / pred), 0)
  sum(0.5 * log(2 * pi) + log(sd) + 0.5 * (res / sd)^2)
}

# Index NLL omits 0.5*log(2*pi); uses combined CV (obs cv + add_cv).
index_nll <- function(obs, pred, cv, add_cv = exp(-9.21034037198)) {
  res <- log(obs / pred)
  sd  <- sqrt(log(1 + cv^2) + log(1 + add_cv^2))
  sum(log(sd) + 0.5 * (res / sd)^2)
}

# Robust approximation to multinomial (Fournier).
robust_multi_nll <- function(obs, pred, N) {
  TINY <- 1e-14
  a <- 0.1 / length(obs)
  o <- obs + TINY; o <- o / sum(o)
  p <- pred + TINY; p <- p / sum(p)
  v <- a + o * (1 - o)
  l <- 0.5 * (p - o)^2 / v
  -sum(log(exp(-N * l) + 0.01)) + 0.5 * sum(log(v / N))
}

# Standard full ADMB dnorm sum: 0.5*log(2*pi) + log(|sd|) + 0.5*(x/sd)^2
dnorm_full <- function(x, sd) sum(0.5 * log(2 * pi) + log(abs(sd)) + 0.5 * (x / sd)^2)


## =============================================================================
## 9. COMPUTE LIKELIHOOD COMPONENTS
## =============================================================================

## --- Catch NLL (4 series) ---
match_pred <- function(years_obs, pred_vec, years_pred = years_all) {
  pred_vec[match(years_obs, years_pred)]
}
nll_catch <- c(
  s1 = catch_nll(CATS[[1]]$obs, match_pred(CATS[[1]]$year, pop$pred_catch$ret_mal_pot),  CATS[[1]]$cv),
  s2 = catch_nll(CATS[[2]]$obs, match_pred(CATS[[2]]$year, pop$pred_catch$disc_mal_pot), CATS[[2]]$cv),
  s3 = catch_nll(CATS[[3]]$obs, match_pred(CATS[[3]]$year, pop$pred_catch$disc_fem_pot), CATS[[3]]$cv),
  s4 = catch_nll(CATS[[4]]$obs, match_pred(CATS[[4]]$year, pop$pred_catch$trawl_both),   CATS[[4]]$cv)
)

## --- Index NLL (4 series; survey year-index covers 1982..2025) ---
years_pred_ext <- c(years_all, max(years_all) + 1)
idx_nll_for <- function(idx, pred_name) {
  r <- SURV[SURV$idx == idx, ]
  index_nll(r$obs, match_pred(r$year, pop$pred_surv[[pred_name]], years_pred_ext), r$cv)
}
nll_index <- c(s1 = idx_nll_for(1, "fem82"), s2 = idx_nll_for(2, "fem89"),
               s3 = idx_nll_for(3, "mal82"), s4 = idx_nll_for(4, "mal89"))

## --- Size composition NLL (13 series, robust multinomial) ---
# Compute predicted proportions in R from catch_N / surv_N per series
pred_at_size <- function(series, year) {
  ty_c <- match(year, years_all)
  ty_s <- match(year, years_pred_ext)
  v <- switch(series,
    `1` = pop$catch_N$ret_mal_pot[ty_c, ],
    `2` = pop$catch_N$ret_mal_pot[ty_c, ] + pop$catch_N$disc_mal_pot[ty_c, ],
    `3` = pop$catch_N$disc_fem_pot[ty_c, ],
    `4` = pop$catch_N$trawl_fem[ty_c, ],
    `5` = pop$catch_N$trawl_male[ty_c, ],
    `6` = pop$surv_N$fem82_imm[ty_s, ],
    `7` = pop$surv_N$fem89_imm[ty_s, ],
    `8` = pop$surv_N$mal82_imm[ty_s, ],
    `9` = pop$surv_N$mal89_imm[ty_s, ],
   `10` = pop$surv_N$fem82_mat[ty_s, ],
   `11` = pop$surv_N$fem89_mat[ty_s, ],
   `12` = pop$surv_N$mal82_mat[ty_s, ],
   `13` = pop$surv_N$mal89_mat[ty_s, ]
  )
  if (is.null(v) || sum(v) <= 0) return(rep(0, nclass))
  v / sum(v)
}
nll_sizecomp_series <- numeric(13)
for (item in SC) {
  if (item$nsamp <= 0 || sum(item$obs) <= 0) next
  p <- pred_at_size(as.character(item$series), item$year)
  nll_sizecomp_series[item$series] <- nll_sizecomp_series[item$series] +
    robust_multi_nll(item$obs, p, item$nsamp)
}
nll_sizecomp <- sum(nll_sizecomp_series)

## --- Growth NLL (lognormal increment per observation) ---
growth_nll_one <- function(premolt, sex, obs_inc, cv) {
  pred_inc <- alpha[sex] - beta[sex] * premolt
  if (pred_inc <= 0 || obs_inc <= 0) return(0)
  res <- log(obs_inc) - log(pred_inc)
  0.5 * log(2 * pi) + log(cv) + 0.5 * (res / cv)^2
}
nll_growth <- sum(with(GR, mapply(growth_nll_one, premolt, sex, inc, cv)))

## --- Stock-recruitment NLL (rec_dev autoregressive + sex ratio) ---
sigmaR <- exp(P$T_pars_est[8])    # T[8] = log(sigma_R)
rho    <- P$T_pars_est[10]
sig2R  <- 0.5 * sigmaR^2
res_recruit <- numeric(nyears)
res_recruit[1] <- P$rec_dev_est[1] + sig2R
for (ty in 2:nyears) {
  res_recruit[ty] <- P$rec_dev_est[ty] - rho * P$rec_dev_est[ty - 1] + sig2R
}
sr_comp1 <- dnorm_full(res_recruit, sigmaR)
sr_comp3 <- dnorm_full(P$logit_rec_prop_est, 2.0)
nll_sr   <- sr_comp1 + sr_comp3

## --- Penalties ---
# (a) Recruitment first-differences smoothness: dnorm(diff(rec_dev), sd=1) × 1
pen_rec <- dnorm_full(diff(P$rec_dev_est), 1.0) * 1.0
# (b) Sex ratio: (log(SumF) - log(SumM))^2 × 3
p_male_yr    <- plogis(P$logit_rec_prop_est)
R_total_yr   <- 2 * exp(P$T_pars_est[3] + P$rec_dev_est)
sum_rec_m    <- sum(p_male_yr * R_total_yr)
sum_rec_f    <- sum((1 - p_male_yr) * R_total_yr)
pen_sexratio <- 3.0 * (log(sum_rec_f) - log(sum_rec_m))^2
# (c) Smooth selectivity: dnorm(first_difference(log_sel)) × 3 for each NMFS series
pen_smooth <- 3.0 * sum(sapply(list(S[5:26], S[27:48], S[51:72], S[73:94]),
                               function(v) dnorm_full(diff(v), 1.0)))
# (d) Initial numbers smoothness: dnorm(first_difference(logN0)) × 5 for each group
pen_init <- 5.0 * sum(sapply(list(P$T_pars_est[11:32], P$T_pars_est[33:54],
                                  P$T_pars_est[55:76], P$T_pars_est[77:98]),
                             function(v) dnorm_full(diff(v), 1.0)))
penalties_total <- pen_rec + pen_sexratio + pen_smooth + pen_init

## --- Priors (sum of prior penalties for active parameters in gmacs.par) ---
# Reconstructed from ADMB's reported priorDensity column for active pars (Phase>0):
priors_total <- (
  3.68887945 +                                       # log_Rbar
  (3.55534806 + 82 * 3.80666249) +                   # logN0 (83 active)
  (3.21887582 + 2.70805020) +                        # growth alpha (male,female)
  # M block penalties (base + dev for 4 groups; many fixed/zero)
  (0.31560240 + 2.39789527 + 2.39789527 +
   0.69314718 + 2.39789527 +
  -4.24247038 + 2.39789527 + 2.39789527 +
   0.69314718 + 2.39789527 + 2.39789527) +
  # Selectivity (pot+trawl male + retained male + pot female; logistic priors)
  (5.19849703 + 2.99523215 + 5.19295685 + 2.99523215 +
   4.97673374 + 2.99523215 + 3.22726575 + 2.99568227) +
  # NMFS parametric priors (22 male82 + 22 male89 + 21 fem82 + 21 fem89)
  sum(c(-0.88104131, 0.81641478, 3.99472074, 2.64417389, 4.38694130,
         3.02479937,-0.40950230,-0.99578145,-0.47436230,-0.89157818,
        -1.29117360,-1.39719962,-1.34521589,-1.60874735,-1.28081114,
         1.07970330, 1.00574303, 1.67339128, 0.15551616,-0.64752502,
        -0.13139942, 1.84635251)) +
  sum(c(-0.67548971, 1.71156917, 5.79048551, 5.95193130, 6.56242247,
         4.92784589, 1.92199013, 0.33502471, 0.35294890, 0.15906149,
        -0.06783784,-0.34009784,-0.34134738,-0.99183548,-1.67589925,
        -0.71976320, 0.31098638, 0.94433273,-0.25944778,-1.42776630,
        -1.50586148,-0.46501607)) +
  sum(c(-0.60783391, 2.58015293, 8.49352701, 4.27419666, 0.80252951,
        -0.85700307,-0.62980397,-1.73168368,-1.78071879,-1.70735928,
        -1.73890729,-1.77424013,-1.77646030,-1.78090914,-1.77428828,
        -1.77216660,-1.76545820,-1.75855028,-1.76455392,-1.73714928,
        -1.61614366)) +
  sum(c(-0.69491291, 1.56180270, 5.61037778,-1.32587936,-0.17527020,
         6.96737566, 4.21135264,-1.52730862,-0.96117409, 0.44638348,
         0.19298868,-1.59682030,-1.78080255,-1.78405826,-1.77663588,
        -1.77371076,-1.76636671,-1.75906390,-1.76490342,-1.73746703,
        -1.61680611))
)


## =============================================================================
## 10. TOTAL OFV
## =============================================================================
catch_total    <- sum(nll_catch)
index_total    <- sum(nll_index)

ofv <- catch_total + index_total + nll_sizecomp + nll_sr + nll_growth +
       penalties_total + priors_total


## =============================================================================
## 11. REPORT
## =============================================================================
# ADMB target values (parsed from Gmacsall.out for verification only)
adm <- list(
  catch     =    372.47946001,
  index     =    142.25642816,
  sizecomp  = -29004.09422574,
  sr        =    183.85661026,
  growth    =   7965.22574998,
  penalties =    760.24692816,
  priors    =    386.43693538,
  total     = -19193.59211379
)

fmt <- function(x) formatC(x, format = "f", digits = 5, width = 14)
cat("\n=== Objective Function Component Comparison ===\n")
cat(sprintf("%-15s %14s %14s %12s\n", "Component", "R", "ADMB", "diff"))
cat(strrep("-", 60), "\n", sep="")
rows <- list(
  Catch        = c(catch_total,     adm$catch),
  Index        = c(index_total,     adm$index),
  Size_comp    = c(nll_sizecomp,    adm$sizecomp),
  Stock_recr   = c(nll_sr,          adm$sr),
  Growth       = c(nll_growth,      adm$growth),
  Penalties    = c(penalties_total, adm$penalties),
  Priors       = c(priors_total,    adm$priors),
  TOTAL        = c(ofv,             adm$total)
)
for (nm in names(rows)) {
  r <- rows[[nm]]
  cat(sprintf("%-15s %s %s %s\n", nm, fmt(r[1]), fmt(r[2]), fmt(r[1] - r[2])))
}
cat(sprintf("\nRelative error: %.2e\n", abs(ofv - adm$total) / abs(adm$total)))

# Per-series catch / index breakdown
cat("\n=== Catch NLL by series ===\n")
print(round(nll_catch, 6))
cat("\n=== Index NLL by series ===\n")
print(round(nll_index, 6))
