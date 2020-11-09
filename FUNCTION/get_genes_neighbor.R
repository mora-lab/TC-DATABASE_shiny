#这里写的函数都是在gene——neighbor用得
#首先都是查询到基因，然后根据所选择来获取对应的关系

################################################################################
################################################################################
##################get_genes_neighbor############################################
################################################################################
get_genes_neighbor <- function(genes = NULL,
                               groups = NULL, 
                               timepoints = NULL,
                               weight = c(0, 0.6)){
  
  source("FUNCTION/options_for_get_genes_rel.R")
  #=========================where options=========================================
  #genes options--------------------------
  genes_options <- paste0("n.Symbols = '", genes, "' ")
  genes_options <- paste(genes_options, collapse = " OR ")
  
  #status_type_option------------------
  if (!is.null(groups)){
    # #status_type_option
    status_type_option <- status_type_option_for_where(groups, timepoints) 
    
    #weight_option-------------------------------
    status_timepoint_weight_option <- weight_option_for_where(groups,timepoints,
                                                              weight = weight)
  }
  
  #========================return options=========================================
  #status_type_return 返回'1010','1101'之类的 
  status_type_return <- status_type_return_for_gg(groups) #如果groups不存在，默认是返回所有

  #status_time_weight_return #返回各个时间的weight
  status_time_weight_return <- status_time_weight_return_for_gg(groups)#如果groups不存在，默认是返回所有
  
  #=========================where 语句=========================================
  if (!is.null(groups)){
    if (is.null(timepoints)){
      where_centence <- paste0("where id(A) in chose_genes_id "," AND ", status_type_option)
    }else{
      where_centence <- paste0("where id(A) in chose_genes_id  "," AND ", status_type_option, 
                               " AND ", status_timepoint_weight_option )
    }
  }else{
    where_centence <- paste0("where id(A) in chose_genes_id ")
  }
  
  
  
  #========================return options=========================================
  return_centence <- paste0("RETURN id(A) AS A_id, A.Symbols AS ANode, id(B) AS B_id, B.Symbols AS BNode,A.GENENAME AS A_geneName, B.GENENAME AS B_geneName, ", 
                            status_type_return, ", ",status_time_weight_return)
  
  #########################query语句##############################################
  query = paste0("MATCH (n:Genes)
                  where ",genes_options,
                 " with collect(distinct id(n)) AS chose_genes_id ",
                 "MATCH (A:Genes)-[r:WGCNA]-(B:Genes)  ",
                 where_centence, "  ",
                 return_centence)
      
  
  #============query============================================================
  genes_neighbor = unique(cypher(graph, query))
  
  return(genes_neighbor)
}



