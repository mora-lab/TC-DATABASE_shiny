#这个函数的意义在于，当选择作图的对象是gene_to_gene/genes_to_kegg/genes_to_GO，
#节点和边都不同，所以需要将节点的信息合并，并为节点和边的信息进行汇总，方便后面节点和边的信息在表格中展示

merge_nodes_edges <- function(plotObeject,nodes_edges_list,groups){

  #两个空数据框
  nodes <- data.frame(id = numeric(0),label = numeric(0),group = numeric(0),title = numeric(0),shape = numeric(0))
  edges <- data.frame(from= numeric(0),to= numeric(0),title= numeric(0),color= numeric(0),dashes= numeric(0))
  edge_info <- data.frame(from= numeric(0),to= numeric(0),relationship= numeric(0))
  gene_node <- data.frame(Symbol =  numeric(0), Name = numeric(0))
  colnames(gene_node) <- c("Gene Symbol", "Gene Name")
  
  #合并数据框
  for (i in 1:length(plotObeject)){
    if (!is.null(nodes_edges_list[[i]])){
      #如果groups只有一个，且选择genes_to_genes
      #就要将nodes表格中的group值为gene的部分，筛选去除
      if (length(groups) == 1 & ("genes_to_genes" %in% plotObeject) & (plotObeject[i] != "genes_to_genes")){
        nodes1 <- nodes_edges_list[[i]]$nodes
        nodes2 <- nodes_edges_list[["genes_to_genes"]]$nodes
        nodes1 <- nodes1[!nodes1$id %in% nodes2$id, ] #删除nodes1中group是gene的
        rm(nodes2)
      }else{
        nodes1 <- nodes_edges_list[[i]]$nodes 
      }
      
      nodes = unique(rbind(nodes, nodes1));rm(nodes1)
      edges = rbind(edges, nodes_edges_list[[i]]$edges)
      
      #----------gene_node-------------------------------------------
      gene_node = unique(rbind(gene_node, nodes_edges_list[[i]]$gene_node))
      edge_info = unique(rbind(edge_info,nodes_edges_list[[i]]$edge_info[,c("from", "to", "relationship")] ))
    }
  }
  nodes <- unique(nodes) #最后去重
  
  #----------------merge edge info----------------------
  if ("genes_to_genes" %in% plotObeject & !is.null(nodes_edges_list[["genes_to_genes"]])){
    edge_info = merge(edge_info, 
                      nodes_edges_list[["genes_to_genes"]]$edge_info,
                      by = c("from", "to", "relationship"),
                      all.x = TRUE)
  }
  
  
  #------------kegg node--------------------------------
  if ("genes_to_kegg" %in% plotObeject & !is.null(nodes_edges_list[["genes_to_kegg"]])){
    kegg_node <- nodes_edges_list[["genes_to_kegg"]]$kegg_node
  }else{
    kegg_node <- data.frame(id = numeric(0), names = numeric(0))
    colnames(kegg_node) <- c("KEGG IDs", "KEGG names")
  }
  
  #--------GO node -------------------------------------
  if ("genes_to_GO" %in% plotObeject & !is.null(nodes_edges_list[["genes_to_GO"]])){
    GO_node <- nodes_edges_list[["genes_to_GO"]]$GO_node
  }else{
    GO_node <- data.frame(go = numeric(0), ontology= numeric(0), term= numeric(0))
    colnames(GO_node) <- c("GO IDs", "GO Ontology", "GO Term")
  }
  

  return(list(nodes = nodes, edges = edges,
              edge_info = edge_info,
              gene_node = gene_node,
              kegg_node = kegg_node,
              GO_node = GO_node))
}