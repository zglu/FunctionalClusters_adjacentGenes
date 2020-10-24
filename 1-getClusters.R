args = commandArgs(trailingOnly=TRUE)
geneNrCoord<-read.delim(args[1], sep=" ", header=F)
# 1 88327 Smp_329140
# 2 103403 Smp_315690
# 3 256087 Smp_317470

rawTable<-read.delim(args[2], sep=" ", header=F)
#colnames(rawTable)=c("chr", "func", "enriched", "firstNr", "lastNr"))
# SM_V7_1-pos PF00188:CAP 3 273 275
# SM_V7_1-pos PF00209:SNF 3 731 733

for (i in 1:nrow(rawTable)) {
    # replace gene order with gene coordinate
    first<-rawTable[i, 4]
    rawTable[i, 4]<-geneNrCoord[first, 2]
    last<-rawTable[i, 5]
    rawTable[i, 5]<-geneNrCoord[last, 2]
    # get genes for the cluster
    subgenes<-geneNrCoord[which(geneNrCoord$V2>=rawTable[i, 4] & geneNrCoord$V2<=rawTable[i, 5]),]
    rawTable[i,6]<-paste(unlist(subgenes$V3), collapse=",")
}

write.table(rawTable, file=paste0(args[2], ".mod.txt"), quote=F, row.names=F, col.names=F)
