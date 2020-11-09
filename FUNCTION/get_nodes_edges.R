#source("FUNCTION/get_results_from_neo4j.R")

#三个函数，是在从neo4j中得到的结果后，用来整理node、edge信息的
#主要根据输入的结果不同而选择不同的函数
#返回的结果包含作图用的nodes，edges数据框，输出gene/kegg/Go nodes 和所有边的关系

################################################################################
#genes_to_kegg
################################################################################
#genes_to_kegg <- get_genes_to_kegg(kegg_id = c("hsa03320","hsa05131", "hsa05231"))

get_nodes_edges_kegg <- function(genes_to_kegg){
  if (!is.null(genes_to_kegg)){
    #------------genes nodes--------------------------------------------------
    genes_nodes <- genes_to_kegg[,c("genes_id", "genes")]
    names(genes_nodes) <- c("id", "label")
    genes_nodes$group <- "gene"
    genes_nodes$title <- paste0("Symbol: <b>", genes_to_kegg$genes, "</b><br>",
                                "geneName: <b>", genes_to_kegg$geneName, "</b>")
    genes_nodes$shape <- "ellipse"
    
    #------------kegg nodes--------------------------------------------------
    kegg_nodes <- genes_to_kegg[,c("kegg_id", "kegg")]
    names(kegg_nodes) <- c("id", "label")
    kegg_nodes$group <- "kegg"
    kegg_nodes$title <- paste0("ID: <b>", genes_to_kegg$kegg, "</b><br>",
                               "Description: <b>", genes_to_kegg$description, "</b>")
    kegg_nodes$shape <- "database"
    
    #------------nodes-------------------------------------------------------
    nodes <- rbind(genes_nodes, kegg_nodes )
    nodes <- unique(nodes)
    
    #-------------Edges------------------------------------------------------
    edges <- genes_to_kegg[,c("genes_id","kegg_id")]
    names(edges) <- c("from", "to")
    edges$color = "black"
    edges$title <- "belongKEGG"
    edges$dashes <- TRUE
    
    
    #----------------kegg_node----------------------------------------------
    kegg_node = unique(genes_to_kegg[,c("kegg","description")])
    colnames(kegg_node) <- c("KEGG IDs", "KEGG names")
    rownames(kegg_node) <- c(1:nrow(kegg_node))
    
    #---------------gene_node-----------------------------------------------
    gene_node = unique(genes_to_kegg[,c("genes","geneName")])
    colnames(gene_node) <- c("Gene Symbol", "Gene Name")
    rownames(gene_node) <- c(1:nrow(gene_node))
    
    #---------------edge_info-----------------------------------------------
    edge_info <- genes_to_kegg[,c("genes","kegg")]
    colnames(edge_info) = c("from", "to")
    edge_info$relationship = "Gene-KEGG"
    
    #------------return------------------------------------------------------
    return(list(nodes = nodes[,c("id","label","group","title","shape")],
                edges = edges[,c("from","to","title","color","dashes")],
                gene_node = gene_node,
                kegg_node = kegg_node,
                edge_info = edge_info
    )
    )
  }else{
    return(NULL) 
  }
  
}

