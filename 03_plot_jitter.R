
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
