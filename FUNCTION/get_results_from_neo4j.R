#这里包含了三个函数，分别是获取基因跟KEGG/GO/基因的关系，而且，这三个函数仅仅用于gene relationship
#get_genes_to_kegg（）是用来获取在输入的keggid的情况下，哪些基因是属于kegg的。
#返回的是数据框

#get_genes_to_GO（）是用来获取在输入的GOid的情况下，哪些基因是属于GO的。
#返回的是数据框

#get_genes_to_genes() 比较复杂，
#1. groups是必须要求选择的，timepoint和weight可选，可不选
#2. 在选择的KEGG通路下所有的基因是否有关系，如果有，就返回结果，没有的话，结果是NULL
#3. 在选择的GO下所有的基因是否有关系，如果有，就返回结果，没有的话，结果是NULL
#4. 在选择的KEGG或/且GO下所有的基因是否有关系，如果有，就返回结果，没有的话，结果是NULL
#5. 当选择timepoint, 返回的是包含该时间点的该组的所有基因的关系；没有选的话，默认是全部
#6. weight的选择，可以选择最大值，也可以选择最小值

################################################################################
#获取基因跟kegg的关系
################################################################################
get_genes_to_kegg <- function(kegg_id){
  # kegg_id = options_input$kegg_id
  # kegg_id = c("hsa03320","hsa05131", "hsa05231")
  kegg_where <- paste0("kegg.KEGGID = '", kegg_id, "' ")
  kegg_where <- paste(kegg_where, collapse = " or ")
  query = paste0(
    "
  MATCH (genes:Genes)-[r:belongKEGG]->(kegg:KEGG_pathway)
  where ",kegg_where,
    "
  RETURN id(genes) AS genes_id,
         genes.Symbols AS genes,
         genes.GENENAME AS geneName,
         id(kegg) AS kegg_id,
         kegg.KEGGID AS kegg,
         kegg.DESCRPTION AS description
  "
  )
  genes_to_kegg <- cypher(graph, query)
  return(genes_to_kegg)
}


################################################################################
#获取基因跟GO的关系
################################################################################
get_genes_to_GO <- function(go_id){
  #go_id = options_input$go_id
  #go_id = c("GO:0000082","GO:0000098","GO:0000123", "GO:0000027")
  go_where = paste0("go.GOID = '",go_id, "' ")
  go_where = paste(go_where, collapse = "or ")
  query = paste0(
    "
  MATCH (genes:Genes)-[r:belongGO]->(go:GO_term)
  where ",go_where,
    "
  RETURN id(genes) AS genes_id,
         genes.Symbols AS genes,
         genes.GENENAME AS geneName,
         id(go) AS go_id,
         go.GOID AS go,
         go.ONTOLOGY AS ontology,
         go.TERM AS term
  "
  )
  genes_to_GO <- cypher(graph, query)
  return(genes_to_GO)
}

################################################################################
#获取基因跟基因之间的关系
################################################################################

get_genes_to_genes <- function(groups = NULL, 
                               timepoints = NULL,
                               kegg_id = NULL, 
                               go_id = NULL,
                               weight = c(0, 0.6)){
  source("FUNCTION/options_for_get_genes_rel.R")
  #=========================where options=========================================
  # #status_type_option
  status_type_option <- status_type_option_for_where(groups, timepoints) 
  
  # #weight_option-------------------------------
  status_timepoint_weight_option <- weight_option_for_where(groups,timepoints,
                                                            weight = weight)
  
  #========================return options=========================================
  status_type_return <- status_type_return_for_gg(groups)
  status_time_weight_return <- status_time_weight_return_for_gg(groups)
  
  #=========================where 语句=========================================
  if (is.null(timepoints)){
    where_centence <- paste0("where ", status_type_option)
  }else{
    where_centence <- paste0("where ", status_type_option, 
                             " AND ", status_timepoint_weight_option )
  }
  
  
  #========================return options=========================================
  return_centence <- paste0("RETURN id(A) AS A_id, A.Symbols AS ANode, id(B) AS B_id, B.Symbols AS BNode,A.GENENAME AS A_geneName, B.GENENAME AS B_geneName, ", 
                            status_type_return, ", ",status_time_weight_return)
  
  
  #########################query语句##############################################
  # kegg_id = NULL
  # go_id = NULL
  
  if (!is.null(kegg_id)){
    kegg_where <- paste0("kegg.KEGGID = '", kegg_id, "' ")
    kegg_where <- paste(kegg_where, collapse = " or ")
  }
  
  if (!is.null(go_id)){
    go_where = paste0("go.GOID = '",go_id, "' ")
    go_where = paste(go_where, collapse = "or ")
  }
  
  
  #如果没有选择kegg===========================
  if (is.null(kegg_id)){
    if (is.null(go_id)){
      #如果没选go--------------------------------
      query = paste0("MATCH (A:Genes)-[r:WGCNA]->(B:Genes)  ",
                     where_centence, "  ",
                     return_centence)
    }else{
      #如果选go--------------------------------
      query = paste0("MATCH (genes:Genes)-[r:belongGO]->(go:GO_term)
                    where ",go_where,
                     "
                    with collect(distinct id(genes)) AS ABgenesID 
                    ",
                     "MATCH (A:Genes)-[r:WGCNA]->(B:Genes)  ",
                     where_centence, "  AND id(A) in ABgenesID AND id(B) in ABgenesID  ",
                     return_centence)
    }
  }else{
    #如果选择kegg===========================
    if (is.null(go_id)){
      #如果没选go--------------------------------
      query = paste0("MATCH (kegg:KEGG_pathway)<-[r:belongKEGG]-(ABgenes)
                    where ",kegg_where,"
                    with collect(distinct id(ABgenes)) AS ABgenesID ",
                     "MATCH (A:Genes)-[r:WGCNA]->(B:Genes)  ",
                     where_centence, "  AND id(A) in ABgenesID AND id(B) in ABgenesID  ",
                     return_centence)
    }else{
      #如果选go--------------------------------
      query = paste0("MATCH (genes1:Genes)-[r:belongGO]->(go:GO_term)
                    where ",go_where,
                     "
                    with collect(distinct id(genes1)) AS GOgenesID 
                    ",
                     
                     "MATCH (genes2:Genes)-[r:belongKEGG]->(kegg:KEGG_pathway)
                   where ",kegg_where,
                     "with collect(distinct id(genes2)) AS KEGGgenesID, GOgenesID ",
                     
                     "MATCH (AB:Genes)
                   where id(AB) in KEGGgenesID or id(AB) in GOgenesID
                   with collect(id(AB)) AS ABgenesID ",
                     
                     "MATCH (A:Genes)-[r:WGCNA]->(B:Genes)  ",
                     where_centence, "  AND id(A) in ABgenesID AND id(B) in ABgenesID  ",
                     return_centence)
    }
  }
  
  #============query============================================================
  genes_to_genes = cypher(graph, query)
  
  return(genes_to_genes)
}
