#!/bin/bash

## find functional (e.g. pfam, interpro) gene clusters (>=3 consecutive genes) on chromosomes; doesn't consider strandness
## usage: ./_functionalClusters.sh

##--*--## INPUT FILES ####
#1 gene-chr-start.txt	gene chromosome start_coord (only for complete chromosomes)
# Smp_329140 SM_V7_1 88327

#2 gene-func.txt	gene and function annotations "," seperated
# Smp_000040	PF13374,PF13424

#3 func-names.txt	function id and name SHOULD NOT CONTAIN : ' or "
# PF00001	7tm_1

#4 chr-length.txt	chromosome length
# SM_V7_1 88881357


# CHECK SPECIAL CHARACTERS IN FUNC-NAMES.TXT
if grep -q "'" func-names.txt; then
	echo "func-names.txt contains single quotes"
elif grep -q '"' func-names.txt; then
	echo "func-names.txt contains double quotes"
elif grep -q ':' func-names.txt; then
	echo "func-names.txt contains :"
	exit 0
fi


echo "Generating files to use..."
sort gene-chr-start.txt | join -a1 - gene-func.txt > gene-chr-func.txt
# Smp_000040 SM_V7_1 46590475 PF13374,PF13424

echo "Splitting and finding clusters on each chromosome..."

for i in $(awk '{print $1}' chr-length.txt | sort -u); do
    grep $i gene-chr-func.txt | sort -k2,2 -k3,3n > $i.txt # each chromosome to a file
    # $i.txt
    # Smp_329140 SM_V7_1 88327
    # Smp_315690 SM_V7_1 103403 PF00150

    sort -nk3 $i.txt | awk '{print NR, $3, $1}' > $i-NrCoord # put genes in consecutive genomic orders
    # $i-NrCoord
    # 1 88327 Smp_329140
    # 2 103403 Smp_315690

    sort -nk3 $i.txt | awk '{print NR, $4}'| sed 's/,/ /g'| awk -v OFS='\t' '{for (i=2;i<=NF;i++) print $1,$i}'| awk '{print $2, $1}'| sort -k1,1 -k2,2n|awk '$1>p || $2!=q+1{if(NR>1)print p,c,q-c+1,q; c=0} {p=$1; q=$2; c++} END{print p,c}' | awk '$2>2'|sort|join func-names.txt - | awk '{print $1 ":" $2, $3, $4, $5}' > $i-pos
    # function genes first_No last_No 
    # PF00188:CAP 3 273 275
    # PF00209:SNF 3 731 733

    awk '{print FILENAME, $0}' $i-pos > $i.clusters
    # SM_V7_1-pos PF00188:CAP 3 273 275
    # SM_V7_1-pos PF00209:SNF 3 731 733

    Rscript 1-getClusters.R $i-NrCoord $i.clusters
    # change gene order No. to coordinates; get genes for that cluster
    # SM_V7_1-pos PF00188:CAP 3 12275798 12354088 Smp_124070,Smp_124060,Smp_124050 88881357
    # SM_V7_1-pos PF00209:SNF 3 30228976 30302542 Smp_333980,Smp_129920,Smp_129900 88881357
done


echo "Plotting clusters..."
# combine single chromosome outputs into one file
cat *.mod.txt | sed 's/-pos//; s/:/ /' | sort | join - chr-length.txt > all-Clusters.txt
# SM_V7_1 PF00188 CAP 3 12275798 12354088 Smp_124070,Smp_124060,Smp_124050
# SM_V7_1 PF00209 SNF 3 30228976 30302542 Smp_333980,Smp_129920,Smp_129900

rm -f *-pos *.clusters *-NrCoord *.mod.txt

Rscript 3-cluster_geneCounts.R all-Clusters.txt
Rscript 4-cluster_geneCoord.R all-Clusters.txt

## modifiy the table
## cat all-Clusters.txt | awk '{print $2, $0}'| sort | join ../pfamRef.txt - | awk '{print $3, $4, $2, $6, $7, $8, $9}'| sed 's/#/ /g'| tr ' ' '\t'|sort -k1,1 -k6,6n > all-Clusters.sheet.txt
## SM_V7_1	PF00188	CAP	Cysteine-rich_secretory_protein_family	3	12275798	12354088	Smp_124070,Smp_124060,Smp_124050
