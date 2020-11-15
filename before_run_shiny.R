library(visNetwork)
library(RNeo4j)
library(ggalluvial)
library(ggplot2)


#连接数据库-----------------------------------------------------------------------
#graph = startGraph("http://192.168.1.104:7474/db/data/", username="neo4j", password="xiaowei")
#load("data/data_for_shiny.RData")

############获取keggID、KEGG通路名称的表格########################
query = "
MATCH (kegg:KEGG_pathway)
RETURN kegg.KEGGID AS KEGGID,
       kegg.DESCRPTION AS DESCRIPTION"

kegg_table <- unique(cypher(graph, query))


############获取GOID、GO术语名称的表格########################
query = "
MATCH (go:GO_term)
RETURN go.GOID AS GOID,
       go.TERM AS TERM
"
go_table <- unique(cypher(graph, query))

#############获取所有基因名称的表格############################
query = "
MATCH (genes:Genes)
RETURN genes.Symbols AS SYMBOL,
genes.GENENAME AS geneName,
genes.ENTREZID AS entrezid
"
all_genes <- unique(cypher(graph,query))


#############基因表达量########################################
load("data/gene_exp.RData")
# save(gene_exp, file = "data/gene_exp.RData")
# 
# save(all_genes,
#      gene_exp,
#      go_table,
#      kegg_table,
#      file = "data_for_shiny.RData")
