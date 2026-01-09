#==set working drive
#==create retro
#==pull over files
#==modify CTL file
#==execute retrospective
library(gmr)
library(dplyr)
library(reshape2)
library(ggplot2)
orig_wd<-getwd()
orig_drv<-c("C:/Users/cody.szuwalski/Work/snow_2025_9/25_gmacs/")
tot_it<-10

for(z in 1:length(orig_drv))
{
#==set up initial folder
dir.create(paste(orig_drv[z],"/retro/",sep=''))
dir.create(paste(orig_drv[z],"/retro/1/",sep=''))

for(x in 1:tot_it)
{
  #==read in .ctl
  ctl_file<-readLines(paste(orig_drv[z],"/gmacs.dat",sep=""))
  take_in<-grep("Retro",ctl_file)+1
  ctl_file[take_in] <-x
  #=make new drive
  work_drv<-paste(orig_drv[z],"/retro/",x,sep='')
  dir.create(work_drv)
  write(ctl_file,paste(work_drv,"/gmacs.dat",sep=""))

    #=copy needed files
  file.copy(paste(orig_drv[z],"/snow.dat",sep=""),
           work_drv)
  file.copy(paste(orig_drv[z],"/snow.ctl",sep=""),
            work_drv)
  file.copy(paste(orig_drv[z],"/snow.prj",sep=""),
            work_drv)
  file.copy(paste(orig_drv[z],"/gmacs.exe",sep=""),
            work_drv)

  #==rerun assessment
  setwd(paste(work_drv))
  system("gmacs.exe -nohess")
  #==do until...what exactly?
}
}

setwd(orig_wd)

# #==dumb thing for time-varying M
# #==need to manually fix the .CTL files for years in which there was time-varying M
# #==manually do one of the drives, then pull the .CTL files over, provided they're not different
# #==then rerun
# for(z in 1:length(orig_drv))
# {
#   #==set up initial folder
#   for(x in 5:tot_it)
#   {
#     pull_drv<-  paste("C:/Users/cody.szuwalski/Work/snow_2024_9/24_gmacs_sq_molt_func_sbpr/retro/",x,sep='')
#     work_drv<-paste(orig_drv[z],"/retro/",x,sep='')
#     file.copy(paste(pull_drv,"/snow.ctl",sep=""),
#               work_drv,overwrite=TRUE)
#     setwd(paste(work_drv))
#     system("gmacs.exe -nohess")
#   }
# }
# setwd(orig_wd)



#===PULL gmacs DATA AND outputs
#===over all models, combine
#===plot
setwd(orig_wd)
mod_names <- c("25.1")
orig_drv<-c("C:/Users/cody.szuwalski/Work/snow_2025_9/25_gmacs/")
retro_outs<-NULL
for(z in 1:length(orig_drv))
{
mod_dir <- paste(orig_drv[z],"retro/",sep="")
take_dir<-paste(mod_dir,seq(1,10),"/",sep='')

#==reference estimates
  tmp<-readLines(paste(orig_drv,"/Gmacsall.out",sep=''))
  st<-grep("Summary: dataframe",tmp)
  ugh<-tmp[(st+1):(st+50)]
  end<-grep(">EOD<",ugh)
  ugh<-ugh[1:(end-1)]
  ref_take_out<-NULL
  
  for(x in 2:length(ugh))
    ref_take_out<-rbind(ref_take_out,as.numeric(unlist(strsplit(unlist(ugh[x]),split=" "))))
  colnames(ref_take_out)<-unlist(strsplit(unlist(ugh[1]),split=" "))[unlist(strsplit(unlist(ugh[1]),split=" "))!='']

#==peels
  keep_ssb<-ref_take_out[,c(1,2)]
for(y in 1:length(take_dir))
{
tmp<-readLines(paste(take_dir[y],"/Gmacsall.out",sep=''))
st<-grep("Summary: dataframe",tmp)
ugh<-tmp[(st+1):(st+50)]
end<-grep(">EOD<",ugh)
ugh<-ugh[1:(end-1)]
take_out<-NULL

for(x in 2:length(ugh))
 take_out<-rbind(take_out,as.numeric(unlist(strsplit(unlist(ugh[x]),split=" "))))
colnames(take_out)<-unlist(strsplit(unlist(ugh[1]),split=" "))[unlist(strsplit(unlist(ugh[1]),split=" "))!='']

keep_ssb<-merge(keep_ssb,take_out[,c(1,2)],all=TRUE,by='Year')
}
}

