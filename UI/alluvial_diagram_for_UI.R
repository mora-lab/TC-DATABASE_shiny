################################################################################
#1. Input
################################################################################
#设置组别选项,组别设置成单选==================================================
al_group_choices <- c("COPD smoker" = "COPD_smoker",
                       "smoker" = "smoker",
                       "non-smoker" = "nonsmoker",
                       "COPD smoker VS smoker" = "COPD_vs_smoker",
                       "COPD smoker VS non-smoker" = "COPD_vs_nonsmoker",
                       "smoker VS non-smoker" = "smoker_vs_nonsmoker")

al_select_groups <- selectInput("al_groups", "Groups:",al_group_choices, selected = "COPD_smoker",multiple = F )

################################################################################
#2. OutPut
################################################################################
#2.1 plot
alluvial_plot <- plotOutput("alluvial_plot",height = "800px")
#2.2 tabe
alluvial_tab <- tabsetPanel(type = "tabs",
            tabPanel('Alluvial data',DT::dataTableOutput('alluvial_tab')),
            tabPanel('Download',
                     downloadButton("download_alluvial.data", "download alluvial data")#, ##下载数据
                     #downloadButton("download_alluvial.plot", "download alluvial plot")
                     )
            )

################################################################################
#3. Layout
################################################################################

alluvial_diagram_UI <- fluidPage(
  column(12,
         sidebarPanel(al_select_groups),
         mainPanel(alluvial_plot)
         ),
  column(12,alluvial_tab)
  
  
)