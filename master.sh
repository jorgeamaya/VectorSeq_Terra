#!/bin/bash

rm -rf Results
mkdir Results

Rscript script1_vgsc.R
Rscript script2_vgsc.R

perl FindKmersASVs.pl -k vgsc_kmers.txt -f Results/Top2ASV_sequences2.fasta -o Results/vgsc_out.txt
