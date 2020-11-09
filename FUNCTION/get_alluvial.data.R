#用来获取alluvial作图的数据

get_alluvial.data <- function(group){
  #group = "COPD_smoker"
  query = paste0("
          MATCH (A:Genes)
          return A.Symbols AS gene,
                 A.",group,"_M0_module,
                 A.",group,"_M3_module,
                 A.",group,"_M6_module,
                 A.",group,"_M12_module
          ")
  mod_tab <- cypher(graph, query)
  
  alluvial.data <- data.frame(gene = numeric(0),
                              module = numeric(0),
                              timepoint = numeric(0))
  
  
  timepoints = c("M0", "M3", "M6", "M12")
  for (i in 2:5){
    mod_mx <- mod_tab[!is.na(mod_tab[i]),c(1,i)]
    names(mod_mx) <- c("gene", "module")
    mod_mx[,"timepoint"] = timepoints[i-1]
    
    #更改module_name
    module <- unique(mod_mx$module)
    mod_name <- paste0(timepoints[i-1],"_module", 01:length(module))
    mod_name <- data.frame(module, mod_name)
    
    mod_mx <- merge(mod_mx,
                    mod_name,
                    by = "module",
                    all.x = TRUE)
    
    mod_mx <- mod_mx[,c("gene","timepoint","mod_name")]
    names(mod_mx)[3] <- "module" 
    
    #合并
    alluvial.data <- rbind(alluvial.data, mod_mx)
    
  }
  
  return(alluvial.data)
}