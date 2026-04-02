# ==============================================================================
# SNOW CRAB CATCH DATA PROCESSING SCRIPT
# This script processes raw catch, discard, size composition, and growth data
# to generate derived datasets ready for assessment models (.DAT files).
# ==============================================================================

# --- 1. Setup and Library Loading ----
library(dplyr)
library(ggplot2)
library(reshape2)
library(png)
library(grid)
library(tidyr)

# --- 2. Load Raw Catch Data ----
ret_cat <- read.csv("data/new_catch/retained_catch.csv") # Snow and hybrids
tot_cat <- read.csv("data/new_catch/total_catch.csv") # Snow only
disc    <- read.csv("data/new_catch/bssc_discards.csv")
tot_cat_hybrid    <- read.csv("data/hybrid_catch/hybrid_total_catch.csv") # Hybrid only

# Extract fishery codes (first two characters)
ret_cat$fish <- substring(ret_cat$fishery, 1, 2)


# --- 3. Combine Hybrid and Snow Catch Data ----
tot_cat_hybrid <- tot_cat_hybrid %>%
  dplyr::rename(count_h = count,
                cpue_h = cpue,
                avg_wt_h = avg_wt,
                total_catch_n_h = total_catch_n,
                total_catch_wt_h = total_catch_wt)


tot_cat_snow <- tot_cat %>%
  dplyr::rename(count_s = count,
                cpue_s = cpue,
                avg_wt_s = avg_wt,
                total_catch_n_s = total_catch_n,
                total_catch_wt_s = total_catch_wt)

tot_cat <- merge(tot_cat_hybrid, tot_cat_snow, all = TRUE) %>%
  dplyr::mutate(total_catch_wt_s = ifelse(is.na(total_catch_wt_s), 0, total_catch_wt_s),
                total_catch_wt_h = ifelse(is.na(total_catch_wt_h), 0, total_catch_wt_h),
                total_catch_wt = total_catch_wt_s + total_catch_wt_h
  )


# --- 4. Process Female and Male Total Catch ----
# Filter females
fems <- filter(tot_cat, group == 'female')
fems$fish <- substring(fems$fishery, 1, 2)

# Filter males, aggregate total catch by year and fishery, and convert to metric tons
males <- filter(tot_cat, group != 'female') %>%
  group_by(crab_year, fishery) %>%
  dplyr::summarize(tot_cat = sum(total_catch_wt) / 1000, .groups = 'drop')
males$fish <- substring(males$fishery, 1, 2)

# Plot Male Discards
png("plots/male_discards_snow_and_hybrids.png")
ggplot(males) +
  geom_line(aes(x = crab_year, y = tot_cat, col = fish, group = fish)) +
  theme_bw() + 
  ylab("Total catch")
dev.off()

# --- 5. Calculate Directed Fishery Discards ----
# Merge retained catch with male total catch specifically for the directed fishery ("QO")
directed_discard <- merge(ret_cat, filter(males, fish == "QO"))
directed_discard$tot_retained_wt <- directed_discard$tot_retained_wt / 1000
directed_discard$subtract_disc <- directed_discard$tot_cat - directed_discard$tot_retained_wt  

# Estimate missing discards using the median discard rate from years with valid data
chrp <- filter(directed_discard, subtract_disc > 0)
med_disc_rate <- median(chrp$subtract_disc / chrp$tot_cat)

directed_discard$use_disc <- directed_discard$subtract_disc
missing_idx <- which(directed_discard$subtract_disc < 0)
directed_discard$use_disc[missing_idx] <- directed_discard$tot_retained_wt[missing_idx] * med_disc_rate

# Write derived directed discards (males and females)
write.csv(
  cbind(directed_discard$crab_year, directed_discard$use_disc, filter(fems, fish == 'QO')$total_catch_wt / 1000),
  "data/derived/dir_disc_m_f_snow_and_hybrid.csv",
  row.names = FALSE
)


