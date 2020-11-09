#这个函数就是用来visNetwork作图的

plot_visNetwork <- function(nodes = nodes, 
                            edges = edges){
  visNetwork(nodes, edges, width = "100%")  %>%
    visInteraction(navigationButtons = TRUE) %>% #增加一些控件来对图进行移动啊，放大缩小啊
    visOptions(highlightNearest = list(enabled = TRUE, #highlightNearest:点击一个节点会只显示这个节点所有关系,
                                       hover = FALSE, #hover设定为TRUE,是当鼠标悬停在某个节点时，可以只显示跟这个节点所有关系
                                       algorithm = "hierarchical"), #这个算法， 只查看当前选择节点的关系
               manipulation = TRUE #manipulation编辑按钮，可以增加/删除节点和边
               #selectedBy = list(variable = "group") #根据nodes的group变量对图中的节点进行选择
               ) %>%    
    #visEdges(color = list( highlight = "red",hover = "red")) %>% #悬停到边的时候这条边变色为红色
    visIgraphLayout()  %>%  #Use igraph layout, use all available layouts in igraph and calculate coordinates
    # visLegend() #设置图例的
    visExport()
}