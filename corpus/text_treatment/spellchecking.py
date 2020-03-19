#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
@author: Ulrike Henny-Krahmer, Christof Schöch
@filename: spellchecking.py

Submodule for checking the orthography of a text collection. The expected input are plain text files.

To install further dictionaries: sudo apt-get install myspell-es (etc.)
See https://pyenchant.github.io/pyenchant/ for more information about the spellchecking library used

How to call the script (example):

import spellchecking
spellchecking.check_collection(wdir, "txt/nh0092.txt", "spellcheck.csv", "es", [])
"""

import enchant
from enchant import checker
from enchant.tokenize import get_tokenizer
import collections
import pandas as pd
import os
from os.path import join
import glob
import sys
import re
import csv
import plotly.graph_objects as go
import numpy as np


##########################################################################
def check_collection(wdir, inpath, outpath, lang, wordFiles=[]):
    """
    Checks the orthography of the text in a collection. The expected input are plain text files.
    The output is one csv file with the results of all the checks.
    
    @author: Ulrike Henny-Krahmer
    
    Arguments:
    wdir (str): path to the working directory
    inpath (str): relative path to the input files, including file name pattern
    outpath (str): relative path to the output file, including the output file's name
    lang (str): which dictionary to use, e.g. "es", "fr", "de"
    wordFiles (list): optional; list of strings; paths to files with lists of words which will not be treated as errors (e.g. named entities)
    """

    try:
        enchant.dict_exists(lang)
        try:
            tknzr = get_tokenizer(lang)
        except enchant.errors.TokenizerNotFoundError:    
            tknzr = get_tokenizer()
        chk = checker.SpellChecker(lang, tokenize=tknzr)
        
    except enchant.errors.DictNotFoundError:
        print("ERROR: The dictionary " + lang + "doesn't exist. Please choose another dictionary.")
        sys.exit(0)

    all_words = []
    all_num = []
    all_idnos = []

    print("...checking...")
    for file in glob.glob(os.path.join(wdir, inpath)):
        idno = os.path.basename(file)[-10:-4]
        all_idnos.append(idno)
        
        err_words = []

        with open(file, "r", encoding="UTF-8") as fin:
            intext = fin.read().lower()
            chk.set_text(intext)

        if len(wordFiles) !=0:
            allCorrects = ""
            for file in wordFiles:
                with open(file, "r", encoding="UTF-8") as f:
                     corrects = f.read().lower()
                     allCorrects = allCorrects + corrects

        for err in chk:
            if not wordFiles or err.word not in allCorrects: 
                err_words.append(err.word)
            all_words.append(err_words)

        err_num = collections.Counter(err_words)
        all_num.append(err_num)
        
        print("..." + str(len(err_num)) + " different errors found in " + idno)
        
    df = pd.DataFrame(all_num,index=all_idnos).T
    
    df = df.fillna(0)
    df = df.astype(int)
    
    df["sum"] = df.sum(axis=1)
    # df = df.sort("sum", ascending=False)
    df = df.sort_values(by="sum", ascending=False)
    
    df.to_csv(os.path.join(wdir, outpath))
    print("done")


########################################################################
def correct_words(errFolder, corrFolder, substFile):
    """
    Corrects misspelled words in TEI files.
    
    @author: Christof Schöch
    
    Arguments: 
    teiFolder (string): Folder in which the TEI files with errors are.
    outFolder (string): Folder in which the corrected TEI files will be stored.
    substFile (string): CSV file with "error, corrected" word, one per line.
    """
    
    print("correct_words...")
    ## Create a dictionary of errors and correct words from a CSV file.
    with open(substFile, "r") as sf:
        subst = csv.reader(sf)
        substDict = {}
        for row in subst:
            key = row[0]
            if key in substDict:
                pass
            substDict[key] = row[1]
    
    ## Open each TEI file and replace all errors with correct words.
    teiPath = os.path.join(errFolder, "*.xml")
    for teiFile in glob.glob(teiPath):
        with open(teiFile,"r") as tf:
            filename = os.path.basename(teiFile)
            print(filename)
            text = tf.read()
            for err,corr in substDict.items(): 
                text = re.sub(err,corr,text)
        
        ## Save each corrected file to a new location.
        with open(os.path.join(corrFolder, filename),"w") as output:
            output.write(text) 



##########################################################################

def plot_error_distribution(wdir, spellcheck_file, **kwargs):
	"""
	Visualizes the distribution of errors (how many errors occur how frequently?)

	@author: Ulrike Henny-Krahmer
	
	Arguments:
	
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	log (str): optional argument; should the x-axis be logarithmic? "yes" or "no"; defaults to "no"
	"""
	
	log = kwargs.get("log", "no")

	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)

	x = np.arange(len(data))
	y = list(data["sum"])

	fig = go.Figure(data=go.Scatter(x=x, y=y, mode="markers"))
	if log == "yes":
		xaxis_type="log"
	else:
		xaxis_type="linear"
		
	fig.update_layout(autosize=False,width=900,height=500,xaxis_type=xaxis_type)
	fig.show()


def plot_top_errors(wdir, spellcheck_file, num_errors):
	"""
	Visualizes the top errors as a bar chart (which top error words occur how frequently?)
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	num_errors (int): number of top errors to plot
	"""
	
	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)
	data = data.head(num_errors)
	
	x = list(data.index)
	y = list(data["sum"])

	fig = go.Figure([go.Bar(x=x, y=y)])
	fig.update_layout(autosize=False,width=1000,height=600)
	fig.update_xaxes(tickangle=270)
	fig.show()
	


##########################################################################

"""
def main(inpath, outpath, lang, wordFiles, errFolder, corrFolder, substFile):
    check_collection(inpath, outpath, lang, wordFiles)
    correct_words(errFolder, corrFolder, substFile)
    
if __name__ == "__main__":
    check_collection(int(sys.argv[1]))
    correct_words(int(sys.argv[1]))
"""

