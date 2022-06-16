version 1.0

import "../wdl_structs.wdl"


task Telomeasure {
    input {
        Bam tumorFinalBam
        String sampleId
        File gcMatchedBed # GRCh38_gc_trusted_tiles_w_100_t_200_s_4.bed
        File nonGcMatchedBed # GRCh38_extreme_free_trusted_tiles_w_100_t_200_s_4.bed
        File teloTargetIndexGem # telo_target_index.gem
        Int readLength
        String duplicateMetricsPath = "~{sampleId}_duplicate_metrics.txt"
        String nonGcMatchedBedCovPath = "~{sampleId}_non_gc_matched_bed_cov.txt"
        String gcMatchedBedCovPath = "~{sampleId}_gc_matched_bed_cov.txt"
        String gemLengthPath = "~{sampleId}_total_telo_length.txt"
        String mateInfoPath = "~{sampleId}_mate_info.txt"
        
        
        Int threads = 8
        Int memoryGb = 10
        Int diskSize
    }
    
    command {
        set -e -o pipefail
        
        samtools view \
        -F 2816 \
        --threads ~{threads} \
        ~{tumorFinalBam} \
        | ./telomeasure/bin/parse_sam.py \
        | ./telomeasure/bin/flag_count.py \
        ~{readLength} \
        ~{duplicateMetricsPath} \
        | ./telomeasure/bin/coord_stream_cigar.py \
        ~{gcMatchedBed} \
        ~{gcMatchedBedCovPath} \
        ~{readLength} \
        | ./telomeasure/bin/coord_stream_cigar.py \
        ~{nonGcMatchedBed} \
        ~{nonGcMatchedBedCovPath} \
        ~{readLength} \
        | ./telomeasure/bin/pre_filter.py \
        | ./telomeasure/bin/aln_stream.py \
        ~{teloTargetIndexGem} \
        ~{threads} \
        ~{gemLengthPath} \
        0.2 \
        ~{readLength} \
        > ~{mateInfoPath}
    }
    
    output {
        File duplicateMetrics = "~{duplicateMetricsPath}"
        File nonGcMatchedBedCov = "~{nonGcMatchedBedCovPath}"
        File gcMatchedBedCov = "~{gcMatchedBedCovPath}"
        File gemLength = "~{gemLengthPath}"
        File mateInfo = "~{mateInfoPath}"
    }
    
    runtime {
        mem: memoryGb + "G"
        cpus: threads
        cpu : threads
        disks: "local-disk " + diskSize + " HDD"
        memory : memoryGb + "GB"
        docker : "gcr.io/nygc-comp-s-fd4e/telomeasure@sha256:a5eca7d39b6786246d5e3afe1bfca1d40485c9f3705cd13390720694f09aa9cc"
    }
}

task Cov {
    input {
        File bedCov
        String sampleId
        String suffix
        String covPrefix = "~{sampleId}_~{suffix}"
        String covTxtPath = "~{covPrefix}.txt"
        String covPlotPath = "~{covPrefix}.pdf"
        
        Int threads = 1
        Int memoryGb = 1
        Int diskSize = 1
    }
    
    command {
        set -e -o pipefail
        
        cat ~{bedCov} \
        | Rscript ./telomeasure/bin/quick_cov.R \
        ~{sampleId} \
        ~{covPrefix} \
        --plotting \
        > ~{covTxtPath}
    }
    
    output {
        File covTxt = "~{covTxtPath}"
        File covPlot = "~{covPlotPath}"
    }
    
    runtime {
        mem: memoryGb + "G"
        cpus: threads
        cpu : threads
        disks: "local-disk " + diskSize + " HDD"
        memory : memoryGb + "GB"
        docker : "gcr.io/nygc-comp-s-fd4e/telomeasure@sha256:a5eca7d39b6786246d5e3afe1bfca1d40485c9f3705cd13390720694f09aa9cc"
    }
}

task TelomeasureSum {
    input {
        String sampleId
        File gemLength
        File gcMatchedCovTxt
        File nonGcMatchedCovTxt
        File duplicateMetrics
        File nonGcMatchedBedCov
        String telomeasureSumPath = "~{sampleId}.telomeasure.summary.csv"
        
        Int threads = 1
        Int memoryGb = 1
        Int diskSize = 4
    }
    
    command {
        ./telomeasure/bin/telomeasure.py \
        ~{gemLength} \
        ~{gcMatchedCovTxt} \
        ~{nonGcMatchedCovTxt} \
        ~{duplicateMetrics} \
        ~{nonGcMatchedBedCov} \
        > ~{telomeasureSumPath}
    }
    
    output {
        File telomeasureSum = "~{telomeasureSumPath}"
    }
    
    runtime {
        mem: memoryGb + "G"
        cpus: threads
        cpu : threads
        disks: "local-disk " + diskSize + " HDD"
        memory : memoryGb + "GB"
        docker : "gcr.io/nygc-comp-s-fd4e/telomeasure@sha256:a5eca7d39b6786246d5e3afe1bfca1d40485c9f3705cd13390720694f09aa9cc"
        
    }
}