colnames(keep_ssb)<-c("Year",seq(2024,2014))
melted<-melt(keep_ssb,id.var='Year')  

perc_diff<-rep(NA,tot_it+3)
for(x in 3:ncol(keep_ssb))
{
 take_ind<-max(which(!is.na(keep_ssb[,x])))
 comp<-keep_ssb[take_ind,2]
 ref<-keep_ssb[take_ind,x]
 perc_diff[x]<-(comp-ref)/ref
}
png("plots/retro_mmb.png",height=8,width=8,res=400,units='in') 
ggplot(melted)+
  geom_line(aes(x=Year,y=value,group=variable,col=variable),lwd=1.2)+
  theme_bw()+expand_limits(y=0)+
  annotate("text", x=2010, y=400, label= paste("Mohn's rho = ",round(mean(perc_diff,na.rm=T),2)) ) +
  guides(col=guide_legend(title="Peel"))
dev.off()

  



  
  
  
  
  
  
  
  
  
  
  
#==facet plots
png("plots/retro_mmb.png",height=8,width=8,res=400,units='in')

ggplot(filter(retro_outs,year>2010))+
  geom_line(aes(x=year,y=ssb,group=peel,col=peel),lwd=1.5,alpha=0.75)+
  theme_bw()+
  facet_wrap(~model)+
  geom_text(aes(x=2015,y=50,label=paste("Mohn's rho = ",round(mohnrho,2))))+
  expand_limits(y=0)+ylab("Mature male biomass (1,000 t)")
dev.off()

#=======================================
# calc the CIs
cpue_df<-data.frame(cbind(M[[1]]$dSurveyData,M[[1]]$pre_cpue,rep(1,length(M[[1]]$pre_cpue))))
colnames(cpue_df)<-c("q","year","season","fleet","sex","mature","obs","cv","uh","dunno","pred",'peel')
ciup<-cpue_df$obs * exp(1.96*sqrt(log(1+cpue_df$cv^2)))
cidn<-cpue_df$obs / exp(1.96*sqrt(log(1+cpue_df$cv^2)))
cpue_df<-cbind(cpue_df,ciup,cidn)
temp<-filter(cpue_df,sex=='1'&fleet=='4')

for(x in 2:length(M))
{
  cpue_df<-data.frame(cbind(M[[x]]$dSurveyData,M[[x]]$pre_cpue),rep(x,length(M[[x]]$pre_cpue)))
  colnames(cpue_df)<-c("q","year","season","fleet","sex","mature","obs","cv","uh",'dunno',"pred",'peel')
  ciup<-cpue_df$obs * exp(1.96*sqrt(log(1+cpue_df$cv^2)))
  cidn<-cpue_df$obs / exp(1.96*sqrt(log(1+cpue_df$cv^2)))
  cpue_df<-cbind(cpue_df,ciup,cidn)
  temp<-rbind(temp,filter(cpue_df,sex==1,fleet==4))
}
temp<-temp[-which(temp$pred==0),] 
peel_yr<-seq(2023,2015)
temp$peel_year<-peel_yr[temp$peel]
library(ggplot2)

png("plots/retro_ind_fit.png",height=8,width=8,res=400,units='in')
p<-ggplot(data=filter(temp,peel<10)) +
  geom_point(aes(x=year,y=obs))+
  geom_line(aes(x=year,y=pred,group=peel),lwd=1) +
  geom_pointrange(aes(x=year,y=obs,ymin=cidn, ymax=ciup))+
  theme_bw()+theme(legend.position='none')+ylab("MMB (kt)")+
  facet_wrap(~peel_year)
print(p)
dev.off()

unq_peel<-unique(temp$peel)
unq_yr<-unique(temp$year)
max_yr<-max(unq_yr)

