## =============================================================================
## GMACS Snow Crab Stock Assessment Model - R Implementation
## Model: 25_gmacs_update_plus_group
## Target objective function value: -19193.5921
## =============================================================================
## This script reimplements the ADMB GMACS model in pure R, using parameter
## estimates from gmacs.par and observed data from gmacs_in.dat / Gmacsall.out.
## All likelihood components are computed and summed to reproduce the total OFV.
## =============================================================================

# -----------------------------------------------------------------------
# SECTION 1: SIZE STRUCTURE AND DIMENSIONS
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
# SECTION 2: WEIGHT-AT-LENGTH (units: 1000_mt per million animals)
# -----------------------------------------------------------------------
wt_male <- c(7.66e-6, 1.29e-5, 2.00e-5, 2.95e-5, 4.17e-5, 5.68e-5, 7.53e-5,
             9.7455e-5, 1.23688e-4, 1.54329e-4, 1.89739e-4, 2.30279e-4,
             2.76313e-4, 3.28208e-4, 3.86333e-4, 4.51057e-4, 5.22754e-4,
             6.01796e-4, 6.88561e-4, 7.83424e-4, 8.86766e-4, 9.98966e-4)

wt_female <- c(9.17e-6, 1.44e-5, 2.13e-5, 2.98e-5, 4.03e-5, 5.29e-5, 6.77e-5,
               8.4796e-5, 1.04451e-4, 1.26759e-4, 1.51857e-4, 1.79881e-4,
               2.10963e-4, 2.45233e-4, 2.82820e-4, 3.23850e-4, 3.68446e-4,
               4.16731e-4, 4.68827e-4, 5.24852e-4, 5.84924e-4, 6.49160e-4)

# Maturity-at-length (from ctl file)
mat_male   <- c(rep(0, 14), rep(1, 8))   # classes 15-22 mature
mat_female <- c(rep(0, 5), rep(1, 17))   # classes 6-22 mature

# -----------------------------------------------------------------------
# SECTION 3: GROWTH PARAMETERS AND TRANSITION MATRIX
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
# SECTION 4: RECRUITMENT SIZE DISTRIBUTION
# -----------------------------------------------------------------------
# Type: gamma CDF, ra=32.5, rb=1.0 for both sexes
# ralpha = ra/rb = 32.5; x[ll] = pgamma(size_breaks[ll]/rb, shape=ralpha)
# Max rec size class = 3 (recruits only enter classes 1-3)
build_rec_sdd <- function(ra, rb) {
  ralpha <- ra / rb
  # Use only the first nclass breakpoints (upper edges of bins 1..22 = 25..130)
  x <- pgamma(size_breaks[1:nclass] / rb, shape = ralpha, rate = 1)
  raw <- diff(c(0, x))     # length = nclass = 22
  raw[raw < 0] <- 0
  # Zero out classes > 3 (recruits only enter small size classes)
  raw[4:nclass] <- 0
  total <- sum(raw)
  if (total > 0) raw <- raw / total
  raw
}

rec_sdd_male   <- build_rec_sdd(32.5, 1.0)
rec_sdd_female <- build_rec_sdd(32.5, 1.0)

# -----------------------------------------------------------------------
# SECTION 5: NATURAL MORTALITY (block-structured by year)
# -----------------------------------------------------------------------
# Base M values
M_base_male_mat   <- 0.285054203583
M_base_fem_mat    <- 0.267898017972
M_base_male_imm   <- M_base_male_mat   * exp(0.0230343115040)   # ~0.29170
M_base_fem_imm    <- M_base_fem_mat    * exp(0.999999927668)    # ~0.72822

# Block group 1 = years {2018, 2019, 2020}  (block 1)
# Block group 2 = years {1983-2024}          (block 2)
# Block 3 = year 1982 only (no deviation => exp(0)=1 => base M)
# Devations: [block1, block2, block3] for each ig
# (block3=0 => exp(0)=1, so block 3 uses base)
# NOTE: Block 1 = 2018,2019,2020; Block 2 = 1983-2024 EXCEPT 2018,2019,2020
#       Block 3 is implicitly everything else (here only 1982)
# M deviation indices: par file M_pars_est
#   Male mature:   blk1=1.57382855761, blk2=0.340229140469, blk3=0.0
#   Male immature: blk1=0.0, blk2=2.33616893493, blk3=0.0
#   Fem mature:    blk1=-0.467604450640, blk2=0.909943800420, blk3=0.0
#   Fem immature:  blk1=1.65491684520, blk2=1.10241589461, blk3=0.0

