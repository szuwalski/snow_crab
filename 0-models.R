#-- Define Models (Labels and Folder Paths) ----
# Using a named vector directly ensures each folder has a unique label 
# and prevents length mismatches.
model_defs <- c(
  "25.1 gmacs"                     = "25_gmacs/",
  "25.1 gmacs (update)"            = "25_gmacs_update/",
  "25.1 gmacs (update + imm_surv + compfix)" = "25_gmacs_update_imm_compfix/",
  "25.1 gmacs (update + imm_surv + plus group)" = "25_gmacs_update_imm_plus_group/",
  "25.1 gmacs (update + compfix)"           = "25_gmacs_update_compfix/",
  "25.1 gmacs (update + plus group)"        = "25_gmacs_update_plus_group/",
  "25.1 gmacs (update + new_mat + plus group)"  = "25_gmacs_update_newmat_plus_group/",
  "25.1 gmacs (update + hyb_surv)"          = "25_gmacs_update_hyb_surv/",
  "25.1 gmacs (update + hyb_fishery)"       = "25_gmacs_update_hyb_fishery/",
  "25.1 gmacs (update + hyb_both)"          = "25_gmacs_update_hyb_surv_and_fsh/",
  "25.1 gmacs (update + new_mat)"           = "25_gmacs_update_newmat/",
  "25.1 gmacs (update + new_mat + compfix)" = "25_gmacs_update_newmat_compfix/",
  "25.1 gmacs (update + hyb_both_new_mat)"  = "25_gmacs_update_hyb_surv_and_fsh_newmat/"
)