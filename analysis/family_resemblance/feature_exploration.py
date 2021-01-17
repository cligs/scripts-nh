#!/usr/bin/env python3
# Submodule name: feature_exploration.py

"""
Submodule for analyzing the top (distinctive) features for the novels and clusters.

@author: Ulrike Henny-Krahmer

"""

from os.path import join
import pandas as pd
import plotly.graph_objects as go
import numpy as np


def visualize_top_features(wdir, md_file, feat_matrix, feat_type, num_top, outfolder, **kwargs):
	"""
	Creates bar charts for the top distinctive features of the novels.
	This is calculated for all the files in the big corpus.
	
	Arguments:
	
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	feat_matrix (str): relative path to the data matrix
	feat_type (str): which feature type to plot, e.g. "mfw", "topics"
	num_top (int): number of top features to plot, e.g. 30
	outfolder (str): relative path to the output directory for the plots
	
	optional:
	
	first_words_file (str): relative path to the file containing information about the first words of the topics (if feat_type = topics, the first words file should be used)
	rank_file (str): relative path to the file containing information about the feature ranks in the whole corpus
	"""

	first_words_file = kwargs.get("first_words_file", "")
	rank_file = kwargs.get("rank_file", "")

	md = pd.read_csv(join(wdir, md_file), index_col=0)
	feat = pd.read_csv(join(wdir, feat_matrix), index_col=0)
	
	idnos = list(md.index)
	# create a plot for each novel
	for idno in idnos:
		print("plotting " + idno + "...")
		
		if feat_type == "mfw":
			# take the if-idf values as they are? or normalize by mean
			#data = feat.loc[idno].sort_values(ascending=False)[:num_top]
			colmeans = feat.mean(axis=0)
			feat_norm = feat / colmeans
			data = feat_norm.loc[idno]
			
			if rank_file:
				# collect the rank information for the x labels
				rank_labels = []
				ranks = pd.read_csv(join(wdir, rank_file), index_col=0)
				for word in list(data.index):
					rank_labels.append(word + " (" + str(ranks.loc[word,"rank"]) + "/" + str(len(data.index)) + ")")
					
				# set rank labels as new index
				data = pd.Series(index=rank_labels,data=list(data))
			
			data = data.sort_values(ascending=False)[:num_top]
			
		else:
			# normalize by topic mean
			colmeans = feat.mean(axis=0)
			feat_norm = feat / colmeans # mean normalization
			#feat_norm = feat # absolute values
			data = feat_norm.loc[idno]
			
			first_words = pd.read_csv(join(wdir, first_words_file), header=None, index_col=0).iloc[:,0]
			
			if rank_file:
				# collect the rank information for the x labels
				rank_labels = []
				ranks = pd.read_csv(join(wdir, rank_file), index_col=0).loc[:,"Rank"]
				for topic in list(data.index):
					rank_labels.append(first_words.iloc[int(topic)] + " (" + str(int(ranks.iloc[int(topic)])) + "/" + str(len(data.index)) + ")")
					
				# set rank labels as new index
				data = pd.Series(index=rank_labels,data=list(data))
			else:			
				# set first words as index
				data = pd.Series(index=list(first_words),data=list(data))
			
			data = data.sort_values(ascending=False)[:num_top]
			
		x_labels = list(data.index)
		y_data = list(data)
		
		titles = {"mfw": "top distinctive words", "topics": "top topics"} # top distinctive topics
		y_titles = {"mfw":"normalized scores", "topics":"topic scores"} # normalized
		x_titles = {"mfw":"words", "topics":"topics"}
		
		title = titles[feat_type] + " for " + idno
		y_title = y_titles[feat_type]
		x_title = x_titles[feat_type]

		fig = go.Figure([go.Bar(x=y_data[::-1], y=x_labels[::-1], orientation="h")]) # orientation="h" for horizontal bar charts, x and y need to be changed then and the sorting reversed and label axis changed
		fig.update_layout(title=title, autosize=False,width=1000,height=900,margin=dict(l=300),xaxis_title=y_title,yaxis_title=x_title,font=dict(size=18),legend=dict(font=dict(size=18))) #xaxis_tickangle=-90
		fig.update_xaxes(tickfont=dict(size=18)) # automargin=True : does not seem to work very well, optional for better display: range=[0, 0.35]
		
		outfile_name = "topfeat_" + feat_type + "_" + idno
		
		fig.write_html(join(wdir, outfolder, outfile_name + ".html"))
		fig.write_image(join(wdir, outfolder, outfile_name + ".png"),scale=2)
	
	print("done")
	
	
	
