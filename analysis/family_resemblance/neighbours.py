#!/usr/bin/env python3
# Submodule name: neighbours.py

"""
Submodule for the creation of a network of nearest neighbours.

@author: Ulrike Henny-Krahmer

"""

from os.path import join
import pandas as pd
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt
#from networkx.algorithms import community
import community


def create_network(wdir, infile, mdfile, simfile, outfile_net, outfile_cl, outfile_edges):
	"""
	Creates a network graph.
	
	Arguments:
	
	wdir (str): path to the working directory
	infile (str): relative path to the input file (the "rankings": a matrix with one row per node and one column per nearest neighbour (ascending from the nearest))
	simfile (str): relative path to the similarity (or distance) matrix file
	mdfile (str): relative path to the metadata file
	outfile_net (str): relative path to the network output file (an image file of the network)
	outfile_cl (str): relative path to the cluster output file (which nodes belong to which cluster)
	outfile_edges (str): relative path to the edge list output file
	"""

	print("starting: create_network...")
	
	# data = rankings
	data = pd.read_csv(join(wdir, infile), header=0, index_col=0)
	md = pd.read_csv(join(wdir, mdfile), header=0, index_col=0)
	similarities = pd.read_csv(join(wdir, simfile), header=None)
	
	nodes = data.index.values
	ids = md.index.values
	subgenres = md["subgenre-theme"].values
	authors = md["author-short"].values
	titles = md["title-short"].values
	years = md["year"].values
	
	G = nx.Graph()
	G.add_nodes_from(nodes)
	
	# add the nodes and edges to the network
	for source_node in nodes:
		
		for col in data.columns:
			
			target_node = int(data.loc[source_node][col])
			
			# calculate the edge weight
			# variant 1: edge weight = rank 1: 3, rank 2: 2, rank 3: 1
			#edge_weight = len(data.columns) - int(col)
			
			# variant 2: edge weight = similarity values for the connected nodes
			edge_weight = similarities.iloc[source_node,target_node]
		
		
			if not(G.has_edge(source_node, target_node)):
				G.add_edge(source_node, target_node, weight=edge_weight)
			# if there is already an edge: add the additional weight
			else:
				curr_weight = G[source_node][target_node]["weight"]
				G[source_node][target_node]["weight"] = curr_weight + edge_weight
	
	#print(G.number_of_nodes())
	#print(G.number_of_edges())
	
	
	# calculate the communities
	
	# Clauset-Newman-Moore greedy modularity maximization (does not consider edge weights):
	# communities_generator = community.greedy_modularity_communities(G)
	
	# Louvain:
	communities_generator = community.best_partition(G, resolution=1.0)
	# see: https://python-louvain.readthedocs.io/en/latest/api.html#community.best_partition
	# resolution: Will change the size of the communities, default to 1. represents the time described in
	# “Laplacian Dynamics and Multiscale Modular Structure in Networks”, R. Lambiotte, J.-C. Delvenne, M. Barahona
	# res 1.0 scheint schon die größten Communities zu ergeben, bei Werten unter 1.0 werden es noch mehr
	
	#print(communities_generator)
	
	# color the nodes according to their community
	colors = ["#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC",
			"#0099C6", "#DD4477", "#66AA00", "#B82E2E", "#316395", "#994499",
			"#22AA99", "#AAAA11", "#6633CC", "#E67300", "#8B0707", "#329262",
			"#5574A6", "#3B3EAC",
			"#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC",
			"#0099C6", "#DD4477", "#66AA00", "#B82E2E", "#316395", "#994499",
			"#22AA99", "#AAAA11", "#6633CC", "#E67300", "#8B0707", "#329262",
			"#5574A6", "#3B3EAC"]
	
	"""
	for idx, comm in enumerate(communities_generator):
		for node_id in comm:
			nx.set_node_attributes(G, {node_id : {"color" : colors[idx]}})
	"""
	
	for node_id in communities_generator:
		comm = communities_generator[node_id]
		nx.set_node_attributes(G, {node_id : {"color" : colors[comm]}})
		
	# save cluster results for later evaluation
	idx = communities_generator.keys()
	vals = communities_generator.values()
	vals = {"cluster" : list(vals)}
	cluster_result = pd.DataFrame(index=idx, data=vals)
	cluster_result.to_csv(join(wdir, outfile_cl))
	
	# save edge lists for later evaluation
	nx.write_weighted_edgelist(G, join(wdir, outfile_edges))
	
	
	# draw the network
	weights = nx.get_edge_attributes(G, "weight")
	weights = list(weights.values())
	
	node_colors = nx.get_node_attributes(G, "color")
	node_colors = list(node_colors.values())
	
	labels = {}
	for node in nodes:
		
		"""
		#ids und subgenre 
		node_id = ids[node][2:].lstrip("0")
		node_subgenre = subgenres[node] #[6:]
		labels[node] = node_id + "_" + node_subgenre
		"""
		
		#author,title,year
		labels[node] = authors[node] + "_"+ titles[node] + "_" + str(years[node])
		
	
	plt.figure(figsize=(25,25))
	#plt.axis("off")
	#plt.tight_layout()
	
	layout = nx.spring_layout(G, dim=2, k=0.15, iterations=20)
	# dim: dimension of layout, integer (??)
	# k controls the distance between nodes, default 0.1
	# iterations:Number of iterations of spring-force relaxation, default 50
	
	layout_labels = {}
	for node in nodes:
		x = layout[node][0]
		y = layout[node][1]
		layout_labels[node] = [x, y - 0.03]
	
	
	nx.draw_networkx_labels(G, layout_labels, labels, font_weight="bold", font_size=14)
	nx.draw_networkx_nodes(G, layout, node_color=node_colors, linewidths=0)
	nx.draw_networkx_edges(G, layout, edge_color="#669900", width=weights, alpha=0.5)
	
	plt.savefig(join(wdir, outfile_net))
	
	print("Done!")

	
	
