``` r
setwd("~/git/subgraph/mgc_based/")

require('igraph')
```

    ## Loading required package: igraph

    ## 
    ## Attaching package: 'igraph'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum

    ## The following object is masked from 'package:base':
    ## 
    ##     union

``` r
require('ggplot2')
```

    ## Loading required package: ggplot2

``` r
require('fields')
```

    ## Loading required package: fields

    ## Loading required package: spam

    ## Loading required package: grid

    ## Spam version 1.4-0 (2016-08-29) is loaded.
    ## Type 'help( Spam)' or 'demo( spam)' for a short introduction 
    ## and overview of this package.
    ## Help for individual functions is also obtained by adding the
    ## suffix '.spam' to the function name, e.g. 'help( chol.spam)'.

    ## 
    ## Attaching package: 'spam'

    ## The following objects are masked from 'package:base':
    ## 
    ##     backsolve, forwardsolve

    ## Loading required package: maps

``` r
options(max.print=100)

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

n = nrow(AdjacencyList[[1]])
half = c(1:(n/2))
reordered = c( half*2-1,half*2)


AdjacencyList<- lapply(AdjacencyList, function(x){
  x[reordered,reordered]
})

HemisphereList<- lapply(graphList, function(x){
  get.vertex.attribute(x,name="hemisphere")
})

DegreeList<- lapply(AdjacencyList, function(x){
  rowSums(as.matrix(x))
  })

####

AdjacencyListPick =  list()
for(i in 1:length(AdjacencyList)){
  if(covariates$GENOTYPE[i]>=1){
    AdjacencyListPick[[length(AdjacencyListPick)+1]] = AdjacencyList[[i]]
  }
}

GENOTYPEPick = covariates$GENOTYPE[covariates$GENOTYPE>=1]

SEXPick = covariates$GENDER[covariates$GENOTYPE>=1]

m = length(GENOTYPEPick)
```

``` r
ase <- function(A, dim){
    if(nrow(A) >= 400){
        require(irlba)
        A.svd <- irlba(A, nu = dim, nv = dim)
        A.svd.values <- A.svd$d[1:dim]
        A.svd.vectors <- A.svd$v[,1:dim]
        if(dim == 1)
            A.coords <- sqrt(A.svd.values) * A.svd.vectors
        else
            A.coords <- A.svd.vectors %*% diag(sqrt(A.svd.values))
    } else{
        A.svd <- svd(A)
        if(dim == 1)
            A.coords <- A.svd$v[,1] * sqrt(A.svd$d[1])
        else
            A.coords <- A.svd$v[,1:dim] %*% diag(sqrt(A.svd$d[1:dim]))
    }

   return(list(Xhat=A.coords,scree=A.svd))
}
```

Omni-embed into 2 dimensions, leading to (332\*2) points for each graph

``` r
# 
# Alist.log <- lapply(AdjacencyListPick, function(x) log(x + t(x)+1))
# Alist.da <- lapply(Alist.log, function(y) y + diag(x=rowSums(y))/(n-1))
# 
# i=1
# 
# dhat <- 2
# Tmat <- normT <- matrix(0,m,m)
# pcol1 <- rep(c(1,3),each=n/2)
# pcol2 <- rep(c(2,4),each=n/2)
# 
# 
# require(Matrix)
# nm = n*m
# # omniA = sparseMatrix(i=1,j=1,x=0, dims=c(nm,nm))
# 
# omniA = matrix(0, nm,nm)
# for(i in 1:m) {
#     for(j in 1:i) {
#         Ad <- as.matrix((Alist.da[[i]] + Alist.da[[j]]) / 2)
#         i_idx1 =  n* (i-1)+1 
#         i_idx2 = (n* i)
#         j_idx1 =  n* (j-1)+1 
#         j_idx2 = (n* j)
#         omniA[i_idx1: i_idx2,j_idx1: j_idx2] = Ad
#         omniA[j_idx1: j_idx2,i_idx1: i_idx2] = t(Ad)
#     }
#   print(i)
# }
# 
# dmax <- 2
# Xhat.out <- ase(omniA,dmax)
# 
# save(Xhat.out,file ="omni_embedding.Rda")
```

``` r
load(file ="omni_embedding.Rda")
```

``` r
require("ggplot2")

Xhat = Xhat.out$Xhat

df = data.frame( "x1"=Xhat[,1] ,"x2"=Xhat[,2], "id"= as.factor(rep(c(1:m),each=n)),"genotype"= as.factor(rep(GENOTYPEPick,each=n)),"sex"=as.factor(rep(SEXPick,each=n)))
```

Scatterplot, colored by genotype

``` r
ggplot(df, aes(x=x1, y=x2,col=genotype, group=id)) +  geom_point()
```

![](Figs/unnamed-chunk-6-1.png)

Scatterplot, colored by sex

``` r
ggplot(df, aes(x=x1, y=x2,col=sex, group=id)) +  geom_point()
```

![](Figs/unnamed-chunk-7-1.png)