################################################################################
#genes_to_GO
################################################################################
get_nodes_edges_GO <- function(genes_to_GO){
  if(!is.null(genes_to_GO)){
    #------------genes nodes--------------------------------------------------
    genes_nodes <- genes_to_GO[,c("genes_id", "genes")]
    names(genes_nodes) <- c("id", "label")
    genes_nodes$group <- "gene"
    genes_nodes$title <- paste0("Symbol: <b>", genes_to_GO$genes, "</b><br>",
                                "geneName: <b>", genes_to_GO$geneName, "</b>")
    genes_nodes$shape <- "ellipse"
    
    #------------GO nodes--------------------------------------------------
    go_nodes <- genes_to_GO[,c("go_id", "go")]
    names(go_nodes) <- c("id", "label")
    go_nodes$group <- paste0("go_",genes_to_GO$ontology)
    go_nodes$title <- paste0("ID: <b>", genes_to_GO$go, "</b><br>",
                             "Term: <b>", genes_to_GO$term, "</b><br>",
                             "Ontology: <b>", genes_to_GO$ontology, "</b>")
    go_nodes$shape <- "box"
    
    #------------nodes-------------------------------------------------------
    nodes <- rbind(genes_nodes, go_nodes )
    nodes <- unique(nodes)
    
    #-------------Edges------------------------------------------------------
    edges <- genes_to_GO[,c("genes_id","go_id")]
    names(edges) <- c("from", "to")
    edges$title <- "belongGO"
    edges$color = "black"
    edges$dashes <- TRUE
    
    #----------------GO_node----------------------------------------------
    GO_node = unique(genes_to_GO[,c("go","ontology","term")])
    colnames(GO_node) <- c("GO IDs", "GO Ontology", "GO Term")
    rownames(GO_node) <- c(1:nrow(GO_node))
    
    #---------------gene_node-----------------------------------------------
    gene_node = unique(genes_to_GO[,c("genes","geneName")])
    colnames(gene_node) <- c("Gene Symbol", "Gene Name")
    rownames(gene_node) <- c(1:nrow(gene_node))
    
    #---------------edge_info-----------------------------------------------
    edge_info <- genes_to_GO[,c("genes","go")]
    colnames(edge_info) = c("from", "to")
    edge_info$relationship = "Gene-GO"
    
    
    #------------return------------------------------------------------------
    return(list(nodes = nodes[,c("id","label","group","title","shape")],
                edges = edges[,c("from","to","title","color","dashes")],
                gene_node = gene_node,
                GO_node = GO_node,
                edge_info = edge_info
    ))
  }else{
    return(NULL)
  }
  
}


################################################################################
#genes_to_genes
################################################################################

get_nodes_edges_gg <- function(genes_to_genes,
                               groups){
  if (!is.null(genes_to_genes) & !is.null(groups)){
    #------------nodes--------------------------------------------------
    Anodes <- unique(genes_to_genes[,c("A_id", "ANode","A_geneName")])
    colnames(Anodes) <- c("id", "label", "geneName")
    Bnodes <- unique(genes_to_genes[,c("B_id", "BNode","B_geneName")])
    colnames(Bnodes) <- c("id", "label", "geneName")
    
    nodes <- unique(rbind(Anodes, Bnodes)) 
    
    #如果groups只有一个时，可以改变nodes的group属性,使节点呈现不同，更容易区分
    if (length(groups) != 1){
      nodes$group = "gene"
    }else{
      source("FUNCTION/define_nodes_group.R")
      nodes$group <- define_nodes_group(genes_to_genes, groups, nodes$id) 
    }
    
    nodes$title = paste0("Symbol: <b>", nodes$label, "</b><br>",
                         "geneName: <b>", nodes$geneName, "</b>")
    nodes$shape = "ellipse"
    
    #-------------Edges------------------------------------------------------
    edges <- genes_to_genes[,c("A_id", "B_id")]
    colnames(edges) <- c("from", "to")
    
    #title------------------
    source("FUNCTION/number_to_time.R")
    source("FUNCTION/title_for_groups_edges.R")
    edges$title <- title_for_groups_edges(genes_to_genes, groups)
    
    #如果groups只有一个时，给边上色，区别不同----------------color----------
    if(length(groups) != 1){
      edges$color <- "blue"
    }else{
      source("FUNCTION/define_edges_color.R")
      edge_type <- genes_to_genes[, paste0(groups, "_time")]
      edges$color <- sapply(edge_type, define_edges_color)
    }
    
    edges$dashes <- FALSE
    
    #--------------------gene_node------------------------------------------
    gene_node = unique(nodes[,c("label", "geneName")])
    colnames(gene_node) <- c("Gene Symbol", "Gene Name")
    rownames(gene_node) <- c(1:nrow(gene_node))
    
    #---------------edge_info-----------------------------------------------
    status_type = paste0(groups, "_time" )
    index <- names(genes_to_genes) %in% c("A_id", "B_id", "A_geneName", "B_geneName", status_type)
    edge_info <- genes_to_genes[, c(!index)]
    names(edge_info)[1:2] <- c("from", "to")
    edge_info$relationship <- "Gene-Gene"
    
    
    #------------return------------------------------------------------------
    return(list(nodes = nodes[,c("id","label","group","title","shape")],
                edges = edges[,c("from","to","title","color","dashes")],
                gene_node = gene_node,
                edge_info = edge_info))
  }else{
    return(NULL)
  }
  
}