################################################################################
################################################################################
##################get_genesneighbor_to_KEGG#####################################
################################################################################
get_genesneighbor_to_KEGG <- function(genes = NULL,
                                      groups = NULL, 
                                      timepoints = NULL,
                                      weight = c(0, 0.6)){
  source("FUNCTION/options_for_get_genes_rel.R")
  #=========================where options=========================================
  #genes options--------------------------
  genes_options <- paste0("n.Symbols = '", genes, "' ")
  genes_options <- paste(genes_options, collapse = " OR ")
  
  #status_type_option------------------
  if (!is.null(groups)){
    # #status_type_option
    status_type_option <- status_type_option_for_where(groups, timepoints) 
    
    #weight_option-------------------------------
    status_timepoint_weight_option <- weight_option_for_where(groups,timepoints,
                                                              weight = weight)
  }
  
  #=========================where 语句=========================================
  if (!is.null(groups)){
    if (is.null(timepoints)){
      where_centence <- paste0("where id(A) in chose_genes_id "," AND ", status_type_option)
    }else{
      where_centence <- paste0("where id(A) in chose_genes_id  "," AND ", status_type_option, 
                               " AND ", status_timepoint_weight_option )
    }
  }else{
    where_centence <- paste0("where id(A) in chose_genes_id ")
  }
  
  #########################query语句##############################################
  query = paste0("MATCH (n:Genes)
                  where ",genes_options,
                 " with collect(distinct id(n)) AS chose_genes_id ",
                 "MATCH (A:Genes)-[r:WGCNA]-(B:Genes)  ",
                 where_centence, "  ",
                 "with collect(distinct id(A)) AS A_id, collect(distinct id(B)) AS B_id  
                 
                 MATCH (AB:Genes)
                 where id(AB) in A_id or id(AB) in B_id
                 with collect(distinct id(AB)) AS AB_id
                 
                 MATCH (genes:Genes)-[r1:belongKEGG]->(kegg:KEGG_pathway)
                 where id(genes) in AB_id
                 RETURN id(genes) AS genes_id,
                         genes.Symbols AS genes,
                         genes.GENENAME AS geneName,
                         id(kegg) AS kegg_id,
                         kegg.KEGGID AS kegg,
                         kegg.DESCRPTION AS description
                 ")
  
  
  #============query============================================================
  genes_neighbor_to_kegg = cypher(graph, query)
  
  return(genes_neighbor_to_kegg)
}


################################################################################
################################################################################
##################get_genesneighbor_to_GO#####################################
################################################################################
get_genesneighbor_to_GO <- function(genes = NULL,
                                      groups = NULL, 
                                      timepoints = NULL,
                                      weight = c(0, 0.6)){
  source("FUNCTION/options_for_get_genes_rel.R")
  #=========================where options=========================================
  #genes options--------------------------
  genes_options <- paste0("n.Symbols = '", genes, "' ")
  genes_options <- paste(genes_options, collapse = " OR ")
  
  #status_type_option------------------
  if (!is.null(groups)){
    # #status_type_option
    status_type_option <- status_type_option_for_where(groups, timepoints) 
    
    #weight_option-------------------------------
    status_timepoint_weight_option <- weight_option_for_where(groups,timepoints,
                                                              weight = weight)
  }
  
  #=========================where 语句=========================================
  if (!is.null(groups)){
    if (is.null(timepoints)){
      where_centence <- paste0("where id(A) in chose_genes_id "," AND ", status_type_option)
    }else{
      where_centence <- paste0("where id(A) in chose_genes_id  "," AND ", status_type_option, 
                               " AND ", status_timepoint_weight_option )
    }
  }else{
    where_centence <- paste0("where id(A) in chose_genes_id ")
  }
  
  #########################query语句##############################################
  query = paste0("MATCH (n:Genes)
                  where ",genes_options,
                 " with collect(distinct id(n)) AS chose_genes_id ",
                 "MATCH (A:Genes)-[r:WGCNA]-(B:Genes)  ",
                 where_centence, "  ",
                 "with collect(distinct id(A)) AS A_id, collect(distinct id(B)) AS B_id  
                 
                 MATCH (AB:Genes)
                 where id(AB) in A_id or id(AB) in B_id
                 with collect(distinct id(AB)) AS AB_id
                 
                 MATCH (genes:Genes)-[r1:belongGO]->(go:GO_term)
                 where id(genes) in AB_id
                 RETURN id(genes) AS genes_id,
                         genes.Symbols AS genes,
                         genes.GENENAME AS geneName,
                         id(go) AS go_id,
                         go.GOID AS go,
                         go.ONTOLOGY AS ontology,
                         go.TERM AS term
                 ")
  
  
  #============query============================================================
  genes_neighbor_to_go = cypher(graph, query)
  
  return(genes_neighbor_to_go)
}


################################################################################
################################################################################
##################get_genesneighbor_to_KEGG#####################################
################################################################################
only_get_genes_to_KEGG <- function(genes = NULL){
  #=========================where options=========================================
  #genes options--------------------------
  genes_options <- paste0("genes.Symbols = '", genes, "' ")
  genes_options <- paste(genes_options, collapse = " OR ")
  
  #########################query语句##############################################
  query = paste0("MATCH (genes:Genes)-[r1:belongKEGG]->(kegg:KEGG_pathway)
                 where ",genes_options,"  
                 RETURN id(genes) AS genes_id,
                         genes.Symbols AS genes,
                         genes.GENENAME AS geneName,
                         id(kegg) AS kegg_id,
                         kegg.KEGGID AS kegg,
                         kegg.DESCRPTION AS description
                 ")
  
  
  #============query============================================================
  only_genes_to_kegg = cypher(graph, query)
  
  return(only_genes_to_kegg)
}


################################################################################
################################################################################
##################get_genesneighbor_to_GO#####################################
################################################################################
only_get_genes_to_GO <- function(genes = NULL){
  #=========================where options=========================================
  #genes options--------------------------
  genes_options <- paste0("genes.Symbols = '", genes, "' ")
  genes_options <- paste(genes_options, collapse = " OR ")
  
  #########################query语句##############################################
  query = paste0("MATCH (genes:Genes)-[r1:belongGO]->(go:GO_term)
                 where ",genes_options,"  
                 RETURN id(genes) AS genes_id,
                         genes.Symbols AS genes,
                         genes.GENENAME AS geneName,
                         id(go) AS go_id,
                         go.GOID AS go,
                         go.ONTOLOGY AS ontology,
                         go.TERM AS term
                 ")
  
  
  #============query============================================================
  only_genes_to_go = cypher(graph, query)
  
  return(only_genes_to_go)
}
