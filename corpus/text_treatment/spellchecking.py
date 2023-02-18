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
spellchecking.check_collection(wdir, "txt/nh0092.txt", "spellcheck.csv", "es", ["exception-list-1.txt", "exception-list-2.txt"])
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
import spacy


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
	

def plot_error_distribution(wdir, spellcheck_file, outfile, **kwargs):
	"""
	Visualizes the distribution of errors (how many errors occur how frequently?)

	@author: Ulrike Henny-Krahmer
	
	Arguments:
	
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	outfile (str): relative path to the output file, without file name extension
	log (str): optional argument; should the x-axis be logarithmic? "yes" or "no"; defaults to "no"
	"""
	print("plot error distribution...")
	
	log = kwargs.get("log", "no")

	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)

	x = np.arange(len(data))
	y = list(data["sum"])

	fig = go.Figure(data=go.Scatter(x=x, y=y, mode="markers"))
	if log == "yes":
		xaxis_type="log"
		xaxis_title="number of errors (log)"
	else:
		xaxis_type="linear"
		xaxis_title="number of errors"
		
	fig.update_layout(autosize=False,width=709,height=500,xaxis_type=xaxis_type,xaxis_title=xaxis_title,yaxis_title="error frequency")
	fig.update_layout(title=dict(text="Distribution of spelling errors with exception words.",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=80, l=100, r=100),font=dict(family="Libertine, serif",color="#000000",size=14))
	fig.update_yaxes(title_font_size=14)
	fig.update_xaxes(title_font_size=14)
	
	
	#fig.write_image(join(wdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")


def plot_top_errors(wdir, spellcheck_file, outfile, num_errors):
	"""
	Visualizes the top errors as a bar chart (which top error words occur how frequently?)
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	outfile (str): relative path to the output file
	num_errors (int): number of top errors to plot
	"""
	print("plot top errors...")
	
	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)
	data = data.head(num_errors)
	
	x = list(data.index)
	y = list(data["sum"])

	fig = go.Figure([go.Bar(x=x, y=y)])
	fig.update_layout(autosize=False,width=709,height=500)
	fig.update_xaxes(tickangle=270,tickfont=dict(size=14),title="error word",title_font_size=14)
	fig.update_yaxes(title="error frequency",title_font_size=14)
	fig.update_layout(title=dict(text="Top 30 spelling errors.",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=80, b=80, l=80, r=80),font=dict(family="Libertine, serif",color="#000000",size=14))
	
	
	#fig.write_image(join(wdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	
	
def plot_errors_per_file(wdir, spellcheck_file, outfile, mode, norm):
	"""
	Visualizes how many errors there are per text file in the corpus (as a violin plot)
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	outfile (str): relative path to the output file (without filename extension)
	mode (str): "types" or "tokens" or "both"
	norm (str): "absolute" error numbers or "relative" to text length
	"""
	print("plot errors per file...")
	
	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)
	data = data.drop("sum", axis=1).T.sort_index()
	
	# for tokens: sum the rows (each row contains the errors in one file)
	data_tokens = data.sum(axis=1)
	# for types: count the number of values in a row that are not zero
	data_types = data.astype(bool).sum(axis=1)
	
	# for relative numbers divide the error values by the number of tokens / types in the text
	if norm == "relative":
		wdir_corpus = "/home/ulrike/Git/conha19/"
		text_lengths = get_text_lengths(wdir_corpus, "txt/*.txt")
		text_vocabs = get_text_vocabulary_sizes(wdir_corpus, "txt/*.txt")
		data_tokens = data_tokens.divide(text_lengths)
		data_types = data_types.divide(text_vocabs)
	
	
	if mode == "tokens" or mode == "types":
		if mode == "tokens":
			data = data_tokens
		elif mode == "types":
			data = data_types
		fig = go.Figure(data=go.Violin(y=data, box_visible=True, line_color='black', meanline_visible=True, fillcolor='lightseagreen', opacity=0.6, x0='number of errors (' + mode + ')'))
	# if none of these modes is given, plot two violins side by side ("both")
	else:
		x_tokens = ["tokens" for i in data_tokens]
		x_types = ["types" for i in data_tokens]
		fig = go.Figure()
		fig.add_trace(go.Violin(x=x_tokens, y=data_tokens, name="tokens", box_visible=True, meanline_visible=True))
		fig.add_trace(go.Violin(x=x_types, y=data_types, name="types", box_visible=True, meanline_visible=True))
	
	if norm == "relative":
		yaxis_title="number of tokens/types (relative)"
	else:
		yaxis_title="number of tokens/types"
	
	fig.update_layout(autosize=False,width=709,height=500,yaxis_title=yaxis_title,xaxis_tickfont=dict(size=14),yaxis_tickfont=dict(size=14),legend_font=dict(size=14))
	fig.update_layout(title=dict(text="Distribution of error tokens and types for the corpus files (relative)",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=80, l=100, r=100),font=dict(family="Libertine, serif",color="#000000",size=14))
	fig.update_yaxes(title_font_size=14)
	fig.update_xaxes(title_font_size=14)
	
	
	#fig.write_image(join(wdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	
	
