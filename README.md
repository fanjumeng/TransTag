# TransTag

This repository contains scripts for the alignment-free Shiny app analysis in: 

**TransTag: simple and efficient transgene mapping in zebrafish via tagmentation.** <br/>
Fanju W. Meng, Paige Schneider, Xiaolu Wei, Krishan Ariyasiri, Marnie E. Halpern, Patrick J. Murphy.


## Scripts

- **TransTag_alignmentFree.sh**

This is a pre-processing script that takes in the raw sequencing reads fastq.gz file (first read R1 file for paired-end reads), extracts chimeric reads that contain Tol2 sequences, trim offs Tn5 adapter and Tol2 sequences, and outputs the remaining flanking sequences. <br/> 
The output flanking sequence file then can be uploaded to the online Shiny app https://menglab.shinyapps.io/transtag_alignmentfree/ for further processing. <br/>
Alternatively, you can run TransTag_alignmentFree.ShinyApp.R on your own computers and upload the output file. <br/>
<ins>Input</ins>: sample.fastq.gz	
<ins>Ouput</ins>: sample.flankingSequences.txt	
<ins>Example usage</ins>: bash TransTag_alignmentFree.sh sample.fastq.gz 
   

- **TransTag_alignmentFree.ShinyApp.R**

This is the R script to launch Shiny app to process the flanking sequence file, and output the top enriched k-mer sequences.
The top enriched k-mer sequences represent genomic regions flanking the most possible insertion site(s). You can search/blast the most enriched k-mer sequence(s) in the genome to find the possible location of insertion site(s).

Required packages in R <br/>
	- shiny
	- tidyverse
	- dplyr
	
<ins>Usage</ins>: Open the downloaded script in R Studio and click "Run App", and the Shiny application will pop out in a new window. Upload the flanking sequence file for process.
	
<ins>Example file</ins>: example.flankingSequences.txt

## Notes

1. Based on the assembled Tn5 used in the library preparation step, R1 reads file for the pair-end sequencing reads will have the Tol2 repeat sequence. For alignment-free analysis, R1 reads file would be the input file for the TransTag_alignmentFree.sh script.

2. If you get "Maximum upload size exceeded" error, modify ```options(shiny.maxRequestSize = )``` in the TransTag_alignmentFree.ShinyApp.R script to increase the limit.
