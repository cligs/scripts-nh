#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Filename: words-per-page.py

"""
@author: Ulrike Henny-Krahmer
"""

import os
import glob
from lxml import etree
import re
import pandas as pd
import random


def get_page_numbers(wdir, num_texts, num_pages):
	"""
	Select X random pages (num_pages) from Y texts (num_texts) from the bibliography, in order to determine the average word number per page.
	Creates a csv file with a list of edition ids and page numbers.
	
	Example call: get_page_numbers("/home/ulrike/Git/bibacme/app/data/", 50, 2)
	
	Arguments:
	
	wdir (str): path to the working directory
	num_texts (int): number of different texts from which to extract page numbers
	num_pages (int): number of pages to extract per text
	
	"""
	namespaces = {'tei':'http://www.tei-c.org/ns/1.0'}
	infile = os.path.join(wdir, "editions.xml")
	xml = etree.parse(infile)
	# select all monographs for which there are page numbers and a link to a digitized text (ref), only the first available edition of each work (@corresp), 
	xpath = "//tei:biblStruct[not(tei:analytic)][tei:ref][tei:monogr/tei:extent/@n][not(@corresp = ./preceding::tei:biblStruct[not(tei:analytic)][tei:ref][tei:monogr/tei:extent/@n]/@corresp)]"
	results = xml.xpath(xpath, namespaces=namespaces)
	
	print(str(len(results)) + " texts found")
	
	random_pages = pd.DataFrame(columns=["edition_id", "page"])
	
	if len(results) < num_texts:
		raise ValueError("Error: the chosen number of texts is higher than the number of available editions.")
	
	for e in range(num_texts):
		res = results[e]
		edition_id = res.xpath("@xml:id", namespaces=namespaces)
		pages = res.xpath("tei:monogr/tei:extent/@n", namespaces=namespaces)
		
		for p in range(num_pages):
			rand_page = random.randint(1, int(pages[0]))
			s = pd.Series([edition_id[0], rand_page], index=["edition_id", "page"])
			random_pages = random_pages.append(s, ignore_index=True)
			
	outfile = "random-pages.csv"
	random_pages.to_csv(os.path.join(wdir, outfile), sep=",", encoding="utf-8")
	print("Done!")
	

def get_words_per_page(wdir, infile):
	"""
	Calculate the word number per page. Incomplete words on page beginnings or endings are counted as a whole word.
	
	Based on the csv file with a list of edition ids and page numbers created with get_page_numbers(), an XML file 
	containing the full text of the selected pages was created (pages-text.xml), which is used as input file here.
	
	A box plot displaying the word numbers per page is created as output.
	
	Arguments:
	
	wdir (str): path to the working directory
	infile (str): relative path to the XML file containing the pages' text
	"""
	
	infile = os.path.join(wdir, infile)
	xml = etree.parse(infile)
	pages = xml.xpath("//page")
	
	words_per_page = []
	
	# count words per page
	for i,page in enumerate(pages):
		filename = "page_" + str(i) + ".txt"
		pagetext = page.xpath(".//text()")
		pagetext = "\r".join(pagetext)
		
		tokens = re.split(r"\W+", pagetext, flags=re.MULTILINE)
		
		num_words = len(tokens)
		words_per_page.append(num_words)
		
	# draw chart
	chart_html_1 = """
	<html>
		<head>
			<!-- Plotly.js -->
			<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
		</head>
		<body>
			<!-- Plotly chart will be drawn inside this DIV -->
			<div id="myDiv" style="width: 500px; height: 500px;"></div>
			<script>
				var data = [
				{
				y: [
	""" 
	data = ",".join([str(x) for x in words_per_page]) 
	chart_html_2 = """
				],
				boxpoints: 'all',
				jitter: 1,
				pointpos: -2,
				type: 'box',
				name: 'pages'
				}
				];
				
				layout = {
				yaxis: {
				dtick: 50,
				title: 'number of words'
				}
				};
				
				
				Plotly.newPlot('myDiv', data, layout);
			</script>
		</body>
	</html>
	"""
	chart_html = chart_html_1 + data + chart_html_2
	
	outfile = os.path.join(wdir, "words-per-page.html")
	with open(outfile, "w") as output:
		output.write(chart_html)
	
	print("done")
	


#get_page_numbers("/home/ulrike/Git/bibacme/app/data/", 50, 2)
#get_words_per_page("/home/ulrike/Git/data-nh/corpus/", "pages-text.xml")


