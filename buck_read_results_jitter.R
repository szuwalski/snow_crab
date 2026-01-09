#--read model files and create R object
require(wtsGMACS)
dirPrj = rstudioapi::getActiveProject()

#devtools::install_github("wStockhausen/wtsQMD")

##--identify relative (from project folder) path and name for each model
fldrs = c("25_gmacs/jitter/20","25_gmacs/jitter/27")
fldrs = c("25_gmacs_func/jitter/70","25_gmacs_func/jitter/94")
cases = names(fldrs)#--model names

#--create full paths, reassign model names
fldrs=file.path(dirPrj,fldrs) 
names(fldrs) = c("cloud 1","cloud 2")

#--read model results (returns a `gmacs_reslst` object)
resLst = wtsGMACS::readModelResults(fldrs)
dirThs = dirname(rstudioapi::getActiveDocumentContext()$path)
wtsUtilities::saveObj(resLst,file.path(dirThs,"rda_ModelsResLst_jitter.RData"))

