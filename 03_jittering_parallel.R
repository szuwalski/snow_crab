# Load necessary libraries
library(doParallel)
library(foreach)
library(ggplot2)
library(dplyr)
library(tidyr)

# --- 1. Setup Environment ----
use_cores <- 6
cl <- parallel::makeCluster(use_cores)
doParallel::registerDoParallel(cl)

# Define scenarios (using your requested snow/gmacs replacement logic)
orig_drv <- c("25_gmacs_update_hyb_surv_and_fsh_newmat",
              "25_gmacs_update_hyb_surv_and_fsh",
              "25_gmacs_update_plus_group",
              "25_gmacs_update_newmat_plus_group",
              "25_gmacs_update_imm_plus_group",
              "25_gmacs_update_newmat_imm_plus_group")

tot_it  <- 100
orig_wd <- getwd()

# --- 1b. Platform / Wine (Whisky) configuration ---------------------------
# gmacs.exe was compiled for Windows. On macOS we run it through Whisky's
# bundled Wine. Set these two paths once for your machine and the parallel
# loop below will dispatch the executable correctly. On Windows the script
# falls back to the original `cmd /c` invocation.
is_mac <- Sys.info()[["sysname"]] == "Darwin"

# Path to the wine64 binary that Whisky ships with. The default below is the
# standard install location for recent Whisky releases; adjust if yours is
# different (Whisky -> right-click bottle -> "Open Bottle Folder" will reveal
# the prefix and a sibling Wine binary path).
whisky_wine <- "~/Library/Application Support/com.isaacmarovitz.Whisky/Libraries/Wine/bin/wine64"

# WINEPREFIX for the Whisky bottle that has the right Windows libraries
# installed. Find the UUID at:
#   ~/Library/Containers/com.isaacmarovitz.Whisky/Bottles/<UUID>/
# (Whisky -> bottle list -> three-dot menu -> "Show in Finder" works too.)
whisky_prefix <- "~/Library/Containers/com.isaacmarovitz.Whisky/Bottles/AD8FC922-1B19-4B6C-92DB-A4699F0AC94B"

# Validate before launching the parallel cluster (cheaper to fail here)
if (is_mac) {
  if (!file.exists(path.expand(whisky_wine))) {
    stop("Whisky wine binary not found at: ", whisky_wine,
         "\nUpdate `whisky_wine` at the top of this script.")
  }
  if (!dir.exists(path.expand(whisky_prefix))) {
    stop("Whisky bottle prefix not found at: ", whisky_prefix,
         "\nUpdate `whisky_prefix` at the top of this script with your bottle's UUID.")
  }
}

# --- 1c. Per-worker wine prefix slots (macOS only) -------------------------
# Concurrent wine instances that share one WINEPREFIX deadlock each other via
# the wineserver. Create one APFS copy-on-write clone per worker slot
# (one-time, cheap on APFS); each worker claims its slot exclusively so all
# parallel runs proceed without conflict.
if (is_mac) {
  slot_dir <- file.path(orig_wd, ".wine_slots")
  dir.create(slot_dir, showWarnings = FALSE, recursive = TRUE)
  for (s in seq_len(use_cores)) {
    slot_path <- file.path(slot_dir, paste0("slot_", s))
    if (!dir.exists(slot_path)) {
      message("Creating wine prefix slot ", s, " (one-time APFS clone)...")
      system2("cp", args = c("-Rc", path.expand(whisky_prefix), slot_path))
    }
  }
  # Assign each persistent doParallel worker a unique slot ID (1..use_cores).
  # Workers survive across foreach iterations, so worker N always uses slot N
  # and no two workers ever share a prefix.
  parallel::clusterApply(cl, seq_len(use_cores), function(slot_id) {
    assign(".wine_slot", slot_id, envir = .GlobalEnv)
  })
}

