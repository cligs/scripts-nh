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
	
	
def get_data_to_plot(data, source_info, **kwargs):
	"""
	Get the data to plot.
	
	Arguments:
	data (data frame)
	source_info (str): possible values: "sources_medium", "sources_filetype", "sources_institution", "sources_edition"
	
	further optional arguments:
	drop_source_info (str): kind of source info for which rows with a certain value should be dropped, e.g. "sources_filetype"
	drop_source_value (str): rows with which value for the kind of source info to drop, e.g. "text"
	"""
	
	drop_source_info = kwargs.get("drop_source_info", None)
	drop_value = kwargs.get("drop_value", None)

	# optional: drop rows with certain column values (when only a subset of the data should be charted, e.g. only the institutions of texts obtained from image files (or text files))
	if drop_source_info and drop_value:
		rows_to_drop = data.loc[data[drop_source_info] == drop_value].index
		data = data.drop(rows_to_drop)
	
	data_grouped = data.groupby(source_info).count()
	data_grouped = data_grouped.sort_values(data_grouped.columns[0], ascending=False)
	labels = data_grouped.index.values
	values = list(data_grouped[data_grouped.columns[0]])
	return [labels, values]
	

def plot_sources(source_info, width, height):
	"""
	Donut charts showing how many texts were included from which type of source.
	
	Arguments:
	source_info (str): which kind of source information to plot. Possible values: "sources_medium", "sources_filetype", "sources_institution", "sources_edition", "institution_type"
	width (int): width of the chart (pixel)
	height (int): height of the chart (pixel)
	"""

	data_dir = "/home/ulrike/Git/data-nh/corpus/corpus-sources/"
	data = pd.read_csv(join(data_dir, "../metadata_sources.csv"), index_col=0)
	
	colors = ["rgb(31, 119, 180)", "rgb(255, 127, 14)", "rgb(44, 160, 44)", "rgb(214, 39, 40)"]
	
	labels, values = get_data_to_plot(data, source_info)

	fig = go.Figure(data=[go.Pie(labels=labels, values=values, marker=dict(colors = colors), direction="clockwise", hole=.4)])
	fig.update_layout(title=dict(text="Sources by institution.",xanchor="center",yanchor="top",y=0.9,x=0.5,font=dict(size=14)))
	fig.update_layout(margin=dict(t=0, b=350, l=50, r=0),font=dict(family="Libertine, serif",color="#000000",size=13),autosize=False,width=width,height=height)
	fig.update_layout(legend=dict(yanchor="top",y=1.6,font=dict(size=13)))
	#fig.write_image(join(data_dir, source_info + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(data_dir, source_info + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	
	