def create_multi_network(wdir, infiles, mdfile, outfile, outfile_cl):
	"""
	Creates a multi network graph.
	
	Arguments:
	
	wdir (str): path to the working directory
	infiles (list): list with relative paths to the input files (matrices with one row per node and one column per nearest neighbour (ascending from the nearest))
	mdfile (str): relative path to the metadata file
	outfile (str): relative path to the output file (an image file of the network)
	outfile_cl (str): relative path to the cluster output file (which nodes belong to which cluster)
	"""

	print("starting: create_multi_network...")
	
	data_1 = pd.read_csv(join(wdir, infiles[0]), header=0, index_col=0)
	md = pd.read_csv(join(wdir, mdfile), header=0, index_col=0)
	
	nodes = data_1.index.values
	ids = md.index.values
	subgenres = md["text.genre.subgenre"].values
	authors = md["author.short"].values
	titles = md["title.short"].values
	years = md["editionFirst.year"].values
	
	# create graph and add nodes
	G = nx.MultiGraph()
	G.add_nodes_from(nodes)
	
	#print(G.number_of_nodes())
	
	colors = ["#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC",
			"#0099C6", "#DD4477", "#66AA00", "#B82E2E", "#316395", "#994499",
			"#22AA99", "#AAAA11", "#6633CC", "#E67300", "#8B0707", "#329262",
			"#5574A6", "#3B3EAC"]
	
	# add edges
	
	for idx,inf in enumerate(infiles):
		
		data = pd.read_csv(join(wdir, inf), header=0, index_col=0)
		for source_node in nodes:
			
			for col in data.columns:
				
				edge_weight = len(data.columns) - int(col)
				target_node = int(data.loc[source_node][col])
			
				if not(G.has_edge(source_node, target_node, idx)):
					G.add_edge(source_node, target_node, idx, weight=edge_weight, color=colors[idx])
				else:
					curr_weight = G[source_node][target_node][idx]["weight"]
					G[source_node][target_node][idx]["weight"] = curr_weight + edge_weight
		
		
		#print(G.number_of_edges())
	
	# communities
	# communities_generator = community.greedy_modularity_communities(G)
	
	# Louvain:
	communities_generator = community.best_partition(G, resolution=1.0)
	
	# color the nodes according to their community
	"""
	for idx, comm in enumerate(communities_generator):
		for node_id in comm:
			nx.set_node_attributes(G, {node_id : {"color" : colors[idx]}})
	"""		
			
	for node_id in communities_generator:
		comm = communities_generator[node_id]
		nx.set_node_attributes(G, {node_id : {"color" : colors[comm]}})
		
	# save cluster results for later evaluation
	idx = communities_generator.keys()
	vals = communities_generator.values()
	vals = {"cluster" : list(vals)}
	cluster_result = pd.DataFrame(index=idx, data=vals)
	cluster_result.to_csv(join(wdir, outfile_cl))
	
	# drawing
	weights = nx.get_edge_attributes(G, "weight")
	weights = list(weights.values())
	
	node_colors = nx.get_node_attributes(G, "color")
	node_colors = list(node_colors.values())
	
	edge_colors = nx.get_edge_attributes(G, "color")
	edge_colors = list(edge_colors.values())
	
	labels = {}
	for node in nodes:
		
		"""
		# id + subgenre
		node_id = ids[node][2:].lstrip("0")
		node_subgenre = subgenres[node] #[6:]
		labels[node] = node_id + "_" + node_subgenre
		"""
		
		#autor,titel,jahr
		labels[node] = authors[node] + "_"+ titles[node] + "_" + str(years[node])
	
	plt.figure(figsize=(25,25))
	#plt.axis("off")
	#plt.tight_layout()
	
	layout = nx.spring_layout(G, dim=2, k=0.15, iterations=20)
	# dim: dimension of layout, integer (??)
	# k controls the distance between nodes, default 0.1
	# iterations:Number of iterations of spring-force relaxation, default 50
	
	layout_labels = {}
	for node in nodes:
		x = layout[node][0]
		y = layout[node][1]
		layout_labels[node] = [x, y - 0.04]
	
	
	nx.draw_networkx_labels(G, layout_labels, labels, font_weight="bold", font_size=14)
	nx.draw_networkx_nodes(G, layout, node_color=node_colors, linewidths=0)
	nx.draw_networkx_edges(G, layout, edge_color=edge_colors, width=weights, alpha=0.5)
	
	plt.savefig(join(wdir, outfile))
	
	#nx.write_weighted_edgelist(G, join(wdir, 'weighted.edgelist.txt'))
	nx.write_gexf(G, join(wdir, "network.gexf"))
	
	print("Done!")



def main(wdir, infile, mdfile, simfile, outfile):
	create_network(wdir, infile, mdfile, simfile, outfile_net, outfile_cl)


if __name__ == "__main__":
	import sys
	create_network(int(sys.argv[1]))


