version 1.0

struct GenomeResources {
    String starFusion
    String genomeDir
}

workflow starFusion {
  input {
    Array[Pair[File, File]] inputFqs
    File? chimeric
    String reference
    String outputFileNamePrefix
  }

Map[String, GenomeResources] resources = {
  "hg38": {
        "starFusion": "STAR-Fusion",
        "genomeLibResources": 
          [
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/AnnotFilterRule.pm",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/PFAM.domtblout.dat.gz",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/blast_pairs.dat.gz",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/blast_pairs.idx",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/fusion_annot_lib.gz",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/fusion_annot_lib.idx",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/pfam_domains.dbm",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.cdna.fa",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.cdna.fa.idx",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.cds",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.cdsplus.fa",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.cdsplus.fa.idx",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.gtf",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.gtf.gene_spans",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.gtf.mini.sortu",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.pep",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_annot.prot_info.dbm",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_genome.fa",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_genome.fa.fai",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_genome.fa.nhr",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_genome.fa.nin",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_genome.fa.nsq",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/trans.blast.align_coords.align_coords.dat",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/trans.blast.align_coords.align_coords.dbm",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/trans.blast.dat.gz",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/__chkpts/",
            "gs://cromwell-wdl/module_data/starfusion_data/ctat_genome_lib_build_dir/ref_genome.fa.star.idx/"
          ]
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
    outputFileNamePrefix: "Prefix of outptu file"
  }

  call runStarFusion { 
    input: 
    fastq1 = fastq1, 
    fastq2 = fastq2, 
    chimeric = chimeric,
    starFusion = resources[reference].starFusion,
    genomeDir = resources[reference].genomeLibResources,
    outputFileNamePrefix = outputFileNamePrefix,
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
    output_meta: {
      fusions: {
        description: "Tab-delimited fusion predictions.",
        vidarr_label: "fusions"
      },
      fusionsAbridged: {
        description: "Tab-delimited fusion predictions, excluding the identification of the evidence fusion reads.",
        vidarr_label: "fusionsAbridged"
      },
      fusionCodingEffects: {
        description: "Fusion predictions with appended column showing effect on coding genes.",
        vidarr_label: "fusionCodingEffects"
      }
    }
  }

}

task runStarFusion {
  input {
    Array[File] fastq1
    Array[File] fastq2
    File? chimeric
    String starFusion
    String docker = "kevin2peng/star-fusion:1.8.1"
    Array[File] genomeLibResources 
    Int threads = 8
    Int jobMemory = 64
    String outputFileNamePrefix
  }
  
  String outdir = "STAR-Fusion_outdir"
  
  command <<<
      set -euxo pipefail
  
      # Recreate the genome lib directory structure
      GENOME_LOCAL="ctat_genome_lib_build_dir"
      mkdir -p "$GENOME_LOCAL"
      
      # Symlink all reference files maintaining their structure
      for file in ~{sep=' ' genomeLibResources}; do
        filename=$(basename "$file")
        ln -s "$file" "$GENOME_LOCAL/$filename"
      done
      
      LEFT_FQ="~{sep=',' fastq1}"
      RIGHT_FQ="~{sep=',' fastq2}"
      
      case "${LEFT_FQ}" in
        *devnull*)
          LEFT_FQ="/dev/null"
          RIGHT_FQ="/dev/null"
          ;;
      esac

    ~{starFusion} \
      --genome_lib_dir "$GENOME_LOCAL" \
      --left_fq ${LEFT_FQ} \
      --right_fq ${RIGHT_FQ} \
      --examine_coding_effect \
      --CPU "~{threads}" ~{if defined(chimeric) then "--chimeric_junction \"" + chimeric + "\"" else ""}
    
    mv ~{outdir}/star-fusion.fusion_predictions.tsv ~{outdir}/~{outputFileNamePrefix}.star-fusion.fusion_predictions.tsv
    mv ~{outdir}/star-fusion.fusion_predictions.abridged.tsv ~{outdir}/~{outputFileNamePrefix}.star-fusion.fusion_predictions.abridged.tsv
    mv ~{outdir}/star-fusion.fusion_predictions.abridged.coding_effect.tsv ~{outdir}/~{outputFileNamePrefix}.star-fusion.fusion_predictions.abridged.coding_effect.tsv
  >>>
  
  runtime {
    memory: "~{jobMemory} GB"
    cpu: "~{threads}"
    docker: "~{docker}"
    disks: "local-disk 500 SSD"
  }
  
  output {
    File fusionPredictions = "~{outdir}/~{outputFileNamePrefix}.star-fusion.fusion_predictions.tsv"
    File fusionPredictionsAbridged = "~{outdir}/~{outputFileNamePrefix}.star-fusion.fusion_predictions.abridged.tsv"
    File fusionCodingEffects = "~{outdir}/~{outputFileNamePrefix}.star-fusion.fusion_predictions.abridged.coding_effect.tsv"
  }
  
  meta {
    output_meta: {
      fusionPredictions: "Raw fusion output tsv",
      fusionPredictionsAbridged: "Abridged fusion output tsv",
      fusionCodingEffects: "Annotated fusion output tsv"
    }
  }
}