# --- 2. Jittering Execution ----
for(d in 1:length(orig_drv)) {
  current_scenario <- orig_drv[d]
  jitter_root <- file.path(current_scenario, "jitter")
  
  if (!dir.exists(jitter_root)) dir.create(jitter_root, recursive = TRUE)
  
  message("Starting jitter for: ", current_scenario)
  
  # Parallel loop for iterations.
  # `.export` ships the platform/Whisky variables to each worker so the
  # `is_mac` branch inside the worker resolves correctly under doParallel.
  foreach(i = 1:tot_it,
          .export = c("is_mac", "whisky_wine", "orig_wd")) %dopar% {
  # for(i in 1:tot_it){
    work_dir <- file.path(jitter_root, as.character(i))
    if (!dir.exists(work_dir)) dir.create(work_dir)
    print(i)
    # Define files to copy
    dat_name <- paste0(gsub("gmacs", "snow", current_scenario), ".dat")
    if(file.exists(file.path(work_dir, "Gmacsall.out"))) next # Skip iteration if already done
    
    files_to_copy <- c(
      file.path(current_scenario, dat_name),
      file.path(current_scenario, "snow.ctl"),
      file.path(current_scenario, "snow.prj"),
      file.path(current_scenario, "gmacs.dat"),
      file.path(current_scenario, "gmacs.exe")
    )
    
    file.copy(files_to_copy, work_dir, overwrite = TRUE)
    
    # Modify gmacs.dat to enable jitter
    gmacs_dat_path <- file.path(work_dir, "gmacs.dat")
    in_proj <- readLines(gmacs_dat_path)
    # Update Jitter line (assuming standard GMACS format)
    jitter_idx <- grep("Jitter", in_proj)
    if(length(jitter_idx) > 0) in_proj[jitter_idx + 1] <- "1 0 0.1"
    writeLines(in_proj, gmacs_dat_path)
    
    # Run assessment using shell/system call.
    # On Windows: cmd /c with cd /d.
    # On macOS:   /bin/sh -c with `cd ... && WINEPREFIX=... wine64 gmacs.exe ...`
    #             so each parallel worker gets its own working directory and
    #             logs are captured into the per-iteration folder.
    gc()
    if (is_mac) {
      slot_prefix <- file.path(orig_wd, ".wine_slots",
                               paste0("slot_", .wine_slot))
      shell_cmd <- sprintf(
        "cd %s && WINEPREFIX=%s WINEDEBUG=-all %s gmacs.exe -nohess -verbose 0 -nox > gmacs_log.txt 2>&1",
        shQuote(normalizePath(work_dir)),
        shQuote(slot_prefix),
        shQuote(path.expand(whisky_wine))
      )
      system2("/bin/sh", args = c("-c", shell_cmd), wait = TRUE)
    } else {
      args <- c("/c", paste0("cd /d ", shQuote(work_dir),
                             " && gmacs -nohess -verbose 0 -nox > gmacs_log.txt 2>&1"))
      system2("cmd", args = args, wait = TRUE)
    }
    gc()
  }
}

# Clean up cluster
parallel::stopCluster(cl)
closeAllConnections()


# --- 3. Extract Results ---
extract_jitter_results <- function(scenario_path, n_iterations) {
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
      
      # Helper to parse the weirdly formatted GMACS output lines
      parse_gmacs_line <- function(lines, pattern, index) {
        line <- lines[grep(pattern, lines)]
        as.numeric(unlist(strsplit(line, " +"))[index])
      }
      
      all_data[[i]] <- data.frame(
        scenario   = scenario_path,
        jitter     = i,
        negloglike = nll_val,
        BMSY       = parse_gmacs_line(use, "BMSY", 3),
        Status     = parse_gmacs_line(use, "Bcurr/BMSY", 3),
        OFL        = parse_gmacs_line(use, "OFL", 3), # Directed OFL
        FMSY       = parse_gmacs_line(use, "Fmsy", 4),
        FOFL       = parse_gmacs_line(use, "Fofl", 4)
      )
    }
  }
  return(bind_rows(all_data))
}

# Run extraction for all scenarios
jit_summary <- bind_rows(lapply(orig_drv[1], extract_jitter_results, n_iterations = tot_it))


# --- 4. Plotting ----
png('plots/jittered_results_all.png', height = 8, width = 10, res = 300, units = 'in')
ggplot(jit_summary, aes(x = negloglike, y = OFL, color = scenario)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~scenario, scales = "free") +
  theme_bw() +
  labs(title = "Jitter Convergence Check", 
       x = "Negative Log-Likelihood", 
       y = "OFL (1,000 t)")
dev.off()
