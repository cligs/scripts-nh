#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: bibacme-sources.py

"""
@author: Ulrike Henny-Krahmer
"""

import pandas as pd
from os.path import join
import plotly.graph_objects as go
from plotly.subplots import make_subplots

wdir = "/home/ulrike/Git/"
outdir = join(wdir, "data-nh/corpus/bibliography-sources/")

def sources_shares():
	"""
	A group of charts showing how many bibliographic entries were checked for BibACMé
	and how many were included (by source)	
	"""

	sources = pd.read_csv(join("/home/ulrike/Git/bibacme/app/data/entries-sources.csv"), header=0)
	colors = ["rgb(31, 119, 180)", "rgb(255, 127, 14)", "rgb(44, 160, 44)", "rgb(214, 39, 40)"]

	gb_all = sources.groupby(["source"])

	# all bibliographical entries that were checked
	TR_all = gb_all.get_group("Torres-Rioseco")
	LB_all = gb_all.get_group("Lichtblau")
	DLC_all = gb_all.get_group("DLC")

	sources = sources.drop(TR_all.index)
	sources = sources.drop(LB_all.index)
	sources_other_all = sources.drop(DLC_all.index)
	 
	# entries remaining in Bib-ACMé
	TR_rest = TR_all.loc[TR_all["bibacme-work-id"] != "-"]
	LB_rest = LB_all.loc[LB_all["bibacme-work-id"] != "-"]
	DLC_rest = DLC_all.loc[DLC_all["bibacme-work-id"] != "-"]

	sources_other_rest = sources_other_all.loc[sources_other_all["bibacme-work-id"] != "-"]


	# create plots

	labels = ['Torres-Rioseco','Lichtblau','DLC','other']
	values_all = [TR_all.count()[0], LB_all.count()[0], DLC_all.count()[0], len(sources_other_all)]
	values_rest = [TR_rest.count()[0], LB_rest.count()[0], DLC_rest.count(0)[0], len(sources_other_rest)]


	fig = make_subplots(vertical_spacing=0.02,horizontal_spacing=0.2,rows=2, cols=2, specs=[[{"type" : "domain"}, {"type" : "domain"}],[{"type" : "xy"}, {"type" : "xy"}]])

	fig.add_trace(
		go.Pie(labels=labels, values=values_all, marker=dict(colors = colors),  direction="clockwise", hole=.4),
		row=1, col=1
	)

	fig.add_trace(
		go.Pie(labels=labels, values=values_rest, marker=dict(colors = colors), direction="clockwise", hole=.4),
		row=1, col=2
	)

	fig.add_trace(
		go.Bar(x=labels, y=values_all, marker_color = colors, text=values_all, textposition="auto", showlegend=False),
		row=2, col=1
	)

	fig.add_trace(
		go.Bar(x=labels, y=values_rest, marker_color = colors, text=values_rest, textposition="auto", showlegend=False),
		row=2, col=2
	)
	#title=dict(text="Works by source. Left: candidates, right: entries in the bibliography",font=dict(size=14)),
	fig.update_layout(autosize=False,width=709,height=650,margin=dict(t=0, b=70, l=70),font=dict(family="Libertine, serif",color="#000000",size=14),legend=dict(font=dict(size=14)))
	fig.update_yaxes(range=[0,600],tickfont=dict(size=14))
	fig.update_xaxes(tickfont=dict(size=14))

	outfile = "sources-shares"
	#fig.write_image(join(wdir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	


def sources_inclusion():
	"""
	A pie chart showing how many bibliographic entries were included into Bib-ACMé and why the rest was discarded
	"""
	
	sources = pd.read_csv(join("/home/ulrike/Git/bibacme/app/data/entries-sources.csv"), header=0)
	colors = ["rgb(31, 119, 180)", "rgb(255, 127, 14)", "rgb(44, 160, 44)", "rgb(214, 39, 40)"]
	min_page = ">=84p"
	min_words = ">=16,000w"
	
	included = sources.loc[sources["bibacme-work-id"] != "-"]
	excluded_missing_info = sources.loc[(sources["bibacme-work-id"] == "-") & ((sources["earliest-publication-date"] == "unknown") | (sources[min_page] == "unknown"))]
	excluded_short = sources.loc[(sources["bibacme-work-id"] == "-") & ((sources[min_page] == "no") | (sources[min_words] == "no")) & (sources["earliest-publication-date"] != "unknown")]
	excluded_other = sources.loc[(sources["bibacme-work-id"] == "-") & (sources["earliest-publication-date"] != "unknown") & (sources[min_page] != "unknown") & (sources[min_page] != "no") & (sources[min_words] != "no")]
	
	labels = ['included','missing information','too short','excluded for other reason']
	values = [len(included), len(excluded_missing_info), len(excluded_short), len(excluded_other)]
	
	fig = go.Figure(data=[go.Pie(labels=labels, values=values, marker=dict(colors = colors),  direction="clockwise", hole=.4)])
	# title=dict(text="Inclusion and reasons for exclusion of works.",font=dict(size=14)),
	fig.update_layout(margin=dict(t=0, b=0, l=220, r=240),font=dict(family="Libertine, serif",color="#000000",size=14),autosize=False,width=709,height=300,legend=dict(font=dict(size=14)))
	fig.update_traces(textfont_size=14)
	
	outfile = "sources-inclusion"
	#fig.write_image(join(wdir, outdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")


#sources_shares()
sources_inclusion()
