version 1.0

# ================== COPYRIGHT ================================================
# New York Genome Center
# SOFTWARE COPYRIGHT NOTICE AGREEMENT
# This software and its documentation are copyright (2021) by the New York
# Genome Center. All rights are reserved. This software is supplied without
# any warranty or guaranteed support whatsoever. The New York Genome Center
# cannot be responsible for its use, misuse, or functionality.
#
#    Jennifer M Shelton (jshelton@nygenome.org)
#    Nico Robine (nrobine@nygenome.org)
#    Minita Shah (mshah@nygenome.org)
#    Timothy Chu (tchu@nygenome.org)
#    Will Hooper (whooper@nygenome.org)
#
# ================== /COPYRIGHT ===============================================

struct IndexedVcf {
    File vcf
    File index
}

struct IndexedTable {
    File table
    File index
}

struct Bam {
    File bam
    File bamIndex
    String? md5sum
}

struct Cram {
    File cram
    File cramIndex
    String? md5sum
}

struct BwaReference {
    File fasta
    File sa
    File pac
    File bwt
    File ann
    File? alt
    File amb
    File? dict
    File? index
}

struct BwaMem2Reference {
    File fasta
    File bwt2bit
    File pac
    File ann
    File amb
    File num
    File? alt
    File? dict
    File? index
}

struct Minimap2Reference {
    File fasta
    File? alt
    File? dict
    File? index
}

struct IndexedReference {
    File fasta
    File? dict
    File index
}

struct Fastqs {
    File fastqR1
    String? md5sumR1
    File fastqR2
    String? md5sumR2
    String sampleId
    String readgroupId
    String rgpu
}

struct sampleInfo {
    String sampleId
    Array[Fastqs] listOfFastqPairs
    Float expectedCoverage
}

struct SampleBamInfo {
    String sampleId
    Bam finalBam
}

struct SampleCramInfo {
    String sampleId
    Cram finalCram
}

struct PreMergedPairVcfInfo {
    String pairId
    File filteredMantaSV
    File strelka2Snv
    File strelka2Indel
    File mutect2
    File lancet
    File svabaSv
    File svabaIndel
    String tumor
    String normal
    Bam tumorFinalBam
    Bam normalFinalBam
}

struct PairRawVcfInfo {
    String pairId
    File? mergedVcf
    File? mainVcf
    File? supplementalVcf
    File filteredMantaSV
    File strelka2Snv
    File strelka2Indel
    File mutect2
    File lancet
    File svabaSv
    File svabaIndel
    IndexedVcf gridssVcf
    File bicseq2Png
    File bicseq2
    String tumor
    String normal
    Bam tumorFinalBam
    Bam normalFinalBam
}

struct MergedPairVcfInfo {
    String pairId
    String tumor
    String normal
    File unannotatedVcf
}

struct PairVcfInfo {
    String pairId
    String tumor
    String normal
    File mainVcf
    File supplementalVcf
    File vcfAnnotatedTxt
    File maf
}

struct FinalVcfPairInfo {
    String pairId
    String tumor
    String normal
    File mainVcf
    File supplementalVcf
    File filteredMantaSV
    File strelka2Snv
    File strelka2Indel
    File mutect2
    File lancet
    File svabaSv
    File svabaIndel
    IndexedVcf gridssVcf
    File bicseq2Png
    File bicseq2
    File cnvAnnotatedFinalBed
    File cnvAnnotatedSupplementalBed
    File svFinalBedPe
    File svHighConfidenceFinalBedPe
    File svSupplementalBedPe
    File svHighConfidenceSupplementalBedPe
}

struct FinalPairInfo {
    String pairId
    String tumor
    String normal
    File mainVcf
    File supplementalVcf
    File filteredMantaSV
    File strelka2Snv
    File strelka2Indel
    File mutect2
    File lancet
    File svabaSv
    File svabaIndel
    IndexedVcf gridssVcf
    File bicseq2Png
    File bicseq2
    File cnvAnnotatedFinalBed
    File cnvAnnotatedSupplementalBed
    File svFinalBedPe
    File svHighConfidenceFinalBedPe
    File svSupplementalBedPe
    File svHighConfidenceSupplementalBedPe
    Bam tumorFinalBam
    Bam normalFinalBam
}

