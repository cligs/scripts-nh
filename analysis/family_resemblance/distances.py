#!/usr/bin/env python3
# Submodule name: distances.py

"""
Submodule for functions related to distances between texts.

@author: Ulrike Henny-Krahmer

"""

from os.path import join
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import euclidean_distances
from sklearn.metrics.pairwise import cosine_similarity



def create_distancematrix(wdir, infile, outfile, measure):
	"""
	Creates a distance matrix, based on a data matrix of n objects and p variables.
	The distance is calculated for each pair of objects.
	
	Arguments:
	
	wdir (str): path to the working directory
	infile (str): relative path to the input file (the data matrix)
	outfile (str): relative path to the output file (the distance matrix)
	measure (str): which distance measure to use, e.g. "euclidean", "cosine"
	"""

	print("starting: create_distancematrix...")
	
	# change this if there are no header row or index column in the input data matrix
	data_matrix = pd.read_csv(join(wdir,infile), header=0, index_col=0)
	data_array = data_matrix.values
	
	if measure == "euclidean":
		dist = euclidean_distances(data_array)
	elif measure == "cosine":
		dist = cosine_similarity(data_array) # 1 - ?
	
	np.savetxt(join(wdir, outfile), dist, delimiter=",")
	
	print("Done!")
	
	
	
def get_nearest_neighbours(wdir, infile, outfile, num, mode):	
	"""
	For each object, get its nearest x neighbours and create a ranking.
	
	Arguments:
	
	wdir (str): path to the working directory
	infile (str): relative path to the input file (a distance matrix)
	outfile (str): relative path to the output file (the ranking file)
	num (int): number of nearest neighbours to fetch
	mode (str): "distance" or "similarity"
	"""
	
	print("starting: get_nearest_neighbours...")

	dist_matrix = pd.read_csv(join(wdir, infile), header=None, index_col=None)
	
	# new frame: one row for each object, one column for each nearest neighbour (ascending from the nearest)
	neighbours = pd.DataFrame()
	
	for column in dist_matrix:
		
		if mode == "distance":
			smallest = dist_matrix.nsmallest(num + 1,column)
			nearest = smallest[column].index.values[1:]
		elif mode == "similarity":
			largest = dist_matrix.nlargest(num + 1,column)
			nearest = largest[column].index.values[1:]
			
		nearest = pd.Series(nearest)
		
		neighbours = neighbours.append(nearest, ignore_index=True)
		
	neighbours.to_csv(join(wdir, outfile))
	
	print("Done!")
		
		

def main(wdir, infile, outfile, measure):
	create_distancematrix(wdir, infile, outfile, measure)


if __name__ == "__main__":
	import sys
	create_distancematrix(int(sys.argv[1]))


