#!/bin/bash

#conda activate prodigal_gv

if [ $# -eq 0 ]; then
    echo "Please provide the nucleotide file as a command-line argument."
    exit 1
fi

# Input file paths
NUCLEOTIDE_FILE="$1"
HMM_FILE="/home/sgomathi/phage_plasmids/essentials/merged_plasmid_hallmark.hmm"

seqkit seq -m 3000 $1 > NUCLEOTIDE_FILE_fil.fa &&

# Prodigal-gv
/home/sgomathi/phage_plasmids/essentials/./prodigal-gv -p meta -i NUCLEOTIDE_FILE_fil.fa -a output_proteins.faa -q

# hmmsearch
hmmsearch -E 1e-20 --tblout new_output_hits.tblout "$HMM_FILE" output_proteins.faa

# Retrieve hits 
awk '{print $1}' new_output_hits.tblout | grep -o '.*_' - > new_list_of_hits.txt
grep -o '.*[^_]' new_list_of_hits.txt > new_hits.txt

# Retrieve hits.fna 
seqtk subseq "$NUCLEOTIDE_FILE" new_hits.txt > tmp.fna
seqkit rmdup -s tmp.fna > new_hits.fna &&
rm tmp.fna 

awk '{OFS="\t"; print $1, $3, $4}' new_output_hits.tblout | grep -o '.*[^_]' - > new_list_of_hits.txt

# CheckV
checkv end_to_end new_hits.fna checkv_out -d $HOME/checkv-db-v1.5 -t 26
