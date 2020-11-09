#这里的函数为在get_results_from_neo4j.R中的几个函数中使用的，
#用来获取query语句中的where的语句和return语句




################################################################################
#status_type_option_for_where
################################################################################
#根据组别和时间点来筛选各个时间点和各个组别之间的关系类型，
#如果时间点没有选择，那就默认是所有时间点都返回。
status_type_option_for_where <- function(groups, timepoints){
  
  #status_type #比如： "COPD_smoker_time" "smoker_time" 
  status_type <- paste0(groups, "_time")
  
  #status_type_option_value, 就那些'1010','1.1.'
  #只要选择一个时间点，就肯定需要
  source("FUNCTION/get_group_options_value.R")
  status_type_option_value <- get_group_options_value(timepoints)
  
  #status_type_option
  #因为当'....'时，需要把都是'0000'的给去掉才行
  if (is.null(timepoints)){ 
    status_type_option <- paste0("r.", status_type, " =~ '", status_type_option_value, "'",
                                 " AND r.", status_type, " <> '", '0000', "' ")
    status_type_option <- paste(status_type_option, collapse = " AND ")
  }else{
    status_type_option <- paste0("r.", status_type, " =~ '", status_type_option_value, "'")
    status_type_option <- paste(status_type_option, collapse = " AND ")
  }
  
  #-------------return---------------------------
  return(status_type_option)
}


################################################################################
#weight_option_for_where
################################################################################
#根据weight的选择来设置weight的筛选条件
weight_option_for_where <- function(groups,
                                    timepoints,
                                    weight = c(0.1,0.6)){
  
  #weight_option-------------------------------
  if (!is.null(timepoints)){
    #status_timepoint_weight
    status_timepoint_weight <- c()
    for (g in groups){  
      status_timepoint_weight = append(status_timepoint_weight, 
                                       paste0(g, "_",timepoints, "_weight"))
    }
    ##status_timepoint_weight_option-----
    status_timepoint_weight_option <- paste0("r.", status_timepoint_weight, " >= ", weight[1],
                                             " AND r.", status_timepoint_weight, " <= ", weight[2])
    status_timepoint_weight_option <- paste(status_timepoint_weight_option, collapse = " AND ")
    
  }else{
    status_timepoint_weight_option <- ""
  }
  
  #-------------return---------------------------
  return(status_timepoint_weight_option)
}


################################################################################
#status_type_return_for_gg
################################################################################
#返回所选择组别的关系类型，如： COPD_smoker_time
status_type_return_for_gg <- function(groups){
  
  if (is.null(groups)){
    groups = c("COPD_smoker","smoker","nonsmoker",
               "COPD_vs_smoker","COPD_vs_nonsmoker","smoker_vs_nonsmoker")
  }
  
  #========================return options=========================================
  #status_type #比如： "COPD_smoker_time" "smoker_time" 
  status_type <- paste0(groups, "_time")

  #status_type_return 返回'1010','1101'之类的
  status_type_return <- paste0("r.", status_type, " AS ", status_type)
  status_type_return <- paste(status_type_return, collapse = ", ")
  
  #-------------return---------------------------
  return(status_type_return)
  
}

################################################################################
#status_time_weight_return_for_gg
################################################################################
#返回所选组的所有时间点的weight的值，没有groups,就默认所有个group
status_time_weight_return_for_gg <- function(groups){
  
  if (is.null(groups)){
    groups = c("COPD_smoker","smoker","nonsmoker",
               "COPD_vs_smoker","COPD_vs_nonsmoker","smoker_vs_nonsmoker")
  }
  
  #status_time_weight 比如： nonsmoker_M3_weight
  time_weight <- c("_M0_weight","_M3_weight", "_M6_weight",  "_M12_weight")
  status_time_weight <- c()
  for (g in groups){  status_time_weight = append(status_time_weight, paste0(g, time_weight))}
  
  #status_time_weight_return #返回各个时间的weight
  status_time_weight_return <- paste0("r.", status_time_weight, " AS ", status_time_weight)
  status_time_weight_return <- paste(status_time_weight_return, collapse = ", ")
  
  #-------------return---------------------------
  return(status_time_weight_return)
}

