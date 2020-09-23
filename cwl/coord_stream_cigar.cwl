cwlVersion: v1.1
class: CommandLineTool
label: extract info from stream.
doc: count alignments from bam to regions used to calculate arm-level coverage.
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.telomeasure_path)
baseCommand: ["coord_stream_cigar.py"]
inputs:
   telomeasure_path: string
   gc_trusted_tiles_bed: 
      type: File
      doc: "GC matched, unique mapping regions"
      format: edam:format_3584 # BED
      inputBinding:
         position: 1
   gc_matched_bed_cov_name:
      type: string
      label: duplicate read count in BAM file according to record flags
      inputBinding:
         position: 2
   read_length:
      type: int
      inputBinding:
         position: 3
   counted_stream_in:
      type: stdin
         
outputs:
   coverage_cacled_stream:
      type: stdout
   gc_matched_bed_cov:
      type: File
      format: http://edamontology.org/format_2330
      outputBinding:
         glob: $(inputs.gc_matched_bed_cov_name)
         
$namespaces:
   edam: http://edamontology.org/
$schemas:
   - http://edamontology.org/EDAM_1.18.owl