def plot_errors_per_file_grouped(wdir, spellcheck_file, outfile, md_file, md_category, norm):
	"""
	Visualizes how many errors there are per text file in the corpus (as a violin plot),
	for a certain metadata type, e.g. kind of edition, grouped by tokens and types
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	outfile (str): relative path to the output file (without filename extension)
	md_file (str): path to the metadata table containing information about the kind of source edition of each file
	md_category (str): metadata category for the plot, e.g. "sources_edition" or "sources_filetype"
	norm (str): "absolute" error numbers or "relative" to text length 
	"""
	print("plot errors per file grouped...")
	
	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)
	metadata = pd.read_csv(join(wdir, md_file), index_col=0, header=0)
	
	# change the form of the frame so that the file IDs become the index
	data = data.drop(columns=["sum"]).T
	data = data.sort_index(inplace=False)
	# add a column for the edition type
	data[md_category] = metadata[md_category]
	# add columns with sums for error tokens and types per file
	data["tokens_sum"] = data.sum(axis=1)
	data["types_sum"] = data.drop(columns=[md_category, "tokens_sum"]).astype(bool).sum(axis=1)
	
	# for relative numbers divide the error values by the number of tokens in the text
	if norm == "relative":
		wdir_corpus = "/home/ulrike/Git/conha19/"
		text_lengths = get_text_lengths(wdir_corpus, "txt/*.txt")
		text_vocabs = get_text_vocabulary_sizes(wdir_corpus, "txt/*.txt")
		data["tokens_sum"] = data["tokens_sum"].divide(text_lengths)
		data["types_sum"] = data["types_sum"].divide(text_vocabs)
		
		#print(data["types_sum"].idxmax())
		#exit()
	
	
	data = data.sort_values(by=md_category)
	

	fig = go.Figure()
	
	fig.add_trace(go.Violin(x=data[md_category], y=data['tokens_sum'], legendgroup='tokens', scalegroup='tokens', name='tokens', line_color='blue', box_line_color="green"))
	fig.add_trace(go.Violin(x=data[md_category], y=data['types_sum'], legendgroup='types', scalegroup='types', name='types', line_color='orange', box_line_color="red"))

	fig.update_traces(box_visible=True, meanline_visible=True)
	fig.update_layout(violinmode='group',yaxis_title="number of tokens/types (relative)")
	fig.update_layout(autosize=False,width=709,height=1000,legend_font=dict(size=14)) 
	fig.update_layout(title=dict(text="Distribution of error tokens and types for the corpus files (by source institution)",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=80, l=50, r=20),font=dict(family="Libertine, serif",color="#000000",size=14))
	
	# source edition type: 900/700, file type: 700/600, institution: 900/900
	
	fig.update_xaxes(tickfont=dict(size=13),title="source edition type",title_font_size=14) # titles: source edition type, source file type, source institution
	fig.update_yaxes(tickfont=dict(size=14),title_font_size=14)
	fig.update_xaxes(tickangle=270) # if there are many values on the x axis: tickangle=270
	
	#  to position the legend inside, top left
	fig.update_layout(legend=dict(
    yanchor="top",
    y=0.99,
    xanchor="left",
    x=0.01
))
	
	#fig.write_image(join(wdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	
	
