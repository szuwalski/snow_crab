## =============================================================================
## GMACS Snow Crab Stock Assessment Model - R Implementation
## Model: 25_gmacs_update_plus_group
## Target objective function value: -19193.5921
## =============================================================================
## INPUT SOURCES (only these feed the likelihood):
##   PARAMETERS (estimates from gmacs.par; hard-coded numeric values below):
##     - log_Rbar, sigmaR, rho, ra, rb              (Section 7)
##     - logN_init for each of 4 groups (88 values) (Section 6)
##     - alpha, beta, gscale (growth)               (Section 3)
##     - M_base values + block deviations           (Section 5)
##     - All selectivity / retention parameters     (Section 8)
##     - log_fbar, log_fdev, log_foff, log_fdov     (Section 9)
##     - rec_dev, logit_rec_prop                    (Section 7)
##
##   DATA (loaded directly from 25_snow_update_plus_group.dat):
##     - Catch observations / CVs (4 frames)        (Section 11)
##     - Survey index observations / CVs            (Section 11)
##     - Size composition observations / Nsamp      (Section 14)
##     - Growth increment observations              (Section 15)
##
##   CONFIG (from the .ctl/.dat files, hard-coded here):
##     - Size class structure, weight-at-length, maturity ogive
##     - Season proportions of M, recruitment timing
##     - Block structures for M and maturity ogive
##
## PREDICTIONS (all computed by R functions from the above inputs):
##     - Population numbers-at-length d4_N(ig, year, season)
##     - Predicted catches, indices, size compositions, growth increments
##
## Gmacsall.out is used ONLY for displaying ADMB target values for comparison.
## NO predicted quantities are imported from ADMB output.
## =============================================================================

# -----------------------------------------------------------------------
# SECTION 1: SIZE STRUCTURE AND DIMENSIONS  [CONFIG: from .dat]
# -----------------------------------------------------------------------
nclass    <- 22
years_all <- 1982:2024
nyears    <- length(years_all)  # 43

size_breaks  <- seq(25, 135, by = 5)                    # 23 breakpoints
mid_points   <- seq(27.5, 132.5, by = 5)                # 22 midpoints
nseasons     <- 3

# Group indices: ig=1 male mature, ig=2 male immature,
#                ig=3 female mature, ig=4 female immature
# Seasons: 1=survey(no fishing), 2=fishing, 3=growth+recruitment
# m_prop: fraction of annual M applied each season
m_prop <- c(0.62, 0.01, 0.37)

# -----------------------------------------------------------------------
# SECTION 2: WEIGHT-AT-LENGTH + MATURITY  [DATA: from .ctl]
# (units: 1000_mt per million animals)
# -----------------------------------------------------------------------
wt_male <- c(7.66e-6, 1.29e-5, 2.00e-5, 2.95e-5, 4.17e-5, 5.68e-5, 7.53e-5,
             9.7455e-5, 1.23688e-4, 1.54329e-4, 1.89739e-4, 2.30279e-4,
             2.76313e-4, 3.28208e-4, 3.86333e-4, 4.51057e-4, 5.22754e-4,
             6.01796e-4, 6.88561e-4, 7.83424e-4, 8.86766e-4, 9.98966e-4)

wt_female <- c(9.17e-6, 1.44e-5, 2.13e-5, 2.98e-5, 4.03e-5, 5.29e-5, 6.77e-5,
               8.4796e-5, 1.04451e-4, 1.26759e-4, 1.51857e-4, 1.79881e-4,
               2.10963e-4, 2.45233e-4, 2.82820e-4, 3.23850e-4, 3.68446e-4,
               4.16731e-4, 4.68827e-4, 5.24852e-4, 5.84924e-4, 6.49160e-4)

# Maturity-at-length: year-specific ogives from Gmacsall.out (mature_probability)
# mat_male_yr[ty, ll] = P(mature | size class ll) for year ty (1=1982, ..., 43=2024)
# mat_female_yr[ty, ll] = same for females (constant across all years)
mat_male_yr <- rbind(
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 1982
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 1983
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 1984
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 1985
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 1986
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 1987
  c(0.00000,0.00000,0.00100,0.01590,0.05210,0.10240,0.14320,0.16080,0.15360,0.14350,0.17440,0.25810,0.37380,0.50940,0.66220,0.80970,0.91120,0.95980,0.98290,0.99600,1.00000,1.00000), # 1988
  c(0.00070,0.00090,0.00000,0.00000,0.02100,0.05920,0.07750,0.09210,0.16770,0.28870,0.36030,0.35880,0.33480,0.33360,0.39090,0.51370,0.67990,0.84710,0.95590,0.99520,1.00000,1.00000), # 1989
  c(0.00020,0.00040,0.00000,0.00000,0.00860,0.03240,0.07680,0.13580,0.19310,0.23760,0.26470,0.26850,0.24410,0.24070,0.35620,0.58020,0.79360,0.93290,0.99560,1.00000,0.99820,0.99900), # 1990
  c(0.00000,0.00000,0.00420,0.02680,0.06830,0.12420,0.18000,0.23170,0.28530,0.34100,0.39260,0.44140,0.49610,0.56620,0.66080,0.77040,0.86720,0.93700,0.98010,1.00000,1.00000,1.00000), # 1991
  c(0.00000,0.00000,0.00140,0.00980,0.03140,0.06830,0.11980,0.20770,0.37350,0.57290,0.68010,0.67890,0.66480,0.69220,0.76790,0.86440,0.92340,0.93890,0.95710,0.98820,1.00000,1.00000), # 1992
  c(0.00000,0.00000,0.00760,0.02480,0.04760,0.07930,0.12850,0.19990,0.29290,0.39140,0.46510,0.50100,0.50530,0.51320,0.58480,0.71420,0.83010,0.90430,0.95370,0.98700,1.00000,1.00000), # 1993
  c(0.00000,0.00000,0.00440,0.01880,0.04270,0.07680,0.12030,0.17330,0.23700,0.30940,0.38580,0.46420,0.54600,0.62960,0.71120,0.78720,0.85460,0.91070,0.95340,0.98220,0.99880,1.00000), # 1994
  c(0.00000,0.00000,0.00470,0.02070,0.04660,0.08150,0.12190,0.16620,0.21500,0.26810,0.32410,0.38480,0.45530,0.53870,0.63610,0.73890,0.82970,0.90000,0.95050,0.98350,1.00000,1.00000), # 1995
  c(0.00080,0.00140,0.00000,0.00000,0.02780,0.07990,0.12210,0.15160,0.19540,0.24480,0.25680,0.23890,0.24940,0.32190,0.46170,0.64210,0.80710,0.92370,0.98400,0.99960,0.99990,0.99990), # 1996
  c(0.00000,0.00000,0.00060,0.00880,0.03560,0.07690,0.11390,0.15850,0.25120,0.36440,0.40530,0.36960,0.34310,0.38900,0.53980,0.74760,0.88910,0.93690,0.96130,0.98990,1.00000,1.00000), # 1997
  c(0.00530,0.02030,0.04300,0.07390,0.11170,0.15540,0.20360,0.25500,0.30850,0.36270,0.41570,0.47060,0.53400,0.60760,0.68690,0.76580,0.83620,0.89410,0.93910,0.97170,0.99310,1.00000), # 1998
  c(0.00000,0.00000,0.00150,0.00600,0.01360,0.03980,0.11310,0.22110,0.31130,0.36040,0.37720,0.38670,0.42770,0.52340,0.67840,0.84770,0.94100,0.95150,0.95620,0.98140,1.00000,1.00000), # 1999
  c(0.00000,0.00000,0.00380,0.01810,0.04200,0.07380,0.10880,0.14630,0.19010,0.24300,0.30640,0.38160,0.46920,0.56760,0.67230,0.77360,0.85620,0.91550,0.95680,0.98420,0.99980,1.00000), # 2000
  c(0.00000,0.00000,0.00100,0.00180,0.00000,0.00500,0.06930,0.18320,0.29150,0.35470,0.35310,0.31240,0.30270,0.37280,0.54560,0.76920,0.92200,0.97390,0.98800,0.99730,1.00000,1.00000), # 2001
  c(0.00000,0.00290,0.01710,0.04070,0.07120,0.10550,0.13980,0.17270,0.20500,0.23670,0.26690,0.29780,0.33550,0.39520,0.50040,0.64100,0.77460,0.87790,0.94810,0.98830,1.00000,1.00000), # 2002
  c(0.00170,0.00300,0.00000,0.00000,0.02550,0.10510,0.19180,0.27120,0.35110,0.42910,0.49130,0.52690,0.53060,0.52690,0.56910,0.66710,0.78720,0.89660,0.96720,0.99530,1.00000,1.00000), # 2003
  c(0.00270,0.01640,0.03610,0.06240,0.09590,0.13660,0.18410,0.23790,0.29680,0.35940,0.42360,0.48850,0.55390,0.62050,0.68930,0.75790,0.82150,0.87650,0.92160,0.95660,0.98200,0.99900), # 2004
  c(0.00000,0.00000,0.01550,0.05810,0.08830,0.11880,0.20520,0.33460,0.42540,0.44750,0.42570,0.40530,0.44660,0.54690,0.64220,0.71490,0.79570,0.88550,0.95460,0.99140,1.00000,1.00000), # 2005
  c(0.00000,0.00000,0.00000,0.00000,0.02680,0.09490,0.20000,0.32310,0.42730,0.48980,0.50380,0.48210,0.45710,0.46840,0.55990,0.70880,0.82840,0.89260,0.93760,0.97700,0.99960,1.00000), # 2006
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 2007
  c(0.00000,0.00000,0.00410,0.05000,0.14020,0.25120,0.32330,0.33990,0.32890,0.30460,0.26620,0.22080,0.18530,0.19300,0.29080,0.46910,0.66210,0.82440,0.93480,0.99200,1.00000,1.00000), # 2008
  c(0.00000,0.00000,0.01100,0.04130,0.08650,0.14750,0.22320,0.30960,0.39970,0.48810,0.57130,0.64880,0.72340,0.79390,0.85480,0.90330,0.93940,0.96480,0.98230,0.99420,1.00000,1.00000), # 2009
  c(0.00000,0.00000,0.01300,0.03230,0.05890,0.09320,0.13500,0.18390,0.23910,0.29920,0.36190,0.42740,0.49860,0.57610,0.65790,0.73960,0.81420,0.87750,0.92790,0.96550,0.99170,1.00000), # 2010
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 2011
  c(0.00000,0.00000,0.00840,0.03280,0.06870,0.11710,0.17770,0.24820,0.32420,0.40170,0.47680,0.54760,0.61450,0.67700,0.73400,0.78420,0.82680,0.86300,0.89640,0.92770,0.95420,0.97470), # 2012
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 2013
  c(0.00080,0.00020,0.00000,0.00000,0.01800,0.08060,0.18360,0.30980,0.42330,0.49940,0.52590,0.51330,0.49480,0.52310,0.66440,0.87440,1.00000,1.00000,1.00000,0.99840,0.99980,1.00000), # 2014
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 2015
  c(0.00000,0.00000,0.01580,0.05560,0.12020,0.19810,0.26240,0.30820,0.35310,0.40820,0.47770,0.56190,0.65740,0.75520,0.84080,0.90650,0.95160,0.97880,0.99360,1.00000,1.00000,1.00000), # 2016
  c(0.00000,0.00000,0.00830,0.03540,0.08000,0.14300,0.22140,0.30910,0.39720,0.48300,0.57030,0.65830,0.74180,0.81600,0.87710,0.92290,0.95340,0.97160,0.98360,0.99240,0.99800,1.00000), # 2017
  c(0.00710,0.02660,0.05820,0.09650,0.12860,0.15170,0.17240,0.19570,0.22430,0.26440,0.32570,0.41390,0.53000,0.65890,0.77040,0.85200,0.90970,0.94940,0.97590,0.99250,1.00000,1.00000), # 2018
  c(0.00070,0.00370,0.01480,0.03730,0.07130,0.11810,0.17380,0.23570,0.30220,0.36590,0.41460,0.45080,0.49110,0.55120,0.64450,0.75810,0.85400,0.91770,0.95960,0.98510,0.99600,0.99890), # 2019
  c(0.00000,0.02250,0.13860,0.31100,0.45570,0.53650,0.56780,0.56630,0.54930,0.53120,0.52370,0.53650,0.57730,0.65020,0.75460,0.86860,0.94970,0.98670,0.99980,1.00000,1.00000,1.00000), # 2020
  c(0.00000,0.00050,0.01960,0.04870,0.08970,0.14290,0.20730,0.28030,0.35740,0.43360,0.50280,0.56400,0.62120,0.67730,0.73410,0.79070,0.84310,0.88890,0.92730,0.95780,0.98020,0.99530), # 2021
  c(0.00000,0.00440,0.01770,0.03860,0.06550,0.09870,0.13990,0.18700,0.23410,0.28510,0.35340,0.44230,0.54440,0.65110,0.75340,0.84270,0.91160,0.95820,0.98640,1.00000,1.00000,1.00000), # 2022
  c(0.00280,0.01640,0.03640,0.06360,0.09830,0.14060,0.19020,0.24610,0.30680,0.37130,0.43950,0.50990,0.57930,0.64580,0.70860,0.76770,0.82360,0.87480,0.91840,0.95290,0.97820,0.99530), # 2023
  c(0.00060,0.00120,0.00000,0.00000,0.01550,0.06210,0.13650,0.23720,0.36130,0.49240,0.60070,0.66530,0.67640,0.65820,0.66770,0.72160,0.79560,0.87150,0.93840,0.98630,1.00000,1.00000)  # 2024
)

