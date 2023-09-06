
#----------------------------------------------------------------------
# Loading the R packages needed for this script
#----------------------------------------------------------------------

library(dplyr)
library(reshape2)
library(ggplot2)
library(tidyr)
library(Biostrings)
library(DECIPHER)
library(ape)
library(msa)
library(ggmsa)

getwd()
#setwd("~/Desktop/VectorSeq/Insecticide_Resistance/Terra_Pipeline/")
#setwd("~/Desktop/VectorSeq/Insecticide_Resistance/")

#----------------------------------------------------------------------
# Read the Top 2 ASVs per sample file. This file should contain 5 columns
# Sample ID, Top1 ASV ID, Top 2 ASV ID, Read count for the top 1 ASV 
# followed by read count for top the top 2 ASV

# To know the list of ASV IDs to explore the number of ASVs within
# the category of top2 per sample run the following code 
# vector <- c(DF1$top1_ASV, DF1$top2_ASV)
# unique_values1 <- unique(vector)
# NOTE: keep in mind that this list would not represent all valid ASVs
#----------------------------------------------------------------------

DF1 <- read.csv("Results/Top2ASVs_perSample.csv")

#-------------------------------------------------------------------------
# Apply the minimum read count threshold of 50. This filter will exclude
# ASV with less than 50 Read Counts.
#-------------------------------------------------------------------------

DF1_melted <- reshape2::melt(DF1, id.vars = c("X", "top1_ASV", "top2_ASV" ), 
                  measure.vars = c("RC_top1_ASV", "RC_top2_ASV"))
RC50 <- DF1_melted[which(DF1_melted$value >= 50),]
DF1_unmelted <- RC50 %>% spread(variable, value)
DF1_unmelted$top2_ASV[is.na(DF1_unmelted$RC_top2_ASV)] <- ""

# calculating row proportion of the cell value
DF2 <- DF1_unmelted
DF2$row_sum <- rowSums(DF2[ , c(4,5)], na.rm=TRUE)
DF2$prop <- DF2[5]/DF2$row_sum
colnames(DF2)[7] = "prop"

#-------------------------------------------------------------------------
# To know the list of ASV IDs to explore the number of ASVs within
# the category of top2 per sample with a minimun of 50 RC
#-------------------------------------------------------------------------

#Applying different thresholds to find a valid top2 ASV
RC50_10 <- DF2
RC50_10$top2_ASV[RC50_10$prop <= 0.1] <- ""
vector3 <- c(RC50_10$top1_ASV, RC50_10$top2_ASV)
unique_ASVIDs2 <- unique(vector3)

#-------------------------------------------------------------------------
#APPROACH 2 to find a valid top2 ASVs 
#-------------------------------------------------------------------------

ASV_seq <- read.csv("Results/ASV_ID_and_Sequences.csv")
top2ASV <- subset(ASV_seq, ASV_seq$ASV_ID %in% unique_ASVIDs2)

sequences <- top2ASV$Sequence
names <- top2ASV$ASV_ID
dna_strings <- DNAStringSet(sequences)
names(dna_strings) <- names

writeXStringSet(dna_strings, file = "Results/Top2ASV_sequences2.fasta", format = "fasta")

