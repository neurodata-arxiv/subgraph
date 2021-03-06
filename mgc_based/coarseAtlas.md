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

TriangleList <-  lapply(graphList, function(x){
  a=count_triangles(x)
  a[reordered]
})


CluscoeffList<- lapply(graphList, function(x){
  a=transitivity(x,"local")
  a[reordered]
})

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
TriangleListPick =list()
CluscoeffListPick = list()
for(i in 1:length(AdjacencyList)){
  if(covariates$GENOTYPE[i]>=1){
    AdjacencyListPick[[length(AdjacencyListPick)+1]] = AdjacencyList[[i]]
    TriangleListPick[[length(TriangleListPick)+1]] = TriangleList[[i]]
    CluscoeffListPick[[length(CluscoeffListPick)+1]] = CluscoeffList[[i]]
  }
}


DegreeListPick<- lapply(AdjacencyListPick, function(x){
  rowSums(as.matrix(x))
  })



GENOTYPEPick = covariates$GENOTYPE[covariates$GENOTYPE>=1]

SEXPick = covariates$GENDER[covariates$GENOTYPE>=1]

m = length(GENOTYPEPick)
```

``` r
atlas = read.csv("../graphml/mouse_atlas.csv")

atlas = atlas[!is.na(atlas$Value),]

atlas = atlas[order(atlas$Value),]
```

``` r
extractRegionCount <- function(levels){
  
regions = apply( cbind(rep(c("L","R"), n/2), rep(as.character(levels),each=2)),1, function(x)paste(x[1],x[2],sep="-"))

regionsSorted = regions[reordered]

u_regions = unique(regionsSorted)
n_regions = length(u_regions)

n_regions


RegionCounts<- lapply(AdjacencyListPick, function(x){
  m = matrix(0,n_regions,n_regions)
  for(i in 1:n_regions){
    pick_i = regionsSorted == u_regions[i]
    for(j in 1:n_regions){
        pick_j = regionsSorted == u_regions[j]
        m[i,j] = sum(x[pick_i,pick_j])
      }
  }
  
  row.names(m) = u_regions
  colnames(m) = u_regions

  m
})

RegionCounts
}

RegionCounts_lv1 = extractRegionCount(atlas$Level_1)
RegionCounts_lv2 = extractRegionCount(atlas$Level_2)
RegionCounts_lv3 = extractRegionCount(atlas$Level_3)
RegionCounts_lv4 = extractRegionCount(atlas$Level_4)
```

Average Adjacency Plots
=======================

1.  At level 1 atlas:

Genotype 1 vs 2

``` r
RegionCounts = RegionCounts_lv1
geno1 = c(1:m)[GENOTYPEPick == 1]

n_regions = nrow(RegionCounts[[1]])


Asum = matrix(0, n_regions,n_regions)
for(i in geno1){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno1 = Asum/length(geno1)

geno2 = c(1:m)[GENOTYPEPick == 2]

Asum = matrix(0, n_regions,n_regions)
for(i in geno2){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno2 = Asum/length(geno2)

par(mfrow=c(1,2))
zlim = range(c(avgGeno1, avgGeno2))

image.plot(avgGeno1,zlim=zlim)
image.plot(avgGeno2,zlim=zlim)
```

![](FigCoarse/unnamed-chunk-4-1.png)

Most of the regions seem to have no difference, except the connections between forebrain region (1 & 6) across L and R hemispheres:

Absolute difference in averages

``` r
image.plot(abs(avgGeno1-avgGeno2))
```

![](FigCoarse/unnamed-chunk-5-1.png)

``` r
region11 = sapply(RegionCounts,function(x){
  x[1,1]
})

region16 = sapply(RegionCounts,function(x){
  x[1,6]
})

region66 = sapply(RegionCounts,function(x){
  x[6,6]
})
```

Across L-R in forebrain

``` r
df = data.frame("total_edges"= c(region16), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=genotype,group=genotype))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~genotype)
```

![](FigCoarse/unnamed-chunk-7-1.png)

``` r
x1 = df$total_edges[df$genotype==1]
x2 = df$total_edges[df$genotype==2]

wilcox.test(x1,x2, alternative = "greater")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 79, p-value = 0.04077
    ## alternative hypothesis: true location shift is greater than 0

``` r
kruskal.test(df$total_edges~as.factor(df$genotype))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 3.1566, df = 1, p-value = 0.07562

Within L-region forebrain

``` r
df = data.frame("total_edges"= c(region11), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=genotype,group=genotype))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~genotype)
```

![](FigCoarse/unnamed-chunk-8-1.png)

``` r
x1 = df$total_edges[df$genotype==1]
x2 = df$total_edges[df$genotype==2]

wilcox.test(x1,x2, alternative = "two.sided")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 66, p-value = 0.4221
    ## alternative hypothesis: true location shift is not equal to 0

``` r
kruskal.test(df$total_edges~as.factor(df$genotype))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 0.72727, df = 1, p-value = 0.3938

Within R-region forebrain

``` r
df = data.frame("total_edges"= c(region66), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=genotype,group=genotype))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~genotype)
```

![](FigCoarse/unnamed-chunk-9-1.png)

``` r
x1 = df$total_edges[df$genotype==1]
x2 = df$total_edges[df$genotype==2]

