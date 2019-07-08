# data cleaning
# 
# organize the information into a format (data frames) that will be amenable for
# sorting the data as appropriate

# where the data's at
inputTSV <- '/home/jfaskowi/JOSHSTUFF/projects/filter_mriqc_res/data/raw/group_bold.tsv'

################################################################################
# init list

inputTab <- read.table(inputTSV, sep = '\t' , header = TRUE )

tmpStr <- rapply(inputTab, function(x){paste(sub('sub-','',x[1]),'-',x[2],sep = '')})
t1_mriqcDf['sub_name'] <- tmpStr

################################################################################
# parse the mriqc fmri file

tmpFileName <- dir(qcmetListbPath, pattern = "mri_qc_group_bold.tsv", full.names = TRUE)
fmri_mriqcDat <- read.table(tmpFileName, header = TRUE, sep = '\t')

acq1400Df <- fmri_mriqcDat[grep(".*acq-1400_bold",fmri_mriqcDat$bids_name),]
attr(acq1400Df,"acqname") <- "acq-1400"
acq2500Df <- fmri_mriqcDat[grep(".*acq-2500_bold",fmri_mriqcDat$bids_name),]
attr(acq2500Df,"acqname") <- "acq-2500"
acq645Df <- fmri_mriqcDat[grep(".*acq-645_bold",fmri_mriqcDat$bids_name),]
attr(acq645Df,"acqname") <- "acq-645"

tmpDat <- strsplit(as.character(acq1400Df$bids_name),split = '_')
tmpStr <- rapply(tmpDat, function(x){paste(sub('sub-','',x[1]),'-',x[2],sep = '')})
acq1400Df['sub_name'] <- tmpStr

tmpDat <- strsplit(as.character(acq2500Df$bids_name),split = '_')
tmpStr <- rapply(tmpDat, function(x){paste(sub('sub-','',x[1]),'-',x[2],sep = '')})
acq2500Df['sub_name'] <- tmpStr

tmpDat <- strsplit(as.character(acq645Df$bids_name),split = '_')
tmpStr <- rapply(tmpDat, function(x){paste(sub('sub-','',x[1]),'-',x[2],sep = '')})
acq645Df['sub_name'] <- tmpStr

fmri_mriqc_list <- list() 
fmri_mriqc_list[[1]] <- acq1400Df 
fmri_mriqc_list[[2]] <- acq2500Df 
fmri_mriqc_list[[3]] <- acq645Df 

################################################################################
# parse the mriqc t1 file

tmpFileName <- dir(qcmetListbPath, pattern = "mri_qc_group_T1w.tsv", full.names = TRUE)
t1_mriqcDf <- read.table(tmpFileName, header = TRUE, sep = '\t')

t1_mriqcDat <- strsplit(as.character(t1_mriqcDf$bids_name),split = '_')
tmpStr <- rapply(t1_mriqcDat, function(x){paste(sub('sub-','',x[1]),'-',x[2],sep = '')})
t1_mriqcDf['sub_name'] <- tmpStr




