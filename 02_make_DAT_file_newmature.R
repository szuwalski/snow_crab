library(dplyr)
library(reshape2)
library(ggplot2)
library(png)
library(grid)
library(patchwork)
library(crabpack)
library(dplyr)
library(ggplot2)
library(reshape2)
library(ggridges)
library(tidyr)

annotation_custom2 <-   function (grob, xmin = -Inf, xmax = Inf, ymin = -Inf,ymax = Inf, data){ layer(data = data, 
                                                                                                      stat = StatIdentity, 
                                                                                                      position = PositionIdentity,
                                                                                                      geom = ggplot2:::GeomCustomAnn,
                                                                                                      inherit.aes = TRUE, 
                                                                                                      params = list(grob = grob,xmin = xmin, xmax = xmax,
                                                                                                                    ymin = ymin, ymax = ymax))}
#in_png_opie<-readPNG('continuity/snowcrab.png')

## Pull specimen data
specimen_data <- crabpack::get_specimen_data(species = "SNOW",
                                             region = "EBS",
                                             years = c(1982:2025),
                                             channel = 'API')


#====================================
# only need males
#===================================
#===================================
#==Male survey Length compositions==
#===================================

male_snow_ind <- crabpack::calc_bioabund(crab_data = specimen_data,
                                            species = "SNOW",
                                            region = "EBS",
                                            crab_category = c("legal_male"))

big_male_snow_ind <- crabpack::calc_bioabund(crab_data = specimen_data,
                                         species = "SNOW",
                                         region = "EBS",
                                         crab_category = c("large_male","preferred_male"))

write.csv(big_male_snow_ind,"data/lg_male_surv_obs.csv")
#==no great way to get a CV for MMB right now...
#==use legals (>76mm for approx)
write.csv(cbind(mat_fem_snow_ind$BIOMASS_MT/1000,
                mat_fem_snow_ind$BIOMASS_MT_CV,
                male_snow_ind$BIOMASS_MT_CV),"data/derived/index_female_biomass_male_cv.csv")

male_snow <- crabpack::calc_bioabund(crab_data = specimen_data,
                                     species = "SNOW",
                                     region = "EBS",
                                     sex='male',
                                     shell_condition="all_categories",
                                     size_min = 25,
                                     bin_1mm = TRUE)

#==n at size
natl_viz<-male_snow%>%
  group_by(YEAR,SIZE_1MM)%>%
  summarize(tot_n=sum(ABUNDANCE))

p <- ggplot(dat=natl_viz) 
p <- p + geom_density_ridges(aes(x=SIZE_1MM , y=YEAR , height = tot_n ,
                                 group = YEAR, 
                                 fill=stat(y),alpha=.9999),stat = "identity",scale=5,fill='#619CFF') +
  theme_bw() +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 90)) +
  labs(x="Carapace width (mm)") +
  xlim(25,135)

natl_viz_b<-filter(male_snow,SIZE_1MM>100)%>%
  group_by(YEAR,SIZE_1MM)%>%
  summarize(tot_n=sum(ABUNDANCE))

ap <- ggplot(dat=natl_viz) 
ap <- ap + geom_density_ridges(aes(x=SIZE_1MM , y=YEAR , height = tot_n ,
                                 group = YEAR, 
                                 fill=stat(y),alpha=.9999),stat = "identity",scale=5,fill='#00BA38') +
  theme_bw() +
  theme(panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 90)) +
  labs(x="Carapace width (mm)") +
  xlim(100,135)


png("plots/size_bins_comp_Kodiak_m.png",height=9,width=6,res=400,units='in')
(p|ap)+plot_layout(widths=c(2.5,1))
dev.off()

yarp<-male_snow%>%
  group_by(YEAR,SHELL_TEXT)%>%
  summarize(tot_n=sum(ABUNDANCE))

ggplot(yarp)+
  geom_line(aes(x=YEAR,y=tot_n,col=SHELL_TEXT))+theme_bw()

