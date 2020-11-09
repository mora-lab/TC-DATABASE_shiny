#########################################################################################################
######### Copy and paste the following code to R in order to install all required dependencies: #########
#########################################################################################################
if (!requireNamespace("BiocManager", quietly = TRUE))
	install.packages("BiocManager", dependencies = TRUE)
	
requiredPackages <- c("visNetwork", "RNeo4j", "ggalluvial", "ggplot2", "shiny")			  
newPackages <- requiredPackages[!(requiredPackages %in% installed.packages()[,"Package"])]
if(length(newPackages)) BiocManager::install(newPackages, ask = TRUE)