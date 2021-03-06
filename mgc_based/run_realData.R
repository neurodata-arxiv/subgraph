# load the data
load("BrainHippoShape.RData")
### Compute all local corr
library(ecodist)
library(energy)
library(HHG)
source("MGCLocalCorr.R")
C=LMRS;P=as.matrix(dist(Label+0.01*runif(n)));
ldcorr=MGCLocalCorr(C,P,option='dcor')$corr;
lmdcorr=MGCLocalCorr(C,P,option='mcor')$corr;
lmantel=MGCLocalCorr(C,P,option='mantel')$corr;
### Global corr from the original authors. 
### Their p-values in permutation test should be very similar to our local corr at largest scale,
### but the actual statistic can be slightly different.
# global dcorr
dcorr=dcor(as.dist(C),as.dist(P));
# global mcorr
mdcorr=dcor.ttest(C,P,distance=TRUE);
# Mantel test
mantel=mantel(as.dist(C)~as.dist(P),nperm=1000);
# HHG test
hhgr=hhg.test(C,P,nr.perm=1000);


### Permutation Test of local corr
source("MGCPermutationTest.R")
C=LMRS;P=as.matrix(dist(Label+0.01*runif(n)));
test=MGCPermutationTest(C,P,rep=1000,option='mcor')



load("BrainCPData.RData")
source("MGCLocalCorr.R")
library(ecodist)
library(energy)
library(HHG)
C=distC;P=distP;ind=723;
ldcorr=MGCLocalCorr(C,P,option='dcor')$corr;
lmdcorr=MGCLocalCorr(C,P,option='mcor')$corr;
weight=MGCLocalCorr(C,P,option='mcor',ind);
lmantel=MGCLocalCorr(C,P,option='mantel')$corr;
dcorr=dcor(as.dist(C),as.dist(P));
mdcorr=dcor.ttest(C,P,distance=TRUE);
mantel=mantel(as.dist(C)~as.dist(P),nperm=1000);
hhgr=hhg.test(C,P,nr.perm=1000);

### Permutation Test of local corr
source("MGCSampleStat.R")
test=MGCSampleStat(C,P)
source("MGCPermutationTest.R")
test=MGCPermutationTest(C,P,rep=1000,option='mcor')
