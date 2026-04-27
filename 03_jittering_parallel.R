## Jitter setup + execution.
## R does the file ops only (create iter dirs, copy inputs, patch gmacs.dat).
## The gmacs.exe runs are done by run_jitter.sh, which calls Whisky's wine64
## sequentially. Re-running is resumable (existing Gmacsall.out is skipped).

library(ggplot2)
library(dplyr)
library(tidyr)
source("0-models.R")

# --- 1. Setup ----
orig_drv <- c("25_gmacs_update_hyb_surv_and_fsh_newmat",
              "25_gmacs_update_hyb_surv_and_fsh",
              "25_gmacs_update_plus_group",
              "25_gmacs_update_newmat_plus_group",
              "25_gmacs_update_imm_plus_group",
              "25_gmacs_update_newmat_imm_plus_group")
# Map each folder in orig_drv -> long label -> short name (from 0-models.R)
mod_names <- unname(model_shorts[
  names(model_defs)[match(paste0(orig_drv, "/"), model_defs)]
])
stopifnot(!anyNA(mod_names))  # catches any folder missing from model_defs
tot_it <- 100

# --- 2. Build iter dirs (copy files + patch gmacs.dat) ----
for (current_scenario in orig_drv) {
  jitter_root <- file.path(current_scenario, "jitter")
  if (!dir.exists(jitter_root)) dir.create(jitter_root, recursive = TRUE)

  message("Setting up jitter dirs for: ", current_scenario)

  dat_name <- paste0(gsub("gmacs", "snow", current_scenario), ".dat")
  files_to_copy <- file.path(current_scenario,
                             c(dat_name, "snow.ctl", "snow.prj",
                               "gmacs.dat", "gmacs.exe"))

  for (i in seq_len(tot_it)) {
    work_dir <- file.path(jitter_root, as.character(i))
    if (!dir.exists(work_dir)) dir.create(work_dir)

    if (file.exists(file.path(work_dir, "Gmacsall.out"))) next

    file.copy(files_to_copy, work_dir, overwrite = TRUE)

    gmacs_dat_path <- file.path(work_dir, "gmacs.dat")
    in_proj <- readLines(gmacs_dat_path)
    jitter_idx <- grep("Jitter", in_proj)
    if (length(jitter_idx) > 0) in_proj[jitter_idx + 1] <- "1 0 0.1"
    writeLines(in_proj, gmacs_dat_path)
  }
}

# --- 3. Run gmacs in every iter dir via the bash script ----
# Comment out this block if you'd rather run `./run_jitter.sh` yourself in a
# terminal (e.g. to keep the long-running job out of RStudio).
Sys.chmod("run_jitter.sh", "755")
message("Launching run_jitter.sh ...")
rc <- system2("/bin/bash", "run_jitter.sh")
message("run_jitter.sh exit code: ", rc)


# --- 4. Extract Results ---
extract_jitter_results <- function(scenario_path, n_iterations, model) {
  all_data <- list()

  for(i in 1:n_iterations) {
    out_file <- file.path(scenario_path, "jitter", i, "Gmacsall.out")

    if (file.exists(out_file)) {
      tmp <- try(readLines(out_file), silent = TRUE)

      if (inherits(tmp, "try-error") | length(tmp) == 1) {
        next
      }

      # Extract Neg Log Likelihood (Total)
      nll_line <- tmp[grep("Total", tmp)[1]]
      nll_val  <- as.numeric(unlist(strsplit(nll_line, " +"))[2])

      # Extract Management Quantities
      st  <- grep("BMSY", tmp)[1]
      end <- grep("Ofl", tmp)[length(grep("Ofl", tmp))]
      use <- tmp[st:end]
      
      # Extract Terminal Derived Quantities
      st  <- grep("Overall_summary", tmp)[1]
      end <- grep("BiomassByXM", tmp)[1]
      use2 <- tmp[st:end]
      
      # Extract Terminal Mature Males
      st  <- grep("males_mature", tmp)[1]
      end <- grep("females_mature", tmp)[1]
      use3 <- tmp[st:end]

      # Helper to parse the weirdly formatted GMACS output lines
      parse_gmacs_line <- function(lines, pattern, index) {
        line <- lines[grep(pattern, lines)]
        as.numeric(unlist(strsplit(line, " +"))[index])
      }

      all_data[[i]] <- data.frame(
        scenario   = scenario_path,
        model = model,
        jitter     = i,
        negloglike = nll_val,
        BMSY       = parse_gmacs_line(use, "BMSY", 3),
        Status     = parse_gmacs_line(use, "Bcurr/BMSY", 3),
        OFL        = parse_gmacs_line(use, "Ofl", 4), # Directed OFL
        FMSY       = parse_gmacs_line(use, "Fmsy", 4),
        FOFL       = parse_gmacs_line(use, "Fofl", 4),
        SSB = parse_gmacs_line(use2, "2024", 2),
        Rmales = parse_gmacs_line(use2, "2024", 9),
        Mmales = sum(sapply(2:23, function(x) parse_gmacs_line(use3, "2025", x)))
      )
    }
  }
  return(bind_rows(all_data))
}

# Run extraction for all scenarios
jit_summary <- bind_rows(Map(
  function(s, m) {
    extract_jitter_results(scenario_path = s,
                           n_iterations  = tot_it,
                           model         = m)
  },
  orig_drv, mod_names
))

unique(jit_summary$scenario)

# --- 5. Plotting ----
# - OFL
p <- jit_summary %>%
  filter(negloglike < 0) %>%
  ggplot(aes(x = negloglike, y = OFL, color = scenario)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~scenario, scales = "free") +
  theme_bw() +
  labs(title = "Jitter Convergence Check",
       x = "Negative Log-Likelihood",
       y = "OFL (1,000 t)")
ggsave(p, filename = 'plots/jittered_results_ofl.png', height = 8, width = 10, dpi = 300, units = 'in')
p

# - SSB
p <- jit_summary %>%
  filter(negloglike < 0) %>%
  ggplot(aes(x = negloglike, y = SSB, color = model)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~model, scales = "free") +
  theme_bw() +
  labs(title = "Jitter Convergence Check",
       x = "Negative Log-Likelihood",
       y = "SSB 2024 (1,000 t)")
ggsave(p, filename = 'plots/jittered_results_ssb.png', height = 8, width = 10, dpi = 300, units = 'in')
p

# - R males
p <- jit_summary %>%
  filter(negloglike < 0) %>%
  ggplot(aes(x = negloglike, y = Rmales, color = model)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~model, scales = "free") +
  theme_bw() +
  labs(title = "Jitter Convergence Check",
       x = "Negative Log-Likelihood",
       y = "Male recruitment 2024 (1,000 t)")
ggsave(p, filename = 'plots/jittered_results_rec.png', height = 8, width = 10, dpi = 300, units = 'in')
p
