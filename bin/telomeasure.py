#!/usr/bin/env python3
################################################################################
#	USAGE:
#   DESCRIPTION: Script to write a telomere pipeline for a particular
#    sample.
#   Created by Jennifer M Shelton, Andre Corvelo, Nicolas Robine
################################################################################
################################################################################
##################### COPYRIGHT ################################################
# New York Genome Center

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

# Version: 0.1
# Author: Jennifer M Shelton, Andre Corvelo, Nicolas Robine
##################### /COPYRIGHT ###############################################
################################################################################

import os
import sys
import subprocess
from subprocess import Popen, PIPE
import logging as log
import numpy

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__)))



class sample_metrics(object):
    '''
        Gather needed values per pair and calculate estimated length.
    '''
    def __init__(self, 
                 total_length_file,
                 gc_matched_cov_file,
                 non_gc_matched_cov_file,
                 dup_correction_file,
                 non_gc_matched_bed_cov_bed_file,
                 testing=False):
        self.sample = sample
        self.out_dir = out_dir
        self.total_length_file = total_length_file
        self.gc_matched_cov_file = gc_matched_cov_file
        self.non_gc_matched_cov_file = non_gc_matched_cov_file
        self.dup_correction_file = dup_correction_file
        self.non_gc_matched_bed_cov_bed_file = non_gc_matched_bed_cov_bed_file
        
        self.total_length = self.get_total_length(self.total_length_file)
        self.gc_matched_cov = self.get_cov(self.gc_matched_cov_file)
        self.non_gc_matched_cov = self.get_cov(self.non_gc_matched_cov_file)
        self.dup_percent = self.get_dup_correction(self.dup_correction_file)
        self.telomere_length = self.calculate_length(self.total_length, self.gc_matched_cov, self.dup_percent)
        self.extreme_free_gc={
            'chr1':[363, 410],
            'chr2':[325, 578],
            'chr3':[361, 374],
            'chr4':[139, 541],
            'chr5':[213, 462],
            'chr6':[241, 422],
            'chr7':[235, 381],
            'chr8':[177, 355],
            'chr9':[171, 225],
            'chr10':[161, 355],
            'chr11':[179, 286],
            'chr12':[127, 324],
            'chr13':[197, 197],
            'chr14':[187, 188],
            'chr15':[163, 163],
            'chr16':[87, 165],
            'chr17':[73, 234],
            'chr18':[55, 282],
            'chr19':[51, 90],
            'chr20':[106, 101],
            'chr21':[64, 64],
            'chr22':[64, 64],
            'chrX':[201, 299],
            'chrY':[203, 297]
        }
        self.telo_count = self.telosum(self.non_gc_matched_bed_cov_bed_file,
                                  self.extreme_free_gc, self.non_gc_matched_cov)
        self.telomere_length = self.calculate_length(self.total_length,
                                                   self.gc_matched_cov,
                                                   self.dup_percent,
                                                   self.telo_count)


    def telosum(self, non_gc_matched_bed_cov_bed_file, extreme_free_gc, non_gc_matched_cov):
        '''
            Estimate number of telomeres.
        '''
        chroms = [chrom for chrom in extreme_free_gc]
        cov_by_chrom = {chrom : {'p': [], 'q' : []} for chrom in chroms}
        outlier_thresholds = {chrom : {'p': '', 'q' : ''} for chrom in chroms}
        with open(non_gc_matched_bed_cov_bed_file) as non_gc_matched_bed_cov_bed:
            for chrom in chroms:
                for region in range(extreme_free_gc[chrom][0]):
                    line = non_gc_matched_bed_cov_bed.next()
                    start = float(line.split('\t')[1])
                    end = float(line.split('\t')[2])
                    cov = float(line.split('\t')[4])
                    cov_by_chrom[chrom]['p'].append(cov / (end - start))
                for region in range(extreme_free_gc[chrom][1]):
                    try:
                        line = non_gc_matched_bed_cov_bed.next()
                        start = float(line.split('\t')[1])
                        end = float(line.split('\t')[2])
                        cov = float(line.split('\t')[4])
                        cov_by_chrom[chrom]['q'].append(cov / (end - start))
                    except StopIteration:
                        log.error('StopIteration : ' + str(chrom) + ' ' +  str(region))
        outlier_thresholds = {chrom : {'p': (numpy.percentile(cov_by_chrom[chrom]['p'], q = 95) * 5.0), 'q' : (numpy.percentile(cov_by_chrom[chrom]['q'], q = 95))} for chrom in chroms} # get .95 quantile and bump up by a multiplier of 5
        clean_cov_by_chrom = {chrom : {'p': self.filter_outliers(chrom, 'p', outlier_thresholds, cov_by_chrom), 'q' : self.filter_outliers(chrom, 'q', outlier_thresholds, cov_by_chrom)} for chrom in chroms} # remove cov spikes
        arm_covs = {chrom : {'p': self.get_cov_mode(clean_cov_by_chrom[chrom]['p']), 'q' : self.get_cov_mode(clean_cov_by_chrom[chrom]['q'])} for chrom in chroms} # get max of cov density
        arm_covs = [[self.get_cov_mode(clean_cov_by_chrom[chrom]['p']), self.get_cov_mode(clean_cov_by_chrom[chrom]['q'])] for chrom in chroms] # get max of cov density
        arm_covs = reduce((lambda x, y : x + y), arm_covs, [])
        arm_ratios = [cov / non_gc_matched_cov for cov in arm_covs]
        return sum(arm_ratios)


    def get_cov_mode(self, covs):
        '''
            Get max of coverage density
        '''
        if sum(covs) == 0:
            return float(0)
        mode = subprocess.check_output(['Rscript', parent_dir + '/quick_cov_direct.R'] + map(str, covs), universal_newlines=True)
        return float(mode)


    def filter_outliers(self, chrom, arm, outlier_thresholds, cov_by_chrom):
        '''
            Remove outliers.
        '''
        covs = cov_by_chrom[chrom][arm]
        outlier = outlier_thresholds[chrom][arm]
        return [x for x in covs if x < outlier]

                                                                                                               
    def calculate_length(self, total_length, gc_matched_cov, dup_percent, telo_count=46):
        '''
            Calculate telomere length. Requires telomere count estimate.
        '''
        total_length_dedup = total_length - ((dup_percent/100.0) * total_length)
        if gc_matched_cov < 1:
            print(gc_matched_cov)
            log.info('Cov too low to estimate telomere length')
            return 'NA'
        telomere_length = (total_length_dedup / float(gc_matched_cov)) / float(telo_count)
        return telomere_length
    
    
    def get_total_length(self, total_length_file):
        '''
            Read total aligned length.
        '''
        with open(total_length_file) as total_length_lines:
            for line in total_length_lines:
                length = line.rstrip()
        return float(length)
    
    
    def get_cov(self, cov_file):
        '''
            Read mode of region coverage.
        '''
        with open(cov_file) as cov_lines:
            for line in cov_lines:
                cov = line.rstrip()
        return float(cov)


    def get_dup_correction(self, dup_correction_file):
        '''
        Read mode of region coverage.
        '''
        with open(dup_correction_file) as dup_lines:
            for line in dup_lines:
                subtract, percent, total_count, bad_count = line.rstrip().split('\t')
        return float(percent)



