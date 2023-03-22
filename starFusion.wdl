version 1.0

struct GenomeResources {
    String modules
    String starFusion
    String genomeDir
}

workflow starFusion {
  input {
    Array[Pair[File, File]] inputFqs
    File? chimeric
    String reference
    String outputFilePrefix
  }

Map[String, GenomeResources] resources = {
  "hg38": {
    		"modules" : "star-fusion/1.8.1 star-fusion-genome/1.8.1-hg38",
        "starFusion": "$STAR_FUSION_ROOT/STAR-Fusion",
        "genomeDir": "$STAR_FUSION_GENOME_ROOT/ctat_genome_lib_build_dir"
  }
}
  ## NOTE: if chimeric file is given, the fastq files will not be used for anything, but are still required arguments.
  ##     : starFusion does NOT accept multiple fastq pairs, so in this case, the chimeric file MUST be given.
  ## TODO: if multiple fastqs are supplied as input, and a chimeric file is NOT: concatenate, and use the concatenated pair as input.

  scatter (fq in inputFqs) {
    File fastq1    = fq.left
    File fastq2    = fq.right
  }

  parameter_meta {
    inputFqs: "Array of fastq read pairs"
    chimeric: "Path to Chimeric.out.junction"
    reference: "Version of reference genome"
    outputFilePrefix: "Prefix of outptu file"
  }

  call runStarFusion { 
    input: 
    fastq1 = fastq1, 
    fastq2 = fastq2, 
    chimeric = chimeric,
    modules = resources[reference].modules,
    starFusion = resources[reference].starFusion,
    genomeDir = resources[reference].genomeDir,
    outputFilePrefix = outputFilePrefix,
    }

  output {
    File fusions = runStarFusion.fusionPredictions
    File fusionsAbridged = runStarFusion.fusionPredictionsAbridged
    File fusionCodingEffects = runStarFusion.fusionCodingEffects 
  }

  meta {
    author: "Heather Armstrong"
    email: "heather.armstrong@oicr.on.ca"
    description: "Workflow that takes a fastq pair or optionally a chimeric file from STAR and detects RNA-seq fusion events."
    dependencies: [
     {
      name: "star-fusion-genome/1.8.1-hg38",
      url: "https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/__genome_libs_StarFv1.8"
     },
     {
      name: "star-fusion/1.8.1",
      url: "https://github.com/STAR-Fusion/STAR-Fusion/wiki"
     }
    ]
  }

}

task runStarFusion {
  input {
    Array[File] fastq1
    Array[File] fastq2
    File? chimeric
    String starFusion
    String modules
    String genomeDir
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
    String outputFilePrefix
  }

  parameter_meta {
    fastq1: "Array of paths to the fastq files for read 1"
    fastq2: "Array of paths to the fastq files for read 2"
    chimeric: "Path to Chimeric.out.junction"
    starFusion: "Name of the STAR-Fusion binary"
    modules: "Names and versions of STAR-Fusion and STAR-Fusion genome to load"
    genomeDir: "Path to the STAR-Fusion genome directory"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  String outdir = "STAR-Fusion_outdir"

  command <<<
      "~{starFusion}" \
      --genome_lib_dir "~{genomeDir}" \
      --left_fq ~{sep="," fastq1} \
      --right_fq ~{sep="," fastq2} \
      --examine_coding_effect \
      --CPU "~{threads}" --chimeric_junction "~{chimeric}"

      mv ~{outdir}/star-fusion.fusion_predictions.tsv ~{outdir}/~{outputFilePrefix}.star-fusion.fusion_predictions.tsv
      mv ~{outdir}/star-fusion.fusion_predictions.abridged.tsv ~{outdir}/~{outputFilePrefix}.star-fusion.fusion_predictions.abridged.tsv
      mv ~{outdir}/star-fusion.fusion_predictions.abridged.coding_effect.tsv ~{outdir}/~{outputFilePrefix}.star-fusion.fusion_predictions.abridged.coding_effect.tsv
  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    modules: "~{modules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File fusionPredictions =          "~{outdir}/~{outputFilePrefix}.star-fusion.fusion_predictions.tsv"
      File fusionPredictionsAbridged =  "~{outdir}/~{outputFilePrefix}.star-fusion.fusion_predictions.abridged.tsv"
      File fusionCodingEffects =        "~{outdir}/~{outputFilePrefix}.star-fusion.fusion_predictions.abridged.coding_effect.tsv"
  }

  meta {
    output_meta: {
      fusionPredictions:          "Raw fusion output tsv",
      fusionPredictionsAbridged:  "Abridged fusion output tsv",
      fusionCodingEffects:        "Annotated fusion output tsv"
    }
  }

}

