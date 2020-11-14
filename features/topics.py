#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: topics.py

"""
@author: Ulrike Henny-Krahmer

Serves to generate topic-based feature sets for the corpus.
"""

from os.path import join
from os.path import isfile
import glob
import pandas as pd
import numpy as np
import plotly.graph_objects as go


def clean_stoplist(wdir, stopwords):
	"""
	Clean the stopword list by removing double entries and sorting it in alphabetical order.
	
	Arguments:
	wdir (str): path to the working directory
	stopwords (str): relative path to the stopword file
	"""
	print("cleaning stopword list...")
	
	# read stopword list
	stopwords = pd.read_csv(join(wdir, stopwords), header=None)
	stopwords = stopwords.drop_duplicates()
	stopwords = stopwords.by(0)
	
	# write stopword list
	stopwords.to_csv(join(wdir, stopwords), header=None)
	
	print("done")
	
	
clean_stoplist("/home/ulrike/Git/data-nh/analysis/features/stopwords/topics_stopwords.txt")
