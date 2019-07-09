# data cleaning
# 
# organize the information into a format (data frames) that will be amenable for
# sorting the data as appropriate

# load required package
require("outliers")

################################################################################

cmdLineArgs <- commandArgs(trailingOnly = TRUE)

# where the data's at
inputTSV <- cmdLineArgs[1]
outDir <- cmdLineArgs[2]

# read 
if (!file.exists(inputTSV)) {
  stop("input tsv does not seem to exist")
} 

# inputTSV <- paste(getwd(),'/data/raw/group_T1w.tsv', sep = '')
print(paste("inputTSV: ",inputTSV,sep=''))

################################################################################
# init list

mriqcDF <- read.table(inputTSV, sep = '\t' , header = TRUE )

# add subject session
tmpDat <- strsplit(as.character(mriqcDF$bids_name),split = '_')
mriqcDF['sub_id'] <- rapply(tmpDat, function(x){paste(sub('sub-','',x[1]))})

################################################################################
# use structural IQM 

outlmat <- matrix(0, nrow = nrow(mriqcDF), ncol = 7)
# true if outlier
# noise measurements
outlmat[,1] <- outliers::scores(mriqcDF$cjv, type = "iqr", lim = 1.5)
outlmat[,2] <- outliers::scores(mriqcDF$cnr, type = "iqr") < -1.5 # lower is worse
outlmat[,3] <- outliers::scores(mriqcDF$snr_total, type = "iqr") < -1.5 # lower is worse
outlmat[,4] <- outliers::scores(mriqcDF$snrd_total, type = "iqr") < -1.5 # lower is worse
outlmat[,5] <- outliers::scores(mriqcDF$qi_2, type = "iqr", lim = 1.5) 
outlmat[,6] <- outliers::scores(mriqcDF$fber, type = "iqr", lim = 1.5)
outlmat[,7] <- outliers::scores(mriqcDF$efc, type = "iqr", lim = 1.5)

oiqm_bool <- rowSums(outlmat) >= 4

################################################################################
# outliers

outl_bool <- oiqm_bool

byScanDf <- data.frame("outlier_scans" = mriqcDF$bids_name[outl_bool])

################################################################################
# per subject
# for each subject, how many of available scans are outlier scans?

uniqSubs <- unique(mriqcDF$sub_id) ; prcnt_oscans <- c() ; tot_scans <- c()

for (subIdx in 1:length(uniqSubs))
{
  ss <- uniqSubs[subIdx]
  ss_scans <- mriqcDF$sub_id == ss
  ss_oscans <- (mriqcDF$sub_id == ss) & outl_bool
  
  tot_scans[subIdx] <-  sum(ss_scans)
  prcnt_oscans[subIdx] <- format(sum(ss_oscans) / sum(ss_scans) * 100, digits = 0) 
}

bySubDf <- data.frame("sub_name" = uniqSubs, 
                      "total_scans" = tot_scans, 
                      "prcnt_outlier_scans" = prcnt_oscans)

################################################################################
# write output

write.table(byScanDf, paste(outDir, '/anat_outlier_scans.csv', sep=''),
            sep=',', row.names = FALSE, col.names = FALSE, quote = FALSE)

write.table(bySubDf, paste(outDir, '/anat_outlier_sub_stats.csv', sep=''),
            sep=',', row.names = FALSE, col.names = TRUE, quote = FALSE)





