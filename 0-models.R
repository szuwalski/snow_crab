#-- Define Models (Labels and Folder Paths) ----
# Using a named vector directly ensures each folder has a unique label
# and prevents length mismatches.
model_defs <- c(
  "25.1 gmacs"                                                                              = "25_gmacs/",
  "25.1 gmacs (update)"                                                               = "25_gmacs_update/",
  "25.1 gmacs (update + compfix)"                                                    = "25_gmacs_update_compfix/",
  "25.1 gmacs (update + compfix + plus group)"                    = "25_gmacs_update_plus_group/", # Jittered
  "25.1 gmacs (update + compfix + imm_surv)"       = "25_gmacs_update_imm_compfix/",
  "25.1 gmacs (update + compfix + plus group + imm_surv)"       = "25_gmacs_update_imm_plus_group/", # Jittered
  "25.1 gmacs (update + new_mat)"                           = "25_gmacs_update_newmat/",
  "25.1 gmacs (update + compfix + new_mat)"       = "25_gmacs_update_newmat_compfix/",
  "25.1 gmacs (update + compfix + plus group + new_mat)"         = "25_gmacs_update_newmat_plus_group/", # Jittered
  "25.1 gmacs (update + compfix + plus group + new_mat + imm_surv)"      = "25_gmacs_update_newmat_imm_plus_group/", # Jittered
  "25.1 gmacs (update + compfix + plus group + hyb_fishery)"                   = "25_gmacs_update_hyb_fishery/",
  "25.1 gmacs (update + compfix + plus group + hyb_surv)"                          = "25_gmacs_update_hyb_surv/",
  "25.1 gmacs (update + compfix + plus group + hyb_both)"                          = "25_gmacs_update_hyb_surv_and_fsh/", # Jittered
  "25.1 gmacs (update + compfix + plus group + hyb_both + new_mat)"         = "25_gmacs_update_hyb_surv_and_fsh_newmat/" # Jittered
)


#-- Compact shortnames for tables and figures -----------------------------
# One-to-one map keyed by the long labels in `model_defs`. Shortnames drop
# the "25.1 gmacs" prefix on every model that includes the data update
# (the rolled-forward reference model keeps "25.1" so it stays visually
# distinct in figure legends). Token meanings: u = update, cf = compfix,
# pg = plus group, imm = immature survey index, nm = new_mat,
# hs = hyb_surv, hf = hyb_fishery, hb = hyb_both.
model_shorts <- c(
  "25.1 gmacs"                                                        =  "Model 25"   , 
  "25.1 gmacs (update)"                                               =  "Model 25.1a", 
  "25.1 gmacs (update + compfix)"                                     =  "Model 25.1b", 
  "25.1 gmacs (update + compfix + plus group)"        =  "Model 25.1c", # Jittered
  "25.1 gmacs (update + compfix + imm_surv)"  =  "Model 25.1d", 
  "25.1 gmacs (update + compfix + plus group + imm_surv)"  =  "Model 25.1e", # Jittered
  "25.1 gmacs (update + new_mat)"            =  "Model 25.2a", 
  "25.1 gmacs (update + compfix + new_mat)"  =  "Model 25.2b", 
  "25.1 gmacs (update + compfix + plus group + new_mat)"   =  "Model 25.2c", # Jittered
  "25.1 gmacs (update + compfix + plus group + new_mat + imm_surv)" =  "Model 25.2d", # Jittered
  "25.1 gmacs (update + compfix + plus group + hyb_fishery)"        =  "Model 25.3a", 
  "25.1 gmacs (update + compfix + plus group + hyb_surv)"           =  "Model 25.3b", 
  "25.1 gmacs (update + compfix + plus group + hyb_both)"           =  "Model 25.3c", # Jittered
  "25.1 gmacs (update + compfix + plus group + hyb_both + new_mat)"   =  "Model 25.3d"  # Jittered
)

# Sanity check: every model in model_defs needs an entry in model_shorts
stopifnot(all(names(model_defs) %in% names(model_shorts)))
stopifnot(!anyDuplicated(model_shorts))


#-- Helper: convert long label(s) to shortname(s) -------------------------
# Vectorised, preserves order, leaves anything not in the lookup unchanged
# (so it's safe to apply to a `case` column that may include intermediate
# labels). Returns a factor whose level order follows `model_defs` so
# ggplot legends and kable column orders stay consistent across chunks.
to_short <- function(x, factor = TRUE) {
  out <- ifelse(x %in% names(model_shorts), model_shorts[x], x)
  if (factor) {
    lvls <- unname(model_shorts[names(model_defs)])
    out  <- factor(out, levels = unique(c(lvls, out)))
  }
  unname(out)
}
