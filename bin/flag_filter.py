#!/usr/bin/env python3

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


def flag_filter(flag, bad_flags=[1024]):
    '''
        Reads SAM file flag and returns 1 for True if alignment contains the
        flag to filter. Returns 0 for false if the flag is not in the SAM flag.
    '''
    for bad_flag in bad_flags:
        if (int(flag)&bad_flag)/bad_flag:
            return True
    return False


def parse(bad_flags=[1024]):
    '''
        Name line parts and pass needed values out.
        Faster as separate assignments.
    '''
    for line in sys.stdin:
        chrom, flag, start, header, cigar, rname_next, pos_next, seq = line.rstrip().split()
        is_duplicate = flag_filter(flag, bad_flags=bad_flags)
        is_supplementary = flag_filter(flag, bad_flags=[2048])
        sys.stdout.write('\t'.join([chrom, flag, start, header, cigar,
                                    rname_next, pos_next, seq,
                                    str(is_duplicate), str(is_supplementary)]) + '\n')


def main():
    parse()


##########################################################################
#####       Execute main unless script is simply imported     ############
#####                for individual functions                 ############
##########################################################################
if __name__ == '__main__':
    main()
