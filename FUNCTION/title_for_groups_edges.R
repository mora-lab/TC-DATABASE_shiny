#gene之间的关系时， 每条边点击时的信息有点多，所以特地建了个函数来搞，省事。

#这个函数就是根据genes_to_genes和groups
#获取用于作图时边定义的title
#格式就会变成：
#COPD_smoker: M0, M3, M6
#smoker: M3, M12
#source("FUNCTION/number_to_time.R")

title_for_groups_edges <- function(genes_to_genes,groups){
  
  t = data.frame(matrix(data = NA, nrow = nrow(genes_to_genes), ncol = length(groups),
                        dimnames = list(1:nrow(genes_to_genes), groups)))
  
  #t <- vector(mode = "list", length = length(groups))
  for (g in groups){
    edge_type <- genes_to_genes[, paste0(g, "_time")]
    edges_time <- sapply(edge_type, number_to_time) ##后面要改的
    t[g] <- paste0(g, ": <b>",edges_time, "</b>")
  }
  
  tx <- c(rep(NA, nrow(t)))
  for (i in 1:nrow(t)){
    tx[i] <- paste(t[i,1:ncol(t)], collapse = "<br>")
  }
  return(tx)
}