#==be sure inclusion of endpoints is consistent among all data sources!
new_male_snow<-filter(male_snow,SHELL_TEXT%in%c('new_hardshell','soft_molting'))%>%
  group_by(YEAR,group = cut(SIZE_1MM , breaks = seq(0, max(SIZE_1MM), 5),right=FALSE)) %>%
  summarise(n = sum(ABUNDANCE),
            data='crabpack')

tmp<-strsplit(as.character(new_male_snow$group),',')
new_male_snow$mid_pts<-NA
for(x in 1:length(tmp))
{
  in1<-as.numeric(substr(unlist(tmp[x])[1],2, nchar(unlist(tmp[x])[1])))
  in2<-as.numeric(substr(unlist(tmp[x])[2],1, nchar(unlist(tmp[x])[2])-1))
  new_male_snow$mid_pts[x]<-sum(in1,in2)/2
}


old_male_snow<-filter(male_snow,SHELL_TEXT%in%c('oldshell','very_oldshell'))%>%
  group_by(YEAR,group = cut(SIZE_1MM , breaks = seq(0, max(SIZE_1MM), 5),right=FALSE)) %>%
  summarise(n = sum(ABUNDANCE),
            data='crabpack')

tmp<-strsplit(as.character(old_male_snow$group),',')
old_male_snow$mid_pts<-NA
for(x in 1:length(tmp))
{
  in1<-as.numeric(substr(unlist(tmp[x])[1],2, nchar(unlist(tmp[x])[1])))
  in2<-as.numeric(substr(unlist(tmp[x])[2],1, nchar(unlist(tmp[x])[2])-1))
  old_male_snow$mid_pts[x]<-sum(in1,in2)/2
}

in_old<-old_male_snow[,c(1,3,5)]
old_male_wide<-dcast(in_old,YEAR~mid_pts,value.var=c("n"))

in_new<-new_male_snow[,c(1,3,5)]
new_male_wide<-dcast(in_new,YEAR~mid_pts,value.var=c("n"))

#==ugh...stupid way to constrain sizes...figure a way to do this in the data pull
sizes<-seq(27.5,132.5,5)
use_old_male<-old_male_wide[,which(!is.na(match(as.numeric(colnames(old_male_wide)),sizes)))]
rownames(use_old_male)<-(old_male_wide[,1])
use_old_male[,ncol(use_old_male)]<-use_old_male[,ncol(use_old_male)]+apply(old_male_wide[,which(as.numeric(colnames(old_male_wide)) >132.5)],1,sum)

use_new_male<-new_male_wide[,which(!is.na(match(as.numeric(colnames(new_male_wide)),sizes)))]
rownames(use_new_male)<-(new_male_wide[,1])
use_new_male[,ncol(use_new_male)]<-use_new_male[,ncol(use_new_male)]+apply(new_male_wide[,which(as.numeric(colnames(new_male_wide)) >132.5)],1,sum)

MaleOld<-use_old_male/1000000
MaleNew<-use_new_male/1000000


#==This should be changed so I don't need to fit the GAMs then predict on the size bins I have
#==crabpack folks are working on this
#==make matrix of probability of maturity given newshell based on 
#==observed + average over years when observations are not available
#==these names often get changed, so check

new_male_mat_dat<-read.csv("data/SNOW_male_pmolt_array.csv")

male_maturity_data <- crabpack::get_male_maturity(species = "SNOW",
                                                  region = "EBS",
                                                  channel = 'API')

all_yr<-seq(1982,max(new_male_mat_dat[,1]))
new_dat<-seq(27.5,132.5,5)
allmat<-matrix(nrow=length(all_yr),ncol=length(new_dat))
rownames(allmat)<-all_yr
colnames(allmat)<-new_dat
yrs<-unique(new_male_mat_dat[,1])
for(x in 1:length(yrs))
 allmat[match(yrs[x],all_yr),]<-unlist(new_male_mat_dat[x,2:ncol(new_male_mat_dat)])

