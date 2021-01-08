#!/usr/bin/env python3
# Submodule name: get_stopwords.py

"""
Submodule for extracting stopwords from a collection of full text files, based on a number of most frequent words.

@author: Ulrike Henny-Krahmer

"""

import os
from nltk import word_tokenize
from nltk.probability import FreqDist
from nltk.corpus import PlaintextCorpusReader

def get_stopwords(wdir, inpath, outfile, mfw):
	"""
	Arguments:
	
	wdir (str): path to the working directory
	inpath (str): relative path to the input directory
	outfile (str): relative path to the output file
	mfw (int): number of most frequent words to include in the stop word list
	"""

	print("starting: get_stopwords...")
	
	corpus = PlaintextCorpusReader(os.path.join(wdir, inpath), ".*")
	
	#print(corpus.fileids())
	print("words in the corpus: " + str(len(corpus.words())))
	
	fdist_corpus = FreqDist(corpus.words())
	
	with open(os.path.join(wdir, outfile), "w", encoding="utf-8") as stopwords_out:
		
		# from the list of tuples, create a list with the X MFW
		top_words = [w[0] for w in fdist_corpus.most_common(mfw)]

		# store list, one word per line
		stopwords_out.write("\n".join(top_words))

	print("Done!")



"""
def main(wdir, inpath, outfile, mfw):
	get_stopwords(wdir, inpath, outfile, mfw)


if __name__ == "__main__":
	import sys
	get_stopwords(int(sys.argv[1]))
"""

get_stopwords("/home/ulrike/Git/papers/family_resemblance_dsrom19/", "topicmodel/corpus_lemmata_N/", "features/topics_stopwords.txt", 50)

