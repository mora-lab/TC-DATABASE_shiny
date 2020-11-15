#两部分，一部分是input参数，一部分是output参数
################################################################################
#1. input
################################################################################
#1.1 设置genes选择==================================================================
gnb_genes_choices <- unique(append(all_genes$SYMBOL, 
                                   all_genes$entrezid))
gnb_genes_select <- selectInput("gnb_genes", "Gene symbol or entrezid:",
                                gnb_genes_choices,
                                selected = c("ABCB6"),
                                multiple = T)

#1.2 设置组别选项,组别设置成可多选==================================================
gnb_group_choices <- c("COPD smoker" = "COPD_smoker",
                   "smoker" = "smoker",
                   "non-smoker" = "nonsmoker")
gnb_select_groups <- selectInput("gnb_groups", "Groups:",gnb_group_choices, selected = "COPD_smoker",multiple = T)

#1.3 设置时间选项，多选============================================================
gnb_timepoints_select <- c("0 months" = "M0",
                       "3 months" = "M3",
                       "6 months" = "M6",
                       "12 months" = "M12")
gnb_select_time_point <- checkboxGroupInput("gnb_timepoints", "Timepoints:",
                                        gnb_timepoints_select,
                                        selected = c("M0", "M3"))


#1.4 设置weight选项=================================================================
gnb_select_weight <- sliderInput("gnb_Weight", "Weight:",
                             min = 0.1, max = 0.6, value = c(0,0.6))

#1.5 设置画图的对象是genes_to_genes, 还是genes_to_kegg/go==============================
gnb_plotObject_choices <- c("genes to genes" = "genes_to_genes",
                        "genes to KEGG " = "genes_to_kegg",
                        "genes to GO " = "genes_to_GO")
gnb_plotObject <- selectInput("gnb_plotObeject", "Plot: ",
                          plotObject_choices, selected = "genes_to_genes", multiple = T)

################################################################################
#2. outPut
################################################################################
#2.1 设置输出visNetwork结果
gnb_visNetwork_plot <- visNetworkOutput("gnb_visNetwork_plot",  height = "800px")

#2.2 图中基本信息-----------------------
gnb_plot_info <- p(strong(h5("In this plot: \n")),
				   strong(textOutput("gnb_gene_num")), "\n",
				   strong(textOutput("gnb_kegg_num")),"\n",
				   strong(textOutput("gnb_go_num")),"\n",
				   strong(textOutput("gnb_gg_edge_num")),"\n",
				   strong(textOutput("gnb_gk_gene_num")),"\n",
				   strong(textOutput("gnb_ggo_edge_num"))
			   )

#2.3 设置数据下载按钮---------------------------
gnb_button_download_gene_nodes <- downloadButton("gnb_download_gene_nodeTable", "download gene nodes information")
gnb_button_download_kegg_nodes <- downloadButton("gnb_download_kegg_nodeTable", "download KEGG nodes information")
gnb_button_download_GO_nodes <- downloadButton("gnb_download_GO_nodeTable", "download GO nodes information")
gnb_button_download_edges <- downloadButton("gnb_download_edgeTable", "download edges information")

#2.4 network coordination scores
gnb_netScore <- p(h4("C1. Number of gene-gene edges: "), strong(textOutput("gnb_net_gg_edge_num")), "\n", 
              h4("C2. Sum of gene-gene edge weights: "), strong(textOutput("gnb_weight_sum")),  "\n",
              h4("C4. Number of GO term and KEGG pathway: "), strong(textOutput("gnb_net_go_num")), "\n", 
                                                            strong(textOutput("gnb_net_kegg_num")),  "\n",
              h4("C5. Average number of GO term and KEGG pathway per genes: "), 
              strong(textOutput("gnb_net_kegg_num_per_gene")), "\n",
              strong(textOutput("gnb_net_go_num_per_gene"))
)


#2.5 查看节点数据--------------
gnb_nodes_information <- tabsetPanel(type = "tabs",
                                 tabPanel('Node information',
                                          tabsetPanel(tabPanel('Gene Node',DT::dataTableOutput('gnb_node_genes_information')),
                                                      tabPanel('KEGG Node',DT::dataTableOutput('gnb_node_kegg_information')),
                                                      tabPanel('GO Node', DT::dataTableOutput('gnb_node_go_information')))
                                          ),
                                 tabPanel('Edge Information', DT::dataTableOutput('gnb_edges_information')),
                                 tabPanel('Network coordination scores', gnb_netScore),
                                 tabPanel('Download', gnb_button_download_gene_nodes,
                                          gnb_button_download_kegg_nodes,
                                          gnb_button_download_GO_nodes,
                                          gnb_button_download_edges))





################################################################################
#3. layout
################################################################################
gene_neighbor_UI <- fluidPage(
  column(12,
         sidebarPanel(#--------------------genes-neighborhood-------------------
                      gnb_genes_select,
                      gnb_select_groups,
                      gnb_select_time_point,
                      conditionalPanel(condition = "input.gnb_timepoints.length > 0",gnb_select_weight),
                      gnb_plotObject, #作图对象
                      gnb_plot_info #总结图中的信息
					  ),
         mainPanel(gnb_visNetwork_plot)
         ),
  column(12,gnb_nodes_information)
)