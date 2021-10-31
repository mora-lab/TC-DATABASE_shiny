<img src="https://github.com/mora-lab/mora-lab.github.io/blob/master/picture/MORALAB_Banner.png">

# TC-DATABASE Shiny app

## Description

`TC-DATABASE` is a platform that combines a `neo4j` graph database with a `shiny` app to explore and analyze dynamic (temporal) biological networks. Analyses include dynamic behavior of pathway-related or GO-term-related subnetworks, gene neighborhoods, and gene modules, among others.

As default and example, we have included the dynamic coexpression network of gene expression data from small airway cells in non-smokers, healthy-smokers, and smokers with COPD (chronic obstructive pulmonary disease), during four time-points (0 months, 3 months, 6 months, and 12 months). We built the network from GEO data ([GSE108134](https://pmlegacy.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE108134)). We computed the gene-gene correlation coefficients (edge weights) using the [WGCNA package](https://horvath.genetics.ucla.edu/html/CoexpressionNetwork/Rpackages/WGCNA/) for each time-point and each group. For pathway information, we used `clusterProfiler::download_KEGG()` to download human KEGG pathways and the `biomaRt` package to convert gene IDs. For Gene Ontology (GO), we used the `GO.db` and `org.Hs.eg.db` packages.

After collecting all gene-gene correlation scores, KEGG pathways, and GO terms, we imported all data into the neo4j graph database, and built the shiny app to perform the different analyses and visualizations.

## Install and run TC-DATABASE:

### Step1: Install R packages:
Go to `R` and [install required R packages](install_package.R).

### Step2: Run this shiny app:

**Option a) Using neo4j from our lab**:
```R
# using our public neo4j:
library(RNeo4j)
graph = startGraph("http://www.moralab.science:3838/db/data/", username="neo4j", password="xiaowei")

#run shiny
library(shiny)
runGitHub("mora-lab/TC-DATABASE_shiny")
```

**Option b) Using your local neo4j**:<br>
Before you run this shiny app, you need to:<br>
(i) Start the [neo4j database (version = 3.5.23)](https://neo4j.com/download-center/#community).<br>
(ii) Download our <a href="http://www.moralab.science/downloads/database/neo4j-copd20201115.tar.gz" target="_blank" download="neo4j-copd20201115.tar.gz">database</a>.<br>
(iii) Unzip the downloaded file and copy it to the `$NEO4J_HOME/data/database` folder.<br>
(iv) Set `dbms.active_database=neo4j-copd20201115` in the `$NEO4J_HOME/conf/neo4j.conf` file.<br>

Now, you can go to R and run the following commands:

```R
library(RNeo4j)
# you should change the username and password in this command
graph = startGraph("http://localhost:7474/db/data/", username="neo4j", password="password")

#run shiny
library(shiny)
runGitHub("mora-lab/TC-DATABASE_shiny")
```

## Install TC-DATABASE from Docker and VirtualBox:
Click [here](https://github.com/mora-lab/TC-DATABASE_shiny/blob/master/Docker-and-VirtualBox.md)

## Tutorial:

The app consists of three tabs: `Gene Relationships in KEGG Pathway/GO Term`, `Genes Neighborhoods Relationships` and `Alluvial Diagram`.

## 1. Gene Relationships in KEGG Pathway/GO Term
This tab is for query genes relationship in each time and groups under KEGG pathway or/and GO term.

### 1.1 KEGG ID or KEGG pathway
You can input one or more KEGG ID or KEGG pathway to query. It means the genes are belong to KEGG pathway your query, and show that genes relationship.
if you didn't input KEGG ID or KEGG pathway, the result will not show you any about KEGG information or relationship.

### 1.2 GO ID or GO Term
You also can input one or more GO Term. It means the genes are belong to GO term your query, and show that genes relationship.
It is the same of KEGG option, the result will not show you any about GO information or relationship.

**Notes**   
You can input GO Term and KEGG pathway at the same time.

### 1.3 Groups
**You must choose at least one group for query.**  
We set this option has three groups: `COPD smoker`, `smoker` and `nonsmoker`.
You can chose one or more groups to get whether those genes have relationship under groups your query.

### 1.4 Timeponts
Here has 4 timepoints, when you chose those timepoints, it means you want to query those gene relationship at that timepoint(**NOT ONLY THAT TIMEPOINTS**).

### 1.5 Weight
This option will be show if you chose the timepoints.  
This weight is for WGCNA weight threshold, it has two option: the min weight and the max weight.

### 1.6 Plot
This option is ask you which type relationship you want plot in this network plot.
It has three option: `genes to genes`, `genes to KEGG`, `genes to GO`.
Only you chose KEGG pathway or GO, it will show you the `genes to KEGG` or `genes to GO` relationship.

### 1.7 Node information, Edge information, Network coordination scores and Download
That show you those nodes and edge information in the network plot. It also make some button for download those information.

![tab1.png](img/tab1.png)

## 2. Genes Neighborhoods Relationships
This tab is for query special genes relationship in each time and groups.

### 2.1 Gene symbol or entrezid
**You must choose at least one gene for query.** you can input gene symbol name or ENtrezid.  

### 2.2 Groups
**You must choose at least one group for query.**  
We set this option has three groups: `COPD smoker`, `smoker` and `nonsmoker`.
You can chose one or more groups to get whether those genes have relationship under groups your query.

### 2.3 Timeponts
Here has 4 timepoints, when you chose those timepoints, it means you want to query those gene relationship at that timepoint(**NOT ONLY THAT TIMEPOINTS**).

### 2.4 Weight
This option will be show if you chose the timepoints.  
This weight is for WGCNA weight threshold, it has two option: the min weight and the max weight.

### 2.5 Plot
This option is ask you which type relationship you want plot in this network plot.
It has three option: `genes to genes`, `genes to KEGG`, `genes to GO`.
**If you didn't chose `genes to genes`, it means you only want to plot relationship between KEGG/GO and genes your input.**

### Node information, Edge information, Network coordination scores and Download
That show you those nodes and edge information in the network plot. It also make some button for download those information.

![tab2.png](img/tab2.png)

## 3. Alluvial Diagram

### 3.1 Groups
We set this option has three groups: `COPD smoker`, `smoker` and `nonsmoker`.
You only chose one group to plot. This Alluvial plot will show you genes changing in WGNCA module in each timepoints in special group. 

### 3.2 Alluvial data and download
Here show you the alluvial plot data and download option.

![tab3.png](img/tab3.png)

*Last updated: Oct.31st, 2021*
