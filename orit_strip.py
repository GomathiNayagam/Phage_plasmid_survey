from Bio import SeqIO

def extract_orit_sequences(concatenated_genbank_file):
    orit_sequences = []
    
    # Parse the concatenated GenBank file
    for record in SeqIO.parse(concatenated_genbank_file, "genbank"):
        for feature in record.features:
            # Check if the feature is 'oriT'
            if feature.type == "oriT":
                # Get the coordinates of the oriT feature
                start = feature.location.start
                end = feature.location.end
                # Retrieve the sequence of the oriT region
                orit_sequence = str(record.seq[start:end])
                orit_sequences.append(orit_sequence)
    
    return orit_sequences

# Provide the path to your concatenated GenBank file
concatenated_genbank_file = "/media/gomathinayagam/Backup/ARG_phage_plasmids/New/orit_finder/oriT_update/merged.gb"

# Extract oriT sequences
oriT_sequences = extract_orit_sequences(concatenated_genbank_file)

# Print the extracted oriT sequences
for i, sequence in enumerate(oriT_sequences, start=1):
    print(f"oriT sequence {i}: {sequence}")

