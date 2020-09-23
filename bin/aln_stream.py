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

import os
import sys
import subprocess
from subprocess import Popen, PIPE
import threading
import logging as log
import re

count_matches = re.compile('[0:]*([1-9]+)')


def feed_gem(run):
    '''
        Feed stdin into GEM for alignment.
    '''
    for line in sys.stdin:
        chrom, flag, start, header, cigar, rname_next, pos_next, seq = line.rstrip().split()
        header = '|telomeasure_divider|'.join([chrom, flag, start, rname_next, pos_next])
        run.stdin.write('>' + header + '\n' + seq + '\n')
    if run:
        run.stdin.close()
    return(True)


def launch_gem(index, pe_smp, m):
    '''
        Launch GEM and wait for reads to be piped in.
    '''
    #######################################
    # launch gem
    #######################################
    gem_args = [ 'gem-mapper',
                '-T', pe_smp,
                '-I', index,
                '-m', m,
                '-e', m,
                '--mismatch-alphabet', 'ATCGN',
                '--fast-mapping', '-q', 'ignore']
    run = Popen(gem_args, stdin=PIPE, stdout=PIPE,stderr=PIPE)
    return run


def check_alignment(line):
    '''
        Check if GEM alignment was found (in best strata of alignments)
    '''
    read_name, read_seq, qual, match_sums, alignments = line.rstrip().split('\t')
    if match_sums != '0':
        match_count = int(re.search(count_matches, match_sums).group(1))
        if match_count > 0:
            return True
    return False


def monitor_gem(run):
    '''
        Count each alignment in output according to test.
        Return count.
        Streams GEM STDERR as well.
    '''
    count = 0
    ##################################
    # Feed gem
    ##################################
    feed_seqs = threading.Thread(target=feed_gem, args=([run]))
    feed_seqs.start()
    for line in run.stdout:
        if check_alignment(line):
            read_name, read_seq, qual, match_sums, alignments = line.rstrip().split('\t')
            chrom, flag, start, rname_next, pos_next = read_name.split('|telomeasure_divider|')
            sys.stdout.write('\t'.join([chrom, flag, start, rname_next, pos_next]) + '\n')
            count += 1
    for line in run.stderr:
        sys.stderr.write(line)
    feed_seqs.join()
    run.wait()
    if run.returncode == 0:
        log.info('Successfully completed GEM alignment')
        return count
    else:
        log.error('Failed with exit status :' + str(run.returncode))
        sys.exit(0) # kill run


def main():
    '''
        counts alignments to a FASTA index
    '''
    gem_index = sys.argv[1]
    pe_smp = sys.argv[2]
    out = sys.argv[3]
    m = sys.argv[4]
    read_length = sys.argv[5]
    assert os.path.isfile(gem_index)
    assert (os.path.isdir(os.path.dirname(out)) or (os.path.dirname(out) == ''))
    run = launch_gem(gem_index, pe_smp, m)
    count = monitor_gem(run)
    with open(out, 'w') as output:
        output.write(str(count * int(read_length)))

##########################################################################
#####       Execute main unless script is simply imported     ############
#####                for individual functions                 ############
##########################################################################
if __name__ == '__main__':
    main()