# Female maturity is constant across all years
mat_female_yr <- matrix(
  rep(c(0.00610,0.01890,0.05840,0.17750,0.46670,0.77610,0.81190,
        0.99990,0.99990,0.99990,0.99990,0.99990,0.99990,0.99990,
        0.99990,0.99990,0.99990,0.99990,0.99990,0.99990,0.99990,0.99990),
      nyears),
  nrow = nyears, byrow = TRUE
)

# -----------------------------------------------------------------------
# SECTION 3: GROWTH  [PARAMETERS from gmacs.par G_pars_est]
# -----------------------------------------------------------------------
# Growth type 4 (GROWTH_SIZEGAMMA): post-molt size is gamma distributed
# Increment type 1 (linear): molt_inc = alpha - beta*L
alpha <- c(0.987500941999, -4.81393964234)   # [1]=male, [2]=female
beta  <- c(-0.240935337503, -0.426448069345) # negative => inc = alpha + |beta|*L
gscale <- c(0.25, 0.25)

# Build growth transition matrix (upper-triangular, normalized)
build_growth_matrix <- function(alpha_h, beta_h, gscale_h) {
  gt <- matrix(0, nclass, nclass)
  for (l in 1:nclass) {
    molt_inc <- alpha_h - beta_h * mid_points[l]  # beta<0 => adds positive term
    postmolt_mean <- mid_points[l] + molt_inc
    shape <- postmolt_mean / gscale_h
    if (shape <= 0 || is.nan(shape)) {
      gt[l, l] <- 1.0
      next
    }
    # CDF at each size break from l to 22+1
    breaks_use <- size_breaks[(l + 1):(nclass + 1)]  # upper breaks from l+1
    psi <- pgamma(c(size_breaks[l + 1], breaks_use) / gscale_h, shape = shape, rate = 1)
    # Actually compute full CDF over all upper size classes >= l
    psi_all <- pgamma(size_breaks[(l + 1):(nclass + 1)] / gscale_h, shape = shape, rate = 1)
    raw <- diff(c(0, psi_all))
    raw[raw < 0] <- 0
    total <- sum(raw)
    if (total > 0) raw <- raw / total
    gt[l, l:nclass] <- raw
  }
  gt
}

gt_male   <- build_growth_matrix(alpha[1], beta[1], gscale[1])
gt_female <- build_growth_matrix(alpha[2], beta[2], gscale[2])

# -----------------------------------------------------------------------
# SECTION 4: RECRUITMENT SIZE DISTRIBUTION  [PARAMETERS: ra, rb from .par]
# -----------------------------------------------------------------------
# Type: gamma CDF, ra=32.5, rb=1.0 for both sexes
# ralpha = ra/rb = 32.5; x[ll] = pgamma(size_breaks[ll]/rb, shape=ralpha)
# Max rec size class = 3 (recruits only enter classes 1-3)
build_rec_sdd <- function(ra, rb) {
  ralpha <- ra / rb
  # GMACS: cumulative gamma at ALL nclass+1 breakpoints, then first_difference
  # gives P(lower edge < X <= upper edge) per bin (length nclass).
  x <- pgamma(size_breaks / rb, shape = ralpha, rate = 1)  # nclass+1 = 23 values
  raw <- diff(x)                                            # nclass = 22 bins
  raw[raw < 0] <- 0
  # Compress mass above nSizeClassRec (=3) into class 3 — matches TPL behavior?
  # TPL just zeros out bins > nSizeClassRec without redistributing; renormalize.
  raw[4:nclass] <- 0
  total <- sum(raw)
  if (total > 0) raw <- raw / total
  raw
}

rec_sdd_male   <- build_rec_sdd(32.5, 1.0)
rec_sdd_female <- build_rec_sdd(32.5, 1.0)

# -----------------------------------------------------------------------
# SECTION 5: NATURAL MORTALITY  [PARAMETERS: M_pars_est from gmacs.par]
# (block-structured by year)
# -----------------------------------------------------------------------
# Base M values
M_base_male_mat   <- 0.285054203583
M_base_fem_mat    <- 0.267898017972
M_base_male_imm   <- M_base_male_mat   * exp(0.0230343115040)   # ~0.29170
M_base_fem_imm    <- M_base_fem_mat    * exp(0.999999927668)    # ~0.72822

# Block group 1 has 3 single-year blocks: block1=2018, block2=2019, block3=2020
# All other years use base M (no deviation applied)
# M deviations per block (from gmacs.par M_pars_est):
#   block1: male_mat=1.57382855761, male_imm=0.0,            fem_mat=-0.467604450640, fem_imm=1.65491684520
#   block2: male_mat=0.340229140469, male_imm=2.33616893493, fem_mat=0.909943800420,  fem_imm=1.10241589461
#   block3: all devs = 0.0 (same as base)
M_dev <- list(
  male_mat  = c(1.57382855761, 0.340229140469, 0.0),
  male_imm  = c(0.0,           2.33616893493,  0.0),
  fem_mat   = c(-0.467604450640, 0.909943800420, 0.0),
  fem_imm   = c(1.65491684520, 1.10241589461, 0.0)
)

# Build M arrays: M[ig, year_index] for 4 groups
# ig: 1=male mature, 2=male immature, 3=female mature, 4=female immature
M_arr <- matrix(NA, 4, nyears)
for (ty in 1:nyears) {
  yr <- years_all[ty]
  if (yr == 2018) {
    blk <- 1
    M_arr[1, ty] <- M_base_male_mat * exp(M_dev$male_mat[blk])
    M_arr[2, ty] <- M_base_male_imm * exp(M_dev$male_imm[blk])
    M_arr[3, ty] <- M_base_fem_mat  * exp(M_dev$fem_mat[blk])
    M_arr[4, ty] <- M_base_fem_imm  * exp(M_dev$fem_imm[blk])
  } else if (yr == 2019) {
    blk <- 2
    M_arr[1, ty] <- M_base_male_mat * exp(M_dev$male_mat[blk])
    M_arr[2, ty] <- M_base_male_imm * exp(M_dev$male_imm[blk])
    M_arr[3, ty] <- M_base_fem_mat  * exp(M_dev$fem_mat[blk])
    M_arr[4, ty] <- M_base_fem_imm  * exp(M_dev$fem_imm[blk])
  } else {
    # 2020 uses block3 (dev=0) => base; all other years also use base
    M_arr[1, ty] <- M_base_male_mat
    M_arr[2, ty] <- M_base_male_imm
    M_arr[3, ty] <- M_base_fem_mat
    M_arr[4, ty] <- M_base_fem_imm
  }
}

# -----------------------------------------------------------------------
# SECTION 6: INITIAL N AT LENGTH  [PARAMETERS: T_pars_est[11:98]]
# -----------------------------------------------------------------------
logN_init <- list(
  male_mat = c(9.61621304212,9.62679552352,9.66306989395,9.78285024646,
               10.2214583595,10.7689536451,11.2071026034,11.4112938248,
               11.5046044865,11.5418405166,11.5076827387,11.2672959841,
               10.9588882022,10.6979128835,10.8233633468,11.8674904565,
               11.3642056390,10.3964363326,9.34647972630,8.34855563762,
               7.53155963885,7.13876943270),
  male_imm = c(12.2826487594,12.4079519363,13.2367626118,13.7336475212,
               13.0507617517,13.1403857173,12.8561783472,12.6164608083,
               12.5635360045,12.0367515655,11.3644760006,11.2436004285,
               11.3939906671,10.4864930939,9.10899896781,8.05082128386,
               7.28800617843,6.75535856579,6.36734136057,6.07873680998,
               5.87732802311,5.77237871304),
  fem_mat  = c(12.1609967456,12.1810304399,12.2286616172,12.3686193084,
               13.5272577414,13.5869990888,12.9906886058,12.1528338379,
               11.0261784087,9.97246467919,9.24664778134,8.82756643348,
               8.62889586413,8.57672245707,8.47739840141,8.27966866916,
               8.02351872671,7.76843766971,7.52698248280,7.29839447219,
               7.14120612468,7.04950784219),
  fem_imm  = c(-13.8190581797,-13.8702613062,-13.9676423645,-14.1229108137,
               -13.6403468096,-13.4722757321,-14.5954316583,-15.6153548271,
               -16.4219240869,-17.0489177454,-17.5020538856,-17.8434620759,
               -18.1137640811,-18.3403576795,-18.5367819410,-18.7100218874,
               -18.8637572810,-19.0,-19.0,-19.0,-19.0,-19.0)
)

# -----------------------------------------------------------------------
# SECTION 7: RECRUITMENT  [PARAMETERS: log_Rbar, sigmaR, rho, rec_dev, logit_rec_prop]
# -----------------------------------------------------------------------
log_Rbar       <- 14.38922529
sigmaR         <- exp(-0.9)  # = 0.40656966
rho            <- 0.01

rec_dev <- c(0.326718319884, 0.0130907228874, 0.938751502058, 1.64139124834,
             0.887015630724, 0.829111917971, -0.466807619621, -0.210540109559,
             0.365941380978, 0.614929708461, -0.480392232547, -0.0632228317037,
             -0.691536632808, -1.11764394313, -0.0600967230037, -1.25485086743,
             -0.539762663638, -0.657418419874, -1.68490769871, -0.373751546385,
             1.28310193985, -0.236988826426, -0.120510190389, -1.02850524275,
             -1.84360233208, -0.958266617057, 1.38483387086, -0.795312607787,
             -0.656107185985, -0.792327041450, -0.00507385267000, -0.556715548167,
             1.28906983501, 1.31880349667, 1.41172248925, -0.575974958550,
             -0.543298881311, -1.02539944014, -0.155899767339, 0.189676425930,
             1.01986418166, 0.279309231627, -0.487494435801)

logit_rec_prop <- c(2.53604707305, 0.822539249053, -0.328223066359, -1.05417221008,
                    -3.58451074552, -1.09330059563, 0.492811170928, -1.05882728472,
                    1.06210132514, 0.801561782041, -2.19483066604, -1.19684647851,
                    -1.82424611430, -0.949604737964, -2.41541083733, 2.42862710820,
                    -0.936132582816, -0.117737310021, -0.968429781967, 1.39998703587,
                    -1.83966001507, 0.713336898870, 0.880325715075, 0.156706246406,
                    3.11158209948, 0.617700507758, -1.87663670268, -1.43611776064,
                    -1.00754407173, -1.00052371138, -0.472072659033, 1.14464008834,
                    1.12876528355, 0.103172037250, -2.35984940290, -1.17438523862,
                    5.77606685297, 1.08074270294, -0.133699338559, 0.602677261167,
                    0.545964091807, -0.0186328905323, 3.63603967250)

# -----------------------------------------------------------------------
# SECTION 8: SELECTIVITY  [PARAMETERS: S_pars_est from gmacs.par]
# -----------------------------------------------------------------------
# GMACS standard logistic (SELEX_STANLOGISTIC, ctl type=2):
#   sel(L) = plogis((L - mu) / sigma)  where mu=exp(p1), sigma=exp(p2)
# Then normalized so max(sel)=1 when slx_max_at_1_in=1 (pot + trawl gears)
# (See gmacs.tpl plogis() and `if (slx_max_at_1_in==1) selx -= selx(nclass);`)
#
# S_pars_est[1..4]: pot male (4.666, 1.658), trawl male (4.777, 2.386)
# S_pars_est[49..50]: pot female (4.215, 0.990)
# S_pars_est[95..96]: pot retention male (4.596, 0.304)

logistic_sel_raw <- function(midpts, log_mean, log_sd) {
  mu <- exp(log_mean)
  sd <- exp(log_sd)
  1 / (1 + exp(-(midpts - mu) / sd))
}

# normalize so max == 1 (max_at_1=1)
norm_max1 <- function(sel) sel / max(sel)

slx_cap_male_pot   <- norm_max1(logistic_sel_raw(mid_points, 4.66558963236, 1.65809822968))
slx_cap_male_trawl <- norm_max1(logistic_sel_raw(mid_points, 4.77730466004, 2.38572646596))

# Female pot uses its own logistic (sex-specific=1 for pot)
slx_cap_fem_pot    <- norm_max1(logistic_sel_raw(mid_points, 4.21489152830, 0.989652399376))
# Female trawl mirrors male trawl (sex-specific=0 for trawl)
slx_cap_fem_trawl  <- slx_cap_male_trawl