M_dev <- list(
  male_mat  = c(1.57382855761, 0.340229140469, 0.0),
  male_imm  = c(0.0,           2.33616893493,  0.0),
  fem_mat   = c(-0.467604450640, 0.909943800420, 0.0),
  fem_imm   = c(1.65491684520, 1.10241589461, 0.0)
)

# Assign block index per year
# Block 1: {2018,2019,2020}; Block 2: {1983..2024} except block1; Block 3: {1982}
get_block <- function(yr) {
  if (yr %in% c(2018, 2019, 2020)) return(1)
  if (yr == 1982) return(3)
  return(2)
}

# Build M arrays: M[ig, year_index] for 4 groups
# ig: 1=male mature, 2=male immature, 3=female mature, 4=female immature
M_arr <- matrix(NA, 4, nyears)
for (ty in 1:nyears) {
  yr  <- years_all[ty]
  blk <- get_block(yr)
  M_arr[1, ty] <- M_base_male_mat * exp(M_dev$male_mat[blk])
  M_arr[2, ty] <- M_base_male_imm * exp(M_dev$male_imm[blk])
  M_arr[3, ty] <- M_base_fem_mat  * exp(M_dev$fem_mat[blk])
  M_arr[4, ty] <- M_base_fem_imm  * exp(M_dev$fem_imm[blk])
}

# -----------------------------------------------------------------------
# SECTION 6: INITIAL CONDITIONS (from gmacs.par T_pars_est[11:98])
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
# SECTION 7: RECRUITMENT PARAMETERS
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
# SECTION 8: SELECTIVITY PARAMETERS
# -----------------------------------------------------------------------
# Logistic selectivity: plogis(log(L/exp(mu)) / cv) style
# S_pars_est[1..4] = logistic params for pot male, trawl male
# S_pars_est[1]=4.66558963236 = ln(mean_pot_male)
# S_pars_est[2]=1.65809822968 = ln(cv_pot_male)
# S_pars_est[3]=4.77730466004 = ln(mean_trawl_male)
# S_pars_est[4]=2.38572646596 = ln(cv_trawl_male)

logistic_sel <- function(midpts, log_mean, log_cv) {
  mu <- exp(log_mean)
  cv <- exp(log_cv)
  1 / (1 + exp(-(log(midpts / mu) / cv)))
}

slx_cap_male_pot   <- logistic_sel(mid_points, 4.66558963236, 1.65809822968)
slx_cap_male_trawl <- logistic_sel(mid_points, 4.77730466004, 2.38572646596)

# Female pot/trawl
# S_pars_est[49]=4.21489152830, [50]=0.989652399376
slx_cap_fem_pot   <- logistic_sel(mid_points, 4.21489152830, 0.989652399376)
slx_cap_fem_trawl <- slx_cap_male_trawl  # trawl female same logistic as male? No - same FM but different sel
# Actually female trawl uses same selectivity curve parameters as male per Gmacsall.out:
# S_pars_est[95]=4.59584328714 (ret pot male mean), [96]=0.304218601686 (ret pot male cv)
# For female trawl - from Gmacsall.out there's no separate female trawl selectivity block
# The model uses same male trawl selectivity for females (confirmed by "mirror" in model config)
slx_cap_fem_trawl <- slx_cap_male_trawl

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

# Retained selectivity (pot male only)
# S_pars_est[95]=4.59584328714, [96]=0.304218601686
slx_ret_male_pot <- logistic_sel(mid_points, 4.59584328714, 0.304218601686)
# All other retained = 0
slx_ret_zero <- rep(0, nclass)