mean_mat<-apply(allmat,2,mean,na.rm=T)
for(x in which(is.na(allmat[,1])))
 allmat[x,]<-mean_mat

write.csv(allmat,"data/derived/2prob_term_molt_males_new.csv")

male_mat_alt<-melt(allmat)
names(male_mat_alt)<-c("year","size","prop_mature")
png("plots/maturity_facet.png",height=8,width=8,res=400,units='in')
p<-ggplot(male_mat_alt)+
  geom_line(aes(x=size ,y=prop_mature,group=year,col=year),lwd=2)+
  scale_color_distiller(palette="RdYlBu", na.value="grey") +
  xlim(35,135)+theme_bw()+ylab("Proportion new shell mature")+
  xlab("Carapace width (mm)")+
  theme(legend.position=c(.9,.2))
print(p)
dev.off()

med_mat<-male_mat_alt%>%
  group_by(size)%>%
  summarize(prop_mature=median(prop_mature))

png("plots/maturity_facet_all.png",height=10,width=8,res=400,units='in')
p<-ggplot(male_mat_alt)+
  geom_line(data=male_mat_alt,aes(x=size ,y=prop_mature,group=year,col=year),lwd=2)+
  geom_line(data=med_mat,aes(x=size ,y=prop_mature),col='red',lwd=1.2)+
  xlim(35,135)+theme_bw()+ylab("Proportion new shell mature")+
  xlab("Carapace width (mm)")+
  facet_wrap(~year)
print(p)
dev.off()

#==divide out to mature and immature
 in_mat<-allmat[-which(rownames(allmat)==2020),]
 MaleNewMature 	<-MaleNew*in_mat
 male_immature   <-MaleNew*(1-in_mat)
 male_mature<-MaleNewMature+MaleOld
 
 sc_male_mat<-sweep(male_mature,1,apply(male_mature,1,sum,na.rm=T),FUN="/")
 sc_male_imm<-sweep(male_immature,1,apply(male_immature,1,sum,na.rm=T),FUN="/")

write.table(round(sc_male_mat ,4), "data/derived/2surv_len_comp_male_mat_newmat.txt",row.names=FALSE,col.names=F)
write.table(round(sc_male_imm,4), "data/derived/2surv_len_comp_male_imm_newmat.txt",row.names=FALSE,col.names=F)

#==calculate biomass by different inputs
wt_at_size<-read.csv("data/wt_at_size.csv")
male_mat_bio<-apply(sweep(male_mature,2,wt_at_size[,1],FUN="*"),1,sum)
male_imm_bio<-apply(sweep(male_immature,2,wt_at_size[,1],FUN="*"),1,sum)

plot(male_mat_bio,type='b',ylim=c(0,400))
lines(male_imm_bio,type='b',col=2)

write.table(male_mat_bio,"data/derived/2index_mmb_new_mat.txt",row.names=FALSE,col.names=F)
write.table(male_imm_bio,"data/derived/2index_imm_male_new_mat.txt",row.names=FALSE,col.names=F)

#==show mature vs immature numbers at size by year
lng_mat<-melt(as.matrix(male_mature))
lng_mat$maturity<-"mature"
lng_imm<-melt(as.matrix(male_immature))
lng_imm$maturity<-"immature"

big_mat<-rbind(lng_mat,lng_imm)
colnames(big_mat)<-c("year",'Size','Abundance','maturity')
imm_v_mat<-ggplot(big_mat, aes(x = Size, y = Abundance, fill = maturity)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Numbers at size by maturity state by year",
       x = "Carapace width (mm)",
       y = "Survey abundance",
       fill = "Maturity")+
  facet_wrap(~year,ncol=5)+theme_bw()+
  theme(legend.position=c(.9,.05))
png("plots/imm_v_mat.png",height=10,width=8,res=400,units='in')
print(imm_v_mat)
dev.off()
