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

#-- 2. Load Model Definitions (Labels and Folder Paths) ----
source("0-models.R")

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
