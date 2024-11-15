#!/bin/bash

"""
This script takes in raw sequencing reads fastq.gz file (first read R1 file for paired-end reads), 
extracts chimeric reads that contain Tol2 sequences, trim offs Tn5 adapter and Tol2 sequences, 
and outputs the remaining flanking sequences. 

The output file needs to be uploaded to https://menglab.shinyapps.io/transtag_alignmentfree/ for further processing.
Alternatively, you can run TransTag_alignmentFree.ShinyApp.R on your own computers and upload the output file.

Input: 
	sample.fastq.gz
Ouput: 
	sample.flankingSequences.txt
Example usage:
	bash TransTag_alignmentFree.sh sample.fastq.gz 

@author: Fanju Meng (fanju.meng@unt.edu) 
"""

#Take input fastq.gz file from command line input
ifile=$1
echo "Processing sequencing file: $1"

#Extract sample name	
iname=$(echo "$ifile" | awk -F'/' '{print $NF}' | sed -r 's/.fq.gz//g' | sed -r 's/.fastq.gz//g' | sed -r 's/.fastq//g' | sed -r 's/.fq//g')
echo "Sample name: $iname"

#Extract chimeric reads that contain Tol2 sequences
echo "Extracting chimeric reads..."
zless "${ifile}" | grep "TTTCACTTGAGTAAAATTTTTGAGTACTTTTTACACCTCTG"  > "${iname}".chimeric_reads.R1.txt


#Trim off Tn5 adapter sequences from 3' end
echo "Trimming off Tn5 adapter..."
printf "" > "${iname}".Tn5adapter_rm.txt
while IFS= read -r line; do
	echo ${line%%CTGTCTCT*} >> "${iname}".Tn5adapter_rm.txt
done < "${iname}".chimeric_reads.R1.txt

#Trim off Tol2 sequences from 5' end
echo "Trimming off Tol2 sequence..."
printf "" > "${iname}".flankingSequences.txt
while IFS= read -r line; do
	echo ${line##*CTTTTTACACCTCTG} >> "${iname}".flankingSequences.txt
done < "${iname}".Tn5adapter_rm.txt

#Delete intermediate files
rm -f "${iname}".chimeric_reads.R1.txt "${iname}".Tn5adapter_rm.txt

echo "Finished!"
echo "Now you can upload the output file: flankingSequences.txt to TransTag_alignmentFree.ShinyApp for processing"