# --- 6. Process Directed Size Compositions ----
ret_cat_sc <- read.csv("data/new_catch/retained_catch_composition.csv")
tot_cat_sc <- read.csv("data/new_catch/directed_total_composition.csv")
ret_cat_hy <- read.csv("data/hybrid_catch/hybrid_retained_catch_comp.csv")
tot_cat_hy <- read.csv("data/hybrid_catch/hybrid_total_catch_comp.csv")


# Combine Hybrid and Snow Catch Data
ret_cat_sc <- ret_cat_sc %>%
  full_join(ret_cat_hy %>%
              dplyr::rename(total_h = total)
  ) %>%
  mutate(total_h = ifelse(is.na(total_h), 0, total_h),
         total = ifelse(is.na(total), 0, total),
         total = total + total_h)


tot_cat_sc <- tot_cat_sc %>%
  full_join(tot_cat_hy %>%
              dplyr::rename(total_h = total)
  ) %>%
  mutate(total_h = ifelse(is.na(total_h), 0, total_h),
         total = ifelse(is.na(total), 0, total),
         total = total + total_h)

# Define uniform midpoints and bin edges for size compositions
midpoints <- seq(27.5, 132.5, by = 5)
bin_width <- 5
bin_edges <- c(midpoints - bin_width / 2, last(midpoints) + bin_width / 2)

# Helper function to bin and normalize size comp data
process_size_comps <- function(df, size_breaks, size_labels, right_closed = FALSE) {
  df %>%
    mutate(bin = cut(size, breaks = size_breaks, include.lowest = TRUE, right = right_closed, labels = size_labels)) %>%
    group_by(crab_year, bin) %>%
    dplyr::summarize(tot_crab_sum = sum(tot_crab), .groups = 'drop') %>%
    group_by(crab_year) %>%
    mutate(
      total_crab_year = sum(tot_crab_sum),
      normalized_crab = tot_crab_sum / total_crab_year
    ) %>%
    ungroup()
}

# * 6a. Retained Size Composition
data_ret <- ret_cat_sc %>%
  group_by(crab_year, size) %>%
  dplyr::summarize(tot_crab = sum(total), .groups = 'drop')

norm_ret <- process_size_comps(data_ret, bin_edges, midpoints, right_closed = FALSE)

# Format for output (insert zeroes for unrepresented size classes)
out_ret <- dcast(norm_ret, crab_year ~ bin, value.var = 'normalized_crab')
out_ret[is.na(out_ret)] <- 0
write.csv(out_ret[, -1], "data/derived/ret_sc_and_hy.csv", row.names = out_ret[, 1])

# * 6b. Total Female Size Composition
data_tot_f <- filter(tot_cat_sc, sex == 2) %>%
  group_by(crab_year, size) %>%
  dplyr::summarize(tot_crab = sum(total), .groups = 'drop')

norm_tot_f <- process_size_comps(data_tot_f, bin_edges, midpoints, right_closed = FALSE)

# Format for output (insert zeroes for unrepresented size classes)
out_tot_f <- dcast(norm_tot_f, crab_year ~ bin, value.var = 'normalized_crab')
out_tot_f[is.na(out_tot_f)] <- 0
write.csv(out_tot_f[, -1], "data/derived/tot_sc_and_hy_f.csv", row.names = out_tot_f[, 1])

# * 6c. Total Male Size Composition
data_tot_m <- filter(tot_cat_sc, sex == 1) %>%
  group_by(crab_year, size) %>%
  dplyr::summarize(tot_crab = sum(total), .groups = 'drop')

norm_tot_m <- process_size_comps(data_tot_m, bin_edges, midpoints, right_closed = TRUE)
out_tot_m <- dcast(norm_tot_m, crab_year ~ bin, value.var = 'normalized_crab')
out_tot_m[is.na(out_tot_m)] <- 0
write.csv(out_tot_m[, -1], "data/derived/tot_sc_and_hy_m.csv", row.names = out_tot_m[, 1])


# --- 7. Process Observer Bycatch Length Composition (Current Year) ----
# Data comes from AKfin Observer data tab ("NORPAC Length Report - Haul & Length")
LenDatBig <- read.csv("data/norpac_length_report/norpac_length_report.csv", skip = 6)
LenDatBig$Haul.Offload.Date <- strptime(LenDatBig$Haul.Offload.Date, format = "%d-%b-%y")

