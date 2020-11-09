# 因为将kegg和go的选择改成了多项搜索选择，所以有些时候，输入的kegg/go可能是重复的，
#也可以是通路名称或术语名称，而不是id，这时候就需要将其统一转换成keggid或goid了。

#KEGGID
get_real_keggID <- function(kegg_id = NULL, kegg_table){
  if (!is.null(kegg_id)){
    kegg_id1 <- kegg_id[kegg_id %in% kegg_table$KEGGID]
    kegg_id2 <- kegg_table$KEGGID[kegg_table$DESCRIPTION %in% kegg_id]
    kegg_id <- unique(c(kegg_id1, kegg_id2))
  }
  return(kegg_id)
}



#GOID
get_real_goID <- function(go_id = NULL, go_table){
  if (!is.null(go_id)){
    go_id1 <- go_id[go_id %in% go_table$GOID]
    go_id2 <- go_table$GOID[go_table$TERM %in% go_id]
    go_id <- unique(c(go_id1, go_id2))
  }
  return(go_id)
}
