#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
@author: Ulrike Henny-Krahmer
@filename: corpus_copyright.py

Submodule to plot some overviews of corpus metadata that is relevant for copyright questions.
"""


import pandas as pd
from os.path import join
import plotly.graph_objects as go

def plot_copyright_status(wdir, md_file, outfile):
	"""
	Creates a donut chart showing the share of novels of different copyright statuses.
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/data-nh/corpus/metadata-encoding/"
	md_file (str): relative path to the metadata file containing the information needed, e.g. "../metadata_copyright.csv"
	outfile (str): relative path to the output HTML file
	"""
	md = pd.read_csv(join(wdir, md_file), index_col=0, header=0)
	md = md["copyright"].value_counts()
	
	labels = ["general", "ancillary", "open domain"]
	values = [md.get("general"), md.get("ancillary"), md.get("open domain")]

	fig = go.Figure(data=[go.Pie(labels=labels, values=values, hole=.4, direction="clockwise")])
	fig.update_layout(autosize=False,width=500,height=500)
	
	fig.write_html(join(wdir, outfile))
	
	print("done: saved figure")
	

def plot_edition_years(wdir, md_file, outfile, edition_type):
	"""
	Creates a bar chart displaying the edition years.
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/data-nh/corpus/metadata-encoding/"
	md_file (str): relative path to the metadata file containing the information needed, e.g. "../metadata_copyright.csv"
	outfile (str): relative path to the output HTML file
	edition_type (str): "first" or "base" (the edition the corpus file is based on)
	"""
	md = pd.read_csv(join(wdir, md_file), index_col=0, header=0)
	if edition_type == "first":
		edition_years = md["year of first publication"]
	else:
		edition_years = md["year of (print) edition used"]
		
		
	# define year range for x axis
	years_set = set(edition_years)
	years_set.discard("unknown")
	start = min(years_set)
	end = max(years_set)
	years_range = range(int(start),int(end) + 1,1)
	years_list = list(years_range)
	
	
	# collect data
	year_counts = edition_years.value_counts()
	
	y = []
	
	if edition_type == "base":
		unknown = year_counts.get("unknown", default=0)
		y.append(unknown)
		
		for i in years_list:
			num = year_counts.get(str(i), default=0)
			y.append(num)
		years_list.insert(0,"unknown")
	else:
		for i in years_list:
			num = year_counts.get(i, default=0)
			y.append(num)
	
	# ticks for the x axis (not possible to get this automatically), show the first ("unknown"), and then starting with 1860 and every fifth year
	# first editions: 1840-1910, all values are known
	if edition_type == "first":
		tick_values = list(range(0,71,5))
		tick_texts = list(range(1840,1911,5))
	# base editions: 1841-2018, also unknown values
	else:
		tick_values = list(range(5,180,10))
		tick_texts = list(range(1845,2020,10))
		tick_values.insert(0,0)
		tick_texts.insert(0,"unknown")
	
	tick_texts = [str(i) for i in tick_texts]

	fig = go.Figure([go.Bar(x=years_list, y=y)])
	fig.update_layout(autosize=False,width=900,height=600,xaxis_type="category")
	fig.update_xaxes(tickangle=270,tickmode="array",tickvals=tick_values,ticktext=tick_texts) # tickfont=dict(size=10)
	fig.write_html(join(wdir, outfile))
	
	print("done: saved figure")
	


def plot_author_death_years(wdir, md_file, outfile):
	"""
	Creates a bar chart displaying the authors' death years.
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/data-nh/corpus/metadata-encoding/"
	md_file (str): relative path to the metadata file containing the information needed, e.g. "../metadata_copyright.csv"
	outfile (str): relative path to the output HTML file
	"""
	
	md = pd.read_csv(join(wdir, md_file), index_col=0, header=0)
	# group by author and just take the first entry for each one
	md = md.groupby("author").first()
	death_years = md["year of author's death"]
	
	# define year range for x axis
	years_set = set(death_years)
	years_set.discard("unknown")
	start = min(years_set)
	end = max(years_set)
	years_range = range(int(start),int(end) + 1,1)
	years_list = list(years_range)
	years_list = [str(i) for i in years_list]
	years_list.insert(0,"unknown")
	
	# collect data
	year_counts = death_years.value_counts()
	
	y = []
	for i in years_list:
		num = year_counts.get(i, default=0)
		y.append(num)
		
	# ticks for the x axis (not possible to get this automatically), show the first ("unknown"), and then starting with 1860 and every fifth year
	tick_values = list(range(2,104,5))
	tick_values.insert(0,0)
	
	tick_texts = list(range(1860,1961,5))
	tick_texts.insert(0,"unknown")
	tick_texts = [str(i) for i in tick_texts]

	fig = go.Figure([go.Bar(x=years_list, y=y)])
	fig.update_layout(autosize=False,width=900,height=600,xaxis_type="category")
	fig.update_xaxes(tickangle=270,tickmode="array",tickvals=tick_values,ticktext=tick_texts) # tickfont=dict(size=10)
	fig.write_html(join(wdir, outfile))
	
	print("done: saved figure")
	