def plot_sources_scalegroup(source_info, drop_source_info, drop_group_1, drop_group_2, outfile):
	"""
	Creates two donut charts showing how many texts were included from which type of source. For each of the charts, another subgroup is dropped,
	e.g. for the sources by institution, one chart is created for full text sources and the other for image sources. The size of the donut charts
	is proportional to the total size of the data (if there are less texts from full text sources, that donut chart will be smaller than the other one).
	
	Arguments:
	source_info (str): which kind of source information to plot. E.g. "sources_institution"
	drop_source_info (str): from which kind of source info should values be dropped? e.g. "sources_filetype"
	drop_group_1 (str): rows with which value to drop for the first group, e.g. "text" if the subplot is for "image" 
	drop_group_2 (str): rows with which value to drop for the second group, e.g. "image" if the subplot is for "text"
	outfile (str): name of the output file (without extension)
	"""
	data_dir = "/home/ulrike/Git/data-nh/corpus/corpus-sources/"
	data = pd.read_csv(join(data_dir, "../metadata_sources.csv"), index_col=0)
	
	colors = ["rgb(31, 119, 180)", "rgb(255, 127, 14)", "rgb(44, 160, 44)", "rgb(214, 39, 40)"]
	
	labels_1, values_1 = get_data_to_plot(data, source_info, drop_source_info=drop_source_info, drop_value=drop_group_1)
	labels_2, values_2 = get_data_to_plot(data, source_info, drop_source_info=drop_source_info, drop_value=drop_group_2)
	
	fig = make_subplots(2, 1, specs=[[{'type':'domain'}], [{'type':'domain'}]], subplot_titles=[drop_group_2, drop_group_1], vertical_spacing=0, row_heights=[0.6,0.4])
	fig.add_trace(go.Pie(labels=labels_1, values=values_1, scalegroup='one', name=drop_group_2, direction="clockwise", hole=.4,marker=dict(colors = colors)), 1, 1)
	fig.add_trace(go.Pie(labels=labels_2, values=values_2, scalegroup='one', name=drop_group_1, direction="clockwise", hole=.4,marker=dict(colors = colors)), 2, 1)
	
	fig.update_layout(title=dict(text="Sources by file type and institution.",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(autosize=False,width=709,height=850)
	fig.update_layout(margin=dict(t=120, b=80, l=30, r=30),font=dict(family="Libertine, serif",color="#000000",size=13))
	fig.update_layout(legend=dict(yanchor="bottom",y=0.05,font=dict(size=13)))
	fig.update_traces(textposition="inside")
	
	
	
	#fig.write_image(join(data_dir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(data_dir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	

def plot_sources_hierarchical(source_info_1, source_info_2):
	"""
	Create a sunburst chart combining different kinds of information about the sources, e.g. the kinds of editions and the type of institution
	or the filetypes and the sources.
	
	Arguments:
	source_info_1 (str): which kind of source information to plot as the inner circle / parents. Possible values: "sources_medium", "sources_filetype", 
	"sources_institution", "sources_edition", "institution_type"
	
	source_info_2 (str): which kind of source information to plot as the outer circle / parents. Possible values are the same as for source_info_1.
	"""
	
	data_dir = "/home/ulrike/Git/data-nh/corpus/corpus-sources/"
	data = pd.read_csv(join(data_dir, "../metadata_sources.csv"), index_col=0)
	
	data_grouped_level_1 = data.groupby([source_info_1, source_info_2]).size()
	data_grouped_level_0 = data_grouped_level_1.sum(level=0)
	labels_level_0_set = list(data_grouped_level_1.keys().levels[0])
	labels_level_0_all = list(data_grouped_level_1.index.get_level_values(0))
	labels_level_1 = list(data_grouped_level_1.index.get_level_values(1))
	
	labels = labels_level_0_set + labels_level_1
	values = list(data_grouped_level_0) + list(data_grouped_level_1)
	ids = labels_level_0_set + [str(i[0]) + "-" + str(i[1]) for i in zip(labels_level_0_all, labels_level_1)]
	parents = ["" for i in range(len(labels_level_0_set))] + labels_level_0_all 
	
	colors = ["rgb(31, 119, 180)", "rgb(255, 127, 14)", "rgb(44, 160, 44)", "rgb(214, 39, 40)"] #"rgb(44, 160, 44)", "rgb(214, 39, 40)"
	
	fig = go.Figure(go.Sunburst(
	ids=ids,
	labels=labels,
	parents=parents,
	values=values,
	marker=dict(colors = colors),
	branchvalues="total",
	textinfo="label+percent entry",
	textfont=dict(size = 16)
	))
	
	fig.update_layout(autosize=False,width=709,height=800)
	
	fig.update_layout(title=dict(text="Sources by type of edition and type of institution.",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=80, l=100, r=100),font=dict(family="Libertine, serif",color="#000000",size=14))
	
	
	outfile = source_info_1 + "_" + source_info_2
	#fig.write_image(join(data_dir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(data_dir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	

#get_sources_metadata()

#plot_sources("sources_medium", 450, 350)
#plot_sources("sources_filetype", 450, 350)
#plot_sources("sources_institution", 709, 1200)
#plot_sources("institution_type", 450, 350)
#plot_sources("sources_edition", 450, 350)

plot_sources_hierarchical("sources_edition", "institution_type")

#plot_sources_scalegroup("sources_institution", "sources_filetype", "text", "image", "sources_institution_filetype")
