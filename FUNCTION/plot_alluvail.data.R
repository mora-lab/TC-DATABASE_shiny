plot_alluvail.data <- function(alluvial.data){
  library(ggalluvial)
  library(ggplot2)
  #alluvial.data$module <- as.factor(alluvial.data$module)
  #alluvial.data$module <- ordered(alluvial.data$module, levels = paste0("module", 1:nrow(mod_name)) )
  #alluvial.data$timepoint <- as.factor(alluvial.data$timepoint, levels = c("M0", "M3", "M6", "M12"))
  alluvial.data$timepoint <- ordered(alluvial.data$timepoint, levels = c("M0", "M3", "M6", "M12"))
  ggplot(alluvial.data,
         aes(x = timepoint, stratum = module, alluvium = gene,
             fill = module, label = module)) +
    # scale_fill_brewer(type = "qual", palette = "Set2") +
    scale_x_discrete(expand = c(.1, .1)) +
    geom_flow() +
    geom_stratum(alpha = .5) +
    #geom_text(stat = "stratum", size = 3) + #没有删除的话，图中的柱子会显示相应的名字
    theme(legend.position = "bottom") #+
  #ggtitle("COPD smoker at four points in time")
}