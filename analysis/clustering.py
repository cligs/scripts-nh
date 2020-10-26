#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import glob
from os.path import join
from os.path import basename
from lxml import etree
from collections import Counter
import pandas as pd
from sklearn import svm
from sklearn.model_selection import GridSearchCV
from sklearn.cluster import KMeans
from sklearn import metrics
from sklearn.model_selection import train_test_split
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import plotly.graph_objects as go

wdir = "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/annotated"
outdir = "/home/ulrike/Git/hennyu/novelashispanoamericanas/analyses/2019-11-22_clustering"
inpath = "*.xml"
namespaces = {'tei':'http://www.tei-c.org/ns/1.0', 'cligs':"https://cligs.hypotheses.org/ns/cligs"}


def extract_features_lexnames():
	"""
	Extract the lexnames from the annotated TEI files of the corpus
	and create a data frame containing the lexnames counts for the 
	files.
	
	@author: Ulrike Henny-Krahmer
	"""
	fr = pd.DataFrame()

	# extract features: lexnames

	for file in glob.glob(join(wdir, inpath)):
		
		idno = basename(file)[:-4]
		
		print("doing " + idno + "...")
		
		xml = etree.parse(file)
		result_lexnames = xml.xpath("//@cligs:wnlex", namespaces=namespaces)
		result_words = xml.xpath("//tei:w", namespaces=namespaces)
		num_words = len(result_words)
		
		c = Counter(result_lexnames)
		
		#fr = pd.DataFrame.from_dict(c, orient="index")
		
		index = []
		data = []
		for el in list(set(c.elements())):
			index.append(el)
			data.append(c[el])
		
		s = pd.Series(data = data, index = index)
		s.name = idno
		s = s.div(num_words)
		
		fr = fr.append(s)
		
	fr = fr.drop("xxx", axis=1)
	fr = fr.fillna(value=0.0)
	# make sure that the index is ordered by CLiGS idno
	fr = fr.sort_index()
	fr.to_csv(join(outdir, "features", "lexnames.csv"))

	print("done")
	

"""
MFW: see bow.create_bow_model(wdir, "txt", "MFW/bow_500_tfidf.csv", 500) in run_scripts
"""

	
def classify_svm():
	
	
	md = pd.read_csv(join(outdir, "metadata_2_summary_HIST_COST.csv"), index_col=0) # metadata_2_explicit_HIST_COST.csv
	md = md.sort_index()
	md_idnos = md.index.values
	labels_true = md["text.genre.subgenre.summary"] # text.genre.subgenre.historical.explicit.norm
	num_genres = len(set(labels_true))
	
	# BOW
	fr = pd.read_csv(join(outdir, "features", "MFW", "bow_1000_tfidf.csv"), index_col=0)
	
	# topics
	#fr = pd.read_csv(join(outdir, "features", "topicmodel", "avgtopicscores_by-idno_100.csv"), index_col=0)
	
	
	
	# lexnames
	#fr = pd.read_csv(join(outdir, "features", "lexnames.csv"), index_col=0)
	#fr = fr.sort_index()
	
	# select only the relevant ids
	fr = fr.loc[md_idnos]

	X = fr.to_numpy()
	y = labels_true

	X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1)

	clf = svm.SVC()

	param_grid = [
	  {'C': [0.1, 1, 10, 100, 1000], 'kernel':['linear']},
	  {'C': [0.1, 1, 10, 100, 1000], 'gamma':[0.001, 0.0001], 'kernel':['rbf']}
	 ]
	# run grid search
	grid_search = GridSearchCV(clf, param_grid=param_grid, cv=10)
	grid_search.fit(X, y)  

	results = pd.DataFrame.from_dict(grid_search.cv_results_)
	results.to_csv(join(outdir, "results_data", "grid-search-svm-1000MFW_summary-HIST-COST.csv")) #explicit-HIST-COST

	print("done")


