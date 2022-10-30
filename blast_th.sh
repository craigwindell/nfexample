#!/usr/bin/env bash

# Set some variables
db="blast-db/pdb"
db_name="tiny"
query="data/sample.fa"

# Run Blast Query
blastp -db ${db}/${db_name} -query ${query} -outfmt 6 > blast_result
cat blast_result | head -n 10 | cut -f 2 > top_hits

# Run blastdbcmd against top_hits
blastdbcmd -db ${db}/${db_name} -entry_batch top_hits | head -n 10 > sequences