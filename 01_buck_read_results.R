#--read model files and create R object
require(wtsGMACS)
dirPrj = rstudioapi::getActiveProject()

#devtools::install_github("wStockhausen/wtsQMD")

##--identify relative (from project folder) path and name for each model
fldrs = c( "25_gmacs/","25_gmacs_update/")
cases = names(fldrs)#--model names

#--create full paths, reassign model names
fldrs=file.path(dirPrj,fldrs) 
names(fldrs) = c("25.1 gmacs","25.1 gmacs (update)")

#--read model results (returns a `gmacs_reslst` object)
resLst = wtsGMACS::readModelResults(fldrs)
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path)
wtsUtilities::saveObj(resLst,file.path(dirThs,"rda_ModelsResLst.RData"))