def cluster():
	
	md = pd.read_csv(join(outdir, "metadata_3_summary_HIST_COST_SENT.csv"), index_col=0)
	md = md.sort_index()
	md_idnos = md.index.values
	labels_true = md["text.genre.subgenre.summary"]
	num_genres = len(set(labels_true))

	fr = pd.read_csv(join(outdir, "features", "topicmodel", "avgtopicscores_by-idno_80.csv"), index_col=0)
	fr = fr.loc[md_idnos]
	X = fr.to_numpy()

	min_clusters = 2
	max_clusters = round(num_genres * 5)

	score_results = pd.DataFrame()

	for i in range(min_clusters, max_clusters):
		print("doing " + str(i) + " clusters...")
		kmeans = KMeans(n_clusters=i, random_state=0).fit(X)
		labels_pred = kmeans.labels_
		
		# store cluster center feature values
		cl_center_fr = pd.DataFrame(data=kmeans.cluster_centers_)
		cl_center_fr.to_csv(join(outdir, "results_data", str(i) + "cl_80topics_summary-HIST-COST-SENT_cluster_center_features.csv"))
		
		# calculate all similarities (texts to cluster centers)
		sim_all = cosine_similarity(X, kmeans.cluster_centers_)
		sim_fr = pd.DataFrame(index=md_idnos, columns=range(i), data=sim_all)
		sim_fr.to_csv(join(outdir, "results_data", str(i) + "_similarities_summary-HIST-COST-SENT_topics80.csv"))
		
		
		# make a heatmap for the similarity of texts to the different cluster centers, sorted by cluster, subgenre, author, title
		labels_fr = pd.DataFrame(index=md_idnos, columns=["cluster"], data=labels_pred)
		labels_fr["genre.short"] = md["genre.short"]
		labels_fr["author.short"] = md["author.short"]
		labels_fr["title.short"] = md["title.short"]
		labels_fr_sorted = labels_fr.sort_values(by=["cluster", "genre.short", "author.short", "title.short"])
		sim_fr_sorted = sim_fr.reindex(labels_fr_sorted.index.values)
		sim_fr_np = sim_fr_sorted.to_numpy()
		
		x_labels = ["cl" + str(x) for x in range(i)]
		y_labels = [y[0] + "_" + y[1] + "_" + y[2] + "_" + str(y[3]) for y in zip(list(labels_fr_sorted["author.short"]), list(labels_fr_sorted["title.short"]), list(labels_fr_sorted["genre.short"]), list(labels_fr_sorted["cluster"]))]
		fig = go.Figure(data=go.Heatmap(
                    z=sim_fr_np, x=x_labels, y=y_labels, colorbar={"tickfont" : dict(size=28)})) #zmin=0, zmax=1,
		fig.update_xaxes(tickfont=dict(size=28))
		fig.update_yaxes(tickfont=dict(size=12))
		fig.update_layout(autosize=False,width=(600 + i * 50),height=1000 + i * 50)
		
		fig.write_image(join(outdir, "results_visual", "heatmaps", str(i) + "_similarities_texts-to-clusters_summary-HIST-COST-SENT_topics80.svg"))
		
		
		# bar charts for the similarity of a single text to the different cluster centers
		for idx, val in enumerate(md_idnos):
			
			data_sorted = sim_fr.loc[val].sort_values(ascending=False)
			x = ["cl" + str(i) for i in data_sorted.index.values]
			y = list(data_sorted)
			
			fig = go.Figure([go.Bar(x=x, y=y)])
			fig.update_layout(title_text=md.loc[val]["title.short"] + " by " + md.loc[val]["author.short"] + " (" + val + ")")
			fig.update_layout(autosize=False,width=(450 + i * 50),height=600)
			fig.update_layout(xaxis_title="cluster centers", yaxis_title="similarity", font=dict(size=20))
			fig.update_xaxes(tickfont=dict(size=20))
			fig.update_yaxes(tickfont=dict(size=20))
						
			fig.write_image(join(outdir, "results_visual", "barcharts", str(i) + "_" + val + "_similarity_cluster_centers_summary-HIST-COST-SENT_topics80.svg"))
			
		
		# bar charts for the similarity of the texts in a single cluster to its center
		for idx in range(i):
			
			#x: texts - welche gehören zum Cluster?, dann die aus simfr nehmen und die Clusterspalte
			#y: similarity
			idnos_texts = labels_fr.loc[labels_fr["cluster"] == idx].index.values
			data_sorted = sim_fr.loc[idnos_texts][idx].sort_values(ascending=False)
			md_sorted = md.loc[idnos_texts].reindex(data_sorted.index.values)
			x = [i[0] + "_" + i[1] + "_" + i[2] for i in zip(md_sorted["author.short"], md_sorted["title.short"], md_sorted["genre.short"])]
			y = list(data_sorted)
			 
			fig = go.Figure([go.Bar(x=x, y=y)])
			fig.update_layout(title_text="Cluster " + str(idx))
			fig.update_layout(autosize=False,width=(450 + len(idnos_texts) * 50),height=800)
			fig.update_layout(yaxis_title="similarity", font=dict(size=20))
			fig.update_xaxes(tickfont=dict(size=20), tickangle=70,automargin=True)
			fig.update_yaxes(tickfont=dict(size=20))
			
			fig.write_image(join(outdir, "results_visual", "barcharts", str(i) + "_cl" + str(idx) + "_similarity_texts_summary-HIST-COST-SENT_topics80.svg"))
		
		
		# calculate similarities of cluster centers to each other
		x_labels = ["cl" + str(x) for x in range(i)]
		y_labels = x_labels
		sim_cl = cosine_similarity(kmeans.cluster_centers_)
		sim_cl_fr = pd.DataFrame(index=range(i), columns=range(i), data=sim_cl)
		sim_cl_fr.to_csv(join(outdir, "results_data", str(i) + "_similarities_clusters_summary-HIST-COST-SENT_topics80.csv"))
		
		# make a heatmap for the cluster center similarity
		fig = go.Figure(data=go.Heatmap(
                    z=sim_cl, x=x_labels, y=y_labels, colorbar={"tickfont" : dict(size=28)})) #zmin=0, zmax=1,
		fig.update_xaxes(tickfont=dict(size=28))
		fig.update_yaxes(tickfont=dict(size=28))
		
		fig.write_image(join(outdir, "results_visual", "heatmaps", str(i) + "_similarities_clusters_summary-HIST-COST-SENT_topics80.svg"))
		
		# calculate similarities to cluster centers
		similarities = []
		for idx, val in enumerate(md_idnos):
			cl_num = labels_pred[idx]
			cl_cent = kmeans.cluster_centers_[cl_num].reshape(1,-1)
			idno_data = fr.loc[val].to_numpy().reshape(1,-1)
			sim = cosine_similarity(idno_data, cl_cent)
			similarities.append(sim[0][0])
		
		cluster_fr = pd.DataFrame(data={"idno": md_idnos, "label_pred": labels_pred, "label_true": labels_true, "similarity_to_center" : similarities},columns=["idno", "label_pred", "label_true", "similarity_to_center"])
		cluster_fr = cluster_fr.sort_values(by=["label_pred","label_true","similarity_to_center"])
		cluster_fr.to_csv(join(outdir, "results_data", str(i) + "_clusters_summary-HIST-COST-SENT_topics80.csv"))
		
		good_clusters = 0
		cluster_size_measure = 0
		
		for j in range(i):
			cluster_current = cluster_fr.loc[cluster_fr["label_pred"] == j]
			mf = cluster_current.label_true.mode()[0]
			
			cluster_mf = cluster_current.loc[cluster_current["label_true"] == mf]
			num_mf = len(cluster_mf)
			
			mf_ratio = num_mf / len(cluster_current)
			if (mf_ratio >= 0.7):
				good_clusters += 1
				cluster_size_measure += (len(cluster_current) / len(md))
			
		u_measure = (good_clusters / i) * cluster_size_measure
		s = pd.Series([u_measure])
		s.name = i
		score_results = score_results.append(s)
		
		#v_measure = metrics.v_measure_score(labels_true, labels_pred)
		#homogeneity = metrics.homogeneity_score(labels_true, labels_pred)

		#score_results[i] = v_measure
		#score_results[i] = homogeneity
		
	score_results = score_results.sort_values(by=0)
	score_results.to_csv(join(outdir, "results_data", "cluster_score_results_summary-HIST-COST-SENT_topics80.csv"))
	print(score_results)
	print("done")