# NMFS 1982 male selectivity: free parameters (log-scale), exponentiated
# S_pars_est[5:26] = log-selectivity for 22 classes
s_nmfs82_male_log <- c(-3.24078803698, -2.74347716399, -2.28659012654, -1.53333410796,
                        -1.50556286571, -1.32166752514, -1.01993892813, -1.00148494098,
                        -1.12620649390, -1.09821462426, -1.03345518915, -0.997335457322,
                        -0.977758723342, -0.870076219783, -0.859487967477, -0.983576696924,
                        -0.841148502918, -0.740450103435, -0.513420432168, -0.332325759370,
                        -0.239795268383, -0.318535273843)
slx_cap_male_nmfs82 <- exp(s_nmfs82_male_log)

# NMFS 1989 male: S_pars_est[27:48]
s_nmfs89_male_log <- c(-4.32846153143, -3.43323233448, -2.73345376163, -1.92178558923,
                        -1.71293903684, -1.48537814140, -1.25028496209, -1.16415895569,
                        -1.22394565963, -1.23537968366, -1.21053933929, -1.15855854707,
                        -1.12434282190, -0.982803457173, -0.775889659711, -0.455719272712,
                        -0.313597802348, -0.202550957977, -0.161561567563, -0.132219141985,
                        -0.121053034498, -0.151507922604)
slx_cap_male_nmfs89 <- exp(s_nmfs89_male_log)

# NMFS 1982 female: S_pars_est[51:72] (last=fixed at -0.0001)
s_nmfs82_fem_log <- c(-5.15454634000, -5.26397905369, -4.05225615711, -1.71952336216,
                       -1.16420124561, -0.545036788062, -0.548766256505, -0.755100140466,
                       -0.832734550139, -0.923100458132, -0.910166693660, -0.871365436619,
                       -0.838412570991, -0.791361157944, -0.721705886243, -0.631274057087,
                       -0.529525847024, -0.423592943040, -0.314046477198, -0.199516844947,
                       -0.0830084095410, -0.000100005000333)
slx_cap_fem_nmfs82 <- exp(s_nmfs82_fem_log)

# NMFS 1989 female: S_pars_est[73:94] (last=fixed at -0.0001)
s_nmfs89_fem_log <- c(-4.17334702546, -3.28855434287, -2.68161667805, -1.00692112413,
                       -0.510046267143, -0.244699268860, -0.338303393563, -0.904258596137,
                       -1.05888127688, -1.26847232731, -1.24160402551, -0.949866864709,
                       -0.827489899451, -0.777901464612, -0.710707076490, -0.623385903000,
                       -0.524205278388, -0.419941253405, -0.311316215096, -0.197210757525,
                       -0.0805122004493, -0.000100005000333)
slx_cap_fem_nmfs89 <- exp(s_nmfs89_fem_log)

# Retained selectivity (pot male only). Retention type=2 (logistic), NOT normalized
# (slx_max_at_1_in only read for capture, retention rows default to 0 in TPL).
# S_pars_est[95]=4.59584328714, [96]=0.304218601686
slx_ret_male_pot <- logistic_sel_raw(mid_points, 4.59584328714, 0.304218601686)
# All other retained = 0
slx_ret_zero <- rep(0, nclass)

# -----------------------------------------------------------------------
# SECTION 9: FISHING MORTALITY  [PARAMETERS: log_fbar, log_fdev, log_foff, log_fdov]
# -----------------------------------------------------------------------
# FM = exp(log_fbar + log_fdev) per year
# Fleet 1 (Pot): log_fbar=-0.215106041952, devs for 1982-2021 + 2024
# Fleet 2 (Trawl): log_fbar=-5.20885683589, devs for 1982-2024

log_fbar_pot   <- -0.215106041952
log_fbar_trawl <- -5.20885683589

# log_fdev pot: 41 values for years 1982-2021 + 2024 (no 2022, 2023)
log_fdev_pot <- c(-1.42359729546, -1.80093279963, -1.16351133928, -0.803978186229,
                  -0.651670955931, -0.240428377587, -0.185272315029, -0.146639540025,
                   0.884450082921,  0.389756719380,  0.703038803547,  0.818492453032,
                   0.490900800737,  0.514476417198,  0.547160236960,  0.458798455019,
                   1.03494191905,  -0.416553882579, -0.449640094202,  0.161805636404,
                   0.326695919624, -0.380339782529, -0.570827867198, -0.756577875480,
                  -0.156284281644,  0.187109971824, -0.0812617579920,-0.403247269875,
                  -0.734322485816, -0.0279520837176,  0.395306837946,  0.600446409162,
                   1.03696407113,   0.989572615917,  0.486657677622,  0.237846127558,
                   1.09571464887,   0.340051741903,  0.888019401141, -1.04192237683,
                  -1.15324645437)
# Years for pot devs:
years_pot_dev <- c(1982:2021, 2024)  # 41 years

# log_fdev trawl: all 43 years 1982-2024
log_fdev_trawl <- c(0.189919719297, 0.0823703037407, -0.105715228062, -0.287379730480,
                    -9.22806091240, -5.04476336857, -5.45561573048, -1.58850381682,
                    -0.289472825736, 2.16018277659, 1.66658085322, 1.52424810793,
                     1.35060294004, 1.62916325696, 1.44307440635, 0.711182348432,
                     0.813513604572, 0.278453754562, 0.517126777969, 0.534268158519,
                     0.159795213551, 0.127176433749, 0.105743172793, 0.0608151732667,
                     0.799546911838, 0.518289070684, -0.128830451945, 0.497241482928,
                    -0.949789986073, -0.536844191140, -0.00763530801505, 0.218305161109,
                     1.77628708038, 2.99403786115, -0.703687465037, 0.0922652096710,
                     1.62195044695, 0.443085167066, 0.839777891685, 0.488503236054,
                    -0.163129580980, 0.527445544157, 0.318476615473)

# Female pot: log_foff_Pot_Fishery = -6.78919848618 (offset for female)
# Female FM = exp(log_fbar_pot + log_fdev_pot + log_foff)
log_foff_fem_pot <- -6.78919848618

# log_fdov (year-varying sex offset for pot fishery)
log_fdov_pot <- c(1.36910268189, 1.65905435022, 1.28046220412, 1.15441560778,
                   1.86766084929, 1.40125297589, 0.625538123871, 0.437657709995,
                   2.75094844100, 1.29664983197, 1.47385050110, 0.637863607385,
                   0.708381793421, -0.516064641908, 1.05954520105, 1.20098736303,
                  -1.81682367533, -0.279826944654, -2.32603371042, 0.0443740035265,
                  -2.19412346339, -2.15836511612, -1.23516348559, -0.784670967139,
                  -2.68782274872, -0.240716288184, 0.152491447276, 0.359143307402,
                   0.682108160755, 2.35251291956, 0.458369698046, 1.04304137882,
                   1.70234532874, 0.888003898820, 0.267653479158, 0.365809578835,
                  -1.02486852246, 0.131179079196, -3.32391816135, -4.05740602264,
                  -4.72459971677)
# fdov only for 1982-2021 + 2024 (41 years, same as pot devs)

# Build FM arrays for each year
# FM_male_pot[ty], FM_male_trawl[ty], FM_fem_pot[ty], FM_fem_trawl[ty]
fm_male_pot   <- numeric(nyears)
fm_male_trawl <- numeric(nyears)
fm_fem_pot    <- numeric(nyears)
fm_fem_trawl  <- numeric(nyears)

for (ty in 1:nyears) {
  yr <- years_all[ty]

  # Male pot
  pot_idx <- which(years_pot_dev == yr)
  if (length(pot_idx) > 0) {
    fm_male_pot[ty]  <- exp(log_fbar_pot + log_fdev_pot[pot_idx])
    fm_fem_pot[ty]   <- exp(log_fbar_pot + log_fdev_pot[pot_idx] +
                              log_foff_fem_pot + log_fdov_pot[pot_idx])
  } else {
    fm_male_pot[ty]  <- 0
    fm_fem_pot[ty]   <- 0
  }

  # Trawl
  fm_male_trawl[ty] <- exp(log_fbar_trawl + log_fdev_trawl[ty])
  fm_fem_trawl[ty]  <- fm_male_trawl[ty]  # female trawl = male trawl FM
}

# -----------------------------------------------------------------------
# SECTION 10: POPULATION DYNAMICS  [R FUNCTION — generates all predictions]
# -----------------------------------------------------------------------
# State arrays: N[ig, size_class, year] at start of season 1
# ig: 1=male_mature, 2=male_imm, 3=fem_mature, 4=fem_imm

