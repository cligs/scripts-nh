#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: classification.py

"""
@author: Ulrike Henny-Krahmer

Classify the novels using different feature sets and types of subgenre labels.
"""

import pandas as pd
from os.path import join
import plotly.graph_objects as go


def plot_overview_literary_currents_primary(wdir, mdfile, outdir, outfile):
	"""
	creates a donut chart displaying the proportion of the different primary literary currents in the corpus
	
	Arguments:
	wdir (str): path to the working directory
	mdfile (str): relative path to the metadata csv file containing the subgenre labels
	outdir (str): relative path to the output directory
	outfile (str): name of the output file (withouth extension)
	"""

	md = pd.read_csv(join(wdir, mdfile), index_col=0)
	subgenres = md["subgenre-current"]
	subgenres_counts = subgenres.value_counts()
	subgenres_set = list(subgenres_counts.index)
	subgenres_values = list(subgenres_counts.values)

	labels = subgenres_set
	values = subgenres_values
	colors = ["rgb(214, 39, 40)","rgb(227, 119, 194)","rgb(44, 160, 44)","rgb(31, 119, 180)","rgb(255, 127, 14)"]

	fig = go.Figure(data=[go.Pie(labels=labels, values=values, hole=0.4, direction="clockwise")])
	fig.update_traces(marker=dict(colors=colors))
	fig.update_layout(autosize=False, width=500, height=400, title="Primary literary currents in the corpus")

	fig.write_image(join(wdir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)

	#fig.show()
	
	print("done: overview primary literary currents")



# FUNCTION CALLS

# primary literary currents
plot_overview_literary_currents_primary("/home/ulrike/Git/", "conha19/metadata.csv", "data-nh/analysis/classification/literary-currents/", "overview-primary-currents-corp")
