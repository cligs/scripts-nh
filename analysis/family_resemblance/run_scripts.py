#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Calls functions to produce "family resemblance networks" of novels.

@author: Ulrike Henny-Krahmer
"""

import sys
from os.path import join
import glob
import re
import pandas as pd

#sys.path.append(os.path.abspath("/home/ulrike/Git/IDE/novelashispanoamericanas/scripts/python/toolbox"))

import distances
import neighbours
import feature_exploration


###################################
wdir = "/home/ulrike/Git/papers/family_resemblance_dsrom19/"


# Before starting the analysis, the features (MFW, topics) and the corresponding metadata have to be prepared.

############ Analyze ############

# for all steps: do several runs for the different subgenres and feature types

runs = ["HIST-mfw", "HIST-topics", "SENT-mfw", "SENT-topics", "all-mfw", "all-topics"]

#### (1) create the distance (or similarity) matrix

feature_filenames = ["mfw_1000_tfidf_HIST.csv", "avgtopicscores_by-idno_HIST.csv", "mfw_1000_tfidf_SENT.csv", "avgtopicscores_by-idno_SENT.csv", "mfw_1000_tfidf.csv", "avgtopicscores_by-idno.csv"]
similarity_filenames = ["cosine_mfw_1000_tfidf_HIST.csv", "cosine_topics_100_HIST.csv", "cosine_mfw_1000_tfidf_SENT.csv", "cosine_topics_100_SENT.csv", "cosine_mfw_1000_tfidf.csv", "cosine_topics_100.csv"]

"""
for idx, run in enumerate(runs):
	distances.create_distancematrix(wdir, join("features", feature_filenames[idx]), join("analysis/similarities", similarity_filenames[idx]), "cosine")
"""


#### (2) get nearest neighbours

rankings_filenames = ["3nn_cosine_mfw_1000_tfidf_HIST.csv", "3nn_cosine_topics_100_HIST.csv", "3nn_cosine_mfw_1000_tfidf_SENT.csv", "3nn_cosine_topics_100_SENT.csv", "3nn_cosine_mfw_1000_tfidf.csv", "3nn_cosine_topics_100.csv"]

"""
for idx, run in enumerate(runs):
	distances.get_nearest_neighbours(wdir, join("analysis/similarities", similarity_filenames[idx]), join("analysis/rankings", rankings_filenames[idx]), 3, "similarity")
"""


#### (3) create networks

metadata_filenames = ["metadata_HIST.csv", "metadata_HIST.csv", "metadata_SENT.csv", "metadata_SENT.csv", "metadata.csv", "metadata.csv"]
network_filenames = ["network_3nn_cosine_mfw_1000_tfidf_HIST.png", "network_3nn_cosine_topics_100_HIST.png", "network_3nn_cosine_mfw_1000_tfidf_SENT.png", "network_3nn_cosine_topics_100_SENT.png", "network_3nn_cosine_mfw_1000_tfidf.png", "network_3nn_cosine_topics_100.png"]
cluster_filenames = ["clusters_3nn_cosine_mfw_1000_tfidf_HIST.csv", "clusters_3nn_cosine_topics_100_HIST.csv", "clusters_3nn_cosine_mfw_1000_tfidf_SENT.csv", "clusters_3nn_cosine_topics_100_SENT.csv", "clusters_3nn_cosine_mfw_1000_tfidf.csv", "clusters_3nn_cosine_topics_100.csv"]
edges_filenames = ["edges_3nn_cosine_mfw_1000_tfidf_HIST.csv", "edges_3nn_cosine_topics_100_HIST.csv", "edges_3nn_cosine_mfw_1000_tfidf_SENT.csv", "edges_3nn_cosine_topics_100_SENT.csv", "edges_3nn_cosine_mfw_1000_tfidf.csv", "edges_3nn_cosine_topics_100.csv"]

"""
for idx, run in enumerate(runs):
	neighbours.create_network(wdir, join("analysis/rankings", rankings_filenames[idx]), join("corpus_metadata", metadata_filenames[idx]),
	join("analysis/similarities", similarity_filenames[idx]), join("analysis/networks", network_filenames[idx]), 
	join("analysis/clusters", cluster_filenames[idx]), join("analysis/edges", edges_filenames[idx]))
"""



############ Visualize item / cluster features ############

#### (1) metadata: cluster size, countries, narrative perspective, years
"""
metadata_categories = ["cluster-size", "country",  "author-gender", "narrative-perspective", "year"]


for md_cat in metadata_categories:
	for idx,run in enumerate(runs):
		feature_exploration.visualize_cluster_metadata(wdir, join("corpus_metadata", metadata_filenames[idx]), md_cat, join("analysis/clusters", cluster_filenames[idx]), join("analysis/feature_exploration", "metadata_" + run, md_cat))
"""
"""
# add: "subgenre-theme" (for analysis of several subgenres)

