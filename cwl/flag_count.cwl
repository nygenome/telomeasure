cwlVersion: v1.1
class: CommandLineTool
label: extract info from stream.
doc: count duplicates from bam stream dump count to file.
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.telomeasure_path)
baseCommand: ["flag_count.py"]
inputs:
   telomeasure_path: string
   read_length:
      type: int
      inputBinding:
         position: 2
   duplicate_metrics_name:
        type: string
        label: duplicate read count in BAM file according to record flags
        inputBinding:
            position: 3
   parts_stream_in:
      type: stdin

outputs:
   counted_stream:
      type: stdout
   duplicate_metrics:
      type: File
      format: http://edamontology.org/format_2330
      outputBinding:
         glob: $(inputs.duplicate_metrics_name)
    