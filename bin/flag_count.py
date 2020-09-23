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

import sys
import flag_filter


def read_from_stream(read_length):
    '''
        Find each flag value in a stream of input from SAM. Return
        counts of indicated flags.
    '''
    bad_count = 0
    total_count = 0
    for is_duplicate in parse():
        total_count += 1
        if is_duplicate:
            bad_count += 1
    percent = (float(bad_count) / total_count) * 100
    subtract = int(read_length) * bad_count
    header = '\t'.join(['subtract', 'percent', 'total_count', 'bad_count'])
    content = '\t'.join([str(subtract), str(percent),
                         str(total_count), str(bad_count)])
    return '\n'.join([header, content]) + '\n'


def parse():
    '''
        Name line parts and pass needed values out.
        Faster as separate assignments.
    '''
    for line in sys.stdin:
        chrom, flag, start, header, cigar, rname_next, pos_next, seq = line.rstrip().split()
        sys.stdout.write(line)
        yield flag_filter.flag_filter(flag)

def main():
    read_length = sys.argv[1]
    out_file = sys.argv[2]
    results = read_from_stream(read_length)
    with open(out_file, 'w') as out:
        out.write(results)


##########################################################################
#####       Execute main unless script is simply imported     ############
#####                for individual functions                 ############
##########################################################################
if __name__ == '__main__':
    main()

