#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: verbs_enclitics.py

"""
@author: Ulrike Henny-Krahmer

Analyze verbs with enclitic pronouns in the corpus.
"""

from os.path import join
import glob
import pandas as pd
import plotly.graph_objects as go
import re
from lxml import etree
import csv


def collect_enclitics_freeling(wdir, inpath, patterns, exceptions, outfile):
	"""
	For the corpus of TEI files with linguistic annotation, check which tokens per novel 
    still match the patterns of verb forms with enclitic pronouns.
    Produce an XML file containined the matches per novel (for further analysis).
	
	Arguments:
	wdir (str): path to the working directory
	inpath (str): relative path to the input files (linguistically annotated TEI corpus files)
	patterns (str): relative path to the CSV file containing regex patterns to match verbs with enclitic pronouns
	exceptions (str): relative path to a list of exception words (words that should not be treated as verbs with enclitic pronouns)
	outfile (str): relative path to the output XML file for the words that match the patterns
	"""
	print("count enclitics freeling...")
	
	# read regex patterns
	patterns = pd.read_csv(join(wdir, patterns), header=None)
	patterns = patterns.iloc[:,0].tolist()
	pattern = "|".join(patterns)
	
	# read exception word list
	exceptions = pd.read_csv(join(wdir, exceptions), header=None)
	exceptions = exceptions.iloc[:,0].tolist()
	
	
	with open(join(wdir,outfile), "w", encoding="UTF-8") as outf:
		outf.write('<?xml version="1.0" encoding="UTF-8"?>')
		outf.write('<div xmlns="http://www.tei-c.org/ns/1.0" xmlns:cligs="https://cligs.hypotheses.org/ns/cligs">')
	
		# go through the TEI files
		for filepath in glob.glob(join(wdir, inpath, "*.xml")):
			filename = filepath[-10:]
			print("doing " + filename + "...")
			idno = filename[:-4]
			outf.write('<ab xml:id="' + idno + '">\n')
			
			# look for words that match the enclitic verb form patterns and write them to the output file
			with open(filepath, "r", encoding="UTF-8") as infile:
				for line in infile.readlines():
					
					cligs_form = re.sub(r"<w.*>([\w_]+)</w>", r"\1", line).lower().strip()
					
					if line[0:2] == "<w" and re.match(pattern, cligs_form) is not None:
						# check for exceptions
						if cligs_form not in exceptions:
							outf.write(line)
			
			outf.write('</ab>\n')
			
		outf.write('</div>')
		
	
	print("done")
	
	
def check_enclitics_freeling(wdir, infile, outfile):
	"""
	create a list of the set of different enclitics still found as tokens in the freeling annotation
	sort it alphabetically
	the list can be inspected to look for exception words
	
	Arguments:
	wdir (str): path to the working directory
	infile (str): relative path to the input XML file containing the list of words in the freeling output that match the enclitic patterns
	outfile (str): relative path to the output file for the enclitic vocabulary
	"""
	print("checking enclitics of freeling output....")
	
	namespaces = {'tei':'http://www.tei-c.org/ns/1.0', 'cligs':"https://cligs.hypotheses.org/ns/cligs"}
	xml = etree.parse(join(wdir,infile))
	words = xml.xpath("//@cligs:form", namespaces=namespaces)
	
	df = pd.DataFrame(data=words).groupby(by=0).size().reset_index(name="counts").sort_values(by="counts", ascending=False)
	df.to_csv(join(wdir, outfile), index=False)
	
	print("done")


