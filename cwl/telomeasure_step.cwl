cwlVersion: v1.1
class: CommandLineTool
label: extract alignments from stream.
doc: Calculates estimated telomere length
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.telomeasure_path)
   ResourceRequirement:
      coresMin: 4
      coresMax: 4
baseCommand: ["telomeasure.py"]

stdout: $(inputs.telomeasure_summary_txt_name)

inputs:
   telomeasure_path: string
   telomeasure_summary_txt_name: string
   sample_id: string
   out_dir: string
   
outputs:
   telomeasure_summary_stream_out:
      type: stdout

