# Shiny app
This shiny app can find out those genes relationship following time in COPD patients.

We used data from GEO data [GSE108134](https://pmlegacy.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE108134).
This data included three groups(COPD smoker, smoker and non-smoker) and four timepoints(0 months, 3 months, 6 months and 12 months).

In order to find out those genes relationship, we used [WGCNA package](https://horvath.genetics.ucla.edu/html/CoexpressionNetwork/Rpackages/WGCNA/)
to get genes relationship for each timepoints of each groups.

We also want to know KEGG pathway and Gene Ontology Term that genes belong to, so we used `clusterProfiler::download_KEGG()` download human KEGG pathway and `biomaRt` package for convert gene ID.
We used `GO.db` and `org.Hs.eg.db` package for Gene Ontology term.

After got genes relationship, Human KEGG pathway and Human GO term, we import all data to neo4j which is a graph database.

At the end, we built the shiny app that make us easily find out genes relationship following time.

In our disign, we made three tab: `Gene Relationships in KEGG Pathway/GO Term`, `Genes Neighborhoods Relationships` and `Alluvial Diagram`.

## Run this shiny

**Step1:**   
Before you run this shiny, you need to start [neo4j database(version = 3.5.23)](https://neo4j.com/download-center/#community) and using my database, so you need to download this [database](http://www.moralab.science/database/downloads/neo4j-copd20201115.tar.gz).  

**Step2** [Install package](install_package.R)

**Step3**  
```
library(RNeo4j)
#using your lacol neo4j, change the username and password
#graph = startGraph("http://localhost:7474/db/data/", username="neo4j", password="password")

#using my public neo4j
graph = startGraph("http://www.moralab.science:3838/db/data/", username="neo4j", password="xiaowei")

#runing shiny
library(shiny)
runGitHub("mora-lab/TC-DATABASE_shiny")
```

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
