#before running this shiny, there has some data need to be using in UI
source("before_run_shiny.R")


#Interface for gene relationship in kEGG pathway/GO term
source("UI/genes_relationships_in_kegg_GO_for_UI.R")
#Interface for gene neighborhood
source("UI/genes_neighborhood_for_UI.R")
#Interface for alluvial_diagram
source("UI/alluvial_diagram_for_UI.R")

#The whole web interface
navbarPage(title = "COPD Time-Course DB Query",
           tabPanel("Genes Relationships in KEGG Pathway/GO Term",
                    genes_relationships_in_pathway_UI
                   ),
           
           tabPanel("Genes Neighborhoods Relationships",
                    gene_neighbor_UI
                    ),
           
           tabPanel("Alluvial Diagram",
                    alluvial_diagram_UI)
           )