for idx,run in enumerate(runs[-2:]):
	idx = idx + 4
	md_cat = "subgenre-theme"
	feature_exploration.visualize_cluster_metadata(wdir, join("corpus_metadata", metadata_filenames[idx]), md_cat, join("analysis/clusters", cluster_filenames[idx]), join("analysis/feature_exploration", "metadata_" + run, md_cat))
"""


#### (2) top features for all the novels
"""
## MFW

feature_exploration.visualize_top_features(wdir, "corpus_metadata/metadata_full.csv", "features/mfw_1000_tfidf_full.csv", "mfw", 30, 
"analysis/feature_exploration/top_mfw/", rank_file="features/mfw_ranks.csv")
"""

"""
## topics

feature_exploration.visualize_top_features(wdir, "corpus_metadata/metadata_full.csv", "features/avgtopicscores_by-idno_full.csv", "topics", 30, 
"analysis/feature_exploration/top_topics/", first_words_file="features/topicmodel/aggregates/100tp-5000it-100in/firstWords.csv", rank_file="features/topicmodel/aggregates/100tp-5000it-100in/topicRanks.csv")
"""
"""
feature_exploration.visualize_top_features(wdir, "corpus_metadata/metadata_full.csv", "features/avgtopicscores_by-idno_full.csv", "topics", 30, 
"analysis/feature_exploration/top_topics/", first_words_file="features/topicmodel/aggregates/100tp-5000it-100in/firstWords.csv")
"""

#### (3) cluster distinctiveness

"""
## historical novels, MFW

feature_exploration.visualize_cluster_distinctiveness(wdir, "corpus_metadata/metadata_HIST.csv", "features/mfw_1000_tfidf_HIST.csv", 
"analysis/clusters/clusters_3nn_cosine_mfw_1000_tfidf_HIST.csv", "mfw", 30, norm_mode="zscores", rank_file="features/mfw_ranks.csv", outfile="analysis/feature_exploration/distinctiveness_mfw_HIST")

## sentimental novels, MFW

feature_exploration.visualize_cluster_distinctiveness(wdir, "corpus_metadata/metadata_SENT.csv", "features/mfw_1000_tfidf_SENT.csv", 
"analysis/clusters/clusters_3nn_cosine_mfw_1000_tfidf_SENT.csv", "mfw", 30, norm_mode="zscores", rank_file="features/mfw_ranks.csv", outfile="analysis/feature_exploration/distinctiveness_mfw_SENT")

## all novels, MFW

feature_exploration.visualize_cluster_distinctiveness(wdir, "corpus_metadata/metadata.csv", "features/mfw_1000_tfidf.csv", 
"analysis/clusters/clusters_3nn_cosine_mfw_1000_tfidf.csv", "mfw", 30, norm_mode="zscores", rank_file="features/mfw_ranks.csv", outfile="analysis/feature_exploration/distinctiveness_mfw")
"""


## historical novels, topics

feature_exploration.visualize_cluster_distinctiveness(wdir, "corpus_metadata/metadata_HIST.csv", "features/avgtopicscores_by-idno_HIST.csv", 
"analysis/clusters/clusters_3nn_cosine_topics_100_HIST.csv", "topics", 30, norm_mode="zscores", rank_file="features/topicmodel/aggregates/100tp-5000it-100in/topicRanks.csv", 
first_words_file="features/topicmodel/aggregates/100tp-5000it-100in/firstWords.csv", outfile="analysis/feature_exploration/distinctiveness_topics_HIST")

## sentimental novels, topics

feature_exploration.visualize_cluster_distinctiveness(wdir, "corpus_metadata/metadata_SENT.csv", "features/avgtopicscores_by-idno_SENT.csv", 
"analysis/clusters/clusters_3nn_cosine_topics_100_SENT.csv", "topics", 30, norm_mode="zscores", rank_file="features/topicmodel/aggregates/100tp-5000it-100in/topicRanks.csv", 
first_words_file="features/topicmodel/aggregates/100tp-5000it-100in/firstWords.csv", outfile="analysis/feature_exploration/distinctiveness_topics_SENT")

## all novels, topics

feature_exploration.visualize_cluster_distinctiveness(wdir, "corpus_metadata/metadata.csv", "features/avgtopicscores_by-idno.csv", 
"analysis/clusters/clusters_3nn_cosine_topics_100.csv", "topics", 30, norm_mode="zscores", rank_file="features/topicmodel/aggregates/100tp-5000it-100in/topicRanks.csv", 
first_words_file="features/topicmodel/aggregates/100tp-5000it-100in/firstWords.csv", outfile="analysis/feature_exploration/distinctiveness_topics")




#### (4) topic distributions ####
"""
## historical novels, topics
feature_exploration.visualize_topic_dists(wdir, "corpus_metadata/metadata_HIST_topics_100_cl.csv", "features/avgtopicscores_by-idno_HIST.csv", 
"features/topicmodel/aggregates/100tp-5000it-100in/topicRanks.csv", "features/topicmodel/aggregates/100tp-5000it-100in/firstWords.csv", "analysis/feature_exploration/topic_lines_HIST_cl3", 3)
"""
