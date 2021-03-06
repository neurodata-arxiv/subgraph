require('igraph')
require('ggplot2')
require('reshape')
# require('lsr')
source("MGCSampleStat.R")
source("MGCPermutationTest.R")
require("ggplot2")
require("fields")

setwd("~/git/subgraph/mgc_based/")

listGs<- list.files(path = "../graphml/", pattern = "*.graphml")

#read in covariates and graph list
#find those with common ids, sort by id

covariates<- read.csv("../covariates/predictors.csv",stringsAsFactors = F)
ids <- unlist( lapply(listGs,function(x)strtrim(x,6)))
common_id<- intersect(covariates$RUNNO , ids)

covariates <- covariates[covariates$RUNNO%in%common_id,]
covariates <- covariates[order(covariates$RUNNO),]  

listGs<- listGs[ids%in%common_id]
listGs<- listGs[order(listGs)]

graphList<- lapply(listGs, function(x){
  read.graph( file = paste("../graphml/",x,sep = ""),format = "graphml")
})

AdjacencyList<- lapply(graphList, function(x){
  get.adjacency(x)
})

HemisphereList<- lapply(graphList, function(x){
  get.vertex.attribute(x,name="hemisphere")
})

DegreeList<- lapply(AdjacencyList, function(x){
  rowSums(as.matrix(x))
  })

n = nrow(AdjacencyList[[1]])
########################
## Compute all local corr
library(ecodist)
library(energy)
library(HHG)
source("MGCLocalCorr.R")
source("MGCSampleStat.R")


LowerTriMatrix = sapply(AdjacencyList,function(x){
  x = as.matrix(x)
  x[lower.tri(x)]
})


AdjMatrix = t(LowerTriMatrix[,covariates$GENOTYPE>=1])
GenoType = covariates$GENOTYPE[covariates$GENOTYPE>=1]
Gender = covariates$GENDER[covariates$GENOTYPE>=1]


A = as.matrix(dist(AdjMatrix))
B = as.matrix(dist(GenoType))
C = as.matrix(dist(Gender))
####
orderByGenotype = order(GenoType)

m = nrow(A)

df = data.frame( "idx"=rep(c(1:m),m),"dist" = c(A), "id"=as.factor(rep(c(1:m),each=m)),"GenoType"=as.factor(rep(GenoType,each=m)),"Gender"=as.factor(rep(Gender,each=m)))

ggplot(df, aes(x=idx, y=dist,col=GenoType)) +  geom_point(shape=1)+ facet_grid(~id)

ggplot(df, aes(x=idx, y=dist,col=Gender)) +  geom_point(shape=1)+ facet_grid(~id)

image.plot(A)
image.plot(B)

#####
orderByGender = order(Gender)

image.plot(A[orderByGender,orderByGender])
image.plot(C[orderByGender,orderByGender])

##### test against Genotype ####
mgc_result = MGCSampleStat(A,B)
mgc_result

MGCLocalCorr(A,B,option='mcor')$corr

permuate_test = MGCPermutationTest(A,B,rep=1000,option='mcor')
permuate_test
#############################

##### test against Gender ####
mgc_result = MGCSampleStat(A,C)
mgc_result

MGCLocalCorr(A,C,option='mcor')$corr

permuate_test = MGCPermutationTest(A,C,rep=1000,option='mcor')
permuate_test
#############################