ref_ssb<-rev(filter(temp,peel==1,year>2010,year<max_yr)$pred)
peel_ssb<-rep(0,length(ref_ssb))
for(x in 1:length(ref_ssb))
  peel_ssb[x]<-filter(temp,year==(max_yr-x),peel==(10-x))$pred

mean((peel_ssb-ref_ssb)/ref_ssb)

in_name<-NULL
in_yr<-NULL
in_val<-NULL
in_peel<-NULL

for(x in 1:length(mod_names))
{
 in_name<-c(in_name,rep('ssb',length(M[[x]]$mod_yrs)),rep('rec',length(M[[x]]$mod_yrs)))
 in_peel<-c(in_peel,rep(mod_names[x],2*length(M[[x]]$mod_yrs)))
 in_val<-c(in_val,M[[x]]$ssb,unlist(M[[x]]$recruits[1,]))
 in_yr<-c(in_yr,M[[x]]$mod_yrs,M[[x]]$mod_yrs)
} 

out_data<-data.frame(quantity=in_name,peel=in_peel,value=in_val,year=in_yr)
write.csv(out_data,"opilio_tseries.csv")

B35<-NULL
for(x in 1:length(mod_names))
 B35<-c(B35,M[[x]]$spr_bmsy)

mod_names_2 <- seq(2018,2010)
.MODELDIR2 = c("./retro/2018_s/","./retro/2017_s/",
              "./retro/2016_s/","./retro/2015_s/",
              "./retro/2014_s/","./retro/2013_s/",
              "./retro/2012_s/","./retro/2011_s/","./retro/2010_s/")

fn       <- paste0(.MODELDIR2, "gmacs")
M2        <- lapply(fn, read_admb) #need .prj file to run gmacs and need .rep file here
names(M2) <- mod_names_2

B35_d<-NULL
for(x in 1:length(mod_names))
  B35_d<-c(B35_d,M2[[x]]$spr_bmsy)

BMSY<-data.frame(BMSY=c(B35,B35_d),peel=c(mod_names,mod_names_2),
                 survey=c(rep("whole",length(mod_names)),rep("drop",length(mod_names_2))))
write.csv(BMSY,"opilio_bmsy.csv")

in_name<-NULL
in_yr<-NULL
in_val<-NULL
in_peel<-NULL

for(x in 1:length(mod_names_2))
{
  in_name<-c(in_name,rep('ssb',length(M2[[x]]$mod_yrs)),rep('rec',length(M2[[x]]$mod_yrs)))
  in_peel<-c(in_peel,rep(mod_names_2[x],2*length(M2[[x]]$mod_yrs)))
  in_val<-c(in_val,M2[[x]]$ssb,unlist(M2[[x]]$recruits[1,]))
  in_yr<-c(in_yr,M2[[x]]$mod_yrs,M2[[x]]$mod_yrs)
} 

out_data<-data.frame(quantity=in_name,peel=in_peel,value=in_val,year=in_yr)
write.csv(out_data,"opilio_tseries_drop.csv")



OFL<-rep(NA,length(mod_names))
OFL2<-rep(NA,length(mod_names))

for(x in 1:length(OFL))
{
  OFL[x]<-M[[x]]$spr_cofl
  OFL2[x]<-M2[[x]]$spr_cofl
}

png("plots/retro_OFL.png",height=4.5,width=8,res=400,units='in')
plot(OFL~as.numeric(mod_names+1),type='l',lwd=2,las=1,xlab="Year",ylim=c(0,250),ylab="OFL (1,000t)")
lines(OFL2~as.numeric(mod_names+1),lty=2,col=2,lwd=2)
legend('bottomleft',bty='n',col=c(1,2),lty=c(1,2),lwd=2,
       legend=c("With last year of survey","Without last year of survey"))
dev.off()

ofl_diff<-(OFL2-OFL)/OFL
mean(ofl_diff)
median(ofl_diff)

boxplot(ofl_diff*100,las=1,frame=F)
abline(h=0,lty=2)
mtext(side=2,line=2.2,"Percent change in OFL")
 df<-data.frame(Change=ofl_diff*100,stock="Opilio")

p <- ggplot(data = df, aes(y = Change, x = stock)) + 
  geom_boxplot(aes(middle = mean(Change)))

print(p)

