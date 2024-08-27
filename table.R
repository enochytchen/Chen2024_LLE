## Filename: table 
## Note: organize results

# Set working directory to where this R program is
if (require("rstudioapi") && isAvailable()) {
  original_wd <- getwd()  # Store the original working directory
  wd <- dirname(rstudioapi::getActiveDocumentContext()$path)}
setwd(wd)

##############################################################
##============================================================
## Install/Read packages
##============================================================
##############################################################
library(haven)
library(flextable)
library(officer)
library(dplyr)

##############################################################
##============================================================
## Read data
##============================================================
##############################################################
scenarios <- read_dta("scenarios.dta")
str(scenarios)
scenarios_sub <- scenarios[,c("scenario", "agestd", "trtgrp", "mean_le", "diff_le", "mean_leexp", "diff_leexp", "mean_lle", "diff_lle")]

roundf <- function(x) {
  format(round(x, 1), nsmall = 1)
}

cols <- c("mean_le", "diff_le", "mean_leexp", "diff_leexp", "mean_lle", "diff_lle")
scenarios_sub[cols] <- lapply(scenarios_sub[cols], roundf)


##############################################################
##============================================================
## Tabulate the results
##============================================================
##############################################################
## print df
print(scenarios_sub)

## Export as docx
## Make a flextable and export it as docx 
ft <- flextable(scenarios_sub)  
ft <- autofit(ft)
ft <- set_header_labels(ft, "scenario" = "Scenario", 
                            "agestd" = "Standardization to age distribution of",
                            "trtgrp" = "Treatment group",
                            "mean_le" = "LE", "diff_le" = "ΔLE", 
                            "mean_leexp" = "LE*", "diff_leexp" = "ΔLE*", 
                            "mean_lle" = "LLE","diff_lle" = "ΔLLE")
ft <- align(ft, align = c("center"), i = 1, j = 1:9, part = "header")
ft <- align(ft, align = c("center"), i = 1:8, j = 1:9, part = "body")

rows <- list(c(1, 2), c(3, 4), c(5, 6), c(7, 8))

# Loop over the defined ranges
for (i in seq_along(rows)) {
  ft <- merge_at(ft, i = rows[[i]], j = 1, part = "body")
}
for (i in seq_along(rows)) {
  ft <- merge_at(ft, i = rows[[i]], j = 2, part = "body")
}
for (i in seq_along(rows)) {
  ft <- merge_at(ft, i = rows[[i]], j = 5, part = "body")
}
for (i in seq_along(rows)) {
  ft <- merge_at(ft, i = rows[[i]], j = 7, part = "body")
}
for (i in seq_along(rows)) {
  ft <- merge_at(ft, i = rows[[i]], j = 9, part = "body")
}

ft <- add_footer_lines(ft,"Δ, difference in; LE, life expectancy; LE*, expected life expectancy; LLE, loss in life expectancy.")
ft <- autofit(ft)
ft <- hline(ft, i = c(2,4,6,8), j = 1:9, part = "body")

ft <- hline_bottom(ft, part = "body")
ft <- fix_border_issues(ft, part = "all")
ft

## Save results
## Prevent from changing the results. We put # here.
save_as_docx(ft, path="table.docx")
################################################################
# Copyright 2024 Chen EYT. All Rights Reserved.
# Loss in Life Expectancy Does Not Adjust Confounding
# 
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


