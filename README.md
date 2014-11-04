Expression Cluster Paper Triage 
-- A First Pass Process to identify papers with expression cluster data

1. ExprClusterTriage.csv 

This is the data file containing all manual curation info that identifies which papers contains what kind of functional genomic assay. 
Datatypes that may generate expression cluster include: 

microarray
tiling array
RNAseq
qRT-PCR
Mass Spectrometry/2D-DIGE

This file include information from: 

     1. Textpresso pattern search (papers with hits > 4 were manually checked already) 
     2. Old First pass curation pipeline by Andrei
     3. Curator feedback after Anderi left.
     4. Array Express and Textpresso search for papers with accession no.

2. mergeECpaper.pl

This script then checks these resources and merge them(listed by priority order): 

     1. citace about curated Expression_cluster, microarray, RNAseq, tiling array papers. These are curated paper list. 
     2. MAPaperGSETable.txt - curation queue for microarray
     3. MAPaperGSETable_RNAseq.txt - curation queue for RNAseq and tiling array
     4. ExprClusterTriage.csv -- detailed first pass results by Wen
     5. Unclassified_FirstPass.txt -- detailed first pass results by other curators
     6. Unclassified_Textpresso.txt -- pattern search by Textpresso

The results can be submitted into curation status form.

3. queryECpaper.pl

This script take a list of paper ids (provided by Chris for topic curation), then check the outout of mergeECpaper.pl to see if they contain expression cluster data and if they were curated. 