def visualize_cluster_distinctiveness(wdir, md_file, feat_matrix, cluster_file, feat_type, num_top, outfile, **kwargs):
	"""
	Create distinctiveness heatmaps for the different clusters and features (i.e.: which features are distinctive for which cluster?)
	Obviously, this is only calculated on the files included in the current analysis (not the whole corpus).
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	feat_matrix (str): relative path to the feature matrix
	cluster_file (str): relative path to the file containing information about the clusters
	feat_type (str): which feature type to plot, e.g. "mfw", "topics"
	num_top (int): number of top features to plot, e.g. 30
	outfile (str): relative path to the output file for the plot (without file name extension!)
	
	optional:
	
	first_words_file (str): relative path to the file containing information about the first words of the topics (if feat_type = topics, the first words file should be used)
	rank_file (str): relative path to the file containing information about the feature ranks in the whole corpus
	norm_mode (str): normalization mode, default: "mean", possible values: "mean", "median", "zscores", "absolute" (= no normalization)
	
	"""
	print("plot cluster distinctivness for " + feat_type + "...")
	
	# get optional parameters
	first_words_file = kwargs.get("first_words_file", "")
	rank_file = kwargs.get("rank_file", "")
	norm_mode = kwargs.get("norm_mode", "mean")
	
	
	# add information about clusters to the metadata file
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	clusters = pd.read_csv(join(wdir, cluster_file), index_col=0)
	md["cluster"] = list(clusters["cluster"])
	
	# get data
	feat = pd.read_csv(join(wdir, feat_matrix), index_col=0)
	featstd = feat.std(axis=0) #std for each feature (before aggregation by cluster)
	
	# get average values for clusters
	feat["cluster"] = list(clusters["cluster"])
	# ADAPT THIS MANUALLY IF NEEDED:
	# keep only certain clusters or merge clusters to a group to compare only certain constellations
	# keep selected clusters:
	#feat = feat[feat.cluster.isin([0,1])]
	# merge clusters (by changing cluster values):
	#feat.cluster[feat.cluster.isin([1,2,3,4])] = 1
	
	grouped = feat.groupby("cluster", axis=0)
	avg_scores = grouped.agg(np.mean)
	feat = avg_scores
	
	colmeans = feat.mean(axis=0) # mean for each feature
	colmedians = feat.median(axis=0) # median for each feature
	colstd = feat.std(axis=0) #std for each feature (after aggregation by cluster)
	
	
	if norm_mode == "mean": # mean normalization
		feat = feat - colmeans 
		# question: Christof used subtraction here instead of division (as in the top feature plots). Why? It seems to make no difference, just that the range of the values is different.
	elif norm_mode == "median": # median normalization
		feat = feat - colmedians
	elif norm_mode == "zscores": # zscore transformation
		# question: why do we see much more variation between the groups when z-score transformation is applied?
		feat = (feat - colmeans) / colstd # = zscore transf.
	elif norm_mode == "absolute": # absolute values
		feat = feat
	
	feat = feat.T
	
	
	# add ranks (and first topic words) to index
	if feat_type == "mfw":
		if rank_file:
			# collect the rank information for the x labels
			rank_labels = []
			ranks = pd.read_csv(join(wdir, rank_file), index_col=0)
			for word in list(feat.index):
				rank_labels.append(word + " (" + str(ranks.loc[word,"rank"]) + "/" + str(len(feat.index)) + ")")
				
			# set rank labels as new index
			feat["ranks"] = rank_labels
			feat = feat.set_index("ranks")
			
	elif feat_type == "topics":
		first_words = pd.read_csv(join(wdir, first_words_file), header=None, index_col=0).iloc[:,0]
		if rank_file:
			# collect the rank information for the x labels
			rank_labels = []
			ranks = pd.read_csv(join(wdir, rank_file), index_col=0).loc[:,"Rank"]
			for topic in list(feat.index):
				rank_labels.append(first_words.iloc[int(topic)] + " (" + str(int(ranks.iloc[int(topic)])) + "/" + str(len(feat.index)) + ")")
				
			# set rank labels as new index
			feat["ranks"] = rank_labels
			feat = feat.set_index("ranks")
			#feat = pd.Series(index=rank_labels,data=list(data))
		else:			
			# set first words as index
			feat["first_words"] = list(first_words)
			feat = feat.set_index("first_words")
			#feat = pd.Series(index=list(first_words),data=list(data))

	# ADAPT THIS MANUALLY IF NEEDED: SORTING
	# variant 1:
	# sort by standard deviation (means that the top features shown are those were the std between all the groups is highest)
	feat["std"] = list(colstd)
	
	# variant 2: normalize std after cluster aggregation by std before aggregation
	# (because it is probable that the general std for each feature is bigger if the feature occurs more often)
	# (so just using the std after aggregation would prefer the more frequent words in the sorting)
	#colstd = np.array(colstd)
	#featstd = np.array(featstd)
	#feat["std"] = colstd / featstd
	
	feat = feat.sort_values(by="std", axis=0, ascending=False)
	feat = feat.drop("std", axis=1)
	
	# variant 3: do not sort at all (and ev. plot all the features) or sort by feature rank (TO DO)
	
	
	# select top features        
	data = feat[0:num_top]
	
	# variant 4: sort by values of a certain cluster 
	# (do this in addition to the other sorting options AFTER selecting the top features)
	# to highlight what is preferred and what is avoided
	#data = data.sort_values(by=0, axis=0, ascending=False)
	
	# x labels: the clusters
	# x_labels = sorted(set(list(clusters["cluster"]))) # old
	x_labels = sorted(set(list(data.columns))) # more flexible (depending on which clusters or cluster groups are kept)
	x_labels = ["cluster " + str(x) for x in x_labels]
	y_labels = data.index
	z_values = data.to_numpy().tolist()
	title = "Top distinctive features for clusters (" + feat_type + ")"
	
	
	fig = go.Figure(data=go.Heatmap(z=z_values,x=x_labels,y=y_labels))
	fig.update_layout(title=title, autosize=False,width=1000,height=1000,xaxis_title="clusters",yaxis_title="features",font=dict(size=20),legend=dict(font=dict(size=20))) # vary width and height as needed
	fig.update_xaxes(tickfont=dict(size=20))
	fig.update_yaxes(tickfont=dict(size=20), autorange="reversed")
	
	fig.write_html(join(wdir, outfile + "_" + norm_mode + ".html"))
	fig.write_image(join(wdir, outfile + "_" + norm_mode + ".png"),scale=2)
	
	print("Done")
	
	
	
