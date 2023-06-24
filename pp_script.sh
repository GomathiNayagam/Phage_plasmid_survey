#!/bin/bash

conda activate prodigal_gv
# Check if the nucleotide file is provided as a command-line argument
if [ $# -eq 0 ]; then
    echo "Please provide the nucleotide file as a command-line argument."
    exit 1
fi

# Input file paths
NUCLEOTIDE_FILE="$1"
HMM_FILE="/home/gomathinayagam/Antioxidants_in_phages/ARG_phage_plasmids/merged.hmm"

# Step 1: Call ORFs using Prodigal-gv
prodigal-gv -p meta -i "$NUCLEOTIDE_FILE" -a output_proteins.faa

# Step 2: Search for hits using hmmsearch
hmmsearch -E 1e-50 --tblout output_hits.tblout "$HMM_FILE" output_proteins.faa

# Step 3: Retrieve hits using awk
awk '{print $1}' output_hits.tblout | grep -o '.*_' - > list_of_hits.txt
grep -o '.*[^_]' list_of_hits.txt > hits.txt

# Step 4: Retrieve hits.fna using grep
seqtk subseq "$NUCLEOTIDE_FILE" hits.txt > tmp.fna
seqkit rmdup -s tmp.fna > hits.fna &&
rm tmp.fna

awk '{OFS="\t"; print $1, $3, $4}' output_hits.tblout | grep -o '.*[^_]' - > list_of_hits.txt

# Step 5: QC of hits.fna using CheckV
checkv end_to_end hits.fna checkv_out -d $HOME/checkv-db-v1.1
