#!/bin/bash

# Copyright (c) 2020, New York Genome Center
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sample_id=$1
out_dir=$2
read_length=$3
# cram or bam file
cram=$4

script_dir=$(dirname "$0")
export PATH=${script_dir}/telomeasure/bin/:$PATH

echo "Compute metrics..."
time \
samtools view \
-F 2816 \
--threads 4 \
${cram} \
| parse_sam.py \
| flag_count.py \
${read_length} \
${out_dir}/${sample_id}_duplicate_metrics.txt \
| coord_stream_cigar.py \
${script_dir}/telomeasure/data/GRCh38_gc_trusted_tiles_w_100_t_200_s_4.bed \
${out_dir}/${sample_id}_gc_matched_bed_cov.txt \
${read_length} \
| coord_stream_cigar.py \
${script_dir}/telomeasure/data/GRCh38_extreme_free_trusted_tiles_w_100_t_200_s_4.bed \
${out_dir}/${sample_id}_non_gc_matched_bed_cov.txt \
${read_length} \
| pre_filter.py \
| aln_stream.py \
telomeasure/data/telo_target_index.gem \
4 \
${out_dir}/${sample_id}_total_telo_length.txt \
0.2 \
${read_length} \
> ${sample_id}_mate_info.txt

echo "Plot coverage..."

cat ${out_dir}/${sample_id}_non_gc_matched_bed_cov.txt \
| Rscript quick_cov.R \
${sample_id} \
${out_dir}/${sample_id}_non_gc_matched_bed_plot \
--plotting \
> ${out_dir}/${sample_id}_non_gc_matched_bed_plot_cov.txt

cat ${out_dir}/${sample_id}_gc_matched_bed_cov.txt \
| Rscript quick_cov.R \
${sample_id} \
${out_dir}/${sample_id}_gc_matched_bed_plot \
--plotting \
> ${out_dir}/${sample_id}_gc_matched_bed_plot_cov.txt

echo "Estimate telomere length..."

telomeasure.py \
${sample_id} \
${out_dir} \
> ${out_dir}/${sample_id}.telomeasure.summary.csv