def visualize_cluster_metadata(wdir, md_file, md_cat, cluster_file, outfile):
	"""
	Visualize relationships between clusters and metadata (countries, narrative perspective, years)
	to find out if the clusters are dominated by texts from a certain group
	
	For cluster size, a simple bar chart is created. 
	For countries and narrative perspective, grouped bar charts are created.
	For the years, a series of box plots is created.
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	md_cat (str): the metadata category to visualize (possible values: cluster-size, country, narrative-perspective, year, subgenre-theme) 
	cluster_file (str): relative path to the file containing information about the resulting clusters
	outfile (str): relative path to the output file for the plot (without file name extension!)
	"""
	
	print("plotting cluster metadata: " + md_cat + "...")
	
	# add information about clusters to the metadata file
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	clusters = pd.read_csv(join(wdir, cluster_file), index_col=0)
	cluster_list = list(clusters["cluster"])
	md["cluster"] = cluster_list
	
	catx = "cluster" # md category to use for the bars
	catx_groups = md_cat # md catgory to use for the bar subgroups
	
	# group the data by clusters
	if md_cat == "cluster-size":
		grouped_orig = md.groupby(catx).count()
	else:
		grouped_orig = md.groupby([catx, catx_groups]).count().unstack(fill_value=0).stack()
	
	
	# (1) plot the cluster sizes as a simple bar chart
	if md_cat == "cluster-size":
		cluster_sizes = []
		cluster_set = sorted(set(grouped_orig.index.get_level_values(catx)))
		for cl in cluster_set:
			# get cluster size
			cl_size = grouped_orig.loc(axis=0)[cl][0]
			cluster_sizes.append(cl_size)
		
		labels = cluster_set
		y_values = cluster_sizes
		
		fig = go.Figure([go.Bar(x=labels, y=cluster_sizes)])
		fig.update_layout(xaxis_type="category")
		
		title = "Cluster sizes"
		y_title = "Number of works"
		
		
	# (2) for years: plot a series of blox plots (per cluster, showing the year distribution)
	elif md_cat == "year":
		
		# prepare the data: add a box per cluster
		cluster_set = sorted(set(grouped_orig.index.get_level_values(catx)))
		data = []
		for cl in cluster_set:
			cl_group = grouped_orig.loc(axis=0)[cl]
			cl_data = []
			for year in cl_group.index:
				# how often does this year occur in the cluster?
				num = cl_group.loc[year][0]
				
				for i in range(num):
					cl_data.append(year)
			# create a box for each cluster
			box = go.Box(name="Cluster " + str(cl), y=cl_data, boxpoints="all")
			data.append(box)

		title = "Clusters by " + md_cat
		y_title = "years"
		
		fig = go.Figure(data=data)
		fig.update_layout(title=title, autosize=False,width=1000,height=700,xaxis_title="clusters",yaxis_title=y_title,font=dict(size=16),legend=dict(font=dict(size=16))) #margin=dict(b=200), legend=dict(y=-0.4), legend_orientation="h"
		fig.update_xaxes(tickfont=dict(size=16))
		fig.update_yaxes(tickfont=dict(size=16))

		outfile_path_html = join(wdir, outfile + ".html")
		outfile_path_png = join(wdir, outfile + ".png")
	
		fig.write_html(outfile_path_html)
		fig.write_image(outfile_path_png,scale=2)
		
		print("Done")
		
		return
		
	
	else:
		# (3) in the other cases (countries, narrative-perspective, subgenre-theme) plot a grouped bar chart	
		cluster_set = sorted(set(grouped_orig.index.get_level_values(catx)))
		grouped = grouped_orig.copy(deep=True)
		"""
		# normalize by cluster size
		for cl in cluster_set:
			# get cluster size
			cl_size = grouped.loc(axis=0)[cl].sum()[0]
			
			# divide grouped results for this cluster by cluster size
			grouped.loc(axis=0)[cl,:] = grouped.loc(axis=0)[cl,:] / cl_size
			
			
		# normalize by category size (e.g. number of works per country)
		# do this on the original grouped frame (without cluster normalization)
		cat_set = sorted(set(grouped_orig.index.get_level_values(catx_groups)))
		for cat in cat_set:
			# get category value size
			cat_size = grouped_orig.loc(axis=0)[:,cat].sum()[0]
			
			# apply the normalization to the frame already normalized by cluster size
			grouped.loc(axis=0)[:,cat] = grouped.loc(axis=0)[:,cat] / cat_size
		"""
		
		labels = cluster_set
		categories = sorted(set(list(grouped.index.get_level_values(catx_groups))))
		
		data = []
		
		for cat in categories:
			data_groups = list(grouped.loc(axis=0)[:,cat].iloc[:,0])
			bar = go.Bar(name=cat, x=labels, y=data_groups)	
			data.append(bar)
		
		fig = go.Figure(data=data)
		
		title = "Clusters by " + md_cat
		y_title = "number of works" # (normalized)

	# this is the same for all the bar charts
	# Change the bar mode
	fig.update_layout(title=title, barmode='group', autosize=False,width=600,height=600,xaxis_title="clusters",yaxis_title=y_title,font=dict(size=18),legend_orientation="h",legend=dict(y=-0.3,font=dict(size=18))) #margin=dict(b=200)
	fig.update_xaxes(tickfont=dict(size=18))
	fig.update_yaxes(tickfont=dict(size=18))
	
	outfile_path_html = join(wdir, outfile + ".html")
	outfile_path_png = join(wdir, outfile + ".png")
	
	fig.write_html(outfile_path_html)
	fig.write_image(outfile_path_png,scale=2)
	
	print("Done")

	
