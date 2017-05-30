setwd("~/git/subgraph/mgc_based/")

spatialCoor = read.csv("../covariates/spatial_coord.csv",stringsAsFactors = F)

coord<- cbind(spatialCoor$x_caudaL_rostral,spatialCoor$y_Right_left,spatialCoor$z_infgerior_superior)


#read in graphs
require('igraph')
require('ggplot2')
require('fields')

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

###
require("TensorEmbedding")

flat_y<- unlist(lapply(AdjacencyListPick,function(x) c(as.matrix(x))))
y = array(flat_y, dim=c(n,n,m))

# coord

testObj<- TensorEmbedding::symmetric_tensor_decomp_cov(y,coord,n,m, k=3, 500,lam = 400,delta1 = 1E-8,delta2 = 1E-8)
save(testObj,file="cov_embedding.RDa")

C = sapply(c(1:m),function(x)diag(testObj$C[,,x]))
plot(t(C[1:2,]),col=GENOTYPEPick)
plot(t(C[1:3,]),col=GENOTYPEPick)

library(plotly)

plotly_C = data.frame(t(C))
colnames(plotly_C)<- c("x","y","z")

p <- plot_ly(plotly_C, x = ~x, y = ~y, z = ~z, color = ~as.factor(GENOTYPEPick), colors = c('#BF382A', '#0C4B8E')) %>%
  add_markers() %>%
  layout(scene = list(xaxis = list(title = 'x'),
                      yaxis = list(title = 'y'),
                      zaxis = list(title = 'z')))

p
