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
fdPrcntThr <- 25 
if (length(cmdLineArgs) > 2)
{
  fdPrcntThr <- as.numeric(cmdLineArgs[3])
}
print(paste("fd thresh set to: ",as.character(fdPrcntThr),sep=''))

# read 
if (!file.exists(inputTSV)) {
  stop("input tsv does not seem to exist")
} 

# inputTSV <- paste(getwd(),'/data/raw/group_bold.tsv', sep = '')
print(paste("inputTSV: ",inputTSV,sep=''))

################################################################################
# init list

mriqcDF <- read.table(inputTSV, sep = '\t' , header = TRUE )

# add subject session
tmpDat <- strsplit(as.character(mriqcDF$bids_name),split = '_')
mriqcDF['sub_id'] <- rapply(tmpDat, function(x){paste(sub('sub-','',x[1]))})

################################################################################
# first threshold based on fd outlier percentage

othr_bool <- mriqcDF$fd_perc >= fdPrcntThr

################################################################################
# use functional IQM 

outlmat <- matrix(0, nrow = nrow(mriqcDF), ncol = 7)
# true if outlier
# temporal measurements
outlmat[,1] <- outliers::scores(mriqcDF$dvars_nstd, type = "iqr", lim = 1.5)
outlmat[,2] <- outliers::scores(mriqcDF$tsnr, type = "iqr") < -1.5 # lower is worse
outlmat[,3] <- outliers::scores(mriqcDF$fd_mean, type = "iqr", lim = 1.5)
outlmat[,4] <- outliers::scores(mriqcDF$aor, type = "iqr", lim = 1.5)
outlmat[,5] <- outliers::scores(mriqcDF$aqi, type = "iqr", lim = 1.5)
# spatial measurements
outlmat[,6] <- outliers::scores(mriqcDF$snr, type = "iqr") < -1.5 # lower is worse
outlmat[,7] <- outliers::scores(mriqcDF$efc, type = "iqr", lim = 1.5)

oiqm_bool <- rowSums(outlmat) >= 4

################################################################################
# outliers

outl_bool <- (othr_bool | oiqm_bool)

byScanDf <- data.frame("outlier_scans" = mriqcDF$bids_name[outl_bool])
byScanDf2 <- data.frame("keep_scans" = mriqcDF$bids_name[!outl_bool])

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

outFile=paste(outDir, '/bold_outlier_scans.csv', sep='')
print(paste('outFile: ',outFile,sep=''))
write.table(byScanDf, outFile,
            sep=',', row.names = FALSE, col.names = FALSE, quote = FALSE)

outFile=paste(outDir, '/bold_keep_scans.csv', sep='')
print(paste('outFile: ',outFile,sep=''))
write.table(byScanDf2, outFile,
            sep=',', row.names = FALSE, col.names = FALSE, quote = FALSE)

outFile=paste(outDir, '/bold_outlier_sub_stats.csv', sep='')
print(paste('outFile: ',outFile,sep=''))
write.table(bySubDf, outFile,
            sep=',', row.names = FALSE, col.names = TRUE, quote = FALSE)