wilcox.test(x1,x2, alternative = "two.sided")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 69, p-value = 0.31
    ## alternative hypothesis: true location shift is not equal to 0

``` r
kruskal.test(df$total_edges~as.factor(df$genotype))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 1.1364, df = 1, p-value = 0.2864

1.  At level 2 atlas:

Genotype 1 vs 2

``` r
RegionCounts = RegionCounts_lv2
geno1 = c(1:m)[GENOTYPEPick == 1]

n_regions = nrow(RegionCounts[[1]])


Asum = matrix(0, n_regions,n_regions)
for(i in geno1){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno1 = Asum/length(geno1)

geno2 = c(1:m)[GENOTYPEPick == 2]

Asum = matrix(0, n_regions,n_regions)
for(i in geno2){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno2 = Asum/length(geno2)

par(mfrow=c(1,2))

zlim = range(c(avgGeno1, avgGeno2))
image.plot(avgGeno1, zlim= zlim)
image.plot(avgGeno2, zlim= zlim)
```

![](FigCoarse/unnamed-chunk-10-1.png)

Absolute difference in averages

``` r
image.plot(abs(avgGeno1-avgGeno2))
```

![](FigCoarse/unnamed-chunk-11-1.png)

Most different region names:

``` r
nregion = nrow(avgGeno1)


diff = abs(avgGeno1-avgGeno2)

pick = diff == (sort(diff,decreasing = T)[3])

colnames(avgGeno1)[colSums(pick)>0]
```

    ## [1] "L-1_secondary_prosencephalon" "R-1_secondary_prosencephalon"

``` r
pick_idx = c(1:nregion)[colSums(pick)>0]
```

Most different region names:

Across L-R

``` r
nregion = nrow(avgGeno1)
region16 = sapply(RegionCounts,function(x){
  x[pick_idx[1], pick_idx[2]]
})

df = data.frame("total_edges"= c(region16), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=genotype,group=genotype))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~genotype)
```

![](FigCoarse/unnamed-chunk-13-1.png)

``` r
x1 = df$total_edges[df$genotype==1]
x2 = df$total_edges[df$genotype==2]

wilcox.test(x1,x2, alternative = "greater")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 73, p-value = 0.0965
    ## alternative hypothesis: true location shift is greater than 0

``` r
kruskal.test(df$total_edges~as.factor(df$genotype))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 1.8232, df = 1, p-value = 0.1769

Not significantly different.

1.  At level 3 atlas:

Genotype 1 vs 2

``` r
RegionCounts = RegionCounts_lv3
geno1 = c(1:m)[GENOTYPEPick == 1]

n_regions = nrow(RegionCounts[[1]])


Asum = matrix(0, n_regions,n_regions)
for(i in geno1){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno1 = Asum/length(geno1)

geno2 = c(1:m)[GENOTYPEPick == 2]

Asum = matrix(0, n_regions,n_regions)
for(i in geno2){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno2 = Asum/length(geno2)

par(mfrow=c(1,2))

zlim = range(c(avgGeno1, avgGeno2))
image.plot(avgGeno1, zlim= zlim)
image.plot(avgGeno2, zlim= zlim)
```

![](FigCoarse/unnamed-chunk-14-1.png)

Absolute difference in averages

``` r
image.plot(abs(avgGeno1-avgGeno2))
```

![](FigCoarse/unnamed-chunk-15-1.png)

Most different region names:

``` r
nregion = nrow(avgGeno1)


diff = abs(avgGeno1-avgGeno2)

pick = diff == (sort(diff,decreasing = T)[3])

colnames(avgGeno1)[colSums(pick)>0]
```

    ## [1] "L-1_isocortex" "R-1_isocortex"

``` r
pick_idx = c(1:nregion)[colSums(pick)>0]
```

Most different region names:

Across L-R

``` r
nregion = nrow(avgGeno1)
region16 = sapply(RegionCounts,function(x){
  x[pick_idx[1], pick_idx[2]]
})

df = data.frame("total_edges"= c(region16), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=genotype,group=genotype))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~genotype)
```

![](FigCoarse/unnamed-chunk-17-1.png)

``` r
x1 = df$total_edges[df$genotype==1]
x2 = df$total_edges[df$genotype==2]

wilcox.test(x1,x2, alternative = "greater")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 66, p-value = 0.2111
    ## alternative hypothesis: true location shift is greater than 0

``` r
kruskal.test(df$total_edges~as.factor(df$genotype))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 0.72727, df = 1, p-value = 0.3938

Not significantly different.

1.  At level 4 atlas:

Genotype 1 vs 2

``` r
RegionCounts = RegionCounts_lv4
geno1 = c(1:m)[GENOTYPEPick == 1]

n_regions = nrow(RegionCounts[[1]])