def analyze_enclitics_freeling(wdir, md, infile, outfile):
	"""
	Count the matches of verbs with enclitic pronouns, and count how many have been tagged as different parts of speech. 
    For nouns, check proper vs. common.
    Produce a CSV file with the counts per novel.
    
    Arguments:
    wdir (str): path to the working directory
    md (str): relative path to the metadata file containing the novels' identifiers
    infile (str): relative path to the XML file containing the enclitic verb form matches
    outfile (str): relative path to the output CSV file for the counts
	"""
	print("analyze enclitics freeling...")
	
	pos = ["adjective", "conjunction", "determiner", "noun", "pronoun", "adverb", "adposition", "verb", "number", "date", "interjection"]
	pos_type = ["common", "proper"]
	
	md = pd.read_csv(join(wdir, md), index_col=0)
	idnos = md.index
	
	# read XML input
	namespaces = {'tei':'http://www.tei-c.org/ns/1.0', 'cligs':"https://cligs.hypotheses.org/ns/cligs"}
	xml = etree.parse(join(wdir,infile))
	
	# prepare df for results
	columns = ["enclitics"] + pos + pos_type
	df = pd.DataFrame(index=idnos, columns=columns)
	
	# count for each novel and add to result frame
	for idno in idnos:
		print("count for " + idno + "...")
		enclitics = xml.xpath("//tei:ab[@xml:id='" + idno + "']/tei:w", namespaces=namespaces)
		df.loc[idno,"enclitics"] = len(enclitics)
		
		for p in pos:
			pos_match = xml.xpath("//tei:ab[@xml:id='" + idno + "']/tei:w[@pos='" + p + "']", namespaces=namespaces)
			df.loc[idno,p] = len(pos_match)
		for pt in pos_type:
			pt_match = xml.xpath("//tei:ab[@xml:id='" + idno + "']/tei:w[@pos='noun'][@type='" + pt + "']", namespaces=namespaces)
			df.loc[idno,pt] = len(pt_match)
	
	# save results
	df.to_csv(join(wdir, outfile))
	
	print("done")


def visualize_enclitics_freeling(wdir, md, infile, outfile):
	"""
	Plot the counts of how verbs with enclitic pronouns have been tagged by FreeLing.
	(1) make a pie chart showing how enclitic verbs that remained in the forms have been classified by freeling
	(2) make a box plot showing how many forms have been classified as what in the novels (relative to text length)
	
	Arguments:
    wdir (str): path to the working directory
    md (str): relative path to the corpus metadata file containing information about text length in tokens
    infile (str): relative path to the CSV file containing the enclitic verb forms counts for FreeLing
    outfile (str): relative path to the output files for the visualization (without file name extension)
	"""
	print("visualize enclitics freeling...")
	
	# read input data
	counts = pd.read_csv(join(wdir, infile), index_col=0)
	counts_pos = counts.drop(["enclitics", "noun"], axis=1)
	counts_pos = counts_pos.rename(columns={"common":"common_nouns", "proper":"proper_nouns"})
	counts_sums = counts_pos.sum()
	
	# read metadata
	md = pd.read_csv(join(wdir, md), index_col=0)
	
	# create pie plot
	labels = list(counts_pos.columns)
	values = counts_sums.tolist()
	
	# take out the zero values for certain pos
	zero_positions = [idx for idx,val in enumerate(values) if val == 0]
	for idx,z in enumerate(zero_positions):
		z = z - idx
		labels.pop(z)
		values.pop(z)
	
	
	fig = go.Figure(data=[go.Pie(labels=labels, values=values, hole=.4, direction="clockwise")])
	fig.update_layout(autosize=False, width=709, height=400)
	fig.update_layout(title=dict(text="FreeLing POS of verb forms with enclitic pronouns",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=90, l=120, r=290),font=dict(family="Libertine, serif",color="#000000",size=14))
	
	
	#fig.write_image(join(wdir, outfile + "_pie.png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + "_pie.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	# create box plot
	counts = counts.rename(columns={"common":"common_nouns","proper":"proper_nouns"})
	
	fig = go.Figure()
	# add a trace for each pos
	for label in labels:
		# get data for this pos
		data = counts[label]
		# divide by text lengths
		data = data / md["tokens"]
		fig.add_trace(go.Box(y=data, name=label, 
		boxpoints="all", # can also be outliers, or suspectedoutliers, or False
		jitter=0.3, # add some jitter for a better separation between points
		pointpos=-1.8)) # relative position of points wrt box
	
	fig.update_layout(autosize=False, width=709, height=600, yaxis_title="number of POS assignments (relative)",showlegend=False)
	fig.update_layout(title=dict(text="FreeLing POS of verb forms with enclitic pronouns",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=90, l=100, r=30),font=dict(family="Libertine, serif",color="#000000",size=14))
	
	fig.update_xaxes(tickfont=dict(size=14),tickangle=270)
	fig.update_yaxes(tickfont=dict(size=14),title_font_size=14)
	
	
	#fig.write_image(join(wdir, outfile + "_box.png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + "_box.html")) # include_plotlyjs="cdn" (don't include whole plotly library)
	
	#fig.show()
	
	
	print("done")


