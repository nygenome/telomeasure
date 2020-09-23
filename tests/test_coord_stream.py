#!/usr/bin/env python2.7
from .context import coord_stream_cigar


def test_hit_test():
    genomic_align_starts =[1, 2, 10, 11, 12, 13, 18, 19, 21, 22, 23] # for all four reads
    starts = [2,13,17]
    ends = [11,19,22]
    results = [coord_stream_cigar.hit_test(starts, ends, pos) for pos in genomic_align_starts]
    print(results)
    print(coord_stream_cigar.hit_test(starts, ends, 19))
    assert results == [False, (0, 1), (0, 1), False, False, (1, 2), (1, 3), (2, 3), (2, 3), False, False]


def test_import_bed():
    bed_generator = [('chr1','0','10','name','+'),
                     ('chr1','10','20','name','+'),
                     ('chr1','20','30','name','+')]
    starts, ends = coord_stream_cigar.import_bed(bed_generator)
    print(starts, ends)
    assert starts['chr1'] == [0, 10, 20]
    assert ends['chr1'] == [10, 20, 30]


def test_test_stream():
    genomic_align_starts =[1, 2, 10, 11, 12, 13, 18, 19, 21, 22, 23] # for all four reads
    chrom = 'chr1'
    starts = {}
    ends = {}
    starts[chrom] = [2,13,17]
    ends[chrom] = [11,19,22]
    feature_indices = {'chr1': [0, 1, 2]}
    counts = {'chr1': {0: 0, 1: 0, 2: 0}}
    cigar='150M'
    for start in genomic_align_starts:
        counts = coord_stream_cigar.test_stream(starts, ends, chrom, start, counts, feature_indices, cigar)
    print(counts)
    assert counts == {'chr1': {0: 300, 1: 300, 2: 450}}


def test_start_counters():
    starts = {'chr1' : [2,13,17]}
    feature_indices, counts = coord_stream_cigar.make_counters(starts)
    print(feature_indices, counts)
    assert feature_indices == {'chr1': [0, 1, 2]}, 'failed to initialize feature_indices'
    assert counts == {'chr1': {0: 0, 1: 0, 2: 0}}, 'failed to initialize counts'