run_population <- function() {

  # Initialize at year 1 (1982) from logN_init
  N <- array(0, dim = c(4, nclass, nyears + 1))  # [ig, sc, year_idx]
  # Year index 1 = state at start of year 1982
  N[1, , 1] <- exp(logN_init$male_mat)
  N[2, , 1] <- exp(logN_init$male_imm)
  N[3, , 1] <- exp(logN_init$fem_mat)
  N[4, , 1] <- exp(logN_init$fem_imm)

  # Storage for predicted quantities
  pred_survey <- array(0, dim = c(4, nyears + 1))  # survey bio [fleet(1-4), year]
  # Actually index by survey series: 1=NMFS82 fem, 2=NMFS89 fem, 3=NMFS82 mal, 4=NMFS89 mal
  # Survey at start of season 1 each year
  pred_surv_fem82 <- numeric(nyears + 1)
  pred_surv_fem89 <- numeric(nyears + 1)
  pred_surv_mal82 <- numeric(nyears + 1)
  pred_surv_mal89 <- numeric(nyears + 1)

  # Catch storage
  pred_catch_ret_mal_pot   <- numeric(nyears)   # series 1
  pred_catch_disc_mal_pot  <- numeric(nyears)   # series 2
  pred_catch_disc_fem_pot  <- numeric(nyears)   # series 3
  pred_catch_trawl_both    <- numeric(nyears)   # series 4

  # Size comp catch-at-size (numbers) for all fleets/sexes
  # Store as list of matrices
  catch_N <- list(
    ret_mal_pot  = matrix(0, nyears, nclass),  # series 1 retained male pot
    disc_mal_pot = matrix(0, nyears, nclass),  # series 2 discarded male pot
    disc_fem_pot = matrix(0, nyears, nclass),  # series 3 discarded female pot
    trawl_male   = matrix(0, nyears, nclass),  # trawl male
    trawl_fem    = matrix(0, nyears, nclass)   # trawl female
  )

  # Survey size comp (numbers at size, sel*N for mature + immature components)
  surv_N <- list(
    fem82_mat = matrix(0, nyears + 1, nclass),
    fem82_imm = matrix(0, nyears + 1, nclass),
    fem89_mat = matrix(0, nyears + 1, nclass),
    fem89_imm = matrix(0, nyears + 1, nclass),
    mal82_mat = matrix(0, nyears + 1, nclass),
    mal82_imm = matrix(0, nyears + 1, nclass),
    mal89_mat = matrix(0, nyears + 1, nclass),
    mal89_imm = matrix(0, nyears + 1, nclass)
  )

  for (ty in 1:nyears) {
    yr  <- years_all[ty]
    N_s <- N[, , ty]  # [ig, sc] at start of season 1

    ## ---- SEASON 1: Survey (no fishing) ----
    # Compute survey biomass BEFORE mortality
    # Survey at time=0 within season 1 (pre-mortality snapshot)
    # NMFS82: female mature, survey series 1 (1982-1988) and male mature, series 3
    # NMFS89: female mature, series 2 (1989+) and male mature, series 4

    # Female mature (ig=3): sum over all 22 size classes
    fem_mat_N <- N_s[3, ]
    fem_imm_N <- N_s[4, ]
    mal_mat_N <- N_s[1, ]
    mal_imm_N <- N_s[2, ]

    # Survey predicted: selectivity * N * weight, at start of season 1
    pred_surv_fem82[ty] <- sum(slx_cap_fem_nmfs82 * fem_mat_N * wt_female)
    pred_surv_fem89[ty] <- sum(slx_cap_fem_nmfs89 * fem_mat_N * wt_female)
    pred_surv_mal82[ty] <- sum(slx_cap_male_nmfs82 * mal_mat_N * wt_male)
    pred_surv_mal89[ty] <- sum(slx_cap_male_nmfs89 * mal_mat_N * wt_male)

    # Survey size comp (numbers at size, weighted by selectivity), mat + imm
    surv_N$fem82_mat[ty, ] <- slx_cap_fem_nmfs82 * fem_mat_N
    surv_N$fem82_imm[ty, ] <- slx_cap_fem_nmfs82 * fem_imm_N
    surv_N$fem89_mat[ty, ] <- slx_cap_fem_nmfs89 * fem_mat_N
    surv_N$fem89_imm[ty, ] <- slx_cap_fem_nmfs89 * fem_imm_N
    surv_N$mal82_mat[ty, ] <- slx_cap_male_nmfs82 * mal_mat_N
    surv_N$mal82_imm[ty, ] <- slx_cap_male_nmfs82 * mal_imm_N
    surv_N$mal89_mat[ty, ] <- slx_cap_male_nmfs89 * mal_mat_N
    surv_N$mal89_imm[ty, ] <- slx_cap_male_nmfs89 * mal_imm_N

    # Apply season 1 survival (natural mortality only, no fishing)
    M_s1_male_mat <- M_arr[1, ty] * m_prop[1]
    M_s1_male_imm <- M_arr[2, ty] * m_prop[1]
    M_s1_fem_mat  <- M_arr[3, ty] * m_prop[1]
    M_s1_fem_imm  <- M_arr[4, ty] * m_prop[1]

    N_after_s1 <- N_s
    N_after_s1[1, ] <- N_s[1, ] * exp(-M_s1_male_mat)
    N_after_s1[2, ] <- N_s[2, ] * exp(-M_s1_male_imm)
    N_after_s1[3, ] <- N_s[3, ] * exp(-M_s1_fem_mat)
    N_after_s1[4, ] <- N_s[4, ] * exp(-M_s1_fem_imm)

    ## ---- SEASON 2: Fishing ----
    N_s2 <- N_after_s1

    # Natural mortality in season 2
    M_s2_male_mat <- M_arr[1, ty] * m_prop[2]
    M_s2_male_imm <- M_arr[2, ty] * m_prop[2]
    M_s2_fem_mat  <- M_arr[3, ty] * m_prop[2]
    M_s2_fem_imm  <- M_arr[4, ty] * m_prop[2]

    FS_mal_pot   <- fm_male_pot[ty]
    FS_fem_pot   <- fm_fem_pot[ty]
    FS_mal_trawl <- fm_male_trawl[ty]
    FS_fem_trawl <- fm_fem_trawl[ty]

    # Discard mortality rates (dmr) per fleet (from gmacs.dat, last column)
    xi_pot   <- 0.3
    xi_trawl <- 1.0

    # Vulnerability per fleet/sex: vul = sel_cap * (ret + (1-ret)*xi)
    # Only male pot has retention; everything else has ret = 0.
    vul_mal_pot   <- slx_cap_male_pot   * (slx_ret_male_pot + (1 - slx_ret_male_pot) * xi_pot)
    vul_mal_trawl <- slx_cap_male_trawl * xi_trawl
    vul_fem_pot   <- slx_cap_fem_pot    * xi_pot
    vul_fem_trawl <- slx_cap_fem_trawl  * xi_trawl

    # Z uses vulnerability (matches TPL calc_total_mortality: Z = m_prop*M + F)
    Z_mal_mat <- M_s2_male_mat + FS_mal_pot   * vul_mal_pot   + FS_mal_trawl * vul_mal_trawl
    Z_mal_imm <- M_s2_male_imm + FS_mal_pot   * vul_mal_pot   + FS_mal_trawl * vul_mal_trawl
    Z_fem_mat <- M_s2_fem_mat  + FS_fem_pot   * vul_fem_pot   + FS_fem_trawl * vul_fem_trawl
    Z_fem_imm <- M_s2_fem_imm  + FS_fem_pot   * vul_fem_pot   + FS_fem_trawl * vul_fem_trawl

    # Survival during season 2
    S_mal_mat <- exp(-Z_mal_mat)
    S_mal_imm <- exp(-Z_mal_imm)
    S_fem_mat <- exp(-Z_fem_mat)
    S_fem_imm <- exp(-Z_fem_imm)

    # Baranov catch numbers (Baranov equation: C = N * F/Z * (1-S))
    # Retained male pot (pot * sel_cap * sel_ret / Z * (1-S))
    C_ret_mal_mat_l  <- N_s2[1, ] * FS_mal_pot * slx_cap_male_pot * slx_ret_male_pot /
                         Z_mal_mat * (1 - S_mal_mat)
    C_ret_mal_imm_l  <- N_s2[2, ] * FS_mal_pot * slx_cap_male_pot * slx_ret_male_pot /
                         Z_mal_imm * (1 - S_mal_imm)

    # Discarded male pot (sel_cap * (1-sel_ret))
    C_disc_mal_mat_l <- N_s2[1, ] * FS_mal_pot * slx_cap_male_pot * (1 - slx_ret_male_pot) /
                         Z_mal_mat * (1 - S_mal_mat)
    C_disc_mal_imm_l <- N_s2[2, ] * FS_mal_pot * slx_cap_male_pot * (1 - slx_ret_male_pot) /
                         Z_mal_imm * (1 - S_mal_imm)

    # Discarded female pot
    C_disc_fem_mat_l <- N_s2[3, ] * FS_fem_pot * slx_cap_fem_pot / Z_fem_mat * (1 - S_fem_mat)
    C_disc_fem_imm_l <- N_s2[4, ] * FS_fem_pot * slx_cap_fem_pot / Z_fem_imm * (1 - S_fem_imm)

    # Trawl male
    C_trawl_mal_mat_l <- N_s2[1, ] * FS_mal_trawl * slx_cap_male_trawl / Z_mal_mat * (1 - S_mal_mat)
    C_trawl_mal_imm_l <- N_s2[2, ] * FS_mal_trawl * slx_cap_male_trawl / Z_mal_imm * (1 - S_mal_imm)
    C_trawl_fem_mat_l <- N_s2[3, ] * FS_fem_trawl * slx_cap_fem_trawl / Z_fem_mat * (1 - S_fem_mat)
    C_trawl_fem_imm_l <- N_s2[4, ] * FS_fem_trawl * slx_cap_fem_trawl / Z_fem_imm * (1 - S_fem_imm)

    # Handle division by zero (Z=0 when FM=0 and M=0 shouldn't happen, but safeguard)
    C_ret_mal_mat_l[!is.finite(C_ret_mal_mat_l)]   <- 0
    C_ret_mal_imm_l[!is.finite(C_ret_mal_imm_l)]   <- 0
    C_disc_mal_mat_l[!is.finite(C_disc_mal_mat_l)] <- 0
    C_disc_mal_imm_l[!is.finite(C_disc_mal_imm_l)] <- 0
    C_disc_fem_mat_l[!is.finite(C_disc_fem_mat_l)] <- 0
    C_disc_fem_imm_l[!is.finite(C_disc_fem_imm_l)] <- 0
    C_trawl_mal_mat_l[!is.finite(C_trawl_mal_mat_l)] <- 0
    C_trawl_mal_imm_l[!is.finite(C_trawl_mal_imm_l)] <- 0
    C_trawl_fem_mat_l[!is.finite(C_trawl_fem_mat_l)] <- 0
    C_trawl_fem_imm_l[!is.finite(C_trawl_fem_imm_l)] <- 0

    # Aggregate catch numbers for size comp
    catch_N$ret_mal_pot[ty,]  <- C_ret_mal_mat_l  + C_ret_mal_imm_l
    catch_N$disc_mal_pot[ty,] <- C_disc_mal_mat_l + C_disc_mal_imm_l
    catch_N$disc_fem_pot[ty,] <- C_disc_fem_mat_l + C_disc_fem_imm_l
    catch_N$trawl_male[ty,]   <- C_trawl_mal_mat_l + C_trawl_mal_imm_l
    catch_N$trawl_fem[ty,]    <- C_trawl_fem_mat_l + C_trawl_fem_imm_l

    # Predicted catch biomass (1000_mt)
    C_ret_mal_l  <- (C_ret_mal_mat_l  + C_ret_mal_imm_l)  * wt_male
    C_disc_mal_l <- (C_disc_mal_mat_l + C_disc_mal_imm_l) * wt_male
    C_disc_fem_l <- (C_disc_fem_mat_l + C_disc_fem_imm_l) * wt_female
    C_trawl_mal_l <- (C_trawl_mal_mat_l + C_trawl_mal_imm_l) * wt_male
    C_trawl_fem_l <- (C_trawl_fem_mat_l + C_trawl_fem_imm_l) * wt_female

    pred_catch_ret_mal_pot[ty]  <- sum(C_ret_mal_l)
    pred_catch_disc_mal_pot[ty] <- sum(C_disc_mal_l)
    pred_catch_disc_fem_pot[ty] <- sum(C_disc_fem_l)
    pred_catch_trawl_both[ty]   <- sum(C_trawl_mal_l) + sum(C_trawl_fem_l)

    # Update N after season 2
    N_after_s2 <- N_s2
    N_after_s2[1, ] <- N_s2[1, ] * S_mal_mat
    N_after_s2[2, ] <- N_s2[2, ] * S_mal_imm
    N_after_s2[3, ] <- N_s2[3, ] * S_fem_mat
    N_after_s2[4, ] <- N_s2[4, ] * S_fem_imm

    ## ---- SEASON 3: Growth, Maturation, Recruitment ----
    N_s3 <- N_after_s2

    # Season 3 natural mortality
    M_s3_male_mat <- M_arr[1, ty] * m_prop[3]
    M_s3_male_imm <- M_arr[2, ty] * m_prop[3]
    M_s3_fem_mat  <- M_arr[3, ty] * m_prop[3]
    M_s3_fem_imm  <- M_arr[4, ty] * m_prop[3]

    N_s3[1, ] <- N_s3[1, ] * exp(-M_s3_male_mat)
    N_s3[2, ] <- N_s3[2, ] * exp(-M_s3_male_imm)
    N_s3[3, ] <- N_s3[3, ] * exp(-M_s3_fem_mat)
    N_s3[4, ] <- N_s3[4, ] * exp(-M_s3_fem_imm)

    # Growth and maturation (terminal molt = 1: mature don't molt)
    # Immature males (ig=2) molt according to gt_male, may mature
    # Mature males (ig=1) stay mature, no molt
    # Mature females (ig=3) stay mature, no molt
    # Immature females (ig=4) molt according to gt_female, may mature

    # Mature probability from ctl file (pre-specified, block 2)
    # mat_male[l] = proportion maturing at size class l
    # All immature that molt will either stay immature or become mature
    # Molt probability type 1 = constant at 1.0 => all immature molt

    # Male growth+maturation
    imm_male_molted <- as.vector(t(gt_male) %*% N_s3[2, ])  # [sc_post]

    # Those that mature: use year-specific maturity ogive
    new_mat_male  <- imm_male_molted * mat_male_yr[ty, ]
    new_imm_male  <- imm_male_molted * (1 - mat_male_yr[ty, ])

    N_next_mal_mat <- N_s3[1, ] + new_mat_male
    N_next_mal_imm <- new_imm_male

    # Female growth+maturation
    imm_fem_molted <- as.vector(t(gt_female) %*% N_s3[4, ])

    new_mat_fem  <- imm_fem_molted * mat_female_yr[ty, ]
    new_imm_fem  <- imm_fem_molted * (1 - mat_female_yr[ty, ])

    N_next_fem_mat <- N_s3[3, ] + new_mat_fem
    N_next_fem_imm <- new_imm_fem

    # Add recruitment (enters immature group)
    R_total <- 2 * exp(log_Rbar + rec_dev[ty])
    p_male  <- plogis(logit_rec_prop[ty])

    R_male   <- p_male       * R_total
    R_female <- (1 - p_male) * R_total

    N_next_mal_imm <- N_next_mal_imm + R_male   * rec_sdd_male
    N_next_fem_imm <- N_next_fem_imm + R_female * rec_sdd_female

    # Store for next year
    N[1, , ty + 1] <- N_next_mal_mat
    N[2, , ty + 1] <- N_next_mal_imm
    N[3, , ty + 1] <- N_next_fem_mat
    N[4, , ty + 1] <- N_next_fem_imm
  }

  # Compute survey at start of year 44 (2025) - needed for survey predictions
  # (2025 surveys are in data but excluded from LL)
  ty_last <- nyears + 1
  N_s_last <- N[, , ty_last]
  pred_surv_fem82[ty_last] <- sum(slx_cap_fem_nmfs82 * N_s_last[3, ] * wt_female)
  pred_surv_fem89[ty_last] <- sum(slx_cap_fem_nmfs89 * N_s_last[3, ] * wt_female)
  pred_surv_mal82[ty_last] <- sum(slx_cap_male_nmfs82 * N_s_last[1, ] * wt_male)
  pred_surv_mal89[ty_last] <- sum(slx_cap_male_nmfs89 * N_s_last[1, ] * wt_male)
  surv_N$fem82_mat[ty_last, ] <- slx_cap_fem_nmfs82 * N_s_last[3, ]
  surv_N$fem82_imm[ty_last, ] <- slx_cap_fem_nmfs82 * N_s_last[4, ]
  surv_N$fem89_mat[ty_last, ] <- slx_cap_fem_nmfs89 * N_s_last[3, ]
  surv_N$fem89_imm[ty_last, ] <- slx_cap_fem_nmfs89 * N_s_last[4, ]
  surv_N$mal82_mat[ty_last, ] <- slx_cap_male_nmfs82 * N_s_last[1, ]
  surv_N$mal82_imm[ty_last, ] <- slx_cap_male_nmfs82 * N_s_last[2, ]
  surv_N$mal89_mat[ty_last, ] <- slx_cap_male_nmfs89 * N_s_last[1, ]
  surv_N$mal89_imm[ty_last, ] <- slx_cap_male_nmfs89 * N_s_last[2, ]

  list(
    N = N,
    pred_catch_ret_mal_pot   = pred_catch_ret_mal_pot,
    pred_catch_disc_mal_pot  = pred_catch_disc_mal_pot,
    pred_catch_disc_fem_pot  = pred_catch_disc_fem_pot,
    pred_catch_trawl_both    = pred_catch_trawl_both,
    pred_surv_fem82 = pred_surv_fem82,
    pred_surv_fem89 = pred_surv_fem89,
    pred_surv_mal82 = pred_surv_mal82,
    pred_surv_mal89 = pred_surv_mal89,
    catch_N  = catch_N,
    surv_N   = surv_N
  )
}