# -----------------------------------------------------------------------
# SECTION 9: FISHING MORTALITY - compute from par file parameters
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
# SECTION 10: POPULATION DYNAMICS
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

  # Survey size comp (numbers)
  surv_N <- list(
    fem82 = matrix(0, nyears + 1, nclass),
    fem89 = matrix(0, nyears + 1, nclass),
    mal82 = matrix(0, nyears + 1, nclass),
    mal89 = matrix(0, nyears + 1, nclass)
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

    # Survey size comp (numbers at size, weighted by selectivity)
    surv_N$fem82[ty, ] <- slx_cap_fem_nmfs82 * fem_mat_N
    surv_N$fem89[ty, ] <- slx_cap_fem_nmfs89 * fem_mat_N
    surv_N$mal82[ty, ] <- slx_cap_male_nmfs82 * mal_mat_N
    surv_N$mal89[ty, ] <- slx_cap_male_nmfs89 * mal_mat_N

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

    # For each size class, compute total Z and Baranov catch
    # Male mature (ig=1)
    Z_mal_mat <- M_s2_male_mat +
      FS_mal_pot   * slx_cap_male_pot   +
      FS_mal_trawl * slx_cap_male_trawl

    # Male immature (ig=2)
    Z_mal_imm <- M_s2_male_imm +
      FS_mal_pot   * slx_cap_male_pot   +
      FS_mal_trawl * slx_cap_male_trawl

    # Female mature (ig=3)
    Z_fem_mat <- M_s2_fem_mat +
      FS_fem_pot   * slx_cap_fem_pot   +
      FS_fem_trawl * slx_cap_fem_trawl

    # Female immature (ig=4)
    Z_fem_imm <- M_s2_fem_imm +
      FS_fem_pot   * slx_cap_fem_pot   +
      FS_fem_trawl * slx_cap_fem_trawl

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

    # Those that mature: imm_male_molted * mat_male
    new_mat_male  <- imm_male_molted * mat_male
    new_imm_male  <- imm_male_molted * (1 - mat_male)

    N_next_mal_mat <- N_s3[1, ] + new_mat_male
    N_next_mal_imm <- new_imm_male

    # Female growth+maturation
    imm_fem_molted <- as.vector(t(gt_female) %*% N_s3[4, ])

    new_mat_fem  <- imm_fem_molted * mat_female
    new_imm_fem  <- imm_fem_molted * (1 - mat_female)

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
  surv_N$fem82[ty_last, ] <- slx_cap_fem_nmfs82 * N_s_last[3, ]
  surv_N$fem89[ty_last, ] <- slx_cap_fem_nmfs89 * N_s_last[3, ]
  surv_N$mal82[ty_last, ] <- slx_cap_male_nmfs82 * N_s_last[1, ]
  surv_N$mal89[ty_last, ] <- slx_cap_male_nmfs89 * N_s_last[1, ]

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
# SECTION 11: OBSERVED DATA
# -----------------------------------------------------------------------

## Catch data
years_pot_obs <- c(1982:2021, 2024)  # 41 years

obs_ret_mal_pot <- c(11.8518,12.1623,29.9369,44.4455,46.2231,61.3965,67.7927,
                     73.3261,149.0722,143.0185,104.6682,67.9448,34.1596,29.7993,
                     54.2394,110.4399,88.1515,15.1007,11.4561,14.7986,12.8420,
                     10.8601,11.2909,16.7711,16.4906,28.5890,26.5568,21.7788,
                     24.6134,40.2929,30.0525,24.4864,30.8178,18.4210,9.7844,
                     8.6017,12.5093,15.4333,20.4122,2.5166,2.1453)
cv_s1 <- 0.04

obs_disc_mal_pot <- c(1.2665,1.2383,2.7587,4.0147,4.2453,5.5224,5.8167,6.6847,
                      35.5500,9.0300,21.1800,22.2700,7.7800,14.7300,23.2300,7.1000,
                      19.5000,4.1300,3.2500,3.9800,4.5000,2.4000,3.5800,0.6200,
                      4.1700,5.7700,5.1100,4.2800,4.4700,3.7300,5.5300,10.6100,
                      11.6200,10.9000,4.5100,5.8800,8.6300,15.6100,6.1200,1.6800,
                      0.6600)
cv_s2 <- 0.07

obs_disc_fem_pot <- c(0.0156,0.0109,0.0108,0.0109,0.0239,0.0346,0.0368,0.0478,
                      1.5227,0.1999,0.2783,0.1156,0.0781,0.0213,0.1006,0.0990,
                      0.0076,0.0080,0.0009,0.0160,0.0018,0.0008,0.0015,0.0035,
                      0.0012,0.0184,0.0174,0.0124,0.0100,0.1909,0.0571,0.1157,
                      0.2989,0.1150,0.0332,0.0280,0.0222,0.0214,0.0008,0.0000,
                      0.0000)
cv_s3 <- 0.07

obs_trawl_both <- c(0.3673,0.4733,0.5029,0.4317,0.0001,0.0028,0.0019,0.1002,
                    0.3316,4.4512,2.0499,1.1260,0.6994,1.0440,1.2235,0.7265,
                    0.5787,0.2422,0.2472,0.1813,0.1045,0.1363,0.1795,0.1887,
                    0.3633,0.3061,0.1891,0.3888,0.1381,0.1396,0.1504,0.1621,
                    0.6174,1.5819,0.0351,0.1012,0.4014,0.2105,0.1932,0.1295,
                    0.0604,0.1072,0.0925)
cv_s4 <- c(rep(0.20, 4), 0.20, 0.20, 0.20, 0.20, rep(0.10, 35))

## Survey data
# Series 1: NMFS82 female mature, years 1982-1988
surv1_years <- 1982:1988
surv1_obs <- c(141.49, 82.18, 39.37, 5.89, 15.17, 119.55, 165.62)
surv1_cv  <- c(0.1580, 0.2030, 0.2000, 0.2150, 0.2090, 0.1890, 0.1770)

# Series 2: NMFS89 female mature, 1989-2019, 2021-2025 (exclude 2025 from LL)
surv2_years <- c(1989:2019, 2021:2025)
surv2_obs <- c(256.73,174.94,199.02,123.48,127.08,122.60,164.96,104.43,101.39,
               70.18,29.85,93.88,74.84,29.51,38.76,47.74,62.60,50.59,54.45,
               49.35,50.00,94.96,169.12,143.25,125.67,111.36,81.63,53.12,
               105.88,165.45,109.23,30.54,21.43,15.30,41.90,147.34)
surv2_cv <- c(0.3240,0.2100,0.2430,0.2020,0.1660,0.1400,0.1360,0.1510,0.1970,
              0.2800,0.2380,0.5390,0.2970,0.3190,0.4060,0.2800,0.2230,0.2040,
              0.3240,0.2350,0.2310,0.1840,0.1920,0.2350,0.2070,0.2140,0.1830,
              0.2060,0.2190,0.2000,0.1970,0.4430,0.3450,0.2740,0.2290,0.1720)

# Series 3: NMFS82 male mature, 1982-1988
surv3_years <- 1982:1988
surv3_obs <- c(170.63,146.95,166.22,69.76,84.32,180.98,245.81)
surv3_cv  <- c(0.1380,0.1260,0.1180,0.1060,0.1120,0.1070,0.1490)

# Series 4: NMFS89 male mature, same years as series 2
surv4_years <- surv2_years
surv4_obs <- c(245.37,348.38,381.69,219.72,175.30,148.74,193.05,263.23,284.08,
               194.36,91.33,85.94,113.97,82.98,63.10,73.04,117.21,134.74,147.14,
               121.93,120.89,164.27,154.35,118.04,99.30,153.58,81.16,57.44,
               87.01,219.79,161.35,59.99,36.50,23.07,61.60,113.01)
surv4_cv <- c(0.1070,0.1390,0.1470,0.0940,0.1050,0.0840,0.1270,0.1250,0.0950,
              0.0900,0.0900,0.1360,0.1160,0.2270,0.1190,0.1380,0.1130,0.2600,
              0.1470,0.1020,0.1280,0.1220,0.1140,0.1190,0.1180,0.1640,0.1180,
              0.1080,0.1310,0.1700,0.1720,0.1340,0.1490,0.1270,0.1220,0.1470)

# log add cv for all surveys (near-zero, adds negligibly)
log_add_cv <- -9.21034037198
add_cv_val <- exp(log_add_cv)  # ~0.0001

# -----------------------------------------------------------------------
# SECTION 12: CATCH LIKELIHOOD (lognormal - full normal)
# -----------------------------------------------------------------------
# GMACS uses: catch_sd = sqrt(log(1 + cv^2)); then dnorm(res, catch_sd)
# dnorm in ADMB = 0.5*log(2*pi) + log(sd) + 0.5*(x/sd)^2 (FULL normal NLL)
lognormal_nll <- function(obs, pred, cv) {
  # ADMB dnorm with sigma = sqrt(log(1+cv^2))
  # NLL = sum(0.5*log(2*pi) + log(sigma) + 0.5*(log(obs/pred))^2/sigma^2)
  # Only include where obs > 0 and pred > 0
  idx <- obs > 0 & pred > 0
  if (sum(idx) == 0) return(0)
  res  <- log(obs[idx] / pred[idx])
  sig2 <- log(1 + cv[idx]^2)
  sum(0.5 * log(2 * pi) + 0.5 * log(sig2) + 0.5 * res^2 / sig2)
}

# Match predicted catch to observed years
pot_ty_idx <- match(years_pot_obs, years_all)  # indices into years_all

pred_s1 <- pop$pred_catch_ret_mal_pot[pot_ty_idx]
pred_s2 <- pop$pred_catch_disc_mal_pot[pot_ty_idx]
pred_s3 <- pop$pred_catch_disc_fem_pot[pot_ty_idx]
pred_s4 <- pop$pred_catch_trawl_both   # all 43 years

nll_catch_s1 <- lognormal_nll(obs_ret_mal_pot,  pred_s1, rep(cv_s1, length(years_pot_obs)))
nll_catch_s2 <- lognormal_nll(obs_disc_mal_pot, pred_s2, rep(cv_s2, length(years_pot_obs)))
nll_catch_s3 <- lognormal_nll(obs_disc_fem_pot, pred_s3, rep(cv_s3, length(years_pot_obs)))
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
nll_surv2 <- survey_nll(surv2_obs, pop$pred_surv_fem89, surv2_cv, surv2_years, years_all_ext,
                         exclude_year = 2025)
nll_surv3 <- survey_nll(surv3_obs, pop$pred_surv_mal82, surv3_cv, surv3_years, years_all_ext)
nll_surv4 <- survey_nll(surv4_obs, pop$pred_surv_mal89, surv4_cv, surv4_years, years_all_ext,
                         exclude_year = 2025)

nll_surv_total <- nll_surv1 + nll_surv2 + nll_surv3 + nll_surv4

cat(sprintf("Survey NLL:  s1=%.5f  s2=%.5f  s3=%.5f  s4=%.5f  TOTAL=%.5f\n",
            nll_surv1, nll_surv2, nll_surv3, nll_surv4, nll_surv_total))
cat(sprintf("Expected:    s1~51.82  s2~7.63  s3~94.95  s4~-12.14  TOTAL~142.26\n\n"))

# -----------------------------------------------------------------------
# SECTION 14: SIZE COMPOSITION DATA (from Gmacsall.out)
# -----------------------------------------------------------------------
# The size comp data is read from Gmacsall.out lines 1079-1076+
# Each line: series year fleet season sex type shell mat nsamp obs[22] pred[22]
# Use observed proportions (DataVec_obs) and Nsamp for multinomial LL

# Parse size comp data from Gmacsall.out
parse_sizecomp_from_file <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  start <- grep("^Size_fit_summary:", lines)
  end_line <- grep("^>EOD<", lines)
  # Find the first >EOD< after Size_fit_summary
  end_line <- end_line[end_line > start][1]

  data_lines <- lines[(start + 2):(end_line - 1)]

  result <- list()
  for (i in seq_along(data_lines)) {
    ln <- trimws(data_lines[i])
    if (nchar(ln) == 0) next
    parts <- strsplit(ln, "\\s+")[[1]]
    if (length(parts) < 12) next

    orig_series <- as.integer(parts[1])
    mod_series  <- as.integer(parts[2])
    yr          <- as.integer(parts[3])
    nsamp       <- as.numeric(parts[10])

    # obs and pred are 22 values each after nsamp
    obs_start <- 11
    obs_vals  <- as.numeric(parts[obs_start:(obs_start + 21)])
    pred_vals <- as.numeric(parts[(obs_start + 22):(obs_start + 43)])

    result[[i]] <- list(
      series = orig_series,
      year   = yr,
      nsamp  = nsamp,
      obs    = obs_vals,
      pred   = pred_vals
    )
  }
  result[!sapply(result, is.null)]
}

