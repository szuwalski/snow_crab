#==script for jittering
library(gmr)
library(doParallel)
library(parallel)
library(foreach)
library(ggplot2)

# Detect the number of available cores and create cluster
use_cores<-detectCores()-2
cl <- parallel::makeCluster(use_cores)
doParallel::registerDoParallel(cl)

orig_drv<-c("C:/Users/cody.szuwalski/Work/snow_2025_9/25_gmacs_func/")

tot_it<-100
orig_wd<-getwd()
z<-1 # add loop for more directories...
for(z in 1:length(orig_drv))
{
  work_drv<-paste(orig_drv[z],"/jitter/",sep='')
  dir.create(work_drv)
  
 foreach(x = 1:tot_it)%dopar%
  {
    #=make new drive
    work_drv<-paste(orig_drv[z],"/jitter/",x,sep='')
    dir.create(work_drv)

    #=copy needed files
    file.copy(paste(orig_drv[z],"/snow.dat",sep=""),
              work_drv)
    file.copy(paste(orig_drv[z],"/snow.ctl",sep=""),
              work_drv)
    file.copy(paste(orig_drv[z],"/snow.prj",sep=""),
              work_drv)
    file.copy(paste(orig_drv[z],"/gmacs.dat",sep=""),
              work_drv)
    file.copy(paste(orig_drv[z],"/gmacs.exe",sep=""),
              work_drv)
    
    in_proj<-readLines(paste(orig_drv[z],"/gmacs.dat",sep=""))
    in_proj[grep("Jitter",in_proj)+1]<-"1 0.1"

    #==rerun assessment
    setwd(paste(work_drv))
    write(in_proj,file="gmacs.dat")
    system("gmacs.exe")
    #system("gmacs.exe")
    #==do until...what exactly?
  }
}

setwd(orig_wd)
#==read in gmacs output
#==compare likelihoods
#==compare derived quantities
#==compare parameter estimatesif(!is.na(mod_names[1]))

keep_out<-matrix(nrow=tot_it,ncol=9)
for(z in 1:tot_it)
{
  mod_dir  <-paste(orig_drv,"jitter/",z,"/",sep="") 
  take_row<-c(1,2,3,4,8,12,13)
  colnames(keep_out)<-seq(1,ncol(keep_out))
  if(file.exists(paste(mod_dir,"Gmacsall.out",sep='')))
  {
    tmp<-readLines(paste(mod_dir,"Gmacsall.out",sep=''))
    st<-grep("BMSY",tmp)[1]
    end<-grep("Ofl",tmp)[length(grep("Ofl",tmp))]
    use<-tmp[st:end]
    
    keep_out[z,9]<-as.numeric(unlist(strsplit(tmp[grep("Total",tmp)[1]],split=" "))[2])
    for(x in 1:length(take_row))
    {
      if(x<4)
        keep_out[z,x]<-as.numeric(strsplit(use[take_row[x]],split=" ")[[1]][3])
      if(x>=4)
        keep_out[z,x]<-as.numeric(strsplit(use[take_row[x]],split=" ")[[1]][4])
      colnames(keep_out)[x]<-strsplit(use[take_row[x]],split=" ")[[1]][1]
    }
    }
    keep_out[z,8]<-z
}

colnames(keep_out)<-c("BMSY","Status","tot_ofl","FMSY","FOFL","OFL","disc_OFL","jitter","negloglike")

# check nll
# keep_out[order(keep_out[,9]), ]
png('plots/jittered_ofl_95.png',height=6,width=6,res=350,units='in')
ggplot()+
  geom_point(data=as.data.frame(keep_out),aes(x=negloglike,y=OFL))+
  theme_bw()+xlim(-19175,-19160)+ylim(0,4)+
  ylab("OFL (1,000 t)")
dev.off()


#======================
# look at parameters
#=====================
hold_pars<-matrix(ncol=262,nrow=tot_it)
for(z in 1:tot_it)
{
tmp<-readLines(paste(orig_drv[3],"/jitter/",z,"/gmacs.par",sep=""))
hold_pars[z,]<-tmp[-grep('#',tmp)]  
} 
colnames(hold_pars)<-tmp[grep('#',tmp)[-1]] 
  
library(dplyr)  
plot(as.numeric(hold_pars[,1])~filter(jit_out,model=="24.1c")$nlogl)
plot(as.numeric(hold_pars[,2])~filter(jit_out,model=="24.1c")$nlogl)
