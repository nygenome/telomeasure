cwlVersion: v1.1
class: CommandLineTool
label: Run samtools on a file.
doc: Run samtools on a file excludes reads.
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.samtools_path)
   ResourceRequirement:
      coresMin: 4
      coresMax: 4
#hints:
#   SoftwareRequirement:
#      packages:
#         - package: samtools
#           version: "1.10"
baseCommand: ["samtools" , "view"]
arguments:
    - valueFrom: $(runtime.cores)
      prefix: --threads
      position: 1
inputs:
   samtools_path: string
   exclude_flag:
      type: int
      inputBinding:
         position: 2
         prefix: -F
      doc: "only include reads with none of the FLAGS in INT present"
   input_bam:
      type: File
      doc: "input alignment"
      secondaryFiles: ^.bai
      format: edam:format_2572 # BAM
      inputBinding:
         position: 3
 
outputs:
   sam_stream:
      type: stdout
#      format: edam:format_2573 # SAM
      
$namespaces:
   edam: http://edamontology.org/
$schemas:
   - http://edamontology.org/EDAM_1.18.owl
