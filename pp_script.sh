#!/bin/bash

#conda activate prodigal_gv
# Check if the nucleotide file is provided as a command-line argument
if [ $# -eq 0 ]; then
    echo "Please provide the nucleotide file as a command-line argument."
    exit 1
fi

# Input file paths
NUCLEOTIDE_FILE="$1"
HMM_FILE="/home/sgomathi/phage_plasmids/essentials/merged_plasmid_hallmark.hmm"

seqkit seq -m 3000 $1 > NUCLEOTIDE_FILE_fil.fa &&

# Step 1: Call ORFs using Prodigal-gv
/home/sgomathi/phage_plasmids/essentials/./prodigal-gv -p meta -i NUCLEOTIDE_FILE_fil.fa -a output_proteins.faa -q

# Step 2: Search for hits using hmmsearch
hmmsearch -E 1e-20 --tblout new_output_hits.tblout "$HMM_FILE" output_proteins.faa

# Step 3: Retrieve hits using awk
awk '{print $1}' new_output_hits.tblout | grep -o '.*_' - > new_list_of_hits.txt
grep -o '.*[^_]' new_list_of_hits.txt > new_hits.txt

# Step 4: Retrieve hits.fna using grep
seqtk subseq "$NUCLEOTIDE_FILE" new_hits.txt > tmp.fna
seqkit rmdup -s tmp.fna > new_hits.fna &&
rm tmp.fna 

awk '{OFS="\t"; print $1, $3, $4}' new_output_hits.tblout | grep -o '.*[^_]' - > new_list_of_hits.txt

# Step 5: QC of hits.fna using CheckV
checkv end_to_end new_hits.fna checkv_out -d $HOME/checkv-db-v1.5 -t 26