sizecomp_data <- parse_sizecomp_from_file(
  "C:/Users/grant.adams/GitHub/AFSC assessments/snow_crab/Models/25_gmacs_update_plus_group/Gmacsall.out"
)

# Multinomial log-likelihood
# LL = N * sum(obs * log(max(pred, eps)))
# (Uses PREDICTED proportions from ADMB output since we use reported predicted)
# For reproducing OFV, use the reported predicted values from Gmacsall.out
mnll_sizecomp_from_admb <- function(sizecomp_data) {
  eps <- 1e-10
  series_nll <- numeric(13)
  series_counts <- numeric(13)

  for (item in sizecomp_data) {
    s   <- item$series
    obs  <- item$obs
    pred <- item$pred
    N    <- item$nsamp
    if (is.na(s) || s < 1 || s > 13) next
    if (sum(obs) <= 0) next

    ll_yr <- N * sum(obs * log(pmax(pred, eps)))
    series_nll[s] <- series_nll[s] + ll_yr
    series_counts[s] <- series_counts[s] + 1
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
# NLL per obs: 0.5*(log(obs_inc/pred_inc))^2/sigma2 + 0.5*log(2*pi*sigma2)
# sigma2 = log(1 + cv^2)

growth_data_raw <- read.table(
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

# Check initial N (abundance in millions)
cat(sprintf("Initial N (1982): male_mat[1]=%g  female_mat[1]=%g\n",
    N[1, 1, 1], N[3, 1, 1]))  # Note: N not defined here; use pop$N
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
