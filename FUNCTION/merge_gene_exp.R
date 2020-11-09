#因为boss要求输出的gene表格中需要有表达值，所以这个函数是后来为所有的gene表格添加表达值的，
#每个时间点的样本数据都被压缩在一个单元格中
#gene_exp是在before run shiny就已经加载进来的。所以没有再去提示

#结果自然就是已经合并表达值得gene node表格咯

merge_gene_exp <- function(groups,timepoints,gene_node  ){
  #group需要重新搞一搞，毕竟没有COPD_vs_smoker
  groups_for_exp <- groups[groups %in% c("COPD_smoker","nonsmoker","smoker") ]
  if ("COPD_vs_smoker" %in% groups){groups_for_exp <- append(groups_for_exp, c("COPD_smoker","smoker"))}
  if ("COPD_vs_nonsmoker" %in% groups){groups_for_exp <- append(groups_for_exp, c("COPD_smoker","nonsmoker"))}
  if ("smoker_vs_nonsmoker" %in% groups){groups_for_exp <- append(groups_for_exp, c("nonsmoker","smoker"))}
  groups_for_exp <- unique(groups_for_exp)
  
  #得到表达值的列名
  col_name = c()
  for (g in groups_for_exp){
    col_name = append(col_name,paste0(g, "_",timepoints, "_exp"))
  }
  
  #得到表达值的行名，并按基因的顺序排序的
  genes = gene_node[,"Gene Symbol"]
  genes_index = match(genes,rownames(gene_exp))
  
  #得到表达值
  gene_node_exp <- gene_exp[genes_index,col_name]
  
  #合并表达值
  gene_node <- cbind(gene_node, gene_node_exp)
  
  #-------return-------------------------
  gene_node
}