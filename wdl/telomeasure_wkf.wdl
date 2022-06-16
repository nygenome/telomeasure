version 1.0

import "telomeasure.wdl" as telomeasureTasks
import "../wdl_structs.wdl"

# ================== COPYRIGHT ================================================
# New York Genome Center
# SOFTWARE COPYRIGHT NOTICE AGREEMENT
# This software and its documentation are copyright (2022) by the New York
# Genome Center. All rights are reserved. This software is supplied without
# any warranty or guaranteed support whatsoever. The New York Genome Center
# cannot be responsible for its use, misuse, or functionality.
#
#    Jennifer M Shelton (jshelton@nygenome.org)
#    Nico Robine (nrobine@nygenome.org)
#
# ================== /COPYRIGHT ===============================================

workflow Telomeasure {
    input {
        Bam tumorFinalBam
        String sampleId
        File gcMatchedBed
        File nonGcMatchedBed
        File teloTargetIndexGem
        Int readLength
        
        Int diskSize = ceil(size(tumorFinalBam.bam, "GB")) + 1
    }
    
    call telomeasureTasks.Telomeasure {
        input:
            tumorFinalBam = tumorFinalBam,
            sampleId = sampleId,
            gcMatchedBed = gcMatchedBed,
            nonGcMatchedBed = nonGcMatchedBed,
            teloTargetIndexGem = teloTargetIndexGem,
            readLength = readLength,
            diskSize = diskSize
    }
    
    call telomeasureTasks.Cov as nonGcMatchedCov {
        input:
            bedCov = Telomeasure.nonGcMatchedBedCov,
            sampleId = sampleId,
            suffix = "_non_gc_matched_bed_cov"
            
    }
    
    call telomeasureTasks.Cov as gcMatchedCov {
        input:
            bedCov = Telomeasure.gcMatchedBedCov,
            sampleId = sampleId,
            suffix = "_gc_matched_bed_cov"
    }
    
    call telomeasureTasks.TelomeasureSum {
        input:
            sampleId = sampleId,
            gemLength = Telomeasure.gemLength,
            gcMatchedCovTxt = gcMatchedCov.covTxt,
            nonGcMatchedCovTxt = nonGcMatchedCov.covTxt,
            duplicateMetrics = Telomeasure.duplicateMetrics,
            nonGcMatchedBedCov = Telomeasure.nonGcMatchedBedCov
    }
    
    output {
        # telomeasure
        File duplicateMetrics = Telomeasure.duplicateMetrics
        File gemLength = Telomeasure.gemLength
        File mateInfo = Telomeasure.mateInfo
        File gcMatchedBedCov = Telomeasure.gcMatchedBedCov
        File nonGcMatchedBedCov = Telomeasure.nonGcMatchedBedCov
        # cov
        File nonGcMatchedCovTxt = nonGcMatchedCov.covTxt
        File nonGcMatchedCovPlot = nonGcMatchedCov.covPlot
        File gcMatchedCovTxt = gcMatchedCov.covTxt
        File gcMatchedCovPlot = gcMatchedCov.covPlot
        # telomeasure_sum
        File telomeasureSum = TelomeasureSum.telomeasureSum
    }
}