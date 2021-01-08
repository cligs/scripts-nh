#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: corpus_overview.py

"""
@author: Ulrike Henny-Krahmer
"""

import pandas as pd
from os.path import join
import plotly.graph_objects as go

def plot_metadata(catx, caty):
	"""
	Creates a stacked bar chart displaying metadata about the novels.
	
	Arguments:
	catx (str): metadata category to use for the x axis, e.g. "decade"  
	caty (str): metadata category to use for the y axis, e.g. "subgenre-theme"
	"""
	
	metadata = pd.read_csv("metadata.csv", index_col=0)
	
	grouped = metadata.groupby([catx, caty]).count()
	labels = sorted(set(grouped.index.get_level_values(catx)))
	categories = sorted(set(list(grouped.index.get_level_values(caty))))
	
	data = []
	
	for cat in categories:
		cat_y = list(grouped.loc(axis=0)[:,cat].iloc[:,0])
		bar = go.Bar(name=cat, x=labels, y=cat_y)	
		data.append(bar)

	fig = go.Figure(data=data)
	
	# Change the bar mode
	fig.update_layout(barmode='stack', autosize=False,width=1000,height=700,xaxis_title="decades",yaxis_title="number of works",font=dict(size=16),legend=dict(font=dict(size=16)))
	fig.update_xaxes(tickfont=dict(size=16))
	
	fig.write_html("corpus_metadata.html")
	fig.write_image("corpus_metadata.png",scale=2)
	fig.show()
	

plot_metadata("decade", "subgenre-theme")