struct PairRelationship {
    String pairId
    String tumor
    String normal
}

struct pairInfo {
    String pairId
    Bam tumorFinalBam
    Bam normalFinalBam
    String tumor
    String normal
}

struct pairCramInfo {
    String pairId
    Cram tumorFinalCram
    Cram normalFinalCram
    String tumor
    String normal
}

struct FinalWorkflowOutput {
    # alignment and calling results (calling results may not exist if qc failed)
    # SNV INDELs CNV SV and BAM output
    Array[FinalVcfPairInfo?] finalPairInfo

    # MSI
    Array[File?] mantisWxsKmerCountsFinal
    Array[File?] mantisWxsKmerCountsFiltered
    Array[File?] mantisExomeTxt
    Array[File?] mantisStatusFinal
    # SIGs
    Array[File?] sigs
    Array[File?] counts
    Array[File?] sig_input
    Array[File?] reconstructed
    Array[File?] diff

    # Preprocessing output.
    Array[Bam] finalBams

    # QC
    Array[File] alignmentSummaryMetrics
    Array[File] qualityByCyclePdf
    Array[File] baseDistributionByCycleMetrics
    Array[File] qualityByCycleMetrics
    Array[File] baseDistributionByCyclePdf
    Array[File] qualityDistributionPdf
    Array[File] qualityDistributionMetrics
    Array[File] insertSizeHistogramPdf
    Array[File] insertSizeMetrics
    Array[File] gcBiasMetrics
    Array[File] gcBiasSummary
    Array[File] gcBiasPdf
    Array[File] flagStat
    Array[File] hsMetrics
    Array[File] hsMetricsPerTargetCoverage
    Array[File] hsMetricsPerTargetCoverageAutocorr
    Array[File] autocorroutput1100
    Array[File] collectOxoGMetrics
    Array[File] collectWgsMetrics
    Array[File] binestCov
    Array[File] normCoverageByChrPng
    # Dedup metrics
    Array[File] collectWgsMetricsPreBqsr
    Array[File] qualityDistributionPdfPreBqsr
    Array[File] qualityByCycleMetricsPreBqsr
    Array[File] qualityByCyclePdfPreBqsr
    Array[File] qualityDistributionMetricsPreBqsr
    Array[File] dedupLog

    # Conpair
    Array[File] concordanceAll
    Array[File] concordanceHomoz
    Array[File] contamination
    Array[File] normalPileup
    Array[File] tumorPileup

    # Germline
    Array[File?] kouramiResult
    Array[IndexedVcf?] haplotypecallerVcf
    Array[IndexedVcf?] haplotypecallerFinalFiltered
    Array[File?] filteredHaplotypecallerAnnotatedVcf
    Array[File?] haplotypecallerAnnotatedVcf
    Array[File?] alleleCountsTxt
}

struct PreprocessingOutput {
    # Preprocessing output.
    Array[Bam] finalBams

    # QC
    Array[File] alignmentSummaryMetrics
    Array[File] qualityByCyclePdf
    Array[File] baseDistributionByCycleMetrics
    Array[File] qualityByCycleMetrics
    Array[File] baseDistributionByCyclePdf
    Array[File] qualityDistributionPdf
    Array[File] qualityDistributionMetrics
    Array[File] insertSizeHistogramPdf
    Array[File] insertSizeMetrics
    Array[File] gcBiasMetrics
    Array[File] gcBiasSummary
    Array[File] gcBiasPdf
    Array[File] flagStat
    Array[File] hsMetrics
    Array[File] hsMetricsPerTargetCoverage
    Array[File] hsMetricsPerTargetCoverageAutocorr
    Array[File] autocorroutput1100
    Array[File] collectOxoGMetrics
    Array[File] collectWgsMetrics
    Array[File] binestCov
    Array[File] normCoverageByChrPng
    
    # Dedup metrics
    Array[File] collectWgsMetricsPreBqsr
    Array[File] qualityDistributionPdfPreBqsr
    Array[File] qualityByCycleMetricsPreBqsr
    Array[File] qualityByCyclePdfPreBqsr
    Array[File] qualityDistributionMetricsPreBqsr

}
