cwlVersion: v1.1
class: Workflow
requirements:
   StepInputExpressionRequirement: {}
   ScatterFeatureRequirement: {}
   SubworkflowFeatureRequirement: {}
 
inputs:
   # samtools
   samtools_path: string
   exclude_flag: int
   input_bam:
      type: File
      secondaryFiles: ^.bai
   # parse sam
   telomeasure_path: string
   # flag_count
   read_length: int
   duplicate_metrics_name: string
   # coord_stream_cigar
   gc_trusted_tiles_bed:
      type: File
   gc_matched_bed_cov_name: string
   # coord_stream_cigar (extreme gc-free)
   gc_trusted_tiles_bed_extreme_free:
      type: File
   gc_matched_bed_cov_extreme_free_name: string
   # pre_filter
   # aln_stream
   telomeasure_gem_path: string
   telo_target_index:
      type: File
   total_telo_length_name: string
   max_mismatch: float
   mate_info_txt_name: string
   # telomeasure
   telomeasure_summary_txt_name: string
   out_dir: string
outputs:
   # samtools
   # parse sam
   # flag_count
   duplicate_metrics:
      type: File 
      outputSource: flag_count/duplicate_metrics
   # coord_stream_cigar
   gc_matched_bed_cov:
      type: File 
      outputSource: coord_stream_cigar/gc_matched_bed_cov
   gc_matched_bed_cov_extreme_free:
      type: File 
      outputSource: coord_stream_cigar_extreme_free/gc_matched_bed_cov
   # pre_filter
   # aln_stream
   total_telo_length:
      type: File 
      outputSource: aln_stream/total_telo_length


   
steps:
   samtools:
      run: samtools.cwl
      in:
         samtools_path: samtools_path
         exclude_flag: exclude_flag
         input_bam: input_bam
      out: [sam_stream]
   parse_sam:
      run: parse_sam.cwl
      in:
         telomeasure_path: telomeasure_path
         sam_stream_in: samtools/sam_stream
      out: [parts_stream]
   flag_count:
      run: flag_count.cwl
      in:
          telomeasure_path: telomeasure_path
          parts_stream_in: parse_sam/parts_stream
          read_length: read_length
          duplicate_metrics_name: duplicate_metrics_name
      out: [counted_stream, duplicate_metrics]
   coord_stream_cigar:
      run: coord_stream_cigar.cwl
      in:
          telomeasure_path: telomeasure_path
          counted_stream_in: flag_count/counted_stream
          gc_trusted_tiles_bed: gc_trusted_tiles_bed
          read_length: read_length
          gc_matched_bed_cov_name: gc_matched_bed_cov_name
      out: [coverage_cacled_stream, gc_matched_bed_cov]
   coord_stream_cigar_extreme_free:
      run: coord_stream_cigar.cwl
      in:
          telomeasure_path: telomeasure_path
          counted_stream_in: coord_stream_cigar/coverage_cacled_stream
          gc_trusted_tiles_bed: gc_trusted_tiles_bed_extreme_free
          read_length: read_length
          gc_matched_bed_cov_name: gc_matched_bed_cov_extreme_free_name
      out: [coverage_cacled_stream, gc_matched_bed_cov]
   pre_filter:
      run: pre_filter.cwl
      in:
          telomeasure_path: telomeasure_path
          coverage_cacled_stream_in: coord_stream_cigar_extreme_free/coverage_cacled_stream
      out: [prefilter_stream]
   aln_stream:
      run: aln_stream.cwl
      in:
         telomeasure_gem_path: telomeasure_gem_path
         mate_info_txt_name: mate_info_txt_name
         prefilter_stream_in: pre_filter/prefilter_stream
         telo_target_index: telo_target_index
         total_telo_length_name: total_telo_length_name
         max_mismatch: max_mismatch
         read_length: read_length
      out:
         [aln_stream_out, total_telo_length]
   telomeasure:
      run: telomeasure.cwl
      in:
         telomeasure_path: telomeasure_path
         telomeasure_summary_txt_name: telomeasure_summary_txt_name
         out_dir: out_dir
      out:
         [telomeasure_summary_stream_out]
         
$namespaces:
   edam: http://edamontology.org/
$schemas:
   - http://edamontology.org/EDAM_1.18.owl

   
   
      