def map_nodes_to_idnos(wdir, md_file, node_file, outfile, mode):
	"""
	Map network node IDs to the IDs of the novels.
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	node_file (str): relative path to the network node file
	outfile (str): relative path to the output file
	mode (str): type of node file, possible values: "neighbours", "edges"
	"""
	
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	idno_list = list(md.index)
	
	if mode == "neighbours":
		nodes = pd.read_csv(join(wdir, node_file), index_col=0)
		nodes.index = md.index
		nodes = nodes.applymap(lambda x : idno_list[int(x)])
	elif mode == "edges":
		nodes = pd.read_csv(join(wdir, node_file), header=None, sep=" ")
		nodes.iloc[:,[0,1]] = nodes.iloc[:,[0,1]].applymap(lambda x : idno_list[int(x)])
	
	nodes.to_csv(join(wdir, outfile))
	print("Done")
	
	
def visualize_topic_dists(wdir, md_file, feat_matrix, rank_file, first_words_file, outfile, cl_num):
	"""
	Visualize the topic distributions of selected novels (from a cluster) in a line plot.
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file which includes information about the clusters
	feat_matrix (str): relative path to the average topic scores per novel
	rank_file (str): relative path to the file containing information about the topic ranks
	first_words_file (str): relative path to the file containing information about the first words of the topics
	outfile (str): relative path to the output file, without filename extension
	cl_num (int): which cluster to visualize
	"""
	
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	feat = pd.read_csv(join(wdir, feat_matrix), index_col=0)
	ranks = pd.read_csv(join(wdir, rank_file), index_col=0)
	first_words = pd.read_csv(join(wdir, first_words_file), index_col=0, header=None)
	
	feat = feat.T
	# add first words
	feat["first_words"] = list(first_words.iloc[:,0])
	feat = feat.set_index("first_words")
	
	# sort feat matrix by topic ranks
	feat["ranks"] = list(ranks["Rank"])
	feat = feat.sort_values(by="ranks")
	feat = feat.drop(columns="ranks")
	feat = feat.T
	
	# add means
	colmeans = feat.mean(axis=0)
	colmeans.name = "mean"
	feat = feat.append(colmeans)
	
	# get idnos of novels in the cluster
	idnos = md[md.cluster == cl_num].index
	topic_names = feat.columns
	
	fig = go.Figure()
	data_x = list(range(100))
	# add a line for each novel
	for idno in idnos:
		data_y = feat.loc[idno]
		#fig.add_trace(go.Bar(name=idno, x=data_x, y=data_y, text=topic_ids))
		fig.add_trace(go.Scatter(mode="lines",name=idno,x=data_x,y=data_y,hovertext=topic_names))
	# add a line for the mean
	data_y_mean = feat.loc["mean"]
	fig.add_trace(go.Scatter(mode="lines",name="mean",x=data_x,y=data_y_mean,hovertext="mean",line=dict(color="black",dash="dash")))
	
	fig.update_layout(title="topic scores for novels (cluster 3, network HIST)",autosize=False,width=1600,height=800,font=dict(size=18))
	fig.update_xaxes(tickangle=-90)
	fig.update_yaxes(tickangle=-90)
	
	outfile_path_html = join(wdir, outfile + ".html")
	outfile_path_png = join(wdir, outfile + ".png")
	
	fig.write_html(outfile_path_html)
	fig.write_image(outfile_path_png,scale=2)
	
	print("Done")
	
	
	
		
"""
def main(wdir, md_file, feat_matrix, outfile, **kwargs):
	visualize_top_features(wdir, md_file, feat_matrix, outfile, **kwargs)


if __name__ == "__main__":
	import sys
	visualize_top_features(int(sys.argv[1]))
"""

#map_nodes_to_idnos("/home/ulrike/Git/papers/family_resemblance_dsrom19", "corpus_metadata/metadata_HIST.csv", "analysis/rankings/3nn_cosine_topics_100_HIST.csv", "analysis/rankings/3nn_cosine_topics_100_HIST_IDNOS.csv", "neighbours")
#map_nodes_to_idnos("/home/ulrike/Git/papers/family_resemblance_dsrom19", "corpus_metadata/metadata_HIST.csv", "analysis/edges/edges_3nn_cosine_topics_100_HIST.csv", "analysis/edges/edges_3nn_cosine_topics_100_HIST_IDNOS.csv", "edges")

