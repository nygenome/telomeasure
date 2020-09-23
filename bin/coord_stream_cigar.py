#!/usr/bin/env python2.7

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

import bisect
import csv
import sys
import os
import re
import flag_filter

# M 0 alignment match (can be a sequence match or mismatch)
# I 1 insertion to the reference
# D 2 deletion from the reference
# N 3 skipped region from the reference
# S 4 soft clipping (clipped sequences present in SEQ)
# H 5 hard clipping (clipped sequences NOT present in SEQ)
# P 6 padding (silent deletion from padded reference)
# = 7 sequence match
# X 8 sequence mismatch

align_pat = re.compile(r'\d+[MDN=]')


def align_length(cigar):
    '''
        Return aligned length across the reference.
    '''
    cigar_entries = align_pat.findall(cigar)
    length = reduce(lambda a, x: a + x, [int(entry[:-1]) for entry in cigar_entries], 0)
    return length


def hit_test(starts, ends, pos):
    '''
        Test is a position lands in a region of interest.
        Run against alignment start positions.
    '''
    first = bisect.bisect(ends, pos)
    last = bisect.bisect(starts, pos)
    if last - first > 0:
        return first, last
    else:
        return False


def read_bed(bed):
    '''
        Get starts and ends from sorted BED file.
        '''
    bed_generator = ([x[0], x[1], x[2], x[3], x[5]] for x in csv.reader(open(bed), delimiter = '\t') if not re.match('^track name.*',x[0])) # generator function to grab BED target annotations
    return bed_generator


def import_bed(bed_generator):
    '''
        Get starts and ends from sorted BED file.
    '''
    starts = {}
    ends = {}
    for chrom, start, end, feature, orientation in bed_generator:
        if not chrom in starts:
            starts[chrom] = []
            ends[chrom] = []
        starts[chrom].append(int(start))
        ends[chrom].append(int(end))
    return starts, ends


def make_counters(starts):
    '''
        Start counters for run.
    '''
    chroms = [chrom for chrom in starts]
    counts = {}
    feature_indices = {chrom : list(xrange(0,len(starts[chrom]))) for chrom in chroms}
    counts = {chrom : {index : 0 for index in list(feature_indices[chrom])} for chrom in chroms}
    return feature_indices, counts


def test_stream(starts, ends, chrom, start, counts, feature_indices, cigar):
    '''
        test streamed info for a hit.
    '''
    if chrom in starts and chrom in ends:
        count_range = hit_test(starts[chrom], ends[chrom], start)
        if count_range:
            length = align_length(cigar)
            for index in feature_indices[chrom][count_range[0]: count_range[1]]:
                counts[chrom][index] += length
    return counts


def test_results(starts, ends, counts, feature_indices):
    '''
        test streamed info for a hit.
    '''
    for chrom in starts:
        assert len(starts[chrom]) == len(counts[chrom]), 'length of counts is wrong for chrom ' + chrom + ': starts=' + str(len(starts[chrom])) + 'counts=' + str(len(counts[chrom]))
        assert len(starts[chrom]) == len(feature_indices[chrom]), 'length of feature_indices is wrong for chrom ' + chrom + ': starts=' + str(len(starts[chrom])) + 'counts=' + str(len(feature_indices[chrom]))


def main():
    '''
        count hits to a bed file and estimate coverage in BED regions.
    '''
    bed = sys.argv[1]
    out_file = sys.argv[2]
    read_length = int(sys.argv[3])
    assert os.path.isfile(bed), 'cannot open BED: ' + bed
    assert ((os.path.isdir(os.path.dirname(out_file))) or (os.path.dirname(out_file) == '')), 'cannot open OUT: ' + out_file
    bed_generator = read_bed(bed)
    starts, ends = import_bed(bed_generator)
    #  ==========================
    #  Start counters
    #  ==========================
    feature_indices, counts = make_counters(starts)
    #  ==========================
    #  Test lines (skipping duplicates)
    #  ==========================
    for line in sys.stdin:
        try:
            chrom, flag, start, header, cigar, rname_next, pos_next, seq = line.rstrip().split('\t')
            if not flag_filter.flag_filter(flag):
                counts = test_stream(starts, ends, chrom, int(start),
                                     counts, feature_indices, cigar)
        except ValueError:
            sys.stderr.write('ERROR: unpacking ' + line + '\n')
        sys.stdout.write(line)
#    test_results(starts, ends, counts, feature_indices)
    #  ==========================
    #  Output BED
    #  ==========================
    bed_generator = read_bed(bed)
    with open(out_file, 'w') as out:
        bed_generator = read_bed(bed)
        last_chrom = 'NA'
        for chrom, start, end, feature, orientation in bed_generator:
            if last_chrom == 'NA':
                last_chrom = chrom
                feat = 0
            elif last_chrom != chrom:
                last_chrom = chrom
                feat = 0
            out.write('\t'.join([chrom, str(start), str(end), str(feature), str(counts[chrom][feat]),orientation]) + '\n')
            feat += 1


##########################################################################
#####       Execute main unless script is simply imported     ############
#####                for individual functions                 ############
##########################################################################
if __name__ == '__main__':
    main()
