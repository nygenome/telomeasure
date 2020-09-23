cwlVersion: v1.1
class: CommandLineTool
label: extract info from stream.
doc: Pull seq from bam stream and input unique id.
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.telomeasure_path)
baseCommand: ["parse_sam.py"]
inputs:
   telomeasure_path: string
#   parts_stream_file: string
   sam_stream_in:
      type: stdin
#      format: edam:format_2573 # SAM
outputs:
   parts_stream:
      type: stdout
      
      #type: File
      #outputBinding:
         #glob: test_parts_stream.txt
         #glob: $(inputs.parts_stream_file)

      
      