def plot_errors_covered_exceptions(wdir, spellcheck_file, outfile, exc_lists, exc_labels):
	"""
	Creates a grouped bar chart showing how many error tokens and types were covered by the
	various exception lists.
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	outfile (str): relative path to the output file (without filename extension)
	exc_lists (list): list of strings; relative paths (from the wdir) to the exception word lists
	exc_labels (list): list of strings; labels/exception list names to show in the plot
	"""
	
	print("Collecting values for exception lists...")
	
	y_tokens = []
	y_types = []
	for counter, exc_list in enumerate(exc_lists):
		num_tokens, num_types = interprete_exception_list_2(wdir, join(wdir, exc_list), join(wdir, spellcheck_file))
		#print(exc_labels[counter])
		#print(num_tokens)
		#print(num_types)
		y_tokens.append(num_tokens)
		y_types.append(num_types)
		
	# sort the values by tokens (descending)
	sorted_vals = sorted(zip(y_tokens, y_types, exc_labels), reverse=True)
	y_tokens = [i[0] for i in sorted_vals]
	y_types = [i[1] for i in sorted_vals]
	exc_labels = [i[2] for i in sorted_vals]
	
	"""
	# report the sums (for all exception lists)
	spellcheck_data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)
	total_error_tokens = spellcheck_data["sum"].sum()
	total_error_types = len(spellcheck_data["sum"])
	sum_exc_tokens = sum(y_tokens)
	sum_exc_types = sum(y_types)
	ratio_error_tokens = (sum_exc_tokens / total_error_tokens) * 100
	ratio_error_types = (sum_exc_types / total_error_types) * 100
	print("The exception lists covered " + str(sum_exc_tokens) + " error tokens in total (" + str(ratio_error_tokens) + " % of all the error tokens).")
	print("The exception lists covered " + str(sum_exc_types) + " error types in total (" + str(ratio_error_types) + " % of all the error types).")
	exit()
	"""

	fig = go.Figure(data=[
		go.Bar(name='tokens', x=exc_labels, y=y_tokens),
		go.Bar(name='types', x=exc_labels, y=y_types)
	])
	# Change the bar mode
	fig.update_layout(barmode='group',autosize=False,width=709,height=500,legend_font=dict(size=14))
	fig.update_layout(title=dict(text="Number of error tokens and types covered by exception lists",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=80, b=80, l=80, r=80),font=dict(family="Libertine, serif",color="#000000",size=14))
	fig.update_xaxes(tickfont=dict(size=14))
	fig.update_yaxes(title="number of tokens/types",tickfont=dict(size=14),title_font_size=14)
	
	
	#fig.write_image(join(wdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	print("done")
	
	
##########################################################################


def count_errors(wdir, spellcheck_file):
	"""
	Counts how many errors occur only once, twice, etc.
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	spellcheck_file (str): name of the csv file containing the spellcheck results, e.g. "spellcheck.csv"
	"""
	
	data = pd.read_csv(join(wdir, spellcheck_file), index_col=0, header=0)
	
	num_errors = data["sum"].sum()
	print("The total number of errors is " + str(num_errors))
	
	diff_errors = len(data["sum"])
	print("The total number of different errors is " + str(diff_errors))
	
	once = len(data.loc[data["sum"] == 1])
	print(str(once) + " errors occur only once.")
	
	
	more_than_10 = data.loc[data["sum"] > 10]
	types_more_than_10 = len(more_than_10)
	tokens_more_than_10 = more_than_10["sum"].sum()
	
	print(str(types_more_than_10) + " errors occur more than 10 times.")
	print(str(tokens_more_than_10) + " tokens are errors that occur more than 10 times.")


def generate_exception_list(wdir, input_list, error_list, outfile, mode):
	"""
	Generate corpus specific exception lists for the spellchecking.
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	input_list (str): path to a text file containing exception words retrieved from elsewhere (corpus external)
	error_list (str): path to the results from the spellcheck for the corpus
	outfile (str): filename for the output exception list
	mode (str): there are two different modes for the generation of exception lists: "full" and "ending". 
				"full" means that the items in the input exception list are full words, these are 
				extracted from the spellcheck result to generate the exception list. "ending" means
				that the items in the input exception list are patterns of word endings, e.g. "*.ito",
				which are applied to the spellcheck result list to extract the exception words.
				
	How to call this function:
	e.g. spellchecking.generate_exception_list(wdir, join(exdir, "capitals-es.txt"), join(wdir, "spellcheck.csv"), "exceptions-capitals.txt", "full"
	"""
	
	# read spellcheck result list, convert frame to list
	error_list = pd.read_csv(error_list, index_col=0, header=0)
	error_list = list(error_list.index)
	
	# read corpus external exception word/pattern list
	input_list = pd.read_csv(input_list, header=None)
	
	if mode == "full":
		# convert values in input_list to lower case, convert frame to list
		input_list = input_list.iloc[:,0].str.lower()
		input_list = list(input_list)
		
		# get values occurring in both lists
		intersection = set(input_list).intersection(error_list)
		# order alphabetically
		intersection = sorted(intersection)
		# save this as corpus specific exception list
		intersection = pd.DataFrame(intersection)
		intersection.to_csv(os.path.join(wdir, outfile), index=False, header=False)
		
		print("done: saved exception list")
		
		
	elif mode == "ending":
		# for each pattern: check which values from the error list match it
		input_list = list(input_list.iloc[:,0])
		
		all_matches = []
		
		for pattern in input_list:
			matches = list(filter(lambda x: re.match(str(pattern), str(x)), error_list))
			all_matches.extend(matches)
			
		all_matches = sorted(set(all_matches))
		
		# save the set of matches as a corpus specific exception list
		all_matches = pd.DataFrame(all_matches)
		all_matches.to_csv(os.path.join(wdir, outfile), index=False, header=False)
		
		print("done: saved exception list")
		
		
	else:
		print("Please indicate a valid mode: 'full' | 'ending'")
		
		