#==martin's figure
retro_ssb<-rep(NA,length(mod_names))
retro_ssb_no<-rep(NA,length(mod_names))

for(x in 1:length(mod_names))
{
  retro_ssb[x]<-M[[x]]$ssb[length(M[[x]]$ssb)]
  retro_ssb_no[x]<-M2[[x]]$ssb[length(M[[x]]$ssb)]
  }

png("plots/retro_term_yr_mmb.png",height=4.5,width=8,res=400,units='in')
plot(M[[1]]$ssb~M[[1]]$mod_yrs,type='b',ylim=c(0,320),xlim=c(2011,2018),
     las=1,lwd=2,ylab="MMB (1,000t)",xlab="Year")
lines(retro_ssb~mod_names,lty=1,col=2,lwd=2,type='b')
lines(retro_ssb_no~mod_names,lty=1,col=3,lwd=2,type='b')

legend('topright',bty='n',col=c(1,2,3),lty=1,lwd=2,legend=c("Most recent assessment","Standard retrospective",
                                                "Drop terminal survey retrospective"))
dev.off()

ref_ssb<-rev(M[[1]]$ssb[(length(M[[1]]$ssb)-length(mod_names)+1):length(M[[1]]$ssb)])
mean((retro_ssb-ref_ssb)/ref_ssb)
mean((retro_ssb_no-ref_ssb)/ref_ssb,na.rm=T)

#==ralston's sigma

sqrt((1/(length(ref_ssb)-1))*sum((log(retro_ssb)-log(ref_ssb))^2))
sqrt((1/(length(ref_ssb)-1))*sum((log(retro_ssb_no)-log(ref_ssb))^2))

sqrt(sum(log(retro_ssb_no)-log(ref_ssb))/(length(ref_ssb)-1))

#==martin's figure
retro_q<-rep(NA,length(mod_names))
retro_q_no<-rep(NA,length(mod_names))

retro_m<-rep(NA,length(mod_names))
retro_m_no<-rep(NA,length(mod_names))

for(x in 1:length(mod_names))
{
  retro_q[x]<-M[[x]]$survey_q[4]
  retro_q_no[x]<-M2[[x]]$survey_q[4]
  
  retro_m[x]<-unique(c(M[[x]]$M))[1]
  retro_m_no[x]<-unique(c(M2[[x]]$M))[1]
}

png("plots/retro_q_m.png",height=4.5,width=8,res=400,units='in')

plot(retro_q~mod_names,ylim=c(0,1),type='l',las=1,pch=15,col=3,lty=2,ylab='',xlab='')
lines(retro_q_no~mod_names,col=3,pch=15,lty=1)

lines(retro_m~mod_names,col=4,pch=16,lty=2,type='l')
lines(retro_m_no~mod_names,col=4,pch=16,lty=1)

mtext(side=1,"Year",line=2.5)
legend('bottom',bty='n',col=c(3,4),lty=c(2,1),legend=c("Terminal survey include","Terminal survey excluded"))

dev.off()


lines(retro_m~mod_names,type='b',col=1)
lines(retro_m_no~mod_names,type='b',col=2)
projyr<-c(mod_names+1,mod_names_2+1)
outs<-data.frame(Spp="Opilio",projYear=projyr,retro=c(rep('retr',length(mod_names)),rep('survRed_retr',length(mod_names))),
           peel=projyr-max(projyr),SSB=c(retro_ssb,retro_ssb_no),OFL=c(OFL,OFL2))
#write.csv(outs,"opilio_retro.csv")


png("plots/retro_mmb_2.png",height=8,width=8,res=400,units='in')
par(mfrow=c(2,1),mar=c(.1,.1,.1,.1),oma=c(4,4,1,1))
plot(M[[1]]$ssb~M[[1]]$mod_yrs,type='l',ylim=c(0,max(M[[1]]$ssb,M2[[1]]$ssb)),las=1,lwd=2,ylab="MMB (1,000t)",xlab="Year",xaxt='n')
for(x in 2:length(mod_names))
  lines(M[[x]]$ssb~M[[x]]$mod_yrs,lty=1,col=x,lwd=2)
legend('topright',bty='n',legend=c("Terminal survey included",
                                   paste("Mohn's rho = ",
                                         round(mean((retro_ssb-ref_ssb)/ref_ssb),2))))

