#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Calls functions from hispam modules

@author: Ulrike Henny-Krahmer
"""

import sys
import os

sys.path.append(os.path.abspath("/home/ulrike/Git/scripts-nh/corpus"))

from corpus.text_treatment import spellchecking


wdir="/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"

#spellchecking.plot_error_distribution(wdir, "spellcheck.csv", log="yes")
spellchecking.plot_top_errors(wdir, "spellcheck.csv", 30)