# Filter for the current crab year
LenDat <- LenDatBig[LenDatBig$Haul.Offload.Date >= "2024-07-01" & 
                      LenDatBig$Haul.Offload.Date <= "2025-06-30" & 
                      LenDatBig$Species.Name == "OPILIO TANNER CRAB", ]

LengthBins <- seq(25, 135, 5)
upperBnd <- 130

# Function to extract frequencies for bycatch
get_bycatch_freqs <- function(dat, bins, sex, upper_bound) {
  freqs <- numeric(length(bins) - 1)
  for(y in 1:(length(bins) - 1)) {
    freqs[y] <- sum(dat$Frequency[dat$Length..cm. >= bins[y] & dat$Length..cm. < bins[y+1] & dat$Sex == sex])
  }
  # Pool tail data into the upper bound bin
  ub_idx <- which(bins == upper_bound)
  freqs[ub_idx] <- sum(freqs[ub_idx:length(freqs)])
  freqs <- freqs[1:ub_idx]
  return(freqs)
}

BycatchFem <- get_bycatch_freqs(LenDat, LengthBins, "F", upperBnd)
BycatchMale <- get_bycatch_freqs(LenDat, LengthBins, "M", upperBnd)

# Normalize and write output
by_f_out <- BycatchFem / sum(BycatchFem)
by_m_out <- BycatchMale / sum(BycatchMale)
write.table(rbind(by_f_out, by_m_out), "data/derived/bycatch_len_comps_f_then_m.txt", row.names = FALSE, col.names = FALSE)


# --- 8. Process Observer Bycatch Length Composition (All Years) ----
use_yrs <- seq(1991, 2025)
bycatch_fem_sc <- matrix(ncol = length(BycatchFem), nrow = 0)
bycatch_male_sc <- matrix(ncol = length(BycatchMale), nrow = 0)

for(x in 1:(length(use_yrs) - 1)) {
  start_date <- paste0(use_yrs[x], "-07-01")
  end_date <- paste0(use_yrs[x] + 1, "-06-30")
  
  yr_dat <- LenDatBig[LenDatBig$Haul.Offload.Date >= start_date & 
                        LenDatBig$Haul.Offload.Date <= end_date & 
                        LenDatBig$Species.Name == "OPILIO TANNER CRAB", ]
  
  bf <- get_bycatch_freqs(yr_dat, LengthBins, "F", upperBnd)
  bm <- get_bycatch_freqs(yr_dat, LengthBins, "M", upperBnd)
  
  # Avoid division by zero if year is missing data
  bf_norm <- if(sum(bf) > 0) round(bf / sum(bf), 3) else rep(0, length(bf))
  bm_norm <- if(sum(bm) > 0) round(bm / sum(bm), 3) else rep(0, length(bm))
  
  bycatch_fem_sc <- rbind(bycatch_fem_sc, bf_norm)
  bycatch_male_sc <- rbind(bycatch_male_sc, bm_norm)
}

write.table(bycatch_fem_sc, "data/derived/bycatch_len_comps_f.txt", row.names = FALSE, col.names = FALSE)
write.table(bycatch_male_sc, "data/derived/bycatch_len_comps_m.txt", row.names = FALSE, col.names = FALSE)


# --- 9. Process Bycatch Extrapolated Numbers & Weights ----
# Data comes from AKfin Observer data tab ("NORPAC catch Report")
bycatch_dat <- read.csv("data/norpac_catch_report/norpac_catch_report.csv", skip = 6)
bycatch_dat$Haul.Date <- substr(strptime(bycatch_dat$Haul.Date, format = "%d-%b-%y"), 1, 10)
bycatch_dat$crab.year <- bycatch_dat$Year

bycatch_year <- sort(unique(bycatch_dat$Year))
bycatch_wt_tot <- numeric(length(bycatch_year) - 1)

