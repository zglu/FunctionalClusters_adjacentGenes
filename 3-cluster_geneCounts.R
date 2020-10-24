library(ggplot2)
library(ggrepel)
args = commandArgs(trailingOnly=TRUE)
segmsall<-read.delim(args[1], sep=" ", header = F, col.names=c("chr", "func", "name", "ng", "start", "end", "genes", "chrlen"))
#SM_V7_1 PF00012 HSP70 3 63516640 63531062 Smp_302170,Smp_302180,Smp_303550 88881357
segms<-segmsall[which(segmsall$ng>=5),]

maxgenes<-max(segms$ng)
pdf(file=paste0(args[1], "_geneCounts.pdf"), width=12, height=6.8)
# facet
pp<-ggplot(data=segms, aes(x=start/1000000, y=ng)) + geom_bar(stat="identity", position="dodge", fill="blue", width=0.6) + geom_text_repel(data=segms[which(segms$ng>=5),], mapping=aes(x=start/1000000, y=ng,label=paste0(name, " (", ng, ")")), size=2.8, vjust=-0.8, color="black")  + geom_rect(mapping=aes(xmin=0, xmax=chrlen/1000000, ymin=0, ymax=maxgenes), fill="grey", color="red", alpha=0.01, size=0.6) + facet_grid(rows=vars(chr)) 
pp<-pp+scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0)) + labs(x="Coordinate (Mb)", y="Genes") + ylim(0, maxgenes) + theme(legend.position="none") #+ theme_classic()# / theme_bw()

pp

dev.off()
