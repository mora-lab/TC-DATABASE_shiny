#这个函数的设置，是为了对每个时间点的类型值的选择
#如果只选择了M3,那这个值就是。1..。
#用来在设置where语句中关于timepoint和group的选择

# M0 M3 M6 M12
get_group_options_value <- function(timepoints){
  #timepoints <- c("M0", "M12")
  if ("M0" %in% timepoints){t1 = "1"}else{t1="."}
  if ("M3" %in% timepoints){t2 = "1"}else{t2="."}
  if ("M6" %in% timepoints){t3 = "1"}else{t3="."}
  if ("M12" %in% timepoints){t4 = "1"}else{t4="."}
  t <- paste0(t1,t2,t3,t4)
  return(t)
}