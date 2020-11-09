function(input, output, session) {

##############################################################################
##############################################################################
#1. Gene relationship in KEGG pathway or GO term
##############################################################################
##############################################################################	
	
  ##############################################################################
  #1.1 get input KEGG id and GO id
  ##############################################################################
  options_input <- reactive({
    source("FUNCTION/get_real_KEGG_GO_ID.R")
    #KEGGID
    kegg_id = input$KEGGID
    kegg_id <- get_real_keggID(kegg_id, kegg_table)
    #GOID
    go_id = input$GOID
    go_id = get_real_goID(go_id, go_table)
    
    list(kegg_id = kegg_id,go_id = go_id)

  })
  
  source("FUNCTION/get_results_from_neo4j.R")
  source("FUNCTION/get_nodes_edges.R")
  ##############################################################################
  #1.2 get genes_to_kegg relationship result from neo4j
  ##############################################################################
  genes_to_kegg_from_neo4j <- reactive({
    kegg_id <- options_input()$kegg_id 
    #------------genes_to_kegg--------------------------
    if (!is.null(kegg_id)){ #如果有选择kegg的话，才会运行，否则结果为NULL	
      genes_to_kegg <- get_genes_to_kegg(kegg_id = kegg_id)
      genes_to_kegg_nodes_edges <- get_nodes_edges_kegg(genes_to_kegg)
    }else{
      genes_to_kegg <- NULL
      genes_to_kegg_nodes_edges <- NULL
    }
    #=======================return==============================================
    list(genes_to_kegg = genes_to_kegg,
         genes_to_kegg_nodes_edges = genes_to_kegg_nodes_edges)
    
  })
  
  ##############################################################################
  #1.3 get genes_to_GO relationship result from neo4j
  ##############################################################################
  genes_to_GO_from_neo4j <- reactive({
    go_id <- options_input()$go_id
    #------------genes_to_GO----------------------------
    if (!is.null(go_id)){ #如果go被选择的话，才会运行，否则结果为NULL
      genes_to_GO <- get_genes_to_GO(go_id = go_id)
      genes_to_GO_nodes_edges <- get_nodes_edges_GO(genes_to_GO)
    }else{
      genes_to_GO <- NULL
      genes_to_GO_nodes_edges <- NULL
    }
    
    #=======================return==============================================
    list(genes_to_GO = genes_to_GO,
         genes_to_GO_nodes_edges = genes_to_GO_nodes_edges)
  })
  
  ##############################################################################
  #1.4 get genes_to_genes relationship from neo4j
  ##############################################################################
  genes_to_genes_from_neo4j <- reactive({
    #-----------------input-------------------------------------------------
	#kegg_id and go_id
    kegg_id = options_input()$kegg_id
    go_id = options_input()$go_id
    #groups
    groups = input$groups
    #timepoints
    timepoints = input$timepoints
    #weight
    weight = input$Weight
    #=======================获取neo4j结果/nodes和edges==========================
    #-------------genes_to_genes------------------------
    genes_to_genes <- get_genes_to_genes(groups = groups,
                                         timepoints = timepoints,
                                         kegg_id = kegg_id,
                                         go_id = go_id,
                                         weight = weight)
    #如果返回的结果genes_to_genes是NULL
    if (is.null(genes_to_genes)){
      genes_to_genes_nodes_edges <- NULL
    }else{
      genes_to_genes_nodes_edges <- get_nodes_edges_gg(genes_to_genes, groups)
    }
    #=======================return==============================================
    list(genes_to_genes = genes_to_genes,
         genes_to_genes_nodes_edges = genes_to_genes_nodes_edges)
    
  })

  
  
  #总共多少条边=================================================================
  output$total_edges_number <- renderText({
    
    if (is.null(genes_to_genes_from_neo4j()$genes_to_genes)){
      "0 edges between genes are in this plot."
    }else{
      paste0(nrow(genes_to_genes_from_neo4j()$genes_to_genes), " edges between genes are in this plot." )
    }
    
  })
  
  ##############################################################################
  #1.5 merge gene nodes, kegg nodes, GO nodes and gene-gene, gene-kegg, gene-GO edges
  ##############################################################################
  plot_nodes_edges <- reactive({
    #-----------input----------------------
    plotObeject <- input$plotObeject
    groups <- input$groups
    timepoints = input$timepoints
    
    #------------data---------------------
    genes_to_genes_nodes_edges <- genes_to_genes_from_neo4j()$genes_to_genes_nodes_edges
    genes_to_kegg_nodes_edges <- genes_to_kegg_from_neo4j()$genes_to_kegg_nodes_edges
    genes_to_GO_nodes_edges <- genes_to_GO_from_neo4j()$genes_to_GO_nodes_edges
    
    ##################合并nodes和edges############################
    nodes_edges_list <- list(
      genes_to_genes = genes_to_genes_nodes_edges,
      genes_to_kegg = genes_to_kegg_nodes_edges,
      genes_to_GO = genes_to_GO_nodes_edges
    )
    #选择只包含选中的gene_to_gene， genes_to_KEGG等
    nodes_edges_list <- nodes_edges_list[c(plotObeject)] #根据plot对象来选择是否合并不同节点
	
    source("FUNCTION/merge_nodes_edges.R")
    plot_nodes_edges <- merge_nodes_edges(plotObeject,nodes_edges_list,groups)
    
    #############合并表达值#######################
    if (!is.null(groups) & !is.null(timepoints)){
      source("FUNCTION/merge_gene_exp.R")
      plot_nodes_edges$gene_node <- merge_gene_exp(groups, 
                                                   timepoints,
                                                   gene_node = plot_nodes_edges$gene_node)
     }
    
    #=======================return==============================================
    list(plot_nodes_edges = plot_nodes_edges)
    
  })
  
  ##############################################################################
  #1.6  plot those relationships with visNetwork
  ##############################################################################
  output$visNetwork_plot <- renderVisNetwork({
    
    plot_nodes_edges <- plot_nodes_edges()$plot_nodes_edges

    nodes <- plot_nodes_edges$nodes
    edges <- plot_nodes_edges$edges
    
    #------------作图-------------------------------
    source("FUNCTION/plot_visNetwork.R")
    plot_visNetwork(nodes, edges)
  })
  
  
  ##############################################################################
  #1.7 node and edge information output
  ##############################################################################
  #=======gene nodes=============================================
  # display 10 rows initially
  output$node_genes_information <- DT::renderDataTable({
    gene_node <- plot_nodes_edges()$plot_nodes_edges$gene_node
    DT::datatable(gene_node, options = list(pageLength = 10))
  })
  
  #=======kegg nodes=============================================
  output$node_kegg_information <- DT::renderDataTable({
    kegg_node = plot_nodes_edges()$plot_nodes_edges$kegg_node
    DT::datatable(kegg_node, options = list(pageLength = 10))
  })
  
  #=======GO nodes=============================================
  output$node_go_information <- DT::renderDataTable({
    GO_node <- plot_nodes_edges()$plot_nodes_edges$GO_node
    DT::datatable(GO_node, options = list(pageLength = 10))
  })
  
  #=======edge info=============================================
  output$edges_information <- DT::renderDataTable({
    edge_info <- plot_nodes_edges()$plot_nodes_edges$edge_info
    DT::datatable(edge_info, options = list(pageLength = 10))
  })
  
  ###############################################################################
  #1.8 node and edge information download
  ###############################################################################
  #=======gene nodes=============================================
  output$download_gene_nodeTable <- downloadHandler(
    filename = function(){ "gene_Nodes_gene_relationships_in_kegg_GO.xls"},
    content = function(file){
      nd <- plot_nodes_edges()$plot_nodes_edges
      library(xlsx)
      write.xlsx(nd$gene_node,file, sheetName = "Gene node")}
  )
  #=======kegg nodes=============================================
  output$download_kegg_nodeTable <- downloadHandler(
    filename = function(){ "kegg_Nodes_gene_relationships_in_kegg_GO.xls"},
    content = function(file){
      nd <- plot_nodes_edges()$plot_nodes_edges
      library(xlsx)
      write.xlsx(nd$kegg_node,file, sheetName = "kegg node")}
  )
  #=======GO nodes=============================================
  output$download_GO_nodeTable <- downloadHandler(
    filename = function(){ "GO_Nodes_gene_relationships_in_kegg_GO.xls"},
    content = function(file){
      nd <- plot_nodes_edges()$plot_nodes_edges
      library(xlsx)
      write.xlsx(nd$GO_node,file, sheetName = "GO_node")}
  )
  #=======edge info=============================================
  output$download_edgeTable <- downloadHandler(
    filename = function(){"Edges_gene_relationships_in_kegg_GO.xls" },
    content = function(file){
      write.xlsx(plot_nodes_edges()$plot_nodes_edges$edge_info,
                 file, sheetName = "Edge")}
  )
  ###############################################################################
  #1.9 summary the plot information such like gene number, edge number
  ###############################################################################
  plot_info <- reactive({
    nd <- plot_nodes_edges()$plot_nodes_edges
    edge <- nd$edge_info
    
    list(gene_num = nrow(nd$gene_node),
         kegg_num = nrow(nd$kegg_node),
         GO_num = nrow(nd$GO_node),
        edge_gg_num = nrow(edge[edge$relationship == "Gene-Gene",]),
        edge_gk_num = nrow(edge[edge$relationship == "Gene-KEGG",]),
        edge_ggo_num = nrow(edge[edge$relationship == "Gene-GO",])
    )
  })
  
  ###############################################################################
  #1.10 Output those summary the plot information when the number large than 0
  ###############################################################################
  output$gene_num <- renderText({if(plot_info()$gene_num >0 ){paste0(plot_info()$gene_num, " genes")}})
  output$kegg_num <- renderText({if (plot_info()$kegg_num >0){paste0(plot_info()$kegg_num, " KEGG pathway")}})
  output$go_num <- renderText({if (plot_info()$GO_num >0){paste0(plot_info()$GO_num, " GO Term")}})
  output$gg_edge_num <- renderText({if (plot_info()$edge_gg_num >0){paste0(plot_info()$edge_gg_num, " edges for genes to genes")}})
  output$gk_gene_num <- renderText({if (plot_info()$edge_gk_num >0){paste0(plot_info()$edge_gk_num, " edges for genes to KEGG")}})
  output$ggo_edge_num <- renderText({if (plot_info()$edge_ggo_num >0){paste0(plot_info()$edge_ggo_num, "  edges for genes to GO")}})
  
  ###############################################################################
  #1.11 network coordination scores
  ###############################################################################
  netscore <- reactive({
	#-----------input----------------------
    timepoints <- input$timepoints
	groups <- input$groups
	#------------data----------------------
	nd <- plot_nodes_edges()$plot_nodes_edges
    edge <- nd$edge_info
    
	#-----------gene-gene number------------------------------
    edge_gg <- edge[edge$relationship == "Gene-Gene",]
    edge_gg_num <- nrow(edge_gg)
    
	#如果没有选择timepoints，就全选
    if (is.null(timepoints)){timepoints = c("M0", "M3", "M6", "M12")}
    
	#-----sum all weight at each time in group------------------
    status_timepoint_weight <- c()
    word_status_timepoint <- c()
    for (g in groups){  
      status_timepoint_weight = append(status_timepoint_weight, 
                                       paste0(g, "_",timepoints, "_weight"))
      word_status_timepoint <- append(word_status_timepoint,paste0(" at ", timepoints, " in ", g, " group "))
    }
    
    weight_sum <- c()
    for (i in 1:length(status_timepoint_weight)){
      stw = status_timepoint_weight[i]
      weight <- edge_gg[,stw]
      weight_sum <- append(weight_sum, sum(weight[!is.na(weight)]))
    }
    
	#---------------return--------------------------------------
    list(
      edge_gg_num = edge_gg_num,
      word_status_timepoint = word_status_timepoint,
      weight_sum = weight_sum
    )
    
  })
  
  ###############################################################################
  #1.12 output network coordination scores
  ############################################################################### 
  #------------------number of gene-to-gene relationship-----------------------
  output$net_gg_edge_num <- renderText({
    edge_gg_num <- netscore()$edge_gg_num
    edge_gg_num
  })
  #-----------------weight sum -----------------------------------------------
  output$weight_sum <- renderText({
    weight_sum <- netscore()$weight_sum
    word_status_timepoint = netscore()$word_status_timepoint
	
    weight_sum_word <- c()
    for (i in 1:length(weight_sum)){
      weight_sum_word <- append(weight_sum_word , paste0(weight_sum[i]," ", word_status_timepoint[i]))
      }
    weight_sum_word <- paste0(weight_sum_word, collapse = ", ")
    weight_sum_word
  })
  
  
##############################################################################
##############################################################################
#2. genes neighborhood
##############################################################################
##############################################################################	
  
  
  source("FUNCTION/get_genes_neighbor.R")
  ##############################################################################
  #2.1 get genes_neighbor/gene-GO/gene-kegg relationship from neo4j
  ##############################################################################
  genes_neighbor <- reactive({
    
    #--------------------input--------------------------------------------------
    genes <- input$gnb_genes
    groups <- input$gnb_groups
    timepoints <- input$gnb_timepoints
    weight <- input$gnb_Weight
    plotObeject <- input$gnb_plotObeject
    
    #------------get_the results------------------------------------------------
    genes_neighbor <- get_genes_neighbor(genes = genes, groups = groups,
                                         timepoints = timepoints, weight = weight)
    #----------------------------------获取节点信息和边信息---------------------------
    if (!is.null(genes_neighbor)){
      if (is.null(groups)){ #如果没有选择组别，就默认是所有组
        genes_neighbor_nodes_edges <- get_nodes_edges_gg(genes_neighbor, 
                                                         groups = c("COPD_smoker","smoker",
                                                                    "nonsmoker","COPD_vs_smoker",
                                                                    "COPD_vs_nonsmoker","smoker_vs_nonsmoker"))
      }else{
        genes_neighbor_nodes_edges <- get_nodes_edges_gg(genes_neighbor, groups)
      }
    }else{ #如果返回的结果genes_neighbor是0行的,即NULL,返回NULL
      genes_neighbor_nodes_edges <- NULL
    }
    
    #=================genes_neighbor_to_KEGG===============================================
	#如果要求作出gene跟kegg的关系，就运行
    if ("genes_to_kegg" %in% plotObeject){
      genes_neighbor_to_kegg <- get_genesneighbor_to_KEGG(genes = genes, groups = groups, 
                                                          timepoints = timepoints, weight = weight)
      genes_neighbor_to_kegg_nodes_edges <- get_nodes_edges_kegg(genes_neighbor_to_kegg)
      
      #只包含kegg和选定gene之间的关系--这种情况是因为只要求作出请求的基因跟KEGG的关系
      only_genes_to_kegg <- only_get_genes_to_KEGG(genes)
      only_genes_to_kegg_nodes_edges <- get_nodes_edges_kegg(only_genes_to_kegg)
      
    }else{
      genes_neighbor_to_kegg <- NULL
      genes_neighbor_to_kegg_nodes_edges <- NULL
      only_genes_to_kegg <- NULL
      only_genes_to_kegg_nodes_edges <- NULL
    }
    
    #=================genes_neighbor_to_GO===============================================
	#如果要求作出gene跟GO的关系，就运行
    if ("genes_to_GO" %in% plotObeject){
      genes_neighbor_to_GO <- get_genesneighbor_to_GO(genes = genes, groups = groups, 
                                                      timepoints = timepoints, weight = weight)
      genes_neighbor_to_GO_nodes_edges <- get_nodes_edges_GO(genes_neighbor_to_GO)
      #只包含GO和选定gene之间的关系--这种情况是因为只要求作出请求的基因跟GO的关系
      only_genes_to_GO <- only_get_genes_to_GO(genes)
      only_genes_to_GO_nodes_edges <- get_nodes_edges_GO(only_genes_to_GO)
    }else{
      genes_neighbor_to_GO <- NULL
      genes_neighbor_to_GO_nodes_edges <- NULL
      only_genes_to_GO <- NULL
      only_genes_to_GO_nodes_edges <- NULL
    }
    
    #=================return===============================================
    list(genes_neighbor = genes_neighbor,
         genes_neighbor_nodes_edges = genes_neighbor_nodes_edges,
         genes_neighbor_to_kegg = genes_neighbor_to_kegg,
         genes_neighbor_to_kegg_nodes_edges = genes_neighbor_to_kegg_nodes_edges,
         genes_neighbor_to_GO = genes_neighbor_to_GO,
         genes_neighbor_to_GO_nodes_edges = genes_neighbor_to_GO_nodes_edges,
         
         only_genes_to_kegg = only_genes_to_kegg ,
         only_genes_to_kegg_nodes_edges = only_genes_to_kegg_nodes_edges,
         only_genes_to_GO = only_genes_to_GO,
         only_genes_to_GO_nodes_edges = only_genes_to_GO_nodes_edges
		 )
  })
  
  ##############################################################################
  #2.2 merge node and edges
  ##############################################################################
  genes_neighbor_plot_nodes_edges <- reactive({
    #-----------input----------------------
    plotObeject <- input$gnb_plotObeject
    groups <- input$gnb_groups
    timepoints <- input$gnb_timepoints
    #--------------------Data--------------------------------
    nodes_edges_list <- list(
      genes_to_genes = genes_neighbor()$genes_neighbor_nodes_edges,
      genes_to_kegg = genes_neighbor()$genes_neighbor_to_kegg_nodes_edges,
      genes_to_GO = genes_neighbor()$genes_neighbor_to_GO_nodes_edges,
      
      only_genes_to_kegg = genes_neighbor()$only_genes_to_kegg_nodes_edges,
      only_genes_to_GO = genes_neighbor()$only_genes_to_GO_nodes_edges
    )
    
	#================two coditions: not/yes gene neighborhood================
    #两种情况，一种是有选择genes_to_genes,一种是没有选择 genes_to_genes
    if (!"genes_to_genes" %in% plotObeject){
      nodes_edges_list <- nodes_edges_list[c("only_genes_to_kegg","only_genes_to_GO")]
      names(nodes_edges_list) = c("genes_to_kegg","genes_to_GO")
    }
    nodes_edges_list <- nodes_edges_list[c(plotObeject)]
    source("FUNCTION/merge_nodes_edges.R")
    plot_nodes_edges_for_genes_neighbor <- merge_nodes_edges(plotObeject,nodes_edges_list,groups)
    
    #===========获取基因的表达值================================================
    #gene_node = plot_nodes_edges_for_genes_neighbor$gene_node
    if (!is.null(groups) & !is.null(timepoints)){
      source("FUNCTION/merge_gene_exp.R")
      plot_nodes_edges_for_genes_neighbor$gene_node <- merge_gene_exp(groups, 
                                                   timepoints,
                                                   gene_node = plot_nodes_edges_for_genes_neighbor$gene_node)
    }

    #=======================return==============================================
    list(plot_nodes_edges_for_genes_neighbor = plot_nodes_edges_for_genes_neighbor)
    
  })
  
  ##############################################################################
  #2.3 plot genes neighborhood relationship with visNetwork
  ##############################################################################
  output$gnb_visNetwork_plot <- renderVisNetwork({
    #------------data----------------------------
    plot_nodes_edges <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor
    
    nodes <- plot_nodes_edges$nodes
    edges <- plot_nodes_edges$edges
    
    #------------作图-------------------------------
    source("FUNCTION/plot_visNetwork.R")
    plot_visNetwork(nodes, edges)
  })
  
  ##############################################################################
  #2.4 Node and Edge information
  ##############################################################################
  #=======gene nodes=============================================
  # display 10 rows initially
  output$gnb_node_genes_information <- DT::renderDataTable({
    gene_node = genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor$gene_node
    DT::datatable(gene_node, options = list(pageLength = 10))
  })
  #=======kegg nodes=============================================
  output$gnb_node_kegg_information <- DT::renderDataTable({
    kegg_node = genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor$kegg_node
    DT::datatable(kegg_node, options = list(pageLength = 10))
  })
  #=======GO nodes=============================================
  output$gnb_node_go_information <- DT::renderDataTable({
    GO_node <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor$GO_node
    DT::datatable(GO_node, options = list(pageLength = 10))
  })
  #=======edge info===========================================
  output$gnb_edges_information <- DT::renderDataTable({
    edge_info <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor$edge_info
    DT::datatable(edge_info, options = list(pageLength = 10))
  })
  
  ####################################################################################################
  #2.5 gene/kegg/GO node or edge information download
  ####################################################################################################
  #=========================gene node ============================
  output$gnb_download_gene_nodeTable <- downloadHandler(
    filename = function(){ "gene_Nodes_gene_neighbor.xls"},
    content = function(file){
      nd <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor
      library(xlsx)
      write.xlsx(nd$gene_node,file, sheetName = "Gene node")
      return(file)
      }
  )
  #=========================KEGG node ============================
  output$gnb_download_kegg_nodeTable <- downloadHandler(
    filename = function(){ "kegg_Nodes_gene_neighbor.xls"},
    content = function(file){
      nd <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor
      library(xlsx)
      write.xlsx(nd$kegg_node,file, sheetName = "kegg node")
      return(file)
    }
  )
  #==========================GO node =============================
  output$gnb_download_GO_nodeTable <- downloadHandler(
    filename = function(){ "GO_Nodes_gene_neighbor.xls"},
    content = function(file){
      nd <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor
      library(xlsx)
      write.xlsx(nd$GO_node,file, sheetName = "GO_node")
      return(file)
    }
  )
  #========================== edge =============================
  output$gnb_download_edgeTable <- downloadHandler(
    filename = function(){"Edges_gene_gene_neighbor.xls" },
    content = function(file){
      library(xlsx)
      write.xlsx(genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor$edge_info,
                 file, sheetName = "Edge")
      }
  )
  
  #############################################################################
  #2.6 summary the plot information such like gene number, edge number
  #############################################################################
  gnb_plot_info <- reactive({
    nd <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor
    edge <- nd$edge_info
    
    list(gene_num = nrow(nd$gene_node),
         kegg_num = nrow(nd$kegg_node),
         GO_num = nrow(nd$GO_node),
         edge_gg_num = nrow(edge[edge$relationship == "Gene-Gene",]),
         edge_gk_num = nrow(edge[edge$relationship == "Gene-KEGG",]),
         edge_ggo_num = nrow(edge[edge$relationship == "Gene-GO",])
    )
  })
  
  #############################################################################
  #2.7 output the summary of the plot information 
  #############################################################################
  output$gnb_gene_num <- renderText({if(gnb_plot_info()$gene_num >0 ){paste0(gnb_plot_info()$gene_num, " genes")}})
  output$gnb_kegg_num <- renderText({if (gnb_plot_info()$kegg_num >0){paste0(gnb_plot_info()$kegg_num, " KEGG pathway")}})
  output$gnb_go_num <- renderText({if (gnb_plot_info()$GO_num >0){paste0(gnb_plot_info()$GO_num, " GO Term")}})
  output$gnb_gg_edge_num <- renderText({if (gnb_plot_info()$edge_gg_num >0){paste0(gnb_plot_info()$edge_gg_num, " edges for genes to genes")}})
  output$gnb_gk_gene_num <- renderText({if (gnb_plot_info()$edge_gk_num >0){paste0(gnb_plot_info()$edge_gk_num, " edges for genes to KEGG")}})
  output$gnb_ggo_edge_num <- renderText({if (gnb_plot_info()$edge_ggo_num >0){paste0(gnb_plot_info()$edge_ggo_num, "  edges for genes to GO")}})
  
  #############################################################################
  #2.8 network coordination scores
  #############################################################################
  gnb_netscore <- reactive({
	#---------------------input----------------------
	timepoints <- input$gnb_timepoints
	groups <- input$gnb_groups
    #--------------------data---------------------------
	nd <- genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor
    edge <- nd$edge_info
    
    edge_gg <- edge[edge$relationship == "Gene-Gene",]
    edge_gg_num <- nrow(edge_gg)
    
    #如果没有选择timepoints，就全选
    if (is.null(timepoints)){timepoints = c("M0", "M3", "M6", "M12")}
    
    #------------weight sum for each timepoint in group-------------------
    status_timepoint_weight <- c()
    word_status_timepoint <- c()
    for (g in groups){  
      status_timepoint_weight = append(status_timepoint_weight, 
                                       paste0(g, "_",timepoints, "_weight"))
      word_status_timepoint <- append(word_status_timepoint,paste0(" at ", timepoints, " in ", g, " group "))
    }
    
    weight_sum <- c()
    for (i in 1:length(status_timepoint_weight)){
      stw = status_timepoint_weight[i]
      if (nrow(edge_gg) > 0){
        weight <- edge_gg[,stw]
        weight_sum <- append(weight_sum, sum(weight[!is.na(weight)]))
      }else{
        weight_sum <- append(weight_sum, 0)
      }
      
    }
    
    #================return=======================================
    list(
      edge_gg_num = edge_gg_num,
      word_status_timepoint = word_status_timepoint,
      weight_sum = weight_sum,
      kegg_num = nrow(nd$kegg_node),
      GO_num = nrow(nd$GO_node),
      edge_ggo_num_per_gene = nrow(edge[edge$relationship == "Gene-GO",])/nrow(nd$gene_node),
      edge_gk_num_per_gene = nrow(edge[edge$relationship == "Gene-KEGG",])/nrow(nd$gene_node)
    )
    
  })

  #############################################################################
  #2.9 output for network coordination scores
  #############################################################################  
  #==================number gene-gene=================================
  output$gnb_net_gg_edge_num <- renderText({
    edge_gg_num <- gnb_netscore()$edge_gg_num
    edge_gg_num
  })
  #=================weight sum ======================================
  output$gnb_weight_sum <- renderText({
    weight_sum <- gnb_netscore()$weight_sum
    word_status_timepoint = gnb_netscore()$word_status_timepoint
    
    weight_sum_word <- c()
    for (i in 1:length(weight_sum)){
      weight_sum_word <- append(weight_sum_word , paste0(weight_sum[i]," ", word_status_timepoint[i]))
    }
    weight_sum_word <- paste0(weight_sum_word, collapse = ", ")
    weight_sum_word
  })
  #===========number of GO/KEGG =====================================
  output$gnb_net_go_num <- renderText({paste0("GO term: ",gnb_netscore()$GO_num)})
  output$gnb_net_kegg_num <- renderText({paste0("KEGG pathway: ",gnb_netscore()$kegg_num)})
  #===========number of GO/KEGG per gene=====================================
  output$gnb_net_kegg_num_per_gene <- renderText({paste0("KEGG pathway: ",gnb_netscore()$edge_gk_num_per_gene)})
  output$gnb_net_go_num_per_gene <- renderText({paste0("GO term: ",gnb_netscore()$edge_ggo_num_per_gene)})


  
##############################################################################
##############################################################################
#3. alluvial_plot
##############################################################################
##############################################################################	


  #############################################################################
  #3.1 get the alluvial plot data
  ############################################################################# 
  alluvial.data <- reactive({
    group = input$al_groups
    
    source("FUNCTION/get_alluvial.data.R")
    alluvial.data <- get_alluvial.data(group)
    
    list(alluvial.data = alluvial.data)
  })
  
  #############################################################################
  #3.2 output alluvial plot
  ############################################################################# 
  output$alluvial_plot <- renderPlot({
    alluvial.data = alluvial.data()$alluvial.data
    source("FUNCTION/plot_alluvail.data.R")
    plot_alluvail.data(alluvial.data)
  })
  #############################################################################
  #3.3 output alluvial.data information
  #############################################################################   
  output$alluvial_tab <- DT::renderDataTable({
    alluvial.data = alluvial.data()$alluvial.data
    gene_node = genes_neighbor_plot_nodes_edges()$plot_nodes_edges_for_genes_neighbor$gene_node
    DT::datatable(alluvial.data, options = list(pageLength = 10))
  })
  
  #############################################################################
  #3.4 output alluvial.data download
  ############################################################################# 
  output$download_alluvial.data <- downloadHandler(
    filename = function(){paste0(input$al_groups,"_alluvial_data",".xls") },
    content = function(file){
      library(xlsx)
      write.xlsx(alluvial.data()$alluvial.data,
                 file, sheetName = "alluvial.data")
    }
  )
    
}