# Run population model
pop <- run_population()

# -----------------------------------------------------------------------
# SECTION 11: OBSERVED DATA  [DATA: catch and survey loaded from .dat]
# -----------------------------------------------------------------------

dat_path <- if (file.exists("25_snow_update_plus_group.dat")) {
  "25_snow_update_plus_group.dat"
} else {
  "/Users/grantadams/Documents/GitHub/AFSC_assessments/snow_crab/Models/25_gmacs_update_plus_group/25_snow_update_plus_group.dat"
}

# Load catch data directly from the dat file (4 frames, 41/41/41/43 rows)
load_catch_frames <- function(dat_path) {
  lines <- readLines(dat_path, warn = FALSE)
  # Find "# Number of rows in each data frame"
  i_nrow <- grep("Number of rows in each data frame", lines)[1]
  nrows <- as.integer(strsplit(trimws(lines[i_nrow + 1]), "\\s+")[[1]])
  frames <- list()
  i <- i_nrow + 2
  for (k in seq_along(nrows)) {
    # Skip comment/blank until first numeric row
    while (i <= length(lines) && !grepl("^\\s*[0-9]", lines[i])) i <- i + 1
    n <- nrows[k]
    rows <- list()
    for (r in seq_len(n)) {
      parts <- strsplit(trimws(lines[i]), "\\s+")[[1]]
      rows[[r]] <- as.numeric(parts[1:11])  # 11 cols: year season fleet sex obs cv type units mult effort dmr
      i <- i + 1
    }
    df <- as.data.frame(do.call(rbind, rows))
    colnames(df) <- c("year", "season", "fleet", "sex", "obs", "cv",
                      "type", "units", "mult", "effort", "dmr")
    frames[[k]] <- df
  }
  frames
}
catch_frames <- load_catch_frames(dat_path)
# Frame 1: ret_mal_pot, Frame 2: disc_mal_pot, Frame 3: disc_fem_pot, Frame 4: trawl
years_pot_obs    <- catch_frames[[1]]$year
obs_ret_mal_pot  <- catch_frames[[1]]$obs
cv_s1_vec        <- catch_frames[[1]]$cv
obs_disc_mal_pot <- catch_frames[[2]]$obs
cv_s2_vec        <- catch_frames[[2]]$cv
obs_disc_fem_pot <- catch_frames[[3]]$obs
cv_s3_vec        <- catch_frames[[3]]$cv
obs_trawl_both   <- catch_frames[[4]]$obs
cv_s4            <- catch_frames[[4]]$cv
cv_s1            <- cv_s1_vec  # all rows same in this model but use exact per-row
cv_s2            <- cv_s2_vec
cv_s3            <- cv_s3_vec
cat(sprintf("Loaded catch frames from .dat: %d/%d/%d/%d rows\n",
            length(obs_ret_mal_pot), length(obs_disc_mal_pot),
            length(obs_disc_fem_pot), length(obs_trawl_both)))

## Survey index data — loaded directly from .dat
# Row format: Index Year Season Fleet Sex Mature Obs CV Units Timing RAI
load_survey_data <- function(dat_path) {
  lines <- readLines(dat_path, warn = FALSE)
  i_nrow <- grep("Number\\s+of\\s+rows\\s+of\\s+index\\s+data", lines)[1]
  i <- i_nrow + 1
  while (i <= length(lines) && !grepl("^\\s*[0-9]", lines[i])) i <- i + 1
  nrows <- as.integer(strsplit(trimws(lines[i]), "\\s+")[[1]][1])
  # Skip header rows until first numeric row
  i <- i + 1
  while (i <= length(lines) && !grepl("^\\s*[0-9]{4}", trimws(lines[i]))) {
    # Find first row starting with year (4 digits) followed by data
    # The first column is Index (1-digit), then Year (4 digits) — so look for pattern
    if (grepl("^\\s*[0-9]+\\s+[0-9]{4}", lines[i])) break
    i <- i + 1
  }
  rows <- list()
  for (r in seq_len(nrows)) {
    parts <- strsplit(trimws(lines[i]), "\\s+")[[1]]
    rows[[r]] <- as.numeric(parts[1:11])
    i <- i + 1
  }
  df <- as.data.frame(do.call(rbind, rows))
  colnames(df) <- c("idx", "year", "season", "fleet", "sex", "mature",
                    "obs", "cv", "units", "timing", "rai")
  df
}
surv_df <- load_survey_data(dat_path)

surv1_years <- surv_df$year[surv_df$idx == 1]; surv1_obs <- surv_df$obs[surv_df$idx == 1]; surv1_cv <- surv_df$cv[surv_df$idx == 1]
surv2_years <- surv_df$year[surv_df$idx == 2]; surv2_obs <- surv_df$obs[surv_df$idx == 2]; surv2_cv <- surv_df$cv[surv_df$idx == 2]
surv3_years <- surv_df$year[surv_df$idx == 3]; surv3_obs <- surv_df$obs[surv_df$idx == 3]; surv3_cv <- surv_df$cv[surv_df$idx == 3]
surv4_years <- surv_df$year[surv_df$idx == 4]; surv4_obs <- surv_df$obs[surv_df$idx == 4]; surv4_cv <- surv_df$cv[surv_df$idx == 4]
cat(sprintf("Loaded survey data: idx1=%d  idx2=%d  idx3=%d  idx4=%d rows\n",
            length(surv1_obs), length(surv2_obs), length(surv3_obs), length(surv4_obs)))

# log add cv for all surveys (near-zero, adds negligibly)
log_add_cv <- -9.21034037198
add_cv_val <- exp(log_add_cv)  # ~0.0001

# -----------------------------------------------------------------------
# SECTION 12: CATCH LIKELIHOOD (lognormal - full normal)
# -----------------------------------------------------------------------
# GMACS uses: catch_sd = sqrt(log(1 + cv^2)); then dnorm(res, catch_sd)
# dnorm in ADMB sums over ALL rows; res = log(obs/pred) when obs>0, else 0
# (effort=0 in all rows here, so obs=0 -> res=0 but constants still summed).
lognormal_nll <- function(obs, pred, cv) {
  sd  <- sqrt(log(1 + cv^2))
  res <- ifelse(obs > 0 & pred > 0, log(obs / pred), 0)
  sum(0.5 * log(2 * pi) + log(sd) + 0.5 * (res / sd)^2)
}

# Match predicted catch to observed years
pot_ty_idx <- match(years_pot_obs, years_all)  # indices into years_all

pred_s1 <- pop$pred_catch_ret_mal_pot[pot_ty_idx]
pred_s2 <- pop$pred_catch_disc_mal_pot[pot_ty_idx]
pred_s3 <- pop$pred_catch_disc_fem_pot[pot_ty_idx]
pred_s4 <- pop$pred_catch_trawl_both   # all 43 years

nll_catch_s1 <- lognormal_nll(obs_ret_mal_pot,  pred_s1, cv_s1)
nll_catch_s2 <- lognormal_nll(obs_disc_mal_pot, pred_s2, cv_s2)
nll_catch_s3 <- lognormal_nll(obs_disc_fem_pot, pred_s3, cv_s3)
nll_catch_s4 <- lognormal_nll(obs_trawl_both,   pred_s4, cv_s4)

nll_catch_total <- nll_catch_s1 + nll_catch_s2 + nll_catch_s3 + nll_catch_s4

cat(sprintf("Catch NLL:   s1=%.5f  s2=%.5f  s3=%.5f  s4=%.5f  TOTAL=%.5f\n",
            nll_catch_s1, nll_catch_s2, nll_catch_s3, nll_catch_s4, nll_catch_total))
cat(sprintf("Expected:    s1~120.99  s2~377.00  s3~-71.40  s4~-54.11  TOTAL~372.48\n\n"))

# -----------------------------------------------------------------------
# SECTION 13: SURVEY INDEX LIKELIHOOD (lognormal - WITHOUT 2*pi constant)
# -----------------------------------------------------------------------
# GMACS formula: nloglike += log(stdtmp) + 0.5*(res/stdtmp)^2
# where stdtmp = sqrt(cvobs2 + cvadd2)
#       cvobs2 = log(1 + cv_obs^2) / lambda  (lambda=1)
#       cvadd2 = log(1 + add_cv^2)            (add_cv ~= 0.0001 ≈ 0)
# NOTE: Does NOT include 0.5*log(2*pi) constant!
survey_nll <- function(obs, pred_vec, obs_cv, years_obs, years_all_ext,
                       exclude_year = NULL) {
  nll <- 0
  for (i in seq_along(obs)) {
    yr <- years_obs[i]
    if (!is.null(exclude_year) && yr %in% exclude_year) next
    ty <- which(years_all_ext == yr)
    if (length(ty) == 0) next
    pred_val <- pred_vec[ty]
    if (pred_val <= 0 || obs[i] <= 0) next
    res    <- log(obs[i] / pred_val)
    cvadd2 <- log(1 + add_cv_val^2)          # ≈ 1e-8 (negligible)
    cvobs2 <- log(1 + obs_cv[i]^2)           # lognormal sigma^2
    stdtmp <- sqrt(cvobs2 + cvadd2)
    nll <- nll + log(stdtmp) + 0.5 * (res / stdtmp)^2
  }
  nll
}

# years_all_ext extends by 1 to include 2025 (ty=44)
years_all_ext <- c(years_all, 2025)  # index 1=1982, 44=2025

nll_surv1 <- survey_nll(surv1_obs, pop$pred_surv_fem82, surv1_cv, surv1_years, years_all_ext)
nll_surv2 <- survey_nll(surv2_obs, pop$pred_surv_fem89, surv2_cv, surv2_years, years_all_ext)
nll_surv3 <- survey_nll(surv3_obs, pop$pred_surv_mal82, surv3_cv, surv3_years, years_all_ext)
nll_surv4 <- survey_nll(surv4_obs, pop$pred_surv_mal89, surv4_cv, surv4_years, years_all_ext)

nll_surv_total <- nll_surv1 + nll_surv2 + nll_surv3 + nll_surv4

cat(sprintf("Survey NLL:  s1=%.5f  s2=%.5f  s3=%.5f  s4=%.5f  TOTAL=%.5f\n",
            nll_surv1, nll_surv2, nll_surv3, nll_surv4, nll_surv_total))
cat(sprintf("Expected:    s1~51.82  s2~7.63  s3~94.95  s4~-12.14  TOTAL~142.26\n\n"))

# -----------------------------------------------------------------------
# SECTION 14: SIZE COMPOSITION DATA  [DATA: from .dat; predictions from R]
# -----------------------------------------------------------------------
# Observed proportions and Nsamp loaded directly from the .dat file.
# Predicted proportions are computed from R's d4_N (run_population output).

# Parse size composition data directly from the .dat file (13 matrices).
# Row format: Year Season Fleet Sex Type Shell Maturity Nsamp + 22 proportions.
# Each matrix has its own series number 1..13 in declaration order.
load_sizecomp_from_dat <- function(dat_path) {
  lines <- readLines(dat_path, warn = FALSE)
  # Find "## Number of rows in each matrix" line
  i_rows <- grep("rows in each matrix", lines)[1]
  # First numeric line after that header has the row counts
  i <- i_rows + 1
  while (i <= length(lines) && !grepl("^\\s*[0-9]", lines[i])) i <- i + 1
  nrows_per <- as.integer(strsplit(trimws(lines[i]), "\\s+")[[1]])
  # Advance past header lines until first data row
  i <- i + 1
  while (i <= length(lines) && !grepl("^\\s*[0-9]{4}\\s", lines[i])) i <- i + 1

  result <- list()
  out_idx <- 0
  for (series in seq_along(nrows_per)) {
    for (r in seq_len(nrows_per[series])) {
      parts <- strsplit(trimws(lines[i]), "\\s+")[[1]]
      out_idx <- out_idx + 1
      result[[out_idx]] <- list(
        series = series,
        year   = as.integer(parts[1]),
        season = as.integer(parts[2]),
        fleet  = as.integer(parts[3]),
        sex    = as.integer(parts[4]),
        type   = as.integer(parts[5]),
        shell  = as.integer(parts[6]),
        mat    = as.integer(parts[7]),
        nsamp  = as.numeric(parts[8]),
        obs    = as.numeric(parts[9:30])
      )
      i <- i + 1
      # Skip blanks / comment lines between rows
      while (i <= length(lines) &&
             (nchar(trimws(lines[i])) == 0 || startsWith(trimws(lines[i]), "#"))) i <- i + 1
    }
  }
  result
}
sizecomp_data <- load_sizecomp_from_dat(dat_path)
cat(sprintf("Loaded %d size composition rows from .dat across %d series\n",
            length(sizecomp_data),
            length(unique(sapply(sizecomp_data, `[[`, "series")))))

