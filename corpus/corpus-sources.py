#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: corpus-sources.py

"""
@author: Ulrike Henny-Krahmer
"""

import pandas as pd
from os.path import join
from os.path import basename
import plotly.graph_objects as go
from lxml import etree
import glob
import re
from plotly.subplots import make_subplots

def get_sources_metadata():
	"""
	Create a csv file containing metadata about the sources of the texts.
	This function is derived from the get_metadata module in the CLiGS toolbox.
	"""
	
	corpus_dir = "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	inpath = "master/*.xml"
	outfile = "metadata_sources.csv"
	namespaces = {'tei':'http://www.tei-c.org/ns/1.0', 'cligs':"https://cligs.hypotheses.org/ns/cligs"}
	
	labels = ["sources_medium", "sources_filetype", "sources_institution", "sources_edition"]
	xpaths = {
		"idno" : "//tei:idno[@type='cligs']//text()",
		"sources_medium" : "//tei:term[@type='text.source.medium']//text()",
		"sources_filetype" : "//tei:term[@type='text.source.filetype']//text()",
		"sources_institution" : "//tei:term[@type='text.source.institution'][@cligs:importance > parent::tei:keywords/tei:term[@type='text.source.institution']/@cligs:importance or not(parent::tei:keywords/tei:term[@type='text.source.institution'][2])]//text()",
		"sources_edition" : "//tei:term[@type='text.source.edition']//text()"
		}
	
	# get list of file idnos and create dataframe
	idnos = []
	for file in glob.glob(join(corpus_dir, inpath)):
		idno_file = basename(file)[0:6]
		idnos.append(idno_file)

	metadata = pd.DataFrame(columns=labels, index=idnos)
	
	# for each file, get the results of each xpath
	for file in glob.glob(join(corpus_dir, inpath)):
		
		xml = etree.parse(file)
		
		# before starting, verify that file idno and header idno are identical
		idno_file = basename(file)[0:6]
		print("doing " + idno_file)
		
		idno_header = xml.xpath(xpaths["idno"], namespaces=namespaces)[0]

		if idno_file != idno_header: 
			print("Error: " + idno_file + " = " + idno_header)
		
		for label in labels:
			xpath = xpaths[label]
			result = xml.xpath(xpath, namespaces=namespaces)

			# check whether something was found; if not, let the result be "n.av."
			if len(result) == 1: 
				result = result[0]
			else: 
				result = "n.av."

			# clean result string
			result = re.sub(r"\s+", r" ", str(result))

			# write the result to the corresponding cell in the dataframe
			metadata.loc[idno_file,label] = result
			
	# write CSV file to disk
	metadata = metadata.sort_index(ascending=True)
	metadata.to_csv(join(corpus_dir, outfile), sep=",", encoding="utf-8")
	
	print("done")
	
	
def get_data_to_plot(data, source_info):
	"""
	Get the data to plot.
	
	Arguments:
	data (data frame)
	source_info (str): possible values: "sources_medium", "sources_filetype", "sources_institution", "sources_edition"
	"""
	data_grouped = data.groupby(source_info).count()
	data_grouped = data_grouped.sort_values(data_grouped.columns[0], ascending=False)
	labels = data_grouped.index.values
	values = list(data_grouped[data_grouped.columns[0]])
	return [labels, values]
	

def plot_sources(source_info):
	"""
	Donut charts showing how many texts were included from which type of source.
	
	Arguments:
	source_info (str): which kind of source information to plot. Possible values: "sources_medium", "sources_filetype", "sources_institution", "sources_edition"
	"""

	corpus_dir = "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	data = pd.read_csv(join(corpus_dir, "metadata_sources.csv"), index_col=0)
	
	colors = ["rgb(31, 119, 180)", "rgb(255, 127, 14)", "rgb(44, 160, 44)", "rgb(214, 39, 40)"]
	
	labels, values = get_data_to_plot(data, source_info)

	fig = go.Figure(data=[go.Pie(labels=labels, values=values, marker=dict(colors = colors),  direction="clockwise", hole=.4)])
	fig.update_layout(autosize=False,width=600,height=500,legend=dict(font=dict(size=16)))
	fig.show()
	


#get_sources_metadata()

plot_sources("sources_edition")