Asum = matrix(0, n_regions,n_regions)
for(i in geno1){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno1 = Asum/length(geno1)

geno2 = c(1:m)[GENOTYPEPick == 2]

Asum = matrix(0, n_regions,n_regions)
for(i in geno2){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno2 = Asum/length(geno2)

par(mfrow=c(1,2))

zlim = range(c(avgGeno1, avgGeno2))
image.plot(avgGeno1, zlim= zlim)
image.plot(avgGeno2, zlim= zlim)
```

![](FigCoarse/unnamed-chunk-18-1.png)

Absolute difference in averages

``` r
image.plot(abs(avgGeno1-avgGeno2))
```

![](FigCoarse/unnamed-chunk-19-1.png)

Most different region names:

``` r
nregion = nrow(avgGeno1)


diff = abs(avgGeno1-avgGeno2)

pick = diff == (sort(diff,decreasing = T)[3])

colnames(avgGeno1)[colSums(pick)>0]
```

    ## [1] "L-1_pons"                     "R-3_pontomedullary_hindbrain"

``` r
pick_idx = c(1:nregion)[colSums(pick)>0]
```

Across L-R

``` r
nregion = nrow(avgGeno1)
region16 = sapply(RegionCounts,function(x){
  x[pick_idx[1], pick_idx[2]]
})



df = data.frame("total_edges"= c(region16), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=genotype,group=genotype))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~genotype)
```

![](FigCoarse/unnamed-chunk-21-1.png)

``` r
x1 = df$total_edges[df$genotype==1]
x2 = df$total_edges[df$genotype==2]

wilcox.test(x1,x2, alternative = "greater")
```

    ## 
    ##  Wilcoxon rank sum test with continuity correction
    ## 
    ## data:  x1 and x2
    ## W = 96.5, p-value = 0.001388
    ## alternative hypothesis: true location shift is greater than 0

``` r
kruskal.test(df$total_edges~as.factor(df$genotype))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 9.1641, df = 1, p-value = 0.002468

Significantly different.

Average Adjacency Plots for Sex
===============================

As reference, we do not find signals in sex.

Sex 1 vs 2

``` r
RegionCounts=   RegionCounts_lv1
geno1 = c(1:m)[SEXPick == 1]

n_regions= nrow(RegionCounts[[1]])

Asum = matrix(0, n_regions,n_regions)
for(i in geno1){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno1 = Asum/length(geno1)

geno2 = c(1:m)[SEXPick == 2]

Asum = matrix(0, n_regions,n_regions)
for(i in geno2){
    Asum = Asum + as.matrix(RegionCounts[[i]])
}

avgGeno2 = Asum/length(geno2)

par(mfrow=c(1,2))
zlim = range(c(avgGeno1,avgGeno2))
image.plot(avgGeno1,zlim=zlim)
image.plot(avgGeno2,zlim=zlim)
```

![](FigCoarse/unnamed-chunk-22-1.png)

Absolute difference in averages

``` r
image.plot(abs(avgGeno1-avgGeno2))
```

![](FigCoarse/unnamed-chunk-23-1.png)

Connections within forebrain (region 1 and 6) seem to have most difference.

Across L-R in forebrain

``` r
df = data.frame("total_edges"= c(region16), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=sex,group=sex))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~sex)
```

![](FigCoarse/unnamed-chunk-24-1.png)

``` r
x1 = df$total_edges[df$sex==1]
x2 = df$total_edges[df$sex==2]

wilcox.test(x1,x2, alternative = "two.sided")
```

    ## 
    ##  Wilcoxon rank sum test with continuity correction
    ## 
    ## data:  x1 and x2
    ## W = 64.5, p-value = 0.5253
    ## alternative hypothesis: true location shift is not equal to 0

``` r
kruskal.test(df$total_edges~as.factor(df$sex))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 0.44956, df = 1, p-value = 0.5025

Within L-region forebrain

``` r
df = data.frame("total_edges"= c(region11), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=sex,group=sex))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~sex)
```

![](FigCoarse/unnamed-chunk-25-1.png)

``` r
x1 = df$total_edges[df$sex==1]
x2 = df$total_edges[df$sex==2]

wilcox.test(x1,x2, alternative = "two.sided")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 53, p-value = 0.9177
    ## alternative hypothesis: true location shift is not equal to 0

``` r
kruskal.test(df$total_edges~as.factor(df$sex))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 0.019835, df = 1, p-value = 0.888

Within R-region forebrain

``` r
df = data.frame("total_edges"= c(region66), "id"= as.factor((c(1:m))),"genotype"= as.factor(GENOTYPEPick),"sex"= as.factor(SEXPick))

ggplot(data=df, aes(x= 1, y=total_edges,col=sex,group=sex))+ geom_point()+geom_jitter()+geom_boxplot(alpha=0.5)+facet_grid(~sex)
```

![](FigCoarse/unnamed-chunk-26-1.png)

``` r
x1 = df$total_edges[df$sex==1]
x2 = df$total_edges[df$sex==2]

wilcox.test(x1,x2, alternative = "two.sided")
```

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 54, p-value = 0.9725
    ## alternative hypothesis: true location shift is not equal to 0

``` r
kruskal.test(df$total_edges~as.factor(df$sex))
```

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 0.0049587, df = 1, p-value = 0.9439
