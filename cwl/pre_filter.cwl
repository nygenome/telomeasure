cwlVersion: v1.1
class: CommandLineTool
label: extract possible hits from stream.
doc: Filter keeping only lines that include at least one canonical telomeric repeat.
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.telomeasure_path)
baseCommand: ["pre_filter.py"]
inputs:
   telomeasure_path: string
   coverage_cacled_stream_in:
      type: stdin
outputs:
   prefilter_stream:
      type: stdout