#!/usr/bin/env python3
# Submodule name: data_selection.py

"""
Submodule to select data: 
- rows of feature tables of the whole corpus based on the metadata file for the reduced corpus
- txt files from the whole corpus, based on the metadata file for the reduced corpus

@author: Ulrike Henny-Krahmer

"""

import pandas as pd
from os.path import join
from os.path import basename
from shutil import copy
import glob

def select_entries(wdir, md_file, feat_file, outfile):
	"""
	Select only those rows from the feature matrices whose IDs are in the metadata table.
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	feat_file (str): relative path to the file containing the full feature matrix
	outfile (str): relative path to the output file for the reduced feature matrix
	
	"""
	
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	
	idnos = list(md.index)
	
	features = pd.read_csv(join(wdir, feat_file), index_col=0)
	features_reduced = features.loc[idnos]
	
	features_reduced.to_csv(join(wdir, outfile), encoding="UTF-8")
	
	print("Done")
	

def select_files(wdir, md_file, file_folder, outfolder):
	"""
	Select only those files from a folder whose IDs are in the metadata table.
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	file_folder (str): relative path to the folder containing all the files (with file name extension pattern, e.g. txt/*.txt)
	outfolder (str): relative path to the output folder for the reduced set of files. This directory has to exist.
	"""
	
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	idnos = list(md.index)
	
	num_files = 0
	
	for filepath in glob.glob(join(wdir, file_folder)):
		filename = basename(filepath)
		fileidno = filename[:-4]
		
		if fileidno in idnos:
			print("copying " + fileidno + "...")
			copy(filepath,join(wdir, outfolder))
			num_files += 1
	
	print("Done: copied " + str(num_files) + " files")
	
	
	
def add_cluster_info(wdir, md_file, cluster_file, outfile):
	"""
	Adds information about clusters to a metadata file and stores this specific file
	
	Arguments:
	wdir (str): path to the working directory
	md_file (str): relative path to the metadata file
	cluster_file (str): relative path to the file containing the information about the clusters
	outfile (str): relative path to the output file
	"""
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	clusters = pd.read_csv(join(wdir, cluster_file), index_col=0)
	cluster_list = list(clusters["cluster"])
	md["cluster"] = cluster_list
	md.to_csv(join(wdir, outfile))
	print("Done")
	
	
	
def copy_cluster_files(wdir, text_dir, md_file, stylo_folder, cluster_1, cluster_2):
	"""
	Copy specific files (of one cluster vs. rest; or one cluster vs. another cluster) to a folder
	for an oppose analysis with stylo. The first group is stored in a "primary_set" folder, the 
	second in a "secondary_set" folder.
	
	Arguments:
	wdir (str): path to the working directory
	text_dir (str): relative path to the folder containing the full text files of the corpus
	md_file (str): relative path to the metadata file
	stylo_folder (str): relative path to the stylo folder
	cluster_1 (int): first cluster to keep
	cluster_2 (int): second cluster to keep for comparison. If cluster_1 should be compared to all other clusters together, set this to None
	"""
	print("Copy cluster files...")
	
	md = pd.read_csv(join(wdir, md_file), index_col=0)
	# get the CLiGS ids of the novels belonging to the first cluster
	idnos_cluster_1 = md[md.cluster == cluster_1].index
	# copy the cluster files of cluster 1 to the stylo folder (make sure that the target directories exist and are empty)
	for idno in idnos_cluster_1:
		filename = idno + ".txt"
		inpath = join(wdir, text_dir, filename)
		outpath = join(wdir, stylo_folder, "primary_set")
		copy(inpath,join(wdir, outpath))
	
	if cluster_2:
		# keep only two selected clusters:
		md = md[md.cluster.isin([cluster_1,cluster_2])]
		# get the CLiGS ids of the novels belonging to the second cluster
		idnos_cluster_2 = md[md.cluster == cluster_2].index
		
		# copy the cluster files of cluster 2 to the stylo folder (make sure that the target directories exist and are empty)
		for idno in idnos_cluster_2:
			filename = idno + ".txt"
			inpath = join(wdir, text_dir, filename)
			outpath = join(wdir, stylo_folder, "secondary_set")
			copy(inpath,join(wdir, outpath))
	
	else:
		# merge clusters (by changing cluster values):
		# first: find out, what "the rest" is
		cluster_rest = set(list(md.cluster))
		cluster_rest.remove(cluster_1)
		# get the CLiGS ids of the novels belonging to the rest cluster
		idnos_cluster_rest = md[md.cluster.isin(cluster_rest)].index
		
		# copy the cluster files of the rest cluster to the stylo folder (make sure that the target directories exist and are empty)
		for idno in idnos_cluster_rest:
			filename = idno + ".txt"
			inpath = join(wdir, text_dir, filename)
			outpath = join(wdir, stylo_folder, "secondary_set")
			copy(inpath,join(wdir, outpath))
		
	print("Done")
	
	
	
