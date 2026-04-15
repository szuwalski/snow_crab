# Load necessary libraries
library(doParallel)
library(foreach)
library(ggplot2)
library(dplyr)
library(tidyr)

# --- 1. Setup Environment ----
use_cores <- 2
# cl <- parallel::makeCluster(use_cores)
# doParallel::registerDoParallel(cl)

# Define scenarios (using your requested snow/gmacs replacement logic)
orig_drv <- c("25_gmacs_update_hyb_surv_and_fsh_newmat", 
              "25_gmacs_update_hyb_surv_and_fsh", 
              "25_gmacs_update_plus_group", 
              "25_gmacs_update_newmat_plus_group")

tot_it  <- 100
orig_wd <- getwd()


# --- 2. Jittering Execution ----
for(d in 1:length(orig_drv)) {
  current_scenario <- orig_drv[d]
  jitter_root <- file.path(current_scenario, "jitter")
  
  if (!dir.exists(jitter_root)) dir.create(jitter_root, recursive = TRUE)
  
  message("Starting jitter for: ", current_scenario)
  
  # Parallel loop for iterations
  # foreach(i = 1:tot_it) %dopar% {
  for(i in 1:tot_it){
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
    
    # Run assessment using shell/system call
    # Using 'shell' on Windows or 'system' on Unix; cd into dir first
    cmd <- paste0("cmd /c \"cd /d ", work_dir, " && gmacs -nohess -verbose 0 -nox > gmacs_log.txt 2>&1\"")
    system(cmd, show.output.on.console = FALSE)
    gc()
  }
}

# Clean up cluster
# parallel::stopCluster(cl)
# closeAllConnections()


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