def visualize_metadata():
	# donut-chart for subgenres
	
	md_all = pd.read_csv(join(outdir, "metadata_all.csv"))
	# sortieren?
	labels = set(list(md_all["text.genre.subgenre.summary"]))
	md_grouped = md_all.groupby("text.genre.subgenre.summary").count()
	md_grouped = md_grouped.sort_values(by="idno",ascending=False)
	
	labels = md_grouped.index.values
	values = list(md_grouped["idno"])

	# Use `hole` to create a donut-like pie chart
	fig = go.Figure(data=[go.Pie(labels=labels, values=values, hole=.5)])
	fig.update_layout(autosize=False,width=1200,height=700)
	fig.update_layout(legend=go.layout.Legend(font=dict(size=20)))
	fig.update_traces(textfont_size=20)
	
	fig.show()
	

def cluster_distinctiveness_heatmap(top_items_shown, cluster_number_start, cluster_number_stop):
	# plot the distinctive features of the cluster centers as a heatmap
	
	for i in range(cluster_number_start, cluster_number_stop):
		print("doing " + str(i) + " clusters")
		
		clusterc_data = pd.read_csv(join(outdir, "results_data", str(i) + "cl_80topics_summary-HIST-COST-SENT_cluster_center_features.csv"), index_col=0)
		colmeans = clusterc_data.mean(axis=0) # mean for each feature
		allstd = clusterc_data.std(axis=0)
		clusterc_data_normalized = (clusterc_data - colmeans) / allstd # zscore transformation
		clusterc_data_transformed = clusterc_data_normalized.T
		clusterc_data_transformed.index = clusterc_data_transformed.index.astype(np.int64) 
		
		# for topic features: add top topic words
		first_words = pd.read_csv(join(outdir, "features", "topicmodel", "firstWords_80.csv"), index_col=0, header=None)
		first_words.rename(columns={1:"topicwords"}, inplace=True)
		
		# join top topic words and data
		data = pd.concat([clusterc_data_transformed, first_words], axis=1, join="inner")
		# sort by std
		standard_deviations = data.std(axis=1)
		standard_deviations.name = "std"
		data.index = data.index.astype(np.int64)        
		data = pd.concat([data, standard_deviations], axis=1)
		data = data.sort_values(by="std", axis=0, ascending=False)
		data = data.drop("std", axis=1)
		
		some_data = data[0:top_items_shown]
		
		z_data = some_data.drop("topicwords", axis=1).to_numpy()
		x_labels = ["cl" + str(i) for i in clusterc_data.index.values]
		y_labels = list(some_data["topicwords"])
		
		fig = go.Figure(data=go.Heatmap(
						z=z_data, x=x_labels, y=y_labels, colorbar={"tickfont" : dict(size=28)})) #zmin=0, zmax=1,
		fig.update_layout(autosize=False,width=1000,height=1600)
		fig.update_xaxes(tickfont=dict(size=24))
		fig.update_yaxes(tickfont=dict(size=18))
		
		fig.write_image(join(outdir, "results_visual", "heatmaps", str(i) + "cl_distinctive-features_summary-HIST-COST-SENT_topics80.svg"))
	
	print("done")


cluster_distinctiveness_heatmap(40, 2, 14)

#visualize_metadata()

#cluster()

#extract_features_lexnames()

#classify_svm()