def interprete_exception_list(wdir, input_list, exception_list, error_list):
	"""
	Evaluate how many words were contained in an external exception word list, 
	how many words in the corresponding corpus-specific list and how many 
	error types and tokens from the spellcheck could be mapped that way
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	input_list (str): path to a text file containing exception words retrieved from elsewhere (corpus external)
	exception_list (str): path to the corpus specific exception list generated on the basis of the input list
	error_list (str): path to the results from the spellcheck for the corpus
	"""
	
	# read spellcheck result list
	error_list = pd.read_csv(error_list, index_col=0, header=0)
	
	# read corpus external exception word list
	input_list = pd.read_csv(input_list, header=None)
	# read corpus specific exception word list
	exception_list = pd.read_csv(exception_list, header=None)
	exception_list = list(exception_list.iloc[:,0])
	
	# how many percent of all the error types were covered by the exception list?
	total_error_types = len(error_list)
	total_error_tokens = error_list["sum"].sum()
	ratio_exception_types = (len(exception_list) / total_error_types) * 100
	# how many error tokens (absolute and relative) were covered by the exception list?
	
	# die zeilen rausfiltern mit den exception words, dann sum-Spalte summieren
	num_exception_tokens = error_list.filter(exception_list, axis=0)["sum"].sum()
	ratio_exception_tokens = (num_exception_tokens / total_error_tokens) * 100
	
	
	print("The input list contains " + str(len(input_list)) + " words.")
	print("The exception list contains " + str(len(exception_list)) + " words.")
	print("The exception list covers " + str(ratio_exception_types) + " % of all the error types.")
	print("The exception list covers " + str(num_exception_tokens) + " (" + str(ratio_exception_tokens) + " % of the) error tokens.")
	

def interprete_exception_list_2(wdir, exception_list, error_list):
	"""
	Evaluate how many tokens and types are covered by an exception word list.
	Returns the two sums.
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus"
	exception_list (str): path to the corpus specific exception list generated on the basis of the input list
	error_list (str): path to the results from the spellcheck for the corpus
	"""
	
	# read spellcheck result list
	error_list = pd.read_csv(error_list, index_col=0, header=0)
	
	# read corpus specific exception word list
	exception_list = pd.read_csv(exception_list, header=None)
	exception_list = list(exception_list.iloc[:,0])
	num_exception_types = len(exception_list)
	
	# how many error tokens were covered by the exception list?
	num_exception_tokens = error_list.filter(exception_list, axis=0)["sum"].sum()
	
	return num_exception_tokens, num_exception_types

##########################################################################

def get_text_lengths(wdir, inpath):
	"""
	Return the number of word tokens for each file in the corpus. Returns a series with CLiGS idnos as index.
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/"
	inpath (str): relative path to the directory containing the text files, including file name pattern, e.g. "txt/.*txt"
	"""
	
	# get list of file idnos
	idnos = []
	all_tokens = []
	for file in glob.glob(join(wdir, inpath)):
		idno_file = os.path.basename(file)[0:6]
		idnos.append(idno_file)
		
		with open(file, "r", encoding="utf-8") as infile:
			text =  infile.read()
			tokens = re.split(r"\W+", text, flags=re.MULTILINE)
			num_tokens = len(tokens)
			all_tokens.append(num_tokens)

	# create series
	text_lengths = pd.Series(data=all_tokens, index=idnos).sort_index()
	return text_lengths
	

def get_text_vocabulary_sizes(wdir, inpath):
	"""
	Return the number of word types for each file in the corpus. Returns a series with CLiGS idnos as index.
	
	@author: Ulrike Henny-Krahmer
	
	Arguments:
	wdir (str): path to the working directory, e.g. "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/"
	inpath (str): relative path to the directory containing the text files, including file name pattern, e.g. "txt/.*txt"
	"""
	
	# get list of file idnos
	idnos = []
	all_types = []
	for file in glob.glob(join(wdir, inpath)):
		idno_file = os.path.basename(file)[0:6]
		idnos.append(idno_file)
		
		with open(file, "r", encoding="utf-8") as infile:
			text =  infile.read()
			counter = collections.Counter()
			
			for token in re.split(r"\W+", text, flags=re.MULTILINE):
				counter[token] += 1
				
			num_types = len(set(counter.elements()))
			all_types.append(num_types)

	# create series
	vocab_sizes = pd.Series(data=all_types, index=idnos).sort_index()
	return vocab_sizes

##########################################################################

"""
def main(inpath, outpath, lang, wordFiles, errFolder, corrFolder, substFile):
    check_collection(inpath, outpath, lang, wordFiles)
    correct_words(errFolder, corrFolder, substFile)
    
if __name__ == "__main__":
    check_collection(int(sys.argv[1]))
    correct_words(int(sys.argv[1]))
"""

