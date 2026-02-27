#--read model files and create R object


# devtools::install_github("wStockhausen/wtsQMD")
# devtools::install_github("wStockhausen/wtsUtilities")
# devtools::install_github("wStockhausen/tcsamFunctions")
# devtools::install_github("wStockhausen/wtsPlots")
# devtools::install_github("wStockhausen/rTCSAM02")
# devtools::install_github("wStockhausen/wtsMarkdown")
# devtools::install_github("wStockhausen/rCompTCMs")
# devtools::install_github("wStockhausen/wtsGMACS")

require(wtsGMACS)
dirPrj = rstudioapi::getActiveProject()

##--identify relative (from project folder) path and name for each model
fldrs = c( "25_gmacs/","25_gmacs_update/","25_gmacs_update_hyb_surv")
cases = names(fldrs)#--model names

#--create full paths, reassign model names
fldrs=file.path(dirPrj,fldrs) 
names(fldrs) = c("25.1 gmacs","25.1 gmacs (update)","25.1 gmacs (up + hyb_surv)")

#--read model results (returns a `gmacs_reslst` object)
resLst = wtsGMACS::readModelResults(fldrs)
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path)
wtsUtilities::saveObj(resLst,file.path(dirThs,"rda_ModelsResLst.RData"))