def count_enclitics(wdir, inpath, patterns, out_csv, md, exceptions):
	"""
	count the number of verb forms with enclitic pronouns in the full text files of the corpus
	save the results as absolute and relative counts
	
	Arguments:
	wdir (str): path to the working directory
	inpath (str): relative path to the corpus of plain text files
	patterns (str): relative path to the list of regex patters for enclitic detection
	out_csv (str): relative path to the CSV output file
	md (str): relative path to the metadata file containing information about text length in tokens
	exceptions (str): relative path to a list of exception words that are not verb forms with enclitic pronouns
	"""
	print("count enclitics...")

	# get metadata
	md = pd.read_csv(join(wdir, md), index_col=0)

	# load patterns as a list
	patterns = pd.read_csv(join(wdir, patterns), header=None)
	patterns = patterns.iloc[:,0].tolist()
	# load exceptions
	exceptions = pd.read_csv(join(wdir, exceptions), header=None)
	exceptions = exceptions.iloc[:,0].tolist()

	# create data frame for results
	df = pd.DataFrame(columns=["enclitics_abs","enclitics_rel"])

	# read text files and check for verbs with enclitic pronouns
	for filepath in glob.glob(join(wdir, inpath, "*.txt")):
		filename = filepath[-10:]
		
		print("doing " + filename + "...")
		
		idno = filename[:-4]
		num_enclitics = 0
		
		with open(filepath, "r", encoding="UTF-8") as infile:
			text = infile.read()
			for pat in patterns:
				results = re.findall(pat, text)
				# join tuples of resulting groups
				results = ["".join(i) for i in results]
				results = [i.lower() for i in results]
				results = [i for i in results if i not in exceptions]
				num_enclitics += len(results)
				
			
		# get number relative to text length
		text_length = md.loc[idno,"tokens"]
		rel_enclitics = num_enclitics / text_length
		
		print(num_enclitics, rel_enclitics)
		# store results in frame
		df.loc[idno] = [num_enclitics, rel_enclitics]
		

	# save frame to csv
	df = df.sort_index()
	df.to_csv(join(wdir, out_csv))

	print("done")
		
	
	
def plot_enclitics(wdir, data, outfile):
	"""
	create a box plot showing proportions of verb forms with enclitic pronouns in the novels
	
	Arguments:
	
	wdir (str): path to the working directory
	data (str): relative path to the input file with verb form counts
	outfile (str): relative path to the output file for the plot (without file name extension)
	"""
	
	print("plot enclitics...")
	
	data = pd.read_csv(join(wdir, data), index_col=0)
	data = data["enclitics_rel"].tolist()
	
	fig = go.Figure(data=[go.Box(y=data,
			name="novels",
            boxpoints='all', # can also be outliers, or suspectedoutliers, or False
            jitter=0.3, # add some jitter for a better separation between points
            pointpos=-1.8 # relative position of points wrt box
              )])
	
	fig.update_layout(autosize=False, width=709, height=600, yaxis_title="verb forms with enclitic pronouns (relative)")
	fig.update_layout(title=dict(text="Verb forms with enclitic pronouns in the novels",xanchor="center",yanchor="top",y=0.95,x=0.5,font=dict(size=16)))
	fig.update_layout(margin=dict(t=120, b=90, l=180, r=150),font=dict(family="Libertine, serif",color="#000000",size=14))
	
	fig.update_xaxes(tickfont=dict(size=14),title_font_size=14)
	fig.update_yaxes(tickfont=dict(size=14),title_font_size=14)
	
	#fig.write_image(join(wdir, outfile + ".png")) # scale=2 (increase physical resolution)
	fig.write_html(join(wdir, outfile + ".html")) # include_plotlyjs="cdn" (don't include whole plotly library)

	#fig.show()

	print("done")
	
	
def correct_enclitics_freeling(wdir, inpath, patterns, exceptions, accents, outpath):
	""" 
	Correct the POS annotation of verb forms with enclitic pronouns that remained in the FreeLing output
	
	Example:
	<w cligs:form="descubríase" lemma="descubríase" cligs:tag="NCFS000" cligs:ctag="NC" pos="noun" type="common" cligs:gen="feminine" cligs:num="singular" cligs:wnsyn="xxx" cligs:wnlex="xxx">descubríase</w>
	is replaced with:	
	<w cligs:form="descubría" lemma="descubría" pos="verb">descubría</w>
	<w cligs:form="se" lemma="se" pos="pronoun">se</w>
	
	Arguments:
	wdir (str): path to the working directory
	inpath (str): relative path to the input files (TEI with FreeLing annotation)
	patterns (str): relative path to the file with regex patterns for enclitics
	exceptions (str): relative path to a list of exception words that are not verb forms with enclitic pronouns
	accents (str): relative path to a list containing accent patterns (for accent replacements after splitting the enclitic verb forms) 
	outpath (str): relative path for the corrected output files
	"""
	print("correcting enclitics...")
	
	# load patterns as a list
	patterns = pd.read_csv(join(wdir, patterns), header=None)
	patterns = patterns.iloc[:,0].tolist()
	pattern = "|".join(patterns)
	# load exceptions
	exceptions = pd.read_csv(join(wdir, exceptions), header=None)
	exceptions = exceptions.iloc[:,0].tolist()
	# load accent patterns into a dictionary
	with open(join(wdir, accents), mode='r', encoding="UTF-8") as infile:
		reader = csv.reader(infile)
		accents = {rows[0]:rows[1] for rows in reader}
        
	
	for filepath in glob.glob(join(wdir, inpath, "*.xml")):
		filename = filepath[-10:]
		idno = filename[:-4]
		outfile_path = join(wdir, outpath, filename)
		print("doing " + filename + "...")
		
		# read the lines and look for matches
		# look for words that match the enclitic verb form patterns
		with open(filepath, "r", encoding="UTF-8") as infile:
			with open(outfile_path, "w", encoding="UTF-8") as outfile:
			
				for line in infile.readlines():
					
					cligs_form = re.sub(r"<w.*>([\w_]+)</w>", r"\1", line).lower().strip()
					
					if line[0:2] == "<w" and re.match(pattern, cligs_form) is not None:
						# check for exceptions
						if cligs_form not in exceptions:
							# here we have a match that needs to be corrected
							# check which pattern applies (use only the first matching patterns), split the form and create new word entries
							for p in patterns:
								if re.match(p, cligs_form) is not None:
									
									# go through the matching groups
									# the first one is always the verb form, the rest are enclitic pronouns
									# copy the new lines to the output file
									for idx,m in enumerate(re.match(p, cligs_form).groups()):
										if idx == 0:
											# check the first group for the accent pattern
											for i in accents:
												
												if m.endswith(i):
													m = re.sub(i, accents[i], m)
													break
													
											new_line = '<w cligs:form="' + m + '" lemma="' + m + '" pos="verb">' + m + '</w>\n'
											outfile.write(new_line)
										else:
											new_line = '<w cligs:form="' + m + '" lemma="' + m + '" pos="pronoun">' + m + '</w>\n'
											outfile.write(new_line)
									break
									
								
								
						# if it is an exception, copy the line as is
						else:
							outfile.write(line)
					# if the word does not match a pattern, copy the line as is
					else:
						outfile.write(line)
		
		
	print("done")


#count_enclitics("/home/ulrike/Git/", "conha19/txt", "data-nh/corpus/derivative-formats/verb-form-patterns-es-detail.txt", "data-nh/corpus/derivative-formats/verbs_enclitics_in_files.csv", "conha19/metadata.csv", "data-nh/corpus/derivative-formats/verbs-enclitics-exceptions.txt")

#plot_enclitics("/home/ulrike/Git", "data-nh/corpus/derivative-formats/verbs_enclitics_in_files.csv", "data-nh/corpus/derivative-formats/verbs_enclitics_box")

#collect_enclitics_freeling("/home/ulrike/Git/", "conha19/annotated/", "data-nh/corpus/derivative-formats/verb-form-patterns-es.txt", "data-nh/corpus/derivative-formats/verbs-enclitics-exceptions.txt", "data-nh/corpus/derivative-formats/verbs-enclitics-freeling-matches.xml")

#check_enclitics_freeling("/home/ulrike/Git/", "data-nh/corpus/derivative-formats/verbs-enclitics-freeling-matches.xml", "data-nh/corpus/derivative-formats/verbs-enclitics-freeling-vocab.csv")

#analyze_enclitics_freeling("/home/ulrike/Git", "conha19/metadata.csv", "data-nh/corpus/derivative-formats/verbs-enclitics-freeling-matches.xml", "data-nh/corpus/derivative-formats/verbs-enclitics-freeling.csv")

visualize_enclitics_freeling("/home/ulrike/Git", "conha19/metadata_all.csv", "data-nh/corpus/derivative-formats/verbs-enclitics-freeling.csv", "data-nh/corpus/derivative-formats/plot-verbs-enclitics-freeling")

#correct_enclitics_freeling("/home/ulrike/Git", "conha19/annotated/", "data-nh/corpus/derivative-formats/verb-form-patterns-es-detail.txt", "data-nh/corpus/derivative-formats/verbs-enclitics-exceptions.txt", "data-nh/corpus/derivative-formats/verb-form-endings-accents.txt", "conha19/annotated_corr")