mean((retro_ssb-ref_ssb)/ref_ssb)
mean((retro_ssb_no-ref_ssb)/ref_ssb)


plot(M2[[1]]$ssb~M2[[1]]$mod_yrs,type='l',ylim=c(0,max(M[[1]]$ssb,M2[[1]]$ssb)),las=1,lwd=2,ylab="MMB (1,000t)",xlab="Year")
for(x in 2:length(mod_names))
  lines(M2[[x]]$ssb~M2[[x]]$mod_yrs,lty=1,col=x,lwd=2)
legend('topright',bty='n',legend=c("Terminal survey excluded",
                                   paste("Mohn's rho = ",
                                         round(mean((retro_ssb_no-ref_ssb)/ref_ssb,na.rm=T),2))))
mtext(side=2,outer=T,"MMB (1,000t)",line=2.5)
dev.off()

#==run all retrospective folders
library(gmr)
library(doParallel)
library(parallel)
library(foreach)

# Detect the number of available cores and create cluster
cl <- parallel::makeCluster(detectCores())
doParallel::registerDoParallel(cl)
orig_drv<-c("C:/Users/cody.szuwalski/Work/snow_2023_5/4_gmacs_focus_m/")
tot_it<-100
orig_wd<-getwd()
foreach(x = 1:10)%dopar%
  {
    work_drv<-paste(orig_drv,"/retro/",x,sep='')
    setwd(work_drv)
    system("gmacs.exe -nohess")
  }
   setwd(orig_wd)  
   
   #==pull the tier 4 OFL from each
   #===PULL gmacs DATA AND outputs
   mod_dir <- "C:/Users/cody.szuwalski/Work/snow_2023_5/4_gmacs_focus_m/retro/"
   take_dir<-paste(mod_dir,seq(1,10),"/",sep='')
   
   fn       <- paste0(take_dir, "gmacs")
   K        <- lapply(fn, read_admb) #need .prj file to run gmacs and need .rep file here

   OFL<-rep(NA,length(take_dir))

   for(x in 1:length(OFL))
     OFL[x]<-K[[x]]$spr_cofl

   
   
#=========================================
# historical biases
#===========================
library(readxl)

dat<-read.csv('data/historical_mmb_estimates_survey.csv',check.names=F)
pl_dat<-melt(dat,id.vars=c("Year"))
survey_ess<-ggplot(pl_dat)+
  geom_line(aes(x=Year,y=value,col=variable,group=variable),lwd=1.2)+
  theme_bw()+ylab("Biomass (1,000 t)")+
  labs(color="Assessment")+
  ggtitle("Morphometrically mature biomass at survey, subject to selectivity")

dat<-read.csv('data/historical_mmb_estimates_MMB_mating.csv',check.names=F)
pl_dat<-melt(dat,id.vars=c("Year"))
mating_ess<-ggplot(pl_dat)+
  geom_line(aes(x=Year,y=value,col=variable,group=variable),lwd=1.2)+
  theme_bw()+ylab("Biomass (1,000 t)")+
  labs(color="Assessment")+
  ggtitle("Morphometrically mature biomass at mating, not subject to selectivity")

df_normalized <- pl_dat %>%
  group_by(variable) %>%
  mutate(normalized_value = value / max(value,na.rm=T))

normie<-ggplot(df_normalized)+
  geom_line(aes(x=Year,y=normalized_value,group=variable,col=variable),lwd=1.2)+
  theme_bw()+ylab("Normalized MMB")+
  labs(color="Assessment")+
  ggtitle("Normalized morphometrically mature biomass at mating, not subject to selectivity")


png("plots/historical_mating_mmb_est.png",height=10,width=8,res=400,units='in')
survey_ess / mating_ess / normie + plot_layout(guides='collect')
dev.off()
 

df_normalized <- pl_dat %>%
  group_by(variable) %>%
  mutate(normalized_value = value / max(value,na.rm=T))

ggplot(df_normalized)+
  geom_line(aes(x=Year,y=normalized_value,group=variable,col=variable),lwd=1.2)+
  theme_bw()+ylab("Normalized MMB")
