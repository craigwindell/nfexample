#!/usr/bin/env nextflow

// Set some variables
db_name = file(params.db).name
db_dir = file(params.db).parent

// Run Blast Query
process BLAST {
  input:
  path 'query.fa'
  path db

  output:
  path 'top_hits'

  script:
  """
  blastp -db ${db}/${db_name} -query query.fa -outfmt 6 > blast_result
  cat blast_result | head -n 10 | cut -f 2 > top_hits
  """
}

// Run blastdbcmd against top_hits
process EXTRACT {
  input:
  path 'top_hits'
  path db

  output:
  path 'sequences'

  script:
  """
  blastdbcmd -db ${db}/${db_name} -entry_batch top_hits | head -n 10 > sequences
  """
}

workflow {
  Channel
    .fromPath(params.query)
    .splitFasta(by: params.chunkSize, file:true)
    .set { ch_fasta }

  ch_hits = BLAST(ch_fasta, db_dir)
  ch_sequences = EXTRACT(ch_hits, db_dir)

  ch_sequences
    .collectFile(name: params.out)
    .view { file -> "matching sequences:\n ${file.text}" }
}