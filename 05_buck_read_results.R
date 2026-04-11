#-----------------------------------------------------------
# Script to read GMACS model results and save as R object
#-----------------------------------------------------------
# devtools::install_github("wStockhausen/wtsQMD")
# devtools::install_github("wStockhausen/wtsUtilities")
# devtools::install_github("wStockhausen/tcsamFunctions")
# devtools::install_github("wStockhausen/wtsPlots")
# devtools::install_github("wStockhausen/rTCSAM02")
# devtools::install_github("wStockhausen/wtsMarkdown")
# devtools::install_github("wStockhausen/rCompTCMs")
# devtools::install_github("wStockhausen/wtsGMACS")
library(wtsGMACS)
library(wtsUtilities)

#-- 1. Setup Directories ----
# Using rstudioapi to ensure paths are relative to the project root
dirPrj <- rstudioapi::getActiveProject()
dirDoc <- dirname(rstudioapi::getActiveDocumentContext()$path)

#-- 2. Define Models (Labels and Folder Paths) ----
# Using a named vector directly ensures each folder has a unique label 
# and prevents length mismatches.
model_defs <- c(
  "25.1 gmacs"                     = "25_gmacs/",
  "25.1 gmacs (update)"            = "25_gmacs_update/",
  "25.1 gmacs (update + hyb_surv)"          = "25_gmacs_update_hyb_surv/",
  "25.1 gmacs (update + hyb_fishery)"       = "25_gmacs_update_hyb_fishery/",
  "25.1 gmacs (update + hyb_both)"          = "25_gmacs_update_hyb_surv_and_fsh/",
  "25.1 gmacs (update + new_mat)"           = "25_gmacs_update_newmat/",
  "25.1 gmacs (update + hyb_both_new_mat)"  = "25_gmacs_update_hyb_surv_and_fsh_newmat/"
)

#-- 3. Construct Full Paths ----
full_paths <- file.path(dirPrj, model_defs)
names(full_paths) <- names(model_defs) # Carry over labels for readModelResults

#-- 4. Read and Save Results ----
# readModelResults uses the names of the vector as the 'case' labels in the R object
message("Reading model results for ", length(full_paths), " cases...")
resLst <- wtsGMACS::readModelResults(full_paths)

# Save the object to the directory where this script is located
out_file <- file.path(dirDoc, "rda_ModelsResLst.RData")
wtsUtilities::saveObj(resLst, out_file)

message("Done! Model results saved to: ", out_file)
