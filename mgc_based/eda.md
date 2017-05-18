Raw Adjacency Plots
===================

Raw Adjacency Plots for Genotype 1

![](FigsEDA/unnamed-chunk-2-1.png)![](FigsEDA/unnamed-chunk-2-2.png)![](FigsEDA/unnamed-chunk-2-3.png)![](FigsEDA/unnamed-chunk-2-4.png)

Raw Adjacency Plots for Genotype 2

![](FigsEDA/unnamed-chunk-3-1.png)![](FigsEDA/unnamed-chunk-3-2.png)![](FigsEDA/unnamed-chunk-3-3.png)![](FigsEDA/unnamed-chunk-3-4.png)![](FigsEDA/unnamed-chunk-3-5.png)![](FigsEDA/unnamed-chunk-3-6.png)

Average Adjacency Plots
=======================

Genotype 1

![](FigsEDA/unnamed-chunk-4-1.png) Genotype 2

![](FigsEDA/unnamed-chunk-5-1.png)

Degree Distribution
===================

Plotted over two genotypes

![](FigsEDA/unnamed-chunk-6-1.png)

Plotted over two sex ![](FigsEDA/unnamed-chunk-7-1.png)

Betweenness Centrality Distribution
===================================

Plotted over two genotypes

![](FigsEDA/unnamed-chunk-8-1.png)

Plotted over two sex

![](FigsEDA/unnamed-chunk-9-1.png)

<!-- Genotype1 -->
<!-- ```{r} -->
<!-- par(mfrow=c(1,2)) -->
<!-- for(i in geno1){ -->
<!--     img = as.matrix(LRSumList[[i]]) -->
<!--     image.plot(img,main=i, zlim=c(0,7000)) -->
<!-- } -->
<!-- ``` -->
<!-- Genotype2 -->
<!-- ```{r} -->
<!-- par(mfrow=c(1,2)) -->
<!-- for(i in geno2){ -->
<!--     img = as.matrix(LRSumList[[i]]) -->
<!--     image.plot(img,main=i, zlim=c(0,7000)) -->
<!-- } -->
<!-- ``` -->
<!-- Average -->
<!-- Genotype 1 -->
<!-- ```{r} -->
<!-- Asum = matrix(0, 2,2) -->
<!-- for(i in geno1){ -->
<!--     Asum = Asum + as.matrix(LRSumList[[i]]) -->
<!-- } -->
<!-- avgGeno1 = Asum/length(geno1) -->
<!-- image.plot(avgGeno1, zlim=c(0,7000)) -->
<!-- ``` -->
<!-- Genotype 2 -->
<!-- ```{r} -->
<!-- Asum = matrix(0, 2,2) -->
<!-- for(i in geno2){ -->
<!--     Asum = Asum + as.matrix(LRSumList[[i]]) -->
<!-- } -->
<!-- avgGeno2 = Asum/length(geno2) -->
<!-- image.plot(avgGeno2, zlim=c(0,7000)) -->
<!-- ``` -->
total edges
===========

Over genotype ![](FigsEDA/unnamed-chunk-14-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 62, p-value = 0.01728
    ## alternative hypothesis: true location shift is greater than 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 4.5297, df = 1, p-value = 0.03331

Over sex ![](FigsEDA/unnamed-chunk-15-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 33, p-value = 0.5457
    ## alternative hypothesis: true location shift is not equal to 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 0.4386, df = 1, p-value = 0.5078

edges in left hemisphere
========================

Over genotype ![](FigsEDA/unnamed-chunk-17-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 66, p-value = 0.005688
    ## alternative hypothesis: true location shift is greater than 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 6.203, df = 1, p-value = 0.01275

Over sex ![](FigsEDA/unnamed-chunk-18-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 46, p-value = 0.6665
    ## alternative hypothesis: true location shift is not equal to 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 0.23587, df = 1, p-value = 0.6272

edges in right hemisphere
=========================

Over genotype ![](FigsEDA/unnamed-chunk-21-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 45, p-value = 0.2981
    ## alternative hypothesis: true location shift is greater than 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 0.34655, df = 1, p-value = 0.5561

Over sex ![](FigsEDA/unnamed-chunk-22-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 42, p-value = 0.9314
    ## alternative hypothesis: true location shift is not equal to 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 0.017544, df = 1, p-value = 0.8946

edges across left and right
===========================

Over genotype ![](FigsEDA/unnamed-chunk-25-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 62, p-value = 0.01728
    ## alternative hypothesis: true location shift is greater than 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$genotype)
    ## Kruskal-Wallis chi-squared = 4.5297, df = 1, p-value = 0.03331

Over sex ![](FigsEDA/unnamed-chunk-26-1.png)

    ## 
    ##  Wilcoxon rank sum test
    ## 
    ## data:  x1 and x2
    ## W = 24, p-value = 0.1615
    ## alternative hypothesis: true location shift is not equal to 0

    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  df$total_edges by as.factor(df$sex)
    ## Kruskal-Wallis chi-squared = 2.1228, df = 1, p-value = 0.1451