wdir = "/home/ulrike/Git/papers/family_resemblance_dsrom19/"
#select_entries(wdir, "corpus_metadata/metadata.csv", "features/mfw_1000_tfidf_full.csv", "features/mfw_1000_tfidf.csv")
#select_entries(wdir, "corpus_metadata/metadata_SENT.csv", "features/mfw_1000_tfidf_full.csv", "features/mfw_1000_tfidf_SENT.csv")
#select_entries(wdir, "corpus_metadata/metadata_HIST.csv", "features/mfw_1000_tfidf_full.csv", "features/mfw_1000_tfidf_HIST.csv")

#select_entries(wdir, "corpus_metadata/metadata.csv", "features/avgtopicscores_by-idno_full.csv", "features/avgtopicscores_by-idno.csv")
#select_entries(wdir, "corpus_metadata/metadata_SENT.csv", "features/avgtopicscores_by-idno_full.csv", "features/avgtopicscores_by-idno_SENT.csv")
#select_entries(wdir, "corpus_metadata/metadata_HIST.csv", "features/avgtopicscores_by-idno_full.csv", "features/avgtopicscores_by-idno_HIST.csv")
	
#select_files(wdir, "corpus_metadata/metadata.csv", "txt_full/*.txt", "txt/")

#add_cluster_info(wdir, "corpus_metadata/metadata_HIST.csv", "analysis/clusters/clusters_3nn_cosine_mfw_1000_tfidf_HIST.csv", "corpus_metadata/metadata_HIST_mfw_1000_cl.csv")
#add_cluster_info(wdir, "corpus_metadata/metadata_HIST.csv", "analysis/clusters/clusters_3nn_cosine_topics_100_HIST.csv", "corpus_metadata/metadata_HIST_topics_100_cl.csv")
add_cluster_info(wdir, "corpus_metadata/metadata_SENT.csv", "analysis/clusters/clusters_3nn_cosine_mfw_1000_tfidf_SENT.csv", "corpus_metadata/metadata_SENT_mfw_1000_tfidf_cl.csv")
add_cluster_info(wdir, "corpus_metadata/metadata_SENT.csv", "analysis/clusters/clusters_3nn_cosine_topics_100_SENT.csv", "corpus_metadata/metadata_SENT_topics_100_cl.csv")
add_cluster_info(wdir, "corpus_metadata/metadata.csv", "analysis/clusters/clusters_3nn_cosine_mfw_1000_tfidf.csv", "corpus_metadata/metadata_mfw_1000_tfidf_cl.csv")
add_cluster_info(wdir, "corpus_metadata/metadata.csv", "analysis/clusters/clusters_3nn_cosine_topics_100.csv", "corpus_metadata/metadata_topics_100_cl.csv")

#copy_cluster_files(wdir, "texts/txt_full", "corpus_metadata/metadata_HIST_mfw_1000_cl.csv", "stylo", 3, None)

