#!/usr/bin/env python2.7
from .context import flag_filter

def test_flag_filter():
    true_flags = ['1024', '1792', '4095']
    false_flags = ['1', '3', '78', '256', '512', '2303', '2816']
    true_results = [flag_filter.flag_filter(flag) for flag in true_flags]
    print(true_results)
    assert not False in true_results
    false_results = [flag_filter.flag_filter(flag) for flag in false_flags]
    print(false_results)
    assert not True in false_results