def main():
    '''
        Returns Telomere length information for a sample.
    '''
    total_length_file = sys.argv[1]
    gc_matched_cov_file = sys.argv[2]
    non_gc_matched_cov_file = sys.argv[3]
    dup_correction_file = sys.argv[4]
    non_gc_matched_bed_cov_bed_file = sys.argv[5]


    sys.stdout.write('subject,aligned_length,gc_cov,dup_percenttelo_count,telomere_length_non_dedup,tumor_telomere_length_46,telomere_length\n')
    try:
        metrics = sample_metrics(total_length_file,
                                gc_matched_cov_file,
                                non_gc_matched_cov_file,
                                dup_correction_file,
                                non_gc_matched_bed_cov_bed_file)
    except IOError:
        log.warning('Coverage too low to estimate telomere length : ' + str(sample_id))
        sys.exit(0)
    if metrics.telomere_length == 'NA':
        telomere_length_non_dedup = 'NA'
        telomere_length_46 = 'NA'
    else:
        telomere_length_non_dedup = (metrics.total_length / metrics.gc_matched_cov) / metrics.telo_count
        telomere_length_46 = (metrics.total_length / metrics.gc_matched_cov) / 46.0
    sys.stdout.write(sample_id + ',' + str(metrics.total_length) + ',' \
                     + str(metrics.gc_matched_cov) + ',' \
                     + str(metrics.dup_percent) + ',' \
                     + str(metrics.telo_count) + ',' \
                     + str(telomere_length_non_dedup) + ',' \
                     + str(telomere_length_46) + ',' \
                     + str(metrics.telomere_length) + '\n')

##########################################################################
#####       Execute main unless script is simply imported     ############
#####                for individual functions                 ############
##########################################################################
if __name__ == '__main__':
    main()