for(y in 1:(length(bycatch_year) - 1)) {  
  start_date <- paste0(bycatch_year[y], "-07-01")
  end_date <- paste0(bycatch_year[y] + 1, "-06-30")
  
  yr_dat <- bycatch_dat[bycatch_dat$Haul.Date >= start_date & 
                          bycatch_dat$Haul.Date <= end_date & 
                          bycatch_dat$Species.Name == "OPILIO TANNER CRAB", ]
  
  bycatch_wt_tot[y] <- sum(yr_dat$Extrapolated.Weight..kg., na.rm = TRUE)  
}

# --- 10. Apply Mortality Rates to Bycatch ----
# Calculate all crab fishery bycatch and apply 30% handling mortality
all_crab_bycatch <- filter(males, fish != "QO") %>%
  group_by(crab_year) %>%
  dplyr::summarize(all_crab_bycatch = sum(tot_cat, na.rm = TRUE) * 0.3, .groups = 'drop')

# Calculate trawl bycatch and apply 80% handling mortality
nondir <- data.frame(
  crab_year = bycatch_year[1:(length(bycatch_year)-1)],
  bycatch_wt_tot = (bycatch_wt_tot / 1000000) * 0.8
)

all_nondir_bycatch <- merge(all_crab_bycatch, nondir)
all_nondir_bycatch$tot_nondir <- all_nondir_bycatch$all_crab_bycatch + all_nondir_bycatch$bycatch_wt_tot
write.csv(all_nondir_bycatch, "data/derived/bycatch_wt_total.csv", row.names = FALSE)

# Plot Bycatch by Gear Type
in_dat <- bycatch_dat[, -24]

# Assign crab years properly based on July 1 cutoff
for(y in 1:(length(bycatch_year) - 1)) {
  start_date <- paste0(bycatch_year[y], "-07-01")
  end_date <- paste0(bycatch_year[y] + 1, "-06-30")
  in_dat$crab.year[in_dat$Haul.Date >= start_date & in_dat$Haul.Date <= end_date] <- bycatch_year[y]
}

gear_plot_dat <- in_dat %>%
  group_by(crab.year, Gear.Description) %>%
  dplyr::summarise(Bycatch = sum(Extrapolated.Number, na.rm = TRUE), .groups = 'drop') %>%
  mutate(
    Year = as.numeric(crab.year),
    Gear.Description = case_when(
      Gear.Description == "NON PELAGIC" ~ "NON-PELAGIC TRAWL",
      Gear.Description == "PELAGIC" ~ "PELAGIC TRAWL",
      TRUE ~ Gear.Description
    )
  )

png("plots/bycatch.png", height = 8, width = 8, res = 400, units = 'in')
ggplot(gear_plot_dat) +
  geom_line(aes(x = crab.year, y = Bycatch, col = Gear.Description)) +
  geom_point(aes(x = crab.year, y = Bycatch, col = Gear.Description)) +
  theme_bw() + 
  theme(legend.position = c(.8, .8))
dev.off()


# --- 11. Process Growth Data ----
grow <- read.csv("data/SnowCrabGrowthMaster.csv")

# Calculate molt increments, assigning a default CV of 0.03
use_grow <- filter(grow, Legs_missing_premolt == 0)
use_grow$molt_inc <- use_grow$Postmolt_CW - use_grow$Premolt_CW
new_grow <- cbind(use_grow[, c(6, 3, 17)], rep(0.03, nrow(use_grow)))
colnames(new_grow) <- c("pre", "sex", "inc", "cv")
write.csv(new_grow, 'data/newgrowth.csv', row.names = FALSE)

# Compare with existing growth master list to filter out duplicates
ass_grow <- read.csv('data/growth_ass.csv')
colnames(ass_grow) <- c("pre", "sex", "inc", "cv")

# Using anti_join to filter out duplicates (much faster than nested for-loops)
keepers <- bind_rows(ass_grow, anti_join(new_grow, ass_grow, by = c("pre", "sex", "inc", "cv")))

write.csv(keepers, 'data/newgrowth2.csv', row.names = FALSE)