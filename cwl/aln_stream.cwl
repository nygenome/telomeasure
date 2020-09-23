cwlVersion: v1.1
class: CommandLineTool
label: extract alignments from stream.
doc: If GEM alignment to telomere target was found (in best strata of alignments) pass aligned reads.
requirements:
   EnvVarRequirement:
      envDef:
         PATH: $(inputs.telomeasure_gem_path)
   ResourceRequirement:
      coresMin: 4
      coresMax: 4
baseCommand: ["aln_stream.py"]

arguments:
    - valueFrom: $(runtime.cores)s
      position: 2
      
stdout: $(inputs.mate_info_txt_name)
      
inputs:
   telomeasure_gem_path: string
   mate_info_txt_name: string
   prefilter_stream_in:
      type: stdin
   telo_target_index: 
      type: File
      doc: "GEM index for TELO target"
      format: edam:format_2330 # TXT
      inputBinding:
         position: 1
   total_telo_length_name:
      type: string
      label: total aligned length to telo targets out file
      inputBinding:
         position: 3
   max_mismatch:
      type: float
      label: max_mismatches and max_edit_distance for GEM alignments as percent or fraction of total
      inputBinding:
         position: 4
   read_length:
      type: int
      inputBinding:
         position: 5
outputs:
   aln_stream_out:
      type: stdout
   total_telo_length:
      type: File
      format: http://edamontology.org/format_2330
      outputBinding:
         glob: $(inputs.total_telo_length_name)
$namespaces:
   edam: http://edamontology.org/
$schemas:
   - http://edamontology.org/EDAM_1.18.owl
   