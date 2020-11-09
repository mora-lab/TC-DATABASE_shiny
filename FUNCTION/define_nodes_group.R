#如果只选择一个组别时，那么可以考虑为不同gene node根据所连接的边的时间类型设置组别，这样作出来的图可以有颜色变化，不同颜色变化，即
#即如果节点相同类型的关系，那么颜色是相同的。

#为node增加一个group参数，
#输入的是node_id 节点的id，一般是node表中的id
#x是neo4j中的得到的结果，其中包含"A_id","B_id", "times", "times"是时间的类别，是否在这个时间点有这个关系
#输出的结果应该就是这个节点所应该是group中的哪一个。


# x <- genes_to_genes
# index <- which(colnames(genes_to_genes) == paste0(groups, "_time"))
# names(x)[index] <- "times"
define_nodes_group <- function(genes_to_genes, groups, nodesID){
  
  x <- genes_to_genes
  index <- which(colnames(genes_to_genes) == paste0(groups, "_time"))
  names(x)[index] <- "times"
  
  define_group <- function(node_id){
    if (node_id %in% x$A_id){A = unique(x$times[which(x$A_id == node_id)])} else{A <- NULL}
    if (node_id %in% x$B_id){B = unique(x$times[which(x$B_id == node_id)])} else{B <- NULL}
    AB <- paste0( sort(unique(c(A, B))), collapse = "," )
    return(AB)}
  
  gr = sapply(nodesID, define_group)
  
  return(gr)
}