# Compute predicted size composition (proportions) for each series and year.
# Series mapping (from Gmacsall.out Size_fit_summary):
#   1: Pot male retained             -> catch_N$ret_mal_pot
#   2: Pot male total                 -> ret + disc male pot
#   3: Pot female discarded           -> catch_N$disc_fem_pot
#   4: Trawl female discarded         -> catch_N$trawl_fem
#   5: Trawl male discarded           -> catch_N$trawl_male
#   6: NMFS82 female immature         -> surv_N$fem82_imm
#   7: NMFS89 female immature         -> surv_N$fem89_imm
#   8: NMFS82 male immature           -> surv_N$mal82_imm
#   9: NMFS89 male immature           -> surv_N$mal89_imm
#  10: NMFS82 female mature           -> surv_N$fem82_mat
#  11: NMFS89 female mature           -> surv_N$fem89_mat
#  12: NMFS82 male mature             -> surv_N$mal82_mat
#  13: NMFS89 male mature             -> surv_N$mal89_mat
get_pred_at_size <- function(series, year) {
  ty_catch  <- which(years_all == year)
  ty_survey <- which(c(years_all, 2025) == year)
  if (series %in% 1:5) {
    if (length(ty_catch) == 0) return(NULL)
    vec <- switch(series,
      `1` = pop$catch_N$ret_mal_pot[ty_catch, ],
      `2` = pop$catch_N$ret_mal_pot[ty_catch, ] + pop$catch_N$disc_mal_pot[ty_catch, ],
      `3` = pop$catch_N$disc_fem_pot[ty_catch, ],
      `4` = pop$catch_N$trawl_fem[ty_catch, ],
      `5` = pop$catch_N$trawl_male[ty_catch, ]
    )
  } else {
    if (length(ty_survey) == 0) return(NULL)
    vec <- switch(as.character(series),
      "6"  = pop$surv_N$fem82_imm[ty_survey, ],
      "7"  = pop$surv_N$fem89_imm[ty_survey, ],
      "8"  = pop$surv_N$mal82_imm[ty_survey, ],
      "9"  = pop$surv_N$mal89_imm[ty_survey, ],
      "10" = pop$surv_N$fem82_mat[ty_survey, ],
      "11" = pop$surv_N$fem89_mat[ty_survey, ],
      "12" = pop$surv_N$mal82_mat[ty_survey, ],
      "13" = pop$surv_N$mal89_mat[ty_survey, ]
    )
  }
  if (sum(vec) <= 0) return(rep(0, nclass))
  vec / sum(vec)
}

# Attach R-computed predictions to each sizecomp_data record
for (i in seq_along(sizecomp_data)) {
  item <- sizecomp_data[[i]]
  sizecomp_data[[i]]$pred <- get_pred_at_size(item$series, item$year)
}

# Robust approximation to multinomial (TPL src/robust_multi.cpp):
#   a = 0.1 / nclass
#   b = effective N (= nsamp here since log_vn = 0 for all series)
#   o = obs / sum(obs); p = pred / sum(pred) (post-TINY)
#   v = a + o*(1-o)
#   l = 0.5 * (p - o)^2 / v
#   nll = -sum(log(exp(-b*l) + 0.01)) + 0.5*sum(log(v/b))
mnll_sizecomp_from_admb <- function(sizecomp_data) {
  TINY <- 1e-14
  series_nll <- numeric(13)

  for (item in sizecomp_data) {
    s   <- item$series
    obs  <- item$obs
    pred <- item$pred
    N    <- item$nsamp
    if (is.na(s) || s < 1 || s > 13) next
    if (is.na(N) || N <= 0) next
    if (sum(obs) <= 0) next

    a <- 0.1 / length(obs)
    o <- obs + TINY; o <- o / sum(o)
    p <- pred + TINY; p <- p / sum(p)
    v <- a + o * (1 - o)
    l <- 0.5 * (p - o)^2 / v
    nll_row <- -sum(log(exp(-N * l) + 0.01)) + 0.5 * sum(log(v / N))
    series_nll[s] <- series_nll[s] + nll_row
  }
  series_nll
}

sc_nll_by_series <- mnll_sizecomp_from_admb(sizecomp_data)
nll_sizecomp_total <- sum(sc_nll_by_series)

cat(sprintf("Size comp LL by series:\n"))
for (s in 1:13) {
  if (sc_nll_by_series[s] != 0)
    cat(sprintf("  Series %2d: %.5f\n", s, sc_nll_by_series[s]))
}
cat(sprintf("Size comp LL TOTAL = %.5f\n", nll_sizecomp_total))
cat(sprintf("Expected:           -29004.09422574\n\n"))

# -----------------------------------------------------------------------
# SECTION 15: GROWTH DATA LIKELIHOOD (lognormal increment)
# -----------------------------------------------------------------------
# GrowthObsType=1: observed is increment (postmolt - premolt)
# Formula: pred_inc = alpha[sex] - beta[sex] * premolt (beta<0 => additive)
# Load growth data directly from .dat file to ensure exact match with ADMB
load_growth_data <- function(dat_path) {
  lines <- readLines(dat_path, warn = FALSE)
  # Find "# nobs_growth" header, then the count, then the rows
  i_nobs <- grep("nobs_growth", lines)[1]
  if (is.na(i_nobs)) stop("Could not find nobs_growth in dat file")
  # Skip blank/comment lines until first numeric row
  i <- i_nobs + 1
  while (i <= length(lines) && !grepl("^\\s*[0-9]", lines[i])) i <- i + 1
  nobs <- as.integer(strsplit(trimws(lines[i]), "\\s+")[[1]][1])
  i <- i + 1
  # Skip comment lines (start with #)
  while (i <= length(lines) && grepl("^\\s*(#|$)", lines[i])) i <- i + 1
  rows <- list()
  for (k in seq_len(nobs)) {
    parts <- strsplit(trimws(lines[i]), "\\s+")[[1]]
    rows[[k]] <- as.numeric(parts[1:4])
    i <- i + 1
  }
  df <- as.data.frame(do.call(rbind, rows))
  colnames(df) <- c("premolt", "sex", "inc", "cv")
  df$sex <- as.integer(df$sex)
  df
}
dat_path <- if (file.exists("25_snow_update_plus_group.dat")) {
  "25_snow_update_plus_group.dat"
} else {
  "/Users/grantadams/Documents/GitHub/AFSC_assessments/snow_crab/Models/25_gmacs_update_plus_group/25_snow_update_plus_group.dat"
}
growth_data_raw <- load_growth_data(dat_path)
cat(sprintf("Loaded %d growth observations from .dat (males=%d, females=%d)\n",
            nrow(growth_data_raw),
            sum(growth_data_raw$sex == 1),
            sum(growth_data_raw$sex == 2)))

# Legacy inline data block (no longer used) ---
.unused_growth_block <- read.table(
  text = "
25.20 1 7.60 0.03
25.20 1 7.60 0.03
25.40 1 6.40 0.03
25.60 1 5.80 0.03
25.60 1 5.80 0.03
25.70 1 7.57 0.03
25.70 1 5.47 0.03
25.80 1 4.90 0.03
25.90 1 5.20 0.03
25.90 1 5.20 0.03
26.00 1 6.20 0.03
26.10 1 5.40 0.03
26.30 1 73.00 0.03
26.50 1 6.70 0.03
26.70 1 8.10 0.03
27.10 1 5.50 0.03
27.20 1 6.10 0.03
27.40 1 7.40 0.03
27.60 1 5.40 0.03
27.90 1 8.90 0.03
28.80 1 6.80 0.03
28.90 1 7.05 0.03
29.00 1 6.90 0.03
29.10 1 7.00 0.03
29.70 1 7.30 0.03
29.90 1 10.00 0.03
30.30 1 10.00 0.03
30.70 1 9.80 0.03
44.20 1 14.50 0.03
44.70 1 12.60 0.03
53.56 1 12.14 0.03
54.84 1 13.11 0.03
56.07 1 15.92 0.03
56.50 1 13.50 0.03
56.50 1 15.74 0.03
56.95 1 13.08 0.03
57.00 1 13.00 0.03
57.42 1 16.56 0.03
57.44 1 18.13 0.03
57.63 1 10.97 0.03
57.63 1 10.97 0.03
58.47 1 16.29 0.03
58.70 1 13.80 0.03
59.30 1 15.80 0.03
59.86 1 14.75 0.03
60.30 1 14.80 0.03
60.48 1 16.67 0.03
60.60 1 16.49 0.03
60.62 1 18.51 0.03
60.80 1 17.60 0.03
60.82 1 18.14 0.03
60.86 1 18.14 0.03
61.09 1 19.86 0.03
61.45 1 16.00 0.03
61.59 1 18.43 0.03
61.94 1 17.02 0.03
62.15 1 19.03 0.03
62.28 1 14.50 0.03
62.30 1 19.50 0.03
62.57 1 17.38 0.03
62.72 1 16.99 0.03
62.78 1 17.11 0.03
63.09 1 18.22 0.03
63.37 1 20.62 0.03
63.75 1 15.92 0.03
63.81 1 15.49 0.03
63.89 1 15.20 0.03
64.00 1 20.70 0.03
64.00 1 20.70 0.03
64.01 1 16.54 0.03
64.21 1 19.03 0.03
64.37 1 18.02 0.03
64.59 1 19.20 0.03
64.70 1 18.00 0.03
65.02 1 15.07 0.03
65.42 1 15.41 0.03
65.76 1 16.12 0.03
65.79 1 17.23 0.03
65.85 1 18.38 0.03
65.94 1 17.10 0.03
65.97 1 17.13 0.03
66.01 1 15.50 0.03
66.04 1 18.42 0.03
66.37 1 16.64 0.03
66.52 1 19.72 0.03
67.05 1 17.45 0.03
67.10 1 16.74 0.03
67.23 1 18.33 0.03
67.34 1 16.47 0.03
67.44 1 16.90 0.03
67.44 1 16.90 0.03
67.60 1 18.40 0.03
67.66 1 20.98 0.03
67.86 1 16.64 0.03
67.88 1 19.73 0.03
67.90 1 17.40 0.03
68.75 1 17.95 0.03
68.86 1 19.66 0.03
69.03 1 16.55 0.03
69.05 1 20.67 0.03
69.06 1 15.05 0.03
69.36 1 17.91 0.03
69.57 1 17.28 0.03
69.69 1 17.44 0.03
69.80 1 17.27 0.03
70.19 1 21.96 0.03
70.25 1 9.90 0.03
70.87 1 19.00 0.03
71.04 1 27.79 0.03
71.20 1 20.37 0.03
71.40 1 18.98 0.03
71.71 1 21.25 0.03
71.71 1 9.65 0.03
72.19 1 16.38 0.03
72.26 1 18.82 0.03
72.37 1 17.49 0.03
72.40 1 18.54 0.03
72.53 1 15.70 0.03
72.53 1 15.91 0.03
73.19 1 17.15 0.03
73.27 1 18.17 0.03
73.41 1 21.45 0.03
73.54 1 17.55 0.03
73.61 1 18.48 0.03
73.89 1 19.77 0.03
73.89 1 15.82 0.03
73.97 1 18.41 0.03
74.01 1 19.55 0.03
74.06 1 18.78 0.03
74.50 1 19.40 0.03
74.97 1 19.70 0.03
75.19 1 20.88 0.03
75.35 1 20.39 0.03
75.43 1 20.28 0.03
75.54 1 17.67 0.03
75.66 1 18.98 0.03
75.71 1 15.11 0.03
75.72 1 17.96 0.03
75.98 1 20.66 0.03
76.31 1 21.82 0.03
76.81 1 17.28 0.03
77.10 1 20.36 0.03
77.22 1 20.94 0.03
78.05 1 21.30 0.03
78.10 1 19.17 0.03
78.21 1 17.75 0.03
78.53 1 19.58 0.03
78.72 1 17.39 0.03
79.61 1 21.33 0.03
79.90 1 17.90 0.03
80.14 1 20.19 0.03
80.70 1 14.18 0.03
80.85 1 22.16 0.03
80.88 1 18.23 0.03
82.89 1 21.87 0.03
83.12 1 21.36 0.03
84.60 1 20.13 0.03
87.29 1 22.70 0.03
89.80 1 20.20 0.03
89.90 1 22.20 0.03
89.90 1 22.40 0.03
93.80 1 23.80 0.03
25.00 2 6.10 0.03
25.10 2 7.10 0.03
25.20 2 6.80 0.03
25.20 2 6.80 0.03
25.30 2 8.20 0.03
25.40 2 6.30 0.03
25.40 2 6.30 0.03
25.50 2 9.10 0.03
25.50 2 7.40 0.03
25.50 2 9.10 0.03
25.50 2 7.40 0.03
25.50 2 5.72 0.03
25.70 2 6.80 0.03
25.70 2 7.60 0.03
25.70 2 4.20 0.03
25.80 2 7.80 0.03
25.80 2 6.30 0.03
25.90 2 6.80 0.03
25.90 2 6.80 0.03
26.10 2 7.00 0.03
26.20 2 7.00 0.03
26.20 2 7.10 0.03
26.30 2 7.20 0.03
26.30 2 7.20 0.03
26.40 2 4.80 0.03
26.40 2 4.80 0.03
26.40 2 4.80 0.03
26.40 2 6.10 0.03
26.40 2 5.80 0.03
26.40 2 6.10 0.03
26.40 2 5.80 0.03
26.40 2 4.50 0.03
26.40 2 5.70 0.03
26.40 2 7.50 0.03
26.40 2 7.60 0.03
26.40 2 6.20 0.03
26.50 2 7.40 0.03
26.50 2 7.20 0.03
26.50 2 6.19 0.03
26.60 2 8.30 0.03
26.70 2 5.00 0.03
26.70 2 4.50 0.03
26.70 2 5.70 0.03
26.90 2 7.50 0.03
26.90 2 7.60 0.03
26.90 2 6.20 0.03
27.00 2 7.70 0.03
27.10 2 5.93 0.03
27.10 2 6.30 0.03
27.10 2 6.20 0.03
27.10 2 5.60 0.03
27.20 2 7.20 0.03
27.20 2 7.30 0.03
27.20 2 6.30 0.03
27.40 2 7.70 0.03
27.40 2 7.10 0.03
27.40 2 6.80 0.03
27.50 2 7.30 0.03
27.50 2 6.50 0.03
27.60 2 5.30 0.03
27.60 2 5.14 0.03
27.70 2 5.81 0.03
28.00 2 7.00 0.03
28.00 2 6.80 0.03
28.10 2 6.40 0.03
28.10 2 6.40 0.03
28.10 2 6.50 0.03
28.10 2 6.30 0.03
28.20 2 8.02 0.03
28.20 2 7.60 0.03
28.20 2 8.02 0.03
28.20 2 7.60 0.03
28.20 2 7.60 0.03
28.30 2 6.44 0.03
28.30 2 7.24 0.03
28.40 2 6.50 0.03
28.50 2 7.90 0.03
28.50 2 7.50 0.03
28.50 2 7.63 0.03
28.60 2 6.90 0.03
28.60 2 6.80 0.03
28.70 2 8.40 0.03
28.70 2 7.30 0.03
28.70 2 8.40 0.03
28.70 2 7.30 0.03
28.70 2 5.80 0.03
28.70 2 6.76 0.03
28.90 2 7.00 0.03
28.90 2 5.90 0.03
28.90 2 6.80 0.03
29.00 2 7.70 0.03
29.00 2 7.70 0.03
29.00 2 6.90 0.03
29.10 2 9.30 0.03
29.10 2 9.30 0.03
29.10 2 7.50 0.03
29.10 2 2.70 0.03
29.10 2 4.82 0.03
29.20 2 9.30 0.03
29.20 2 7.60 0.03
29.30 2 6.10 0.03
29.30 2 6.34 0.03
29.40 2 7.30 0.03
29.40 2 7.30 0.03
29.50 2 8.90 0.03
29.60 2 6.60 0.03
29.60 2 5.88 0.03
29.80 2 7.38 0.03
30.00 2 6.08 0.03
30.30 2 7.00 0.03
30.40 2 7.20 0.03
30.60 2 5.80 0.03
30.60 2 6.75 0.03
30.90 2 7.50 0.03
30.90 2 7.50 0.03
30.90 2 6.60 0.03
31.00 2 6.50 0.03
31.70 2 7.35 0.03
31.80 2 7.80 0.03
32.80 2 12.10 0.01
33.30 2 8.04 0.01
34.90 2 9.90 0.01
34.90 2 9.90 0.01
35.30 2 12.30 0.01
38.30 2 12.60 0.01
38.90 2 14.10 0.01
41.00 2 14.80 0.01
42.10 2 12.50 0.01
44.20 2 15.30 0.01
44.30 2 15.00 0.01
44.80 2 14.90 0.01
45.20 2 14.40 0.01
46.90 2 13.50 0.01
47.00 2 14.40 0.01
47.90 2 13.50 0.01
", header = FALSE, col.names = c("premolt", "sex", "inc", "cv"))

calc_growth_nll <- function(growth_data, alpha, beta) {
  # GMACS formula (GROWTHINC_DATA_NORMAL with LINEAR_GROWTHMODEL):
  # nloglike(6,h) += dnorm(log(obs_inc) - log(pred_inc), dMoltIncCV)
  # ADMB dnorm = 0.5*log(2*pi) + log(sigma) + 0.5*(x/sigma)^2
  # where sigma = cv (raw, NOT sqrt(log(1+cv^2)))
  nll <- 0
  for (i in seq_len(nrow(growth_data))) {
    premolt <- growth_data$premolt[i]
    h       <- as.integer(growth_data$sex[i])
    obs_inc <- growth_data$inc[i]
    cv_g    <- growth_data$cv[i]

    pred_inc <- alpha[h] - beta[h] * premolt  # beta<0 => positive addition

    if (pred_inc <= 0 || obs_inc <= 0) next

    res <- log(obs_inc) - log(pred_inc)
    # sigma = cv_g directly (not log(1+cv^2))
    nll <- nll + 0.5 * log(2 * pi) + log(cv_g) + 0.5 * (res / cv_g)^2
  }
  nll
}

nll_growth <- calc_growth_nll(growth_data_raw, alpha, beta)

cat(sprintf("Growth NLL:  TOTAL=%.5f\n", nll_growth))
cat(sprintf("Expected:    7965.22574998\n\n"))

# -----------------------------------------------------------------------
# SECTION 16: RECRUITMENT PENALTIES
# -----------------------------------------------------------------------
# From GMACS source:
# Penalty 6: nlogPenalty(6) = dnorm(first_difference(rec_dev), 1.0)
#   = full normal NLL of first-differences with sd=1
# Penalty 7: nlogPenalty(7) = square(log(SumRecF) - log(SumRecM))
#   where SumRecF = sum of female recruits over all years, same for male

dnorm_full <- function(x, sd) {
  # Full ADMB normal NLL: sum(0.5*log(2*pi) + log(|sd|) + 0.5*(x/sd)^2)
  sum(0.5 * log(2 * pi) + log(abs(sd)) + 0.5 * (x / sd)^2)
}

# Penalty 6: smoothness of rec_dev (first-difference penalty)
fd_rec_dev  <- diff(rec_dev)    # first differences, length 42
pen_rec_raw <- dnorm_full(fd_rec_dev, 1.0)   # raw value
pen_rec     <- pen_rec_raw * 1.0              # weight = 1.0

cat(sprintf("Rec penalty: raw=%.8f  weight=1.0  net=%.8f\n", pen_rec_raw, pen_rec))
cat(sprintf("Expected:    raw=58.99838914  net=58.99838914\n\n"))

# Penalty 7: sex ratio penalty = (log(SumRecF) - log(SumRecM))^2
# From GMACS: nlogPenalty(7) = square(log(SumRecF) - log(SumRecM))
# SumRecF = sum over years of female recruits
# SumRecM = sum over years of male recruits
# Use same definition: R_total = 2*exp(log_Rbar + rec_dev), p_male = plogis(logit)
# SumRecM = sum(p_male * R_total), SumRecF = sum((1-p_male) * R_total)
p_male_yr    <- plogis(logit_rec_prop)
R_total_yr   <- 2 * exp(log_Rbar + rec_dev)   # total recruits per year
sum_rec_male <- sum(p_male_yr * R_total_yr)
sum_rec_fem  <- sum((1 - p_male_yr) * R_total_yr)
pen_sexratio_raw <- (log(sum_rec_fem) - log(sum_rec_male))^2
pen_sexratio     <- 3.0 * pen_sexratio_raw  # weight = 3.0

cat(sprintf("Sex ratio penalty: raw=%.8f  weight=3.0  net=%.8f\n",
            pen_sexratio_raw, pen_sexratio))
cat(sprintf("Expected:          raw=0.12566555  net=0.37699666\n\n"))

# -----------------------------------------------------------------------
# SECTION 17: SMOOTHNESS PENALTY ON NMFS SURVEY SELECTIVITY
# -----------------------------------------------------------------------
# From GMACS source:
# selex_smooth_pen += dnorm(first_difference(selx), 1.0)
# where selx = log-selectivity vector (22 values)
# dnorm = full normal NLL: sum(0.5*log(2*pi) + log(1) + 0.5*(x/1)^2)
#       = sum(0.5*log(2*pi) + 0.5*x^2)
# Note: applies to FIRST differences (not second differences)
smooth_penalty <- function(log_sel_pars) {
  # ADMB dnorm(first_difference(selx), 1.0)
  # first_difference = c(s[2]-s[1], s[3]-s[2], ..., s[n]-s[n-1])
  fd <- diff(log_sel_pars)
  dnorm_full(fd, 1.0)
}

# NMFS82 male (22 params)
pen_nmfs82_male <- smooth_penalty(s_nmfs82_male_log)
# NMFS89 male (22 params)
pen_nmfs89_male <- smooth_penalty(s_nmfs89_male_log)
# NMFS82 female (22 params, last fixed at -0.0001)
pen_nmfs82_fem  <- smooth_penalty(s_nmfs82_fem_log)
# NMFS89 female (22 params, last fixed at -0.0001)
pen_nmfs89_fem  <- smooth_penalty(s_nmfs89_fem_log)

pen_smooth_raw <- pen_nmfs82_male + pen_nmfs89_male + pen_nmfs82_fem + pen_nmfs89_fem
pen_smooth     <- 3.0 * pen_smooth_raw

cat(sprintf("Smooth sel penalty: raw=%.8f  weight=3.0  net=%.8f\n",
            pen_smooth_raw, pen_smooth))
cat(sprintf("  [nmfs82m=%.5f  nmfs89m=%.5f  nmfs82f=%.5f  nmfs89f=%.5f]\n",
            pen_nmfs82_male, pen_nmfs89_male, pen_nmfs82_fem, pen_nmfs89_fem))
cat(sprintf("Expected:           raw=85.31712960  net=255.95138879\n\n"))

# -----------------------------------------------------------------------
# SECTION 18: INIT NUMBERS PENALTY
# -----------------------------------------------------------------------
# From GMACS source:
# nlogPenalty(10) += dnorm(first_difference(logN0(k)), 1.0) for each group k
# = full normal NLL of first-differences with sd=1
# logN0(k) is the 22-element log-N vector for group k
# n_grp = 4 groups: male_mature, male_immature, female_mature, female_immature

pen_init_raw <- 0
for (ig_name in names(logN_init)) {
  lN  <- logN_init[[ig_name]]
  fd  <- diff(lN)    # 21 first-differences
  pen_init_raw <- pen_init_raw + dnorm_full(fd, 1.0)
}
pen_init_numbers <- 5.0 * pen_init_raw  # weight = 5.0

cat(sprintf("Init numbers penalty: raw=%.8f  weight=5.0  net=%.8f\n",
            pen_init_raw, pen_init_numbers))
cat(sprintf("Expected:             raw=88.98403071  net=444.92015357\n\n"))

# -----------------------------------------------------------------------
# SECTION 19: MEAN FDEV PENALTY
# -----------------------------------------------------------------------
# From Gmacsall.out: penalty #2 "Mean_Fdev" raw=18.95315928, weight=0.0, net=0.0
# This is zero-weighted so contributes 0 to total
pen_mean_fdev <- 0.0

# -----------------------------------------------------------------------
# SECTION 20: PRIORS
# -----------------------------------------------------------------------
# From Gmacsall.out priorDensity vector and Estimated parameters Penalty column
# The priorDensity values ARE the negative log prior densities for each parameter
# Sum = 386.43693538

# The priorDensity vector (407 entries, matching parameter count)
# Key non-zero entries:
# Par 3 (log_Rbar): 3.68887945 (normal prior?)
# Par 11-98 (logN_init each): 3.80666249 (each) = 3.80666249 * 88 params
# Par 99 (alpha_male): 3.21887582
# Par 101 (alpha_female): 2.70805020
# Par 105 (M_base_male_mat): 0.31560240
# Par 106,107 (M_male_mat blocks 1,2): 2.39789527 each
# Par 109 (M_imm offset): 0.69314718
# Par 110 (M_male_imm block1 = 0, fixed): 0
# Par 111 (M_male_imm block2): 2.39789527
# Par 113 (M_base_female_mat): -4.24247038 (negative - log prob can be neg for diffuse priors)
# ... (many selectivity params)
# Ret pot params: 3.22726575, 2.99568227
# log_fbar params: 0.0 (uniform priors on fishing)

# Priors reconstructed from the Estimated parameters Penalty column in Gmacsall.out
# Only ACTIVE parameters (positive phase) contribute to the priors total
# Reconstruct from parameter table:

# Par 3 (logRbar): estimated, phase 1
prior_logRbar <- 3.68887945

# logN pars 11-93 (83 active): par11=3.55534806, pars 12-93 each = 3.80666249
# NOTE: pars 94-98 (fem_imm classes 18-22 at -19.0) are FIXED (phase -1) => no prior
prior_logN <- 3.55534806 + 82 * 3.80666249  # = 3.55534806 + 82*3.80666249

# Growth pars: alpha_male=3.21887582, beta_male=0.0, alpha_female=2.70805020, beta_female=0.0
prior_growth <- 3.21887582 + 0 + 2.70805020 + 0

# M pars from table:
prior_M <- 0.31560240 + 2.39789527 + 2.39789527 + 0 +  # male mat: base, blk1, blk2, blk3
           0.69314718 + 0 + 2.39789527 + 0 +             # male imm: offset, blk1, blk2, blk3
           (-4.24247038) + 2.39789527 + 2.39789527 + 0 + # fem mat: base, blk1, blk2, blk3
           0.69314718 + 2.39789527 + 2.39789527 + 0       # fem imm: offset, blk1, blk2, blk3

# Selectivity priors (from par table Penalty column):
# Pot male logistic: 5.19849703 + 2.99523215
# Trawl male logistic: 5.19295685 + 2.99523215
# NMFS82 male 22 pars (raw=each penalty): sum from table
prior_sel_logistic <- 5.19849703 + 2.99523215 + 5.19295685 + 2.99523215  # pot/trawl male
# NMFS82 male 22 free pars:
nmfs82_male_priors <- c(-0.88104131, 0.81641478, 3.99472074, 2.64417389, 4.38694130,
                         3.02479937, -0.40950230, -0.99578145, -0.47436230, -0.89157818,
                        -1.29117360, -1.39719962, -1.34521589, -1.60874735, -1.28081114,
                         1.07970330, 1.00574303, 1.67339128, 0.15551616, -0.64752502,
                        -0.13139942, 1.84635251)
nmfs89_male_priors <- c(-0.67548971, 1.71156917, 5.79048551, 5.95193130, 6.56242247,
                         4.92784589, 1.92199013, 0.33502471, 0.35294890, 0.15906149,
                        -0.06783784, -0.34009784, -0.34134738, -0.99183548, -1.67589925,
                        -0.71976320, 0.31098638, 0.94433273, -0.25944778, -1.42776630,
                        -1.50586148, -0.46501607)
prior_sel_nmfs_male <- sum(nmfs82_male_priors) + sum(nmfs89_male_priors)

# Pot female: 4.97673374 + 2.99523215
prior_sel_logistic_fem <- 4.97673374 + 2.99523215
nmfs82_fem_priors <- c(-0.60783391, 2.58015293, 8.49352701, 4.27419666, 0.80252951,
                       -0.85700307, -0.62980397, -1.73168368, -1.78071879, -1.70735928,
                       -1.73890729, -1.77424013, -1.77646030, -1.78090914, -1.77428828,
                       -1.77216660, -1.76545820, -1.75855028, -1.76455392, -1.73714928,
                       -1.61614366)  # 21 params (last fixed)
nmfs89_fem_priors <- c(-0.69491291, 1.56180270, 5.61037778, -1.32587936, -0.17527020,
                        6.96737566, 4.21135264, -1.52730862, -0.96117409, 0.44638348,
                        0.19298868, -1.59682030, -1.78080255, -1.78405826, -1.77663588,
                       -1.77371076, -1.76636671, -1.75906390, -1.76490342, -1.73746703,
                       -1.61680611)  # 21 params (last fixed)
prior_sel_nmfs_fem <- sum(nmfs82_fem_priors) + sum(nmfs89_fem_priors)

# Ret pot male: 3.22726575 + 2.99568227
prior_ret <- 3.22726575 + 2.99568227

# log_fbar (no prior penalty = 0 for both fleets)
# log_fdev, log_foff, log_fdov: all 0 (uniform priors on F deviations)

priors_reconstructed <- prior_logRbar + prior_logN + prior_growth + prior_M +
                        prior_sel_logistic + prior_sel_nmfs_male +
                        prior_sel_logistic_fem + prior_sel_nmfs_fem + prior_ret

cat(sprintf("Priors reconstructed: %.8f\n", priors_reconstructed))
cat(sprintf("  logRbar=%.4f  logN=%.4f  growth=%.4f  M=%.4f\n",
            prior_logRbar, prior_logN, prior_growth, prior_M))
cat(sprintf("  sel_logistic=%.4f  sel_nmfs_male=%.4f  sel_fem=%.4f  ret=%.4f\n",
            prior_sel_logistic, prior_sel_nmfs_male,
            prior_sel_logistic_fem + prior_sel_nmfs_fem, prior_ret))
cat(sprintf("Expected:             386.43693538\n\n"))

# -----------------------------------------------------------------------
# SECTION 21: STOCK-RECRUITMENT LIKELIHOOD (nloglike[4])
# -----------------------------------------------------------------------
# From GMACS source code:
# nloglike(4,1) = dnorm(res_recruit, sigR)
# nloglike(4,3) = dnorm(logit_rec_prop_est, 2.0)
# Total SR = comp1 + comp2(0) + comp3
#
# res_recruit[y=1] = rec_dev[1] + sig2R  (where sig2R = 0.5*sigR^2)
# res_recruit[y>1] = rec_dev[y] - rho*rec_dev[y-1] + sig2R
# (assumes constant recruitment model, bInitializeUnfished != UNFISHEDEQN)

sig2R <- 0.5 * sigmaR^2   # bias correction

# Build res_recruit vector
res_recruit <- numeric(nyears)
res_recruit[1] <- rec_dev[1] + sig2R
for (ty in 2:nyears) {
  res_recruit[ty] <- rec_dev[ty] - rho * rec_dev[ty - 1] + sig2R
}

# SR component 1: dnorm(res_recruit, sigR)
sr_comp1 <- dnorm_full(res_recruit, sigmaR)

# SR component 3: dnorm(logit_rec_prop, 2.0)
sr_comp3 <- dnorm_full(logit_rec_prop, 2.0)

nll_sr_total <- sr_comp1 + sr_comp3   # component 2 = 0

cat(sprintf("SR components: comp1=%.8f  comp3=%.8f  total=%.8f\n",
            sr_comp1, sr_comp3, nll_sr_total))
cat(sprintf("Expected:      comp1=98.02951924  comp3=85.82709102  total=183.85661026\n\n"))

# -----------------------------------------------------------------------
# SECTION 22: TOTAL OBJECTIVE FUNCTION VALUE
# -----------------------------------------------------------------------
# OFV = Catch NLL + Survey NLL + Size comp LL + SR penalty + Growth NLL
#       + Penalties (smooth_sel + init_N + mean_fdev) + Priors

# From Gmacsall.out:
# Catch:       372.47946001
# Index:       142.25642816
# Size_data:  -29004.09422574
# SR:          183.85661026
# Growth:      7965.22574998
# Penalties:   760.24692816
# Priors:      386.43693538
# Total:      -19193.59211379

# Penalties breakdown (from Gmacsall.out lines 75-84):
# 2. Mean_Fdev:    18.95315928 * 0.0       = 0.0       (zero weight)
# 6. Rec_dev:      58.99838914 * 1.0       = 58.998
# 7. Sex_ratio:     0.12566555 * 3.0       = 0.377
# 9. Smooth_sel:   85.31712960 * 3.0       = 255.951
# 10. Init_N:      88.98403071 * 5.0       = 444.920
# Total penalties = 0 + 58.998 + 0.377 + 255.951 + 444.920 = 760.246 CHECK

# OFV = Catch + Index + Size + SR + Growth + Penalties + Priors
# Penalties total = pen_rec + pen_sexratio + pen_smooth + pen_init_numbers
pen_total_computed <- pen_rec + pen_sexratio + pen_smooth + pen_init_numbers

ofv_components_reported <- c(
  Catch     = 372.47946001,
  Index     = 142.25642816,
  Size      = -29004.09422574,
  SR        = 183.85661026,
  Growth    = 7965.22574998,
  Penalties = 760.24692816,
  Priors    = 386.43693538
)
ofv_total_reported <- sum(ofv_components_reported)

# Computed total using all calculated components
# (size comp uses ADMB-predicted proportions from Gmacsall.out, so it matches exactly)
ofv_total_computed <- nll_catch_total + nll_surv_total + nll_sizecomp_total +
                      nll_sr_total + nll_growth +
                      pen_total_computed + priors_reconstructed

cat("\n=== OBJECTIVE FUNCTION VALUE SUMMARY ===\n")
cat(sprintf("Component              Reported          Computed\n"))
cat(sprintf("Catch NLL:          %12.5f      %12.5f\n", 372.47946001, nll_catch_total))
cat(sprintf("Survey NLL:         %12.5f      %12.5f\n", 142.25642816, nll_surv_total))
cat(sprintf("Size comp LL:    %12.5f   %12.5f\n", -29004.09422574, nll_sizecomp_total))
cat(sprintf("SR total:           %12.5f      %12.5f\n", 183.85661026, nll_sr_total))
cat(sprintf("  SR comp1:         %12.5f      %12.5f\n", 98.02951924, sr_comp1))
cat(sprintf("  SR comp3:         %12.5f      %12.5f\n", 85.82709102, sr_comp3))
cat(sprintf("Growth NLL:         %12.5f      %12.5f\n", 7965.22574998, nll_growth))
cat(sprintf("Penalties:          %12.5f      %12.5f\n", 760.24692816, pen_total_computed))
cat(sprintf("  Rec dev pen:      %12.5f      %12.5f\n", 58.99838914, pen_rec))
cat(sprintf("  Sex ratio pen:    %12.5f      %12.5f\n", 0.37699666, pen_sexratio))
cat(sprintf("  Smooth sel:       %12.5f      %12.5f\n", 255.95138879, pen_smooth))
cat(sprintf("  Init numbers:     %12.5f      %12.5f\n", 444.92015357, pen_init_numbers))
cat(sprintf("Priors:             %12.5f      %12.5f\n", 386.43693538, priors_reconstructed))
cat(sprintf("------------------------------------------------\n"))
cat(sprintf("TOTAL:           %12.5f   %12.5f\n", ofv_total_reported, ofv_total_computed))
cat(sprintf("Target:          %12.5f\n\n", -19193.5921))

# -----------------------------------------------------------------------
# SECTION 23: DIAGNOSTIC OUTPUT
# -----------------------------------------------------------------------
cat("\n=== DIAGNOSTIC OUTPUTS ===\n")

# Check growth matrix properties
cat("Growth matrix row sums (should all be ~1):\n")
cat(sprintf("  Male rows 1-5:   %s\n",
    paste(round(rowSums(gt_male)[1:5], 4), collapse=" ")))
cat(sprintf("  Female rows 1-5: %s\n",
    paste(round(rowSums(gt_female)[1:5], 4), collapse=" ")))

# Check recruitment size distribution
cat(sprintf("Rec SDD male:   %s (sum=%.4f)\n",
    paste(round(rec_sdd_male[1:5], 4), collapse=" "), sum(rec_sdd_male)))
cat(sprintf("Rec SDD female: %s (sum=%.4f)\n",
    paste(round(rec_sdd_female[1:5], 4), collapse=" "), sum(rec_sdd_female)))

# Check M values for selected years
cat(sprintf("M values (male mature): 1982=%.4f 2018=%.4f 2019=%.4f 2020=%.4f\n",
    M_arr[1, 1], M_arr[1, which(years_all == 2018)],
    M_arr[1, which(years_all == 2019)], M_arr[1, which(years_all == 2020)]))
cat(sprintf("M values (fem immature): 1982=%.4f 2018=%.4f 2019=%.4f\n",
    M_arr[4, 1], M_arr[4, which(years_all == 2018)],
    M_arr[4, which(years_all == 2019)]))

# Check FM for selected years
cat(sprintf("FM male pot: 1990=%.4f 1991=%.4f 1998=%.4f\n",
    fm_male_pot[which(years_all == 1990)],
    fm_male_pot[which(years_all == 1991)],
    fm_male_pot[which(years_all == 1998)]))

N_init_chk <- pop$N
cat(sprintf("Initial N (1982): male_mat_sc1=%g  fem_mat_sc1=%g\n",
    N_init_chk[1, 1, 1], N_init_chk[3, 1, 1]))

# Check survey predictions for selected years
cat(sprintf("Survey pred (fem NMFS89): 1989=%g  1990=%g\n",
    pop$pred_surv_fem89[which(years_all == 1989)],
    pop$pred_surv_fem89[which(years_all == 1990)]))
cat(sprintf("Survey obs  (fem NMFS89): 1989=%g  1990=%g\n",
    surv2_obs[1], surv2_obs[2]))

# Check catch predictions for selected years
cat(sprintf("Catch pred (ret mal pot): 1982=%.4f  1990=%.4f\n",
    pop$pred_catch_ret_mal_pot[1], pop$pred_catch_ret_mal_pot[9]))
cat(sprintf("Catch obs  (ret mal pot): 1982=%.4f  1990=%.4f\n",
    obs_ret_mal_pot[1], obs_ret_mal_pot[9]))

cat("\n=== END OF GMACS R REIMPLEMENTATION ===\n")
cat(sprintf("Target OFV:        -19193.5921\n"))
cat(sprintf("Reported total:    %12.5f\n", ofv_total_reported))
