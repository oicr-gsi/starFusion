# starFusion

Workflow that takes a fastq pair or optionally a chimeric file from STAR and detects RNA-seq fusion events.


## Dependencies

* [star-fusion-genome 1.8.1-hg38](https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/__genome_libs_StarFv1.8)
* [star-fusion 1.8.1](https://github.com/STAR-Fusion/STAR-Fusion/wiki)


## Usage

### Cromwell
```
java -jar cromwell.jar run starFusion.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`inputFqs`|Array[Pair[File,File]]|Array of fastq read pairs
`reference`|String|Version of reference genome
`outputFileNamePrefix`|String|Prefix of outptu file


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`chimeric`|File?|None|Path to Chimeric.out.junction


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runStarFusion.threads`|Int|8|Requested CPU threads
`runStarFusion.jobMemory`|Int|64|Memory allocated for this job
`runStarFusion.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description | Labels
---|---|---|---
`fusions`|File|Tab-delimited fusion predictions.|vidarr_label: fusions
`fusionsAbridged`|File|Tab-delimited fusion predictions, excluding the identification of the evidence fusion reads.|vidarr_label: fusionsAbridged
`fusionCodingEffects`|File|Fusion predictions with appended column showing effect on coding genes.|vidarr_label: fusionCodingEffects


## Commands
 
 This section lists command(s) run by starFusion workflow
 
 starFusion workflow runs the following command (excerpt from .wdl file). 
 
  * STARFUSION_PATH  - path to starFusion program
  * REF_GENOME_DIR   - directory with reference genome file
  * FASTQR* - input fastq files.
  * THREADS - threads to use
  * CHIMERIC_JUNCTIONS - input file with chimeric junctions information (STAR output)
 
 ```
   STARFUSION_PATH
   --genome_lib_dir REF_GENOME_DIR
   --left_fq  FASTQR1_01, FASTQR1_02, ... 
   --right_fq FASTQR2_01, FASTQR2_02, ...
   --examine_coding_effect 
   --CPU THREADS --chimeric_junction CHIMERIC_JUNCTIONS
 
 ```
 
 ## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
