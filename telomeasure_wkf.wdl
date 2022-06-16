version 1.0

import "wdl/telomeasure_wkf.wdl" as telomeasure
import "wdl_structs.wdl"

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
        Array[SampleBamInfo]+ tumorInfos
        File gcMatchedBed
        File nonGcMatchedBed
        File teloTargetIndexGem
        Int readLength
        
    }
    
    scatter(tumorInfo in tumorInfos) {
        call telomeasure.Telomeasure {
            input:
                tumorFinalBam = tumorInfo.finalBam,
                sampleId = tumorInfo.sampleId,
                gcMatchedBed = gcMatchedBed,
                nonGcMatchedBed = nonGcMatchedBed,
                teloTargetIndexGem = teloTargetIndexGem,
                readLength = readLength
        }
        
    }
    
    output {
        # telomeasure
        Array[File] duplicateMetrics = Telomeasure.duplicateMetrics
        Array[File] gemLength = Telomeasure.gemLength
        Array[File] mateInfo = Telomeasure.mateInfo
        Array[File] gcMatchedBedCov = Telomeasure.gcMatchedBedCov
        Array[File] nonGcMatchedBedCov = Telomeasure.nonGcMatchedBedCov
        # cov
        Array[File] nonGcMatchedCovTxt = Telomeasure.nonGcMatchedCovTxt
        Array[File] nonGcMatchedCovPlot = Telomeasure.nonGcMatchedCovPlot
        Array[File] gcMatchedCovTxt = Telomeasure.gcMatchedCovTxt
        Array[File] gcMatchedCovPlot = Telomeasure.gcMatchedCovPlot
        # telomeasure_sum
        Array[File] telomeasureSum = Telomeasure.telomeasureSum
    }
}