#!/usr/bin/env python3
# file name: dh2018.py

"""
@author: Ulrike Henny-Krahmer
"""
import sys
import os

sys.path.append(os.path.abspath("/home/ulrike/Git/"))
sys.path.append(os.path.abspath("/home/ulrike/Programme/FreeLing-4.0/APIs/python"))

from toolbox.check_quality import spellchecking
from toolbox.annotate import annotate_fw
from toolbox.annotate import prepare_tei
from toolbox.extract import read_tei

import re
import glob
from lxml import etree
import pandas as pd
import subprocess
import numpy as np
import pygal
import freeling
import matplotlib.pyplot as plt

from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.tree import export_graphviz
from sklearn.model_selection import cross_val_score
import graphviz



def get_metadata(wdir, corpus_folder, md_file):
    """
    Extracts metadata from the CLiGs teiHeader and writes it to CSV.
    This function is a customization of the CLiGS toolbox extract/get_metadata.py module written by Christof Schöch.

	Arguments:
	wdir (str): working directory
	corpus_folder (str): name of the corpus folder in the wdir
	md_file (str): name of the metadata file to write
    """

    # metadata items to extract
    labels = ["idno", "author-name", "title", "author-gender", "author-country", "narrative-perspective", "genre", "subgenre-title-norm", "subgenre-interp", "publication-country", "year"]
    
    ## Dictionary of all relevant xpaths with their labels
    xpaths = {
			  "idno": '//tei:idno[@type="cligs"]//text()',
              "author-name": '//tei:author//tei:name[@type="short"]//text()',
              "title": '//tei:title[@type="short"]//text()',
              "author-gender":'//tei:term[@type="author-gender"]//text()',
              "author-country": '//tei:term[@type="author-country"]//text()',
              "narrative-perspective": '//tei:term[@type="narrative-perspective"]//text()',
              "genre": '//tei:term[@type="genre"]//text()',
              "subgenre-title-norm":'//tei:term[@type="subgenre-title-norm"]//text()',
              "subgenre-interp":'//tei:term[@type="subgenre-interp"][@subtype > parent::tei:keywords/tei:term[@type="subgenre-interp"]/@subtype or not(parent::tei:keywords/tei:term[@type="subgenre-interp"][2])]//text()',
              "publication-country":'//tei:term[@type="publication-country"]//text()',
              "year":'//tei:bibl[@type="edition-first"]//tei:date//text()'
              }

            
    namespaces = {'tei':'http://www.tei-c.org/ns/1.0'}
    idnos = []
    
    ## Get list of file idnos and create empty dataframe
    for file in glob.glob(os.path.join(wdir, corpus_folder, "*.xml")):
        idno_file = os.path.basename(file)[0:6]
        idnos.append(idno_file)
    metadata = pd.DataFrame(columns=labels, index=idnos)
    #print(metadata)

    ## For each file, get the results of each xpath
    for file in glob.glob(os.path.join(wdir, corpus_folder, "*.xml")):
        #print(file)
        xml = etree.parse(file)
        ## Before starting, verify that file idno and header idno are identical.
        idno_file = os.path.basename(file)[0:6]
        idno_header = xml.xpath(xpaths["idno"], namespaces=namespaces)[0]
        if idno_file != idno_header: 
            print("Error: "+ idno_file+ " = "+idno_header)
        for label in labels:
            xpath = xpaths[label]
            result = xml.xpath(xpath, namespaces=namespaces)
            
            ## Check whether something was found; if not, let the result be "n.av."
            if len(result) == 1: 
                result = result[0]
            else: 
                result = "n.av."
            
            ## Write the result to the corresponding cell in the dataframe
            metadata.loc[idno_file,label] = result
        
    ## Add decade column based on pub_year
    metadata["decade"] = metadata["year"].map(lambda x: str(x)[:-1]+"0")
    
    ## Check result and write CSV file to disk.
    #print(metadata.head())
    metadata=metadata.sort_values(by="idno",ascending=True)  
    metadatafile= md_file+".csv"
    metadata.to_csv(os.path.join(wdir, md_file), sep=",", encoding="utf-8")
    print("Metadata extracted. Number of documents and metadata columns:", metadata.shape)
    
 
def annotate_paragraphs(wdir, corpus_folder):
    """
    Annotate TEI paragraphs of input files with Freeling. Store an output file for each paragraph. 
    Keep information if the paragraph contains direct speech or not.
    
    Arguments:
    wdir (str): working directory
    corpus_folder (str): name of the corpus folder in the wdir
    """
    
    for file in glob.glob(os.path.join(wdir, corpus_folder, "*.xml")):
        xml = etree.parse(file)
        idno_file = os.path.basename(file)[0:6]
        print("doing " + idno_file + "...")
        
        namespaces = {'tei':'http://www.tei-c.org/ns/1.0'}
        paras = xml.xpath("//tei:body//tei:p", namespaces=namespaces)
        
        for idx,p in enumerate(paras):
            p_text = p.xpath(".//text()", namespaces=namespaces)
            p_text = " ".join(p_text)
            p_text = re.sub(r"[\s\n]+", r" ", p_text)
            
            textfile_name = idno_file + "_p_" + str(idx) + ".txt"
            textfile_path = os.path.join(wdir, "p_txt", textfile_name)
            
            with open(textfile_path, "w", encoding="utf-8") as textfile:
                textfile.write(p_text)
            
            p_speech = p.xpath("boolean(.//tei:said)", namespaces=namespaces)
            
            outfile_name = idno_file + "_p_" + str(idx) + "_sp_" + str(p_speech) + ".xml"
            outfile_path = os.path.join(wdir, "fl_anno", outfile_name)
            
            Command = "analyze -f es.cfg --outlv dep --sense ukb --output xml < " + textfile_path + " > " + outfile_path
            subprocess.call(Command, shell=True)
    print("Done!")


    
def split_paragraphs(wdir, corpus_folder):
    """
    Split annotated paragraphs into sentences.
    
    Arguments:
    wdir (str): working directory
    corpus_folder (str): name of the corpus folder in the wdir
    """
    for file in glob.glob(os.path.join(wdir, corpus_folder, "*.xml")):
        file_name = os.path.basename(file)
        print("doing " + file_name + "...")
		
        with open(file, "r", encoding="utf-8") as infile:
            intext = infile.read()
            insents = re.split(r"sentence>\n<sentence", intext)
            num_sents = len(insents)
            
            for idx,s in enumerate(insents):
                 outfile_name = os.path.basename(file)[:-4] + "_s" + str(idx) + ".xml"
                 outfile_path = os.path.join(wdir, "annotated_sentences", outfile_name)
                 if num_sents > 1:
                     if (idx == 0):
                         s = s + "sentence>"
                     elif (idx == (num_sents - 1)):
                         s = "<sentence" + s
                     else:
                         s = "<sentence" + s + "sentence>"
                 
                 with open(outfile_path, "w", encoding="utf-8") as newfile:
                     newfile.write(s)
    
    print("Done!")
    
	
    """
    xml = etree.parse(file)
    sentences = xml.xpath("//sentence")
    
    for idx,s in enumerate(sentences):
        outfile_name = os.path.basename(file)[:-4] + "_s_" + str(idx) + ".xml"
        print(outfile_name)
        exit()
        
        outfile_path = os.path.join(wdir, "annotated_sentences", outfile_name)
        with open(outfile_path, "w", encoding="utf-8") as newfile:
            newfile.write(s)
	"""
    
    
def get_speech_proportions(wdir, corpus_folder, md_file):
    """
    Extracts proportions of direct speech vs. narrator speech. Results are saved as a CSV file and as a column chart.
    @author: uhk

	Arguments:
	wdir (str): working directory
	corpus_folder (str): name of the corpus folder in the wdir
	md_file (str): name of the metadata file to write
    """
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = md.index
    
    fr = pd.DataFrame(columns=["words-total", "words-speech", "speech-rate"], index=idnos)
    
    for file in glob.glob(os.path.join(wdir, corpus_folder, "*.xml")):
        xml = etree.parse(file)
        idno_file = os.path.basename(file)[0:6]
        print("doing " + idno_file + "...")
        
        namespaces = {'tei':'http://www.tei-c.org/ns/1.0'}
        chapters = xml.xpath("//tei:div[@type='chapter']", namespaces=namespaces)
       
        num_words_speeches = 0
        num_words_total = 0
       
        for ch in chapters:
            ch_speech = ch.xpath(".//tei:said", namespaces=namespaces)
            #print(len(ch_speech))
            
            for sp in ch_speech:
                sp_text = sp.xpath(".//text()", namespaces=namespaces)
                sp_text = " ".join(sp_text)
                sp_text = re.sub(r"[\s\n]+", r" ", sp_text)
                num_words_sp = len(sp_text.split())
                num_words_speeches += num_words_sp
            
            ch_text = ch.xpath(".//text()", namespaces=namespaces)
            ch_text = " ".join(ch_text)
            ch_text = re.sub(r"[\s\n]+", r" ", ch_text)
            num_words_ch = len(ch_text.split())
            num_words_total += num_words_ch
                 
        
        fr.loc[idno_file,"words-total"] = num_words_total
        fr.loc[idno_file,"words-speech"] = num_words_speeches
        fr.loc[idno_file,"speech-rate"] = num_words_speeches / num_words_total
     
    fr.to_csv(os.path.join(wdir, "speech.csv"), sep=",")
          
    print("Done!")
    
    
    
def spellcheck_nrc_lex(wdir):
    """
    Check the Spanish version of the NRC Emotion Lexicon for spelling errors.
    
    Arguments:
	wdir (str): working directory
    """
    nrc = pd.read_csv(os.path.join(wdir, "NRC-Emotion-Lexicon-v0.92-EN-ES.csv"), sep=",")
    nrc_es = nrc.Spanish
    nrc_es.to_string(os.path.join(wdir, "NRC-ES.txt"), index=False, header=False)
    
    spellchecking.check_collection(os.path.join(wdir, "NRC-ES.txt"), os.path.join(wdir, "spellcheck.csv"), "es", [])

    print("Done!")



########################################################
# analyze sentiments
########################################################


def analyze_sentiments(wdir, corpus_folder):
    """
    Analyze the annotated sentences. Are they neutral or emotional?
    If they are emotional, positive or negative?
    Using NRC, and SentiWordNet.
    
    Arguments:
	wdir (str): working directory
	corpus_folder (str): name of the corpus folder in the wdir
    """
    
    sentiWN = pd.read_csv(os.path.join(wdir, "sentiments", "SentiWordNet_3.0.0_20130122.txt"), sep="\t")
    nrc = pd.read_csv(os.path.join(wdir, "sentiments", "NRC-Emotion-Lexicon-v0.92-EN-ES.csv"), sep=",")
    
    
    file_list = [os.path.basename(f) for f in glob.glob(os.path.join(wdir, corpus_folder, "*.xml"))]
    
    fr = pd.DataFrame(index=file_list, columns=["text_idno", "p_num", "s_num", "speech", "WN_emotional", "WN_positive", "WN_negative", "WN_emotion_sum", 
    "NRC_emotional", "NRC_positive", "NRC_negative", "NRC_emotion_sum", "NRC_Anger", "NRC_Anticipation", "NRC_Disgust", "NRC_Fear", "NRC_Joy", "NRC_Sadness", "NRC_Surprise", "NRC_Trust",
    "WN_synsets_identified", "NRC_lemmata_identified"])
    
    idnos = []
    p_nums = []
    s_nums = []
    speech = []
    WN_emotional = []
    WN_positive = []
    WN_negative = []
    WN_emotion_sum = []
    NRC_emotional = []
    NRC_positive = []
    NRC_negative = []
    NRC_emotion_sum = []
    NRC_Anger = []
    NRC_Anticipation = []
    NRC_Disgust = []
    NRC_Fear = []
    NRC_Joy = []
    NRC_Sadness = []
    NRC_Surprise = []
    NRC_Trust = []
    WN_synsets_identified = []
    NRC_lemmata_identified = []
    
    
    for file in glob.glob(os.path.join(wdir, corpus_folder, "*.xml")):
        # file name pattern: nh0001_p_0_sp_False_s1.xml
        
        file_name = os.path.basename(file)
        print("doing " + file_name + "...")
        idno = file_name[0:6]
        p_num = re.sub(r"^.*p_(\d+)_.*$", r"\1", file_name)
        s_num = re.sub(r"^.*_s(\d+)\.xml", r"\1", file_name)
        sp = re.sub(r"^.*sp_(True|False)_.*$", r"\1", file_name)
        
        idnos.append(idno)
        p_nums.append(p_num)
        s_nums.append(s_num)
        speech.append(sp)
        
        xml = etree.parse(file)
        wn_tokens = xml.xpath("//token[@wn]/@wn")
        lemmata = xml.xpath("//token/@lemma")
        
        # SentiWordNet
        WN_pos_score = 0
        WN_neg_score = 0
        WN_synsets_identified_sentence = []
        
        for wn_t in wn_tokens:
            wn_num = int(wn_t[0:8])
            wn_pos = wn_t[9]
            
            WN_pos = sentiWN.loc[sentiWN.ID == wn_num][sentiWN.POS == wn_pos]["PosScore"]
            WN_neg = sentiWN.loc[sentiWN.ID == wn_num][sentiWN.POS == wn_pos]["NegScore"]
            
            if not(WN_pos.empty):
                WN_pos_score += WN_pos.iloc[0]
            else:
                print("Error: WN ID " + str(wn_num) + " not found!")
                
            if not(WN_neg.empty):
                WN_neg_score += WN_neg.iloc[0]
            else:
                print("Error: WN ID " + str(wn_num) + " not found!")
                
            if not(WN_pos.empty) or not(WN_neg.empty):
                WN_synsets_identified_sentence.append(wn_t)
                
            
        if WN_pos_score > 1 or WN_neg_score > 1: # Schwelle für Emotionalität
            WN_emotional.append(1)
        else:
            WN_emotional.append(0) 
        WN_emotion_sum.append(WN_pos_score - WN_neg_score)
        
        WN_synsets_identified.append(",".join(WN_synsets_identified_sentence))
            
        WN_positive.append(WN_pos_score)
        WN_negative.append(WN_neg_score)
        
        # NRC Emotion Lexicon
        NRC_pos_score = 0
        NRC_neg_score = 0
        NRC_Anger_score = 0
        NRC_Anticipation_score = 0
        NRC_Disgust_score = 0
        NRC_Fear_score = 0
        NRC_Joy_score = 0
        NRC_Sadness_score = 0
        NRC_Surprise_score = 0
        NRC_Trust_score = 0
        NRC_lemmata_identified_sentence = []
        
        for l in lemmata:
            NRC_l = nrc.loc[nrc.Spanish == l]
            
            if not(NRC_l.empty):
                NRC_pos_score += NRC_l["Positive"].iloc[0]
                NRC_neg_score += NRC_l["Negative"].iloc[0]
            
                NRC_Anger_score += NRC_l["Anger"].iloc[0]
                NRC_Anticipation_score += NRC_l["Anticipation"].iloc[0]
                NRC_Disgust_score += NRC_l["Disgust"].iloc[0]
                NRC_Fear_score += NRC_l["Fear"].iloc[0]
                NRC_Joy_score += NRC_l["Joy"].iloc[0]
                NRC_Sadness_score += NRC_l["Sadness"].iloc[0]
                NRC_Surprise_score += NRC_l["Surprise"].iloc[0]
                NRC_Trust_score += NRC_l["Trust"].iloc[0]
                
                NRC_lemmata_identified_sentence.append(l)
            
               
        if NRC_pos_score > 1 or NRC_neg_score > 1: # Schwelle für Emotionalität
            NRC_emotional.append(1)
        else:
            NRC_emotional.append(0)
        NRC_emotion_sum.append(NRC_pos_score - NRC_neg_score)
        
        NRC_lemmata_identified.append(",".join(NRC_lemmata_identified_sentence))
        
        NRC_positive.append(NRC_pos_score)
        NRC_negative.append(NRC_neg_score)
        NRC_Anger.append(NRC_Anger_score)
        NRC_Anticipation.append(NRC_Anticipation_score)
        NRC_Disgust.append(NRC_Disgust_score)
        NRC_Fear.append(NRC_Fear_score)
        NRC_Joy.append(NRC_Joy_score)
        NRC_Sadness.append(NRC_Sadness_score)
        NRC_Surprise.append(NRC_Surprise_score)
        NRC_Trust.append(NRC_Trust_score)
    
    fr["text_idno"] = idnos
    fr["p_num"] = p_nums
    fr["s_num"] = s_nums
    fr["speech"] = speech
    fr["WN_positive"] = WN_positive
    fr["WN_negative"] = WN_negative
    fr["WN_emotional"] = WN_emotional
    fr["WN_emotion_sum"] = WN_emotion_sum
    fr["NRC_positive"] = NRC_positive
    fr["NRC_negative"] = NRC_negative
    fr["NRC_emotional"] = NRC_emotional
    fr["NRC_emotion_sum"] = NRC_emotion_sum
    fr["NRC_Anger"] = NRC_Anger
    fr["NRC_Anticipation"] = NRC_Anticipation
    fr["NRC_Disgust"] = NRC_Disgust
    fr["NRC_Fear"] = NRC_Fear
    fr["NRC_Joy"] = NRC_Joy
    fr["NRC_Sadness"] = NRC_Sadness
    fr["NRC_Surprise"] = NRC_Surprise
    fr["NRC_Trust"] = NRC_Trust
    fr["WN_synsets_identified"] = WN_synsets_identified
    fr["NRC_lemmata_identified"] = NRC_lemmata_identified
    
    fr.to_csv(os.path.join(wdir, "sentiments_gt1.csv"), sep=",", encoding="utf-8")  
    
    print("Done!")


def create_sections(wdir, sent_file):
    """
    Create sentiment sections as a basis for features.
    
    Arguments:
    wdir (str): working directory
    sent_file (str): name of the sentiments analysis results file
    """
    # Sektion-Größe: ein Fünftel der Sätze jedes Romans
    # nh0054_p_624_sp_False_s1.xml
    # Grundlage: die große sent.Tabelle
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    # initiate section column
    sents["section"] = [0 for i in range(len(sents.index))]
    
    sents_sorted = sents.sort_values(by=["text_idno","p_num","s_num"], axis=0)
    
    idnos = sorted(set(sents.text_idno))
    for i in idnos:
        # number of sentences per text:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        # size of the section in number of sentences, divided by 5 and rounded up
        section_size = int(num_sents / 5)
        
        # set section number KORRIGIEREN
        idx = sents_sorted[sents_sorted.text_idno == i].index.tolist()
        first = sents_sorted.index.get_loc(idx[0])
        #last = sents_sorted.index.get_loc(idx[len(idx)-1])
        
        
        for n in range(5):
            start = first + n*section_size
            end = start + num_sents
            if n < 4:
                sents_sorted.loc[start:(start+section_size),"section"] = n+1
            else:
                # last section:
                sents_sorted.loc[start:,"section"] = 5    
    sents_sorted.to_csv(os.path.join(wdir, "sentiments_gt1_sections.csv"), sep=",", encoding="utf-8") 
    print("Sections done!")
    


###############################################
# CHARTS
###############################################


def bar_chart_emotional(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of emotional sentences in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    sp = []
    nosp = []
    neu_sp = []
    neu_narr = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        WN_num_sents_emo_sp = len(sents.loc[sents.text_idno == i][sents.WN_emotional == 1][sents.speech == True])
        WN_num_sents_emo_nosp = len(sents.loc[sents.text_idno == i][sents.WN_emotional == 1][sents.speech == False])
        WN_num_sents_neutral_sp = len(sents.loc[sents.text_idno == i][sents.WN_emotional == 0][sents.speech == True])
        WN_num_sents_neutral_nosp = len(sents.loc[sents.text_idno == i][sents.WN_emotional == 0][sents.speech == False])
        
        WN_qu_sp = WN_num_sents_emo_sp / num_sents
        sp.append(WN_qu_sp * 100)
        WN_qu_nosp = WN_num_sents_emo_nosp / num_sents
        nosp.append(WN_qu_nosp * 100)
        
        WN_qu_neu_sp = WN_num_sents_neutral_sp / num_sents
        neu_sp.append(WN_qu_neu_sp * 100)
        WN_qu_neu_narr = WN_num_sents_neutral_nosp / num_sents
        neu_narr.append(WN_qu_neu_narr * 100)
        
        NRC_num_sents_emo_sp = len(sents.loc[sents.text_idno == i][sents.NRC_emotional == 1][sents.speech == True])
        NRC_num_sents_emo_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_emotional == 1][sents.speech == False])
        NRC_num_sents_neutral_sp = len(sents.loc[sents.text_idno == i][sents.NRC_emotional == 0][sents.speech == True])
        NRC_num_sents_neutral_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_emotional == 0][sents.speech == False])
        
        NRC_qu_sp = NRC_num_sents_emo_sp / num_sents
        sp.append(NRC_qu_sp * 100)
        NRC_qu_nosp = NRC_num_sents_emo_nosp / num_sents
        nosp.append(NRC_qu_nosp * 100)
        
        NRC_qu_neu_sp = NRC_num_sents_neutral_sp / num_sents
        neu_sp.append(NRC_qu_neu_sp * 100)
        NRC_qu_neu_narr = NRC_num_sents_neutral_nosp / num_sents
        neu_narr.append(NRC_qu_neu_narr * 100)
    
    labels_1 = [i + " (WN)" for i in idnos]
    labels_2 = [i + " (NRC)" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2):
        labels.append(i[0])
        labels.append(i[1])
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Emotional sentences (in %)'
    bar_chart.x_labels = labels
    bar_chart.add('emo-speech', sp)
    bar_chart.add('emo-narr', nosp)
    bar_chart.add('neutral-speech', neu_sp)
    bar_chart.add('neutral-narr', neu_narr)
    
    out_file = os.path.join(wdir, out_folder, "emotional-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    

def bar_chart_emotional_simple(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of emotional and neutral sentences in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    emo = []
    neutral = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        WN_num_sents_emo = len(sents.loc[sents.text_idno == i][sents.WN_emotional == 1])
        WN_num_sents_neutral = len(sents.loc[sents.text_idno == i][sents.WN_emotional == 0])
        
        WN_qu_emo = WN_num_sents_emo / num_sents
        emo.append(WN_qu_emo * 100)
        WN_qu_neutral = WN_num_sents_neutral / num_sents
        neutral.append(WN_qu_neutral * 100)
        
        NRC_num_sents_emo = len(sents.loc[sents.text_idno == i][sents.NRC_emotional == 1])
        NRC_num_sents_neutral = len(sents.loc[sents.text_idno == i][sents.NRC_emotional == 0])
        
        NRC_qu_emo = NRC_num_sents_emo / num_sents
        emo.append(NRC_qu_emo * 100)
        NRC_qu_neutral = NRC_num_sents_neutral / num_sents
        neutral.append(NRC_qu_neutral * 100)
    
    labels_1 = [i + " (WN)" for i in idnos]
    labels_2 = [i + " (NRC)" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2):
        labels.append(i[0])
        labels.append(i[1])
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Emotional sentences (in %)'
    bar_chart.x_labels = labels
    bar_chart.add('emotional', emo)
    bar_chart.add('neutral', neutral)
    
    out_file = os.path.join(wdir, out_folder, "emotional-simple-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    
    
    
def bar_chart_negative_sp(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of negative sentences in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    sp = []
    nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        WN_num_sents_neg_sp = len(sents.loc[sents.text_idno == i][sents.WN_emotion_sum < 0][sents.speech == True])
        WN_num_sents_neg_nosp = len(sents.loc[sents.text_idno == i][sents.WN_emotion_sum < 0][sents.speech == False])
        
        WN_qu_sp = WN_num_sents_neg_sp / num_sents
        sp.append(WN_qu_sp * 100)
        WN_qu_nosp = WN_num_sents_neg_nosp / num_sents
        nosp.append(WN_qu_nosp * 100)
        
        NRC_num_sents_neg_sp = len(sents.loc[sents.text_idno == i][sents.NRC_emotion_sum < 0][sents.speech == True])
        NRC_num_sents_neg_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_emotion_sum < 0][sents.speech == False])
        
        NRC_qu_sp = NRC_num_sents_neg_sp / num_sents
        sp.append(NRC_qu_sp * 100)
        NRC_qu_nosp = NRC_num_sents_neg_nosp / num_sents
        nosp.append(NRC_qu_nosp * 100)
    
    labels_1 = [i + " (WN)" for i in idnos]
    labels_2 = [i + " (NRC)" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2):
        labels.append(i[0])
        labels.append(i[1])
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Negative sentences (in %)'
    bar_chart.x_labels = labels
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', nosp)
    
    out_file = os.path.join(wdir, out_folder, "negative-sp-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    
    
    
def bar_chart_positive_sp(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of positive sentences in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    sp = []
    nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        WN_num_sents_pos_sp = len(sents.loc[sents.text_idno == i][sents.WN_emotion_sum > 0][sents.speech == True])
        WN_num_sents_pos_nosp = len(sents.loc[sents.text_idno == i][sents.WN_emotional > 0][sents.speech == False])
        
        WN_qu_sp = WN_num_sents_pos_sp / num_sents
        sp.append(WN_qu_sp * 100)
        WN_qu_nosp = WN_num_sents_pos_nosp / num_sents
        nosp.append(WN_qu_nosp * 100)
        
        NRC_num_sents_pos_sp = len(sents.loc[sents.text_idno == i][sents.NRC_emotion_sum > 0][sents.speech == True])
        NRC_num_sents_pos_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_emotion_sum > 0][sents.speech == False])
        
        NRC_qu_sp = NRC_num_sents_pos_sp / num_sents
        sp.append(NRC_qu_sp * 100)
        NRC_qu_nosp = NRC_num_sents_pos_nosp / num_sents
        nosp.append(NRC_qu_nosp * 100)
    
    labels_1 = [i + " (WN)" for i in idnos]
    labels_2 = [i + " (NRC)" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2):
        labels.append(i[0])
        labels.append(i[1])
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Positive sentences (in %)'
    bar_chart.x_labels = labels
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', nosp)
    
    out_file = os.path.join(wdir, out_folder, "positive-sp-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    

def bar_chart_positive(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of positive sentences in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    pos = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        WN_num_sents_pos = len(sents.loc[sents.text_idno == i][sents.WN_emotion_sum > 0])
        
        WN_qu = WN_num_sents_pos / num_sents
        pos.append(WN_qu * 100)
        
        NRC_num_sents_pos = len(sents.loc[sents.text_idno == i][sents.NRC_emotion_sum > 0])
        
        NRC_qu = NRC_num_sents_pos / num_sents
        pos.append(NRC_qu * 100)
    
    labels_1 = [i + " (WN)" for i in idnos]
    labels_2 = [i + " (NRC)" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2):
        labels.append(i[0])
        labels.append(i[1])
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Positive sentences (in %)'
    bar_chart.x_labels = labels
    bar_chart.add('positive', pos)
    
    out_file = os.path.join(wdir, out_folder, "positive-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    


def bar_chart_negative(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of negative sentences in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    neg = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        WN_num_sents_neg = len(sents.loc[sents.text_idno == i][sents.WN_emotion_sum < 0])
        
        WN_qu = WN_num_sents_neg / num_sents
        neg.append(WN_qu * 100)
        
        NRC_num_sents_neg = len(sents.loc[sents.text_idno == i][sents.NRC_emotion_sum < 0])
        
        NRC_qu = NRC_num_sents_neg / num_sents
        neg.append(NRC_qu * 100)
    
    labels_1 = [i + " (WN)" for i in idnos]
    labels_2 = [i + " (NRC)" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2):
        labels.append(i[0])
        labels.append(i[1])
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Negative sentences (in %)'
    bar_chart.x_labels = labels
    bar_chart.add('negative', neg)
    
    out_file = os.path.join(wdir, out_folder, "negative-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")    

    
    
    
def bar_chart_emotions(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of emotions (Trust, Fear, Joy, Sadness, Anger, Disgust, Anticipation, Surprise) in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Trust_sp = []
    Trust_nosp = []
    Fear_sp = []
    Fear_nosp = []
    Joy_sp = []
    Joy_nosp = []
    Sadness_sp = []
    Sadness_nosp = []
    Anger_sp = []
    Anger_nosp = []
    Disgust_sp = []
    Disgust_nosp = []
    Anticipation_sp = []
    Anticipation_nosp = []
    Surprise_sp = []
    Surprise_nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Trust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0][sents.speech == True])
        num_sents_Trust_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0][sents.speech == False])
        
        num_sents_Fear_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0][sents.speech == True])
        num_sents_Fear_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0][sents.speech == False])
        
        num_sents_Joy_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0][sents.speech == True])
        num_sents_Joy_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0][sents.speech == False])
        
        num_sents_Sadness_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Sadness > 0][sents.speech == True])
        num_sents_Sadness_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Sadness > 0][sents.speech == False])
        
        num_sents_Anger_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Anger > 0][sents.speech == True])
        num_sents_Anger_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Anger > 0][sents.speech == False])
        
        num_sents_Disgust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Disgust > 0][sents.speech == True])
        num_sents_Disgust_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Disgust > 0][sents.speech == False])
        
        num_sents_Anticipation_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Anticipation > 0][sents.speech == True])
        num_sents_Anticipation_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Anticipation > 0][sents.speech == False])
        
        num_sents_Surprise_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Surprise > 0][sents.speech == True])
        num_sents_Surprise_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Surprise > 0][sents.speech == False])
        
        
        qu_sp_Trust = num_sents_Trust_sp / num_sents
        Trust_sp.append(qu_sp_Trust * 100)
        qu_nosp_Trust = num_sents_Trust_nosp / num_sents
        Trust_nosp.append(qu_nosp_Trust * 100)
        
        qu_sp_Fear = num_sents_Fear_sp / num_sents
        Fear_sp.append(qu_sp_Fear * 100)
        qu_nosp_Fear = num_sents_Fear_nosp / num_sents
        Fear_nosp.append(qu_nosp_Fear * 100)
        
        qu_sp_Joy = num_sents_Joy_sp / num_sents
        Joy_sp.append(qu_sp_Joy * 100)
        qu_nosp_Joy = num_sents_Joy_nosp / num_sents
        Joy_nosp.append(qu_nosp_Joy * 100)
        
        qu_sp_Sadness = num_sents_Sadness_sp / num_sents
        Sadness_sp.append(qu_sp_Sadness * 100)
        qu_nosp_Sadness = num_sents_Sadness_nosp / num_sents
        Sadness_nosp.append(qu_nosp_Sadness * 100)
        
        qu_sp_Anger = num_sents_Anger_sp / num_sents
        Anger_sp.append(qu_sp_Anger * 100)
        qu_nosp_Anger = num_sents_Anger_nosp / num_sents
        Anger_nosp.append(qu_nosp_Anger * 100)
        
        qu_sp_Disgust = num_sents_Disgust_sp / num_sents
        Disgust_sp.append(qu_sp_Disgust * 100)
        qu_nosp_Disgust = num_sents_Disgust_nosp / num_sents
        Disgust_nosp.append(qu_nosp_Disgust * 100)
        
        qu_sp_Anticipation = num_sents_Anticipation_sp / num_sents
        Anticipation_sp.append(qu_sp_Anticipation * 100)
        qu_nosp_Anticipation = num_sents_Anticipation_nosp / num_sents
        Anticipation_nosp.append(qu_nosp_Anticipation * 100)
        
        qu_sp_Surprise = num_sents_Surprise_sp / num_sents
        Surprise_sp.append(qu_sp_Surprise * 100)
        qu_nosp_Surprise = num_sents_Surprise_nosp / num_sents
        Surprise_nosp.append(qu_nosp_Surprise * 100)
        
    
    labels_1 = [i + "_Trust" for i in idnos]
    labels_2 = [i + "_Fear" for i in idnos]
    labels_3 = [i + "_Joy" for i in idnos]
    labels_4 = [i + "_Sadness" for i in idnos]
    labels_5 = [i + "_Anger" for i in idnos]
    labels_6 = [i + "_Disgust" for i in idnos]
    labels_7 = [i + "_Anticipation" for i in idnos]
    labels_8 = [i + "_Surprise" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2, labels_3, labels_4, labels_5, labels_6, labels_7, labels_8):
        labels.append(i[0])
        labels.append(i[1])
        labels.append(i[2])
        labels.append(i[3])
        labels.append(i[4])
        labels.append(i[5])
        labels.append(i[6])
        labels.append(i[7])
        
    
    bar_chart = pygal.StackedBar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Emotion sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    no_sp = []
    
    
    for idx in range(len(Trust_sp)):
		
        sp.append(Trust_sp[idx])
        sp.append(Fear_sp[idx])
        sp.append(Joy_sp[idx])
        sp.append(Sadness_sp[idx])
        sp.append(Anger_sp[idx])
        sp.append(Disgust_sp[idx])
        sp.append(Anticipation_sp[idx])
        sp.append(Surprise_sp[idx])
        
        no_sp.append(Trust_nosp[idx])
        no_sp.append(Fear_nosp[idx])
        no_sp.append(Joy_nosp[idx])
        no_sp.append(Sadness_nosp[idx])
        no_sp.append(Anger_nosp[idx])
        no_sp.append(Disgust_nosp[idx])
        no_sp.append(Anticipation_nosp[idx])
        no_sp.append(Surprise_nosp[idx])
    
    
    
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', no_sp)
    
    out_file = os.path.join(wdir, out_folder, "emotion-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")  


def bar_chart_trust(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of Trust in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Trust = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Trust = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0])
        
        qu_Trust = num_sents_Trust / num_sents
        Trust.append(qu_Trust * 100)
        
    labels = idnos
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Trust sentences (in %)'
    bar_chart.x_labels = labels
    
    bar_chart.add('with Trust', Trust)
    
    out_file = os.path.join(wdir, out_folder, "trust-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")  
    
    
def bar_chart_trust_sp(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of Trust in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Trust_sp = []
    Trust_nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Trust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0][sents.speech == True])
        num_sents_Trust_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0][sents.speech == False])
        
        qu_sp_Trust = num_sents_Trust_sp / num_sents
        Trust_sp.append(qu_sp_Trust * 100)
        qu_nosp_Trust = num_sents_Trust_nosp / num_sents
        Trust_nosp.append(qu_nosp_Trust * 100)
    
    
    labels = idnos
        
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Trust sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    no_sp = []
    
    
    for idx in range(len(Trust_sp)):
		
        sp.append(Trust_sp[idx])
        no_sp.append(Trust_nosp[idx])
    
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', no_sp)
    
    out_file = os.path.join(wdir, out_folder, "trust-sp-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")      
    

def bar_chart_fear(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of Fear in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Fear = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Fear = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0])
        
        qu_Fear = num_sents_Fear / num_sents
        Fear.append(qu_Fear * 100)
        
    labels = idnos
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Fear sentences (in %)'
    bar_chart.x_labels = labels
    
    bar_chart.add('with Fear', Fear)
    
    out_file = os.path.join(wdir, out_folder, "fear-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")  
    
    
def bar_chart_fear_sp(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of Fear in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Fear_sp = []
    Fear_nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Fear_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0][sents.speech == True])
        num_sents_Fear_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0][sents.speech == False])
        
        qu_sp_Fear = num_sents_Fear_sp / num_sents
        Fear_sp.append(qu_sp_Fear * 100)
        qu_nosp_Fear = num_sents_Fear_nosp / num_sents
        Fear_nosp.append(qu_nosp_Fear * 100)
    
    
    labels = idnos
        
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Fear sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    no_sp = []
    
    
    for idx in range(len(Fear_sp)):
		
        sp.append(Fear_sp[idx])
        no_sp.append(Fear_nosp[idx])
    
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', no_sp)
    
    out_file = os.path.join(wdir, out_folder, "fear-sp-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    
    
def bar_chart_joy(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of Joy in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Joy = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Joy = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0])
        
        qu_Joy = num_sents_Joy / num_sents
        Joy.append(qu_Joy * 100)
        
    labels = idnos
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Joy sentences (in %)'
    bar_chart.x_labels = labels
    
    bar_chart.add('with Joy', Joy)
    
    out_file = os.path.join(wdir, out_folder, "joy-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")  
    
    
def bar_chart_joy_sp(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of Joy in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Joy_sp = []
    Joy_nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Joy_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0][sents.speech == True])
        num_sents_Joy_nosp = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0][sents.speech == False])
        
        qu_sp_Joy = num_sents_Joy_sp / num_sents
        Joy_sp.append(qu_sp_Joy * 100)
        qu_nosp_Joy = num_sents_Joy_nosp / num_sents
        Joy_nosp.append(qu_nosp_Joy * 100)
    
    
    labels = idnos
        
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Joy sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    no_sp = []
    
    
    for idx in range(len(Joy_sp)):
		
        sp.append(Joy_sp[idx])
        no_sp.append(Joy_nosp[idx])
    
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', no_sp)
    
    out_file = os.path.join(wdir, out_folder, "joy-sp-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    
    
def bar_chart_speech(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of direct speech in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    sp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_speech = len(sents.loc[sents.text_idno == i][sents.speech == True])
        
        qu_sp = num_sents_speech / num_sents
        sp.append(qu_sp * 100)
        
    labels = idnos
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Sentences with direct speech (in %)'
    bar_chart.x_labels = labels
    
    bar_chart.add('with speech', sp)
    
    out_file = os.path.join(wdir, out_folder, "speech-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")    
    
    
def bar_chart_emotion_type(wdir, md_file, sent_file, out_folder, emotion_type):
    """
    Create a bar chart to show the percentage of Joy in novels.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    emotion_type (str): type of basic emotion (e.g. Joy, Sadness)
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Emo = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Emo = len(sents.loc[sents.text_idno == i][sents["NRC_" + emotion_type] > 0])
        
        qu_Emo = num_sents_Emo / num_sents
        Emo.append(qu_Emo * 100)
        
    labels = idnos
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = emotion_type + ' sentences (in %)'
    bar_chart.x_labels = labels
    
    bar_chart.add('with ' + emotion_type, Emo)
    
    out_file = os.path.join(wdir, out_folder, emotion_type.lower() + "-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")  
    
    
    
def bar_chart_emotion_type_sp(wdir, md_file, sent_file, out_folder, emotion_type):
    """
    Create a bar chart to show the percentage of one basic emotion type in novels,
    differentiated by sentences with direct speech and without.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    emotion_type (str): type of basic emotion (e.g. Joy, Sadness)
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Emo_sp = []
    Emo_nosp = []
    
    for i in idnos:
        num_sents = len(sents.loc[sents.text_idno == i])
        
        num_sents_Emo_sp = len(sents.loc[sents.text_idno == i][sents["NRC_" + emotion_type] > 0][sents.speech == True])
        num_sents_Emo_nosp = len(sents.loc[sents.text_idno == i][sents["NRC_" + emotion_type] > 0][sents.speech == False])
        
        qu_sp_Emo = num_sents_Emo_sp / num_sents
        Emo_sp.append(qu_sp_Emo * 100)
        qu_nosp_Emo = num_sents_Emo_nosp / num_sents
        Emo_nosp.append(qu_nosp_Emo * 100)
    
    
    labels = idnos
        
    
    bar_chart = pygal.Bar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = emotion_type + ' sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    no_sp = []
    
    
    for idx in range(len(Emo_sp)):
		
        sp.append(Emo_sp[idx])
        no_sp.append(Emo_nosp[idx])
    
    bar_chart.add('with direct speech', sp)
    bar_chart.add('without direct speech', no_sp)
    
    out_file = os.path.join(wdir, out_folder, emotion_type.lower() + "-sp-sentences-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")


def bar_chart_emotions_speech(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of emotions (Trust, Fear, Joy, Sadness, Anger, Disgust, Anticipation, Surprise) in novels,
    for sentences with direct speech.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Trust_sp = []
    Fear_sp = []
    Joy_sp = []
    Sadness_sp = []
    Anger_sp = []
    Disgust_sp = []
    Anticipation_sp = []
    Surprise_sp = []
    
    for i in idnos:
        num_sents_sp = len(sents.loc[sents.text_idno == i][sents.speech == True])
        
        num_sents_Trust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0][sents.speech == True])
        num_sents_Fear_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0][sents.speech == True])
        num_sents_Joy_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0][sents.speech == True])
        num_sents_Sadness_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Sadness > 0][sents.speech == True])
        num_sents_Anger_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Anger > 0][sents.speech == True])
        num_sents_Disgust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Disgust > 0][sents.speech == True])
        num_sents_Anticipation_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Anticipation > 0][sents.speech == True])
        num_sents_Surprise_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Surprise > 0][sents.speech == True])
        
        
        qu_sp_Trust = num_sents_Trust_sp / num_sents_sp
        Trust_sp.append(qu_sp_Trust * 100)
        
        qu_sp_Fear = num_sents_Fear_sp / num_sents_sp
        Fear_sp.append(qu_sp_Fear * 100)
        
        qu_sp_Joy = num_sents_Joy_sp / num_sents_sp
        Joy_sp.append(qu_sp_Joy * 100)
        
        qu_sp_Sadness = num_sents_Sadness_sp / num_sents_sp
        Sadness_sp.append(qu_sp_Sadness * 100)
        
        qu_sp_Anger = num_sents_Anger_sp / num_sents_sp
        Anger_sp.append(qu_sp_Anger * 100)
        
        qu_sp_Disgust = num_sents_Disgust_sp / num_sents_sp
        Disgust_sp.append(qu_sp_Disgust * 100)
        
        qu_sp_Anticipation = num_sents_Anticipation_sp / num_sents_sp
        Anticipation_sp.append(qu_sp_Anticipation * 100)
        
        qu_sp_Surprise = num_sents_Surprise_sp / num_sents_sp
        Surprise_sp.append(qu_sp_Surprise * 100)
        
    
    labels_1 = [i + "_Trust" for i in idnos]
    labels_2 = [i + "_Fear" for i in idnos]
    labels_3 = [i + "_Joy" for i in idnos]
    labels_4 = [i + "_Sadness" for i in idnos]
    labels_5 = [i + "_Anger" for i in idnos]
    labels_6 = [i + "_Disgust" for i in idnos]
    labels_7 = [i + "_Anticipation" for i in idnos]
    labels_8 = [i + "_Surprise" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2, labels_3, labels_4, labels_5, labels_6, labels_7, labels_8):
        labels.append(i[0])
        labels.append(i[1])
        labels.append(i[2])
        labels.append(i[3])
        labels.append(i[4])
        labels.append(i[5])
        labels.append(i[6])
        labels.append(i[7])
        
    
    bar_chart = pygal.StackedBar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Emotion sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    
    
    for idx in range(len(Trust_sp)):
		
        sp.append(Trust_sp[idx])
        sp.append(Fear_sp[idx])
        sp.append(Joy_sp[idx])
        sp.append(Sadness_sp[idx])
        sp.append(Anger_sp[idx])
        sp.append(Disgust_sp[idx])
        sp.append(Anticipation_sp[idx])
        sp.append(Surprise_sp[idx])
    
    
    bar_chart.add('with direct speech', sp)
    
    out_file = os.path.join(wdir, out_folder, "emotion-sentences-speech-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")
    

def bar_chart_emotions_nospeech(wdir, md_file, sent_file, out_folder):
    """
    Create a bar chart to show the percentage of emotions (Trust, Fear, Joy, Sadness, Anger, Disgust, Anticipation, Surprise) in novels,
    for sentences with direct speech.
    
    Arguments:
    wdir (str): working directory
    md_file (str): name of the metadata file to write
    sent_file (str): name of the sentiments analysis results file
    out_folder (str): name of the output folder for the visualization
    """
    
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    Trust_sp = []
    Fear_sp = []
    Joy_sp = []
    Sadness_sp = []
    Anger_sp = []
    Disgust_sp = []
    Anticipation_sp = []
    Surprise_sp = []
    
    for i in idnos:
        num_sents_sp = len(sents.loc[sents.text_idno == i][sents.speech == False])
        
        num_sents_Trust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Trust > 0][sents.speech == False])
        num_sents_Fear_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Fear > 0][sents.speech == False])
        num_sents_Joy_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Joy > 0][sents.speech == False])
        num_sents_Sadness_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Sadness > 0][sents.speech == False])
        num_sents_Anger_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Anger > 0][sents.speech == False])
        num_sents_Disgust_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Disgust > 0][sents.speech == False])
        num_sents_Anticipation_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Anticipation > 0][sents.speech == False])
        num_sents_Surprise_sp = len(sents.loc[sents.text_idno == i][sents.NRC_Surprise > 0][sents.speech == False])
        
        
        qu_sp_Trust = num_sents_Trust_sp / num_sents_sp
        Trust_sp.append(qu_sp_Trust * 100)
        
        qu_sp_Fear = num_sents_Fear_sp / num_sents_sp
        Fear_sp.append(qu_sp_Fear * 100)
        
        qu_sp_Joy = num_sents_Joy_sp / num_sents_sp
        Joy_sp.append(qu_sp_Joy * 100)
        
        qu_sp_Sadness = num_sents_Sadness_sp / num_sents_sp
        Sadness_sp.append(qu_sp_Sadness * 100)
        
        qu_sp_Anger = num_sents_Anger_sp / num_sents_sp
        Anger_sp.append(qu_sp_Anger * 100)
        
        qu_sp_Disgust = num_sents_Disgust_sp / num_sents_sp
        Disgust_sp.append(qu_sp_Disgust * 100)
        
        qu_sp_Anticipation = num_sents_Anticipation_sp / num_sents_sp
        Anticipation_sp.append(qu_sp_Anticipation * 100)
        
        qu_sp_Surprise = num_sents_Surprise_sp / num_sents_sp
        Surprise_sp.append(qu_sp_Surprise * 100)
        
    
    labels_1 = [i + "_Trust" for i in idnos]
    labels_2 = [i + "_Fear" for i in idnos]
    labels_3 = [i + "_Joy" for i in idnos]
    labels_4 = [i + "_Sadness" for i in idnos]
    labels_5 = [i + "_Anger" for i in idnos]
    labels_6 = [i + "_Disgust" for i in idnos]
    labels_7 = [i + "_Anticipation" for i in idnos]
    labels_8 = [i + "_Surprise" for i in idnos]
    labels = []
    for i in zip(labels_1, labels_2, labels_3, labels_4, labels_5, labels_6, labels_7, labels_8):
        labels.append(i[0])
        labels.append(i[1])
        labels.append(i[2])
        labels.append(i[3])
        labels.append(i[4])
        labels.append(i[5])
        labels.append(i[6])
        labels.append(i[7])
        
    
    bar_chart = pygal.StackedBar(x_label_rotation=-90, legend_at_bottom=True)
    bar_chart.title = 'Emotion sentences (in %)'
    bar_chart.x_labels = labels
    
    sp = []
    
    
    for idx in range(len(Trust_sp)):
		
        sp.append(Trust_sp[idx])
        sp.append(Fear_sp[idx])
        sp.append(Joy_sp[idx])
        sp.append(Sadness_sp[idx])
        sp.append(Anger_sp[idx])
        sp.append(Disgust_sp[idx])
        sp.append(Anticipation_sp[idx])
        sp.append(Surprise_sp[idx])
    
    
    bar_chart.add('without direct speech', sp)
    
    out_file = os.path.join(wdir, out_folder, "emotion-sentences-nospeech-bar.svg")
    bar_chart.render_to_file(out_file)
    
    print("Done!")  


def generate_features(wdir, md_file, sent_file, feature_file, target_categories):
    """
    Generate features for learning.
    """

    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", index_col=0)
    #print(md.head())
    idnos = list(md.index.values)
    sections = range(1,6)
    
    sents = pd.read_csv(os.path.join(wdir, sent_file), sep=",", index_col=0)
    
    
    # calculate values per section
    index = []
    for i in idnos:
        for sec in sections:
            index.append(i + "_" + str(sec))
    
    feat_fr = pd.DataFrame(index=index, columns=["section", "speech", "narrated",
     "emotional_WN","neutral_WN","positive_WN","negative_WN",
     "speech_emotional_WN","narrated_emotional_WN","speech_neutral_WN","narrated_neutral_WN",
     "emotional_NRC","neutral_NRC","positive_NRC","negative_NRC",
     "speech_emotional_NRC","narrated_emotional_NRC","speech_neutral_NRC","narrated_neutral_NRC",
     "Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC",
     "Trust_NRC_speech", "Trust_NRC_narrated", "Fear_NRC_speech", "Fear_NRC_narrated", "Joy_NRC_speech", "Joy_NRC_narrated", "Sadness_NRC_speech", "Sadness_NRC_narrated",
     "Anger_NRC_speech", "Anger_NRC_narrated", "Disgust_NRC_speech", "Disgust_NRC_narrated", "Anticipation_NRC_speech", "Anticipation_NRC_narrated", "Surprise_NRC_speech", "Surprise_NRC_narrated"])
    
    
    # for each text...
    for i in idnos:
    
        # for each section...
        for sec_num in sections:
            # number of sentences in this section
            num_sents = len(sents.loc[sents.text_idno == i][sents.section == sec_num])
            #print(num_sents)
            
            speech = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.speech == True]) / num_sents) * 100
            narrated = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.speech == False]) / num_sents) * 100
            
            emotional_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotional == 1]) / num_sents) * 100
            neutral_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotional == 0]) / num_sents) * 100
            positive_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotion_sum > 1]) / num_sents) * 100 # Schwelle für positiv
            negative_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotion_sum < -1]) / num_sents) * 100 # Schwelle für negativ
            speech_emotional_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotional == 1][sents.speech == True]) / num_sents) * 100
            narrated_emotional_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotional == 1][sents.speech == False]) / num_sents) * 100
            speech_neutral_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotional == 0][sents.speech == True]) / num_sents) * 100
            narrated_neutral_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotional == 0][sents.speech == False]) / num_sents) * 100
            
            
            emotional_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 1]) / num_sents) * 100
            neutral_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 0]) / num_sents) * 100
            positive_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum > 1]) / num_sents) * 100 # Schwelle für positiv
            negative_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum < -1]) / num_sents) * 100 # Schwelle für negativ
            speech_emotional_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 1][sents.speech == True]) / num_sents) * 100
            narrated_emotional_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 1][sents.speech == False]) / num_sents) * 100
            speech_neutral_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 0][sents.speech == True]) / num_sents) * 100
            narrated_neutral_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 0][sents.speech == False]) / num_sents) * 100
            
            #Trust_NRC = (len(sents.loc[sents.text_idno == i][sents.section == (sec_num + 1)][sents.NRC_Trust > sents.NRC_Fear and sents.NRC_Trust > sents.NRC_Joy and sents.NRC_Trust > sents.NRC_Sadness and sents.NRC_Trust > sents.NRC_Anger and sents.NRC_Trust > sents.NRC_Disgust and sents.NRC_Trust > sents.NRC_Anticipation and sents.NRC_Trust > sents.NRC_Surprise]) / num_sents) * 100
            
            sents_current = sents.loc[sents.text_idno == i][sents.section == sec_num]
            sents_current_speech = sents.loc[sents.text_idno == i][sents.section == sec_num][sents.speech == True]
            sents_current_narrated = sents.loc[sents.text_idno == i][sents.section == sec_num][sents.speech == False]
            
            Trust = []
            Trust_speech = []
            Trust_narrated = []
            Fear = []
            Fear_speech = []
            Fear_narrated = []
            Joy = []
            Joy_speech = []
            Joy_narrated = []
            Sadness = []
            Sadness_speech = []
            Sadness_narrated = []
            Anger = []
            Anger_speech = []
            Anger_narrated = []
            Disgust = []
            Disgust_speech = []
            Disgust_narrated = []
            Anticipation = []
            Anticipation_speech = []
            Anticipation_narrated = []
            Surprise = []
            Surprise_speech = []
            Surprise_narrated = []
            
            for idx,val in enumerate(sents_current.iterrows()):
                
                if (val[1]["NRC_Trust"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Anticipation"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Surprise"]):
                    Trust.append(1)
                if (val[1]["NRC_Fear"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Fear"] > val[1]["NRC_Surprise"]):
                    Fear.append(1)
                if (val[1]["NRC_Joy"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Joy"] > val[1]["NRC_Surprise"]):
                    Joy.append(1)
                if (val[1]["NRC_Sadness"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Sadness"] > val[1]["NRC_Surprise"]):
                    Sadness.append(1)
                if (val[1]["NRC_Anger"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Anger"] > val[1]["NRC_Surprise"]):
                    Anger.append(1)
                if (val[1]["NRC_Disgust"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Disgust"] > val[1]["NRC_Surprise"]):
                    Disgust.append(1)
                if (val[1]["NRC_Anticipation"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Anger"]) and(val[1]["NRC_Anticipation"] > val[1]["NRC_Surprise"]):
                    Anticipation.append(1)
                if (val[1]["NRC_Surprise"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Disgust"]) and(val[1]["NRC_Surprise"] > val[1]["NRC_Anticipation"]):
                    Surprise.append(1)    
            
            Trust_NRC = (len(Trust) / num_sents) * 100
            Fear_NRC = (len(Fear) / num_sents) * 100
            Joy_NRC = (len(Joy) / num_sents) * 100
            Sadness_NRC = (len(Sadness) / num_sents) * 100
            Anger_NRC = (len(Anger) / num_sents) * 100
            Disgust_NRC = (len(Disgust) / num_sents) * 100
            Anticipation_NRC = (len(Anticipation) / num_sents) * 100
            Surprise_NRC = (len(Surprise) / num_sents) * 100
            
            
            # emotions speech:
            
            for idx,val in enumerate(sents_current_speech.iterrows()):
             
                if (val[1]["NRC_Trust"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Anticipation"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Surprise"]):
                    Trust_speech.append(1)
                if (val[1]["NRC_Fear"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Fear"] > val[1]["NRC_Surprise"]):
                    Fear_speech.append(1)
                if (val[1]["NRC_Joy"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Joy"] > val[1]["NRC_Surprise"]):
                    Joy_speech.append(1)
                if (val[1]["NRC_Sadness"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Sadness"] > val[1]["NRC_Surprise"]):
                    Sadness_speech.append(1)
                if (val[1]["NRC_Anger"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Anger"] > val[1]["NRC_Surprise"]):
                    Anger_speech.append(1)
                if (val[1]["NRC_Disgust"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Disgust"] > val[1]["NRC_Surprise"]):
                    Disgust_speech.append(1)
                if (val[1]["NRC_Anticipation"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Anger"]) and(val[1]["NRC_Anticipation"] > val[1]["NRC_Surprise"]):
                    Anticipation_speech.append(1)
                if (val[1]["NRC_Surprise"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Disgust"]) and(val[1]["NRC_Surprise"] > val[1]["NRC_Anticipation"]):
                    Surprise_speech.append(1)    
            
            Trust_NRC_speech = (len(Trust_speech) / num_sents) * 100
            Fear_NRC_speech = (len(Fear_speech) / num_sents) * 100
            Joy_NRC_speech = (len(Joy_speech) / num_sents) * 100
            Sadness_NRC_speech = (len(Sadness_speech) / num_sents) * 100
            Anger_NRC_speech = (len(Anger_speech) / num_sents) * 100
            Disgust_NRC_speech = (len(Disgust_speech) / num_sents) * 100
            Anticipation_NRC_speech = (len(Anticipation_speech) / num_sents) * 100
            Surprise_NRC_speech = (len(Surprise_speech) / num_sents) * 100   
                
                
            # emotions narrated:
            
            for idx,val in enumerate(sents_current_narrated.iterrows()):
                
                if (val[1]["NRC_Trust"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Anticipation"]) and (val[1]["NRC_Trust"] > val[1]["NRC_Surprise"]):
                    Trust_narrated.append(1)
                if (val[1]["NRC_Fear"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Fear"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Fear"] > val[1]["NRC_Surprise"]):
                    Fear_narrated.append(1)
                if (val[1]["NRC_Joy"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Joy"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Joy"] > val[1]["NRC_Surprise"]):
                    Joy_narrated.append(1)
                if (val[1]["NRC_Sadness"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Sadness"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Sadness"] > val[1]["NRC_Surprise"]):
                    Sadness_narrated.append(1)
                if (val[1]["NRC_Anger"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Anger"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Anger"] > val[1]["NRC_Surprise"]):
                    Anger_narrated.append(1)
                if (val[1]["NRC_Disgust"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Disgust"] > val[1]["NRC_Anticipation"]) and(val[1]["NRC_Disgust"] > val[1]["NRC_Surprise"]):
                    Disgust_narrated.append(1)
                if (val[1]["NRC_Anticipation"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Disgust"]) and (val[1]["NRC_Anticipation"] > val[1]["NRC_Anger"]) and(val[1]["NRC_Anticipation"] > val[1]["NRC_Surprise"]):
                    Anticipation_narrated.append(1)
                if (val[1]["NRC_Surprise"] > val[1]["NRC_Trust"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Fear"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Joy"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Sadness"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Anger"]) and (val[1]["NRC_Surprise"] > val[1]["NRC_Disgust"]) and(val[1]["NRC_Surprise"] > val[1]["NRC_Anticipation"]):
                    Surprise_narrated.append(1)    
            
            Trust_NRC_narrated = (len(Trust_narrated) / num_sents) * 100
            Fear_NRC_narrated = (len(Fear_narrated) / num_sents) * 100
            Joy_NRC_narrated = (len(Joy_narrated) / num_sents) * 100
            Sadness_NRC_narrated = (len(Sadness_narrated) / num_sents) * 100
            Anger_NRC_narrated = (len(Anger_narrated) / num_sents) * 100
            Disgust_NRC_narrated = (len(Disgust_narrated) / num_sents) * 100
            Anticipation_NRC_narrated = (len(Anticipation_narrated) / num_sents) * 100
            Surprise_NRC_narrated = (len(Surprise_narrated) / num_sents) * 100   
           
            
            idx = i + "_" + str(sec_num)
            feat_fr.set_value(idx,"section",sec_num)
            feat_fr.set_value(idx,"speech",speech)
            feat_fr.set_value(idx,"narrated",narrated)
            
            feat_fr.set_value(idx,"emotional_WN",emotional_WN)
            feat_fr.set_value(idx,"neutral_WN",neutral_WN)
            feat_fr.set_value(idx,"positive_WN",positive_WN)
            feat_fr.set_value(idx,"negative_WN",negative_WN)
            feat_fr.set_value(idx,"speech_emotional_WN",speech_emotional_WN)
            feat_fr.set_value(idx,"narrated_emotional_WN",narrated_emotional_WN)
            feat_fr.set_value(idx,"speech_neutral_WN",speech_neutral_WN)
            feat_fr.set_value(idx,"narrated_neutral_WN",narrated_neutral_WN)
            
            feat_fr.set_value(idx,"emotional_NRC",emotional_NRC)
            feat_fr.set_value(idx,"neutral_NRC",neutral_NRC)
            feat_fr.set_value(idx,"positive_NRC",positive_NRC)
            feat_fr.set_value(idx,"negative_NRC",negative_NRC)
            feat_fr.set_value(idx,"speech_emotional_NRC",speech_emotional_NRC)
            feat_fr.set_value(idx,"narrated_emotional_NRC",narrated_emotional_NRC)
            feat_fr.set_value(idx,"speech_neutral_NRC",speech_neutral_NRC)
            feat_fr.set_value(idx,"narrated_neutral_NRC",narrated_neutral_NRC)
            
            feat_fr.set_value(idx,"Trust_NRC",Trust_NRC)
            feat_fr.set_value(idx,"Fear_NRC",Fear_NRC)
            feat_fr.set_value(idx,"Joy_NRC",Joy_NRC)
            feat_fr.set_value(idx,"Sadness_NRC",Sadness_NRC)
            feat_fr.set_value(idx,"Anger_NRC",Anger_NRC)
            feat_fr.set_value(idx,"Disgust_NRC",Disgust_NRC)
            feat_fr.set_value(idx,"Anticipation_NRC",Anticipation_NRC)
            feat_fr.set_value(idx,"Surprise_NRC",Surprise_NRC)
            
            feat_fr.set_value(idx,"Trust_NRC_speech",Trust_NRC_speech)
            feat_fr.set_value(idx,"Fear_NRC_speech",Fear_NRC_speech)
            feat_fr.set_value(idx,"Joy_NRC_speech",Joy_NRC_speech)
            feat_fr.set_value(idx,"Sadness_NRC_speech",Sadness_NRC_speech)
            feat_fr.set_value(idx,"Anger_NRC_speech",Anger_NRC_speech)
            feat_fr.set_value(idx,"Disgust_NRC_speech",Disgust_NRC_speech)
            feat_fr.set_value(idx,"Anticipation_NRC_speech",Anticipation_NRC_speech)
            feat_fr.set_value(idx,"Surprise_NRC_speech",Surprise_NRC_speech)
            
            feat_fr.set_value(idx,"Trust_NRC_narrated",Trust_NRC_narrated)
            feat_fr.set_value(idx,"Fear_NRC_narrated",Fear_NRC_narrated)
            feat_fr.set_value(idx,"Joy_NRC_narrated",Joy_NRC_narrated)
            feat_fr.set_value(idx,"Sadness_NRC_narrated",Sadness_NRC_narrated)
            feat_fr.set_value(idx,"Anger_NRC_narrated",Anger_NRC_narrated)
            feat_fr.set_value(idx,"Disgust_NRC_narrated",Disgust_NRC_narrated)
            feat_fr.set_value(idx,"Anticipation_NRC_narrated",Anticipation_NRC_narrated)
            feat_fr.set_value(idx,"Surprise_NRC_narrated",Surprise_NRC_narrated)
    
    feat_fr.to_csv(os.path.join(wdir, feature_file), sep=",", encoding="utf-8")
    
    """
    # generate targets
    for tc in target_categories:
        target_fr = pd.DataFrame(index=index, columns=[tc])
        targets = []
        
        for i in idnos:
            t_val = md[md.idno == i][tc].values[0]
            for r in range(5):
                 targets.append(t_val)
            
        target_fr[tc] = targets
    
        target_fr.to_csv(os.path.join(wdir, "targets_" + tc + ".csv"), sep=",", encoding="utf-8")
    """
    print("Done!")
 

def run_classification_experiments():
    """
    Run a series of classification experiments with sentiment features and subgenre targets.
    """   
    wdir = "/home/ulrike/Dokumente/Konferenzen/DH/2018"
    
    # features sets:
    feature_sets = {"WN_all": ["section", "speech", "narrated", "emotional_WN", "neutral_WN", "positive_WN", "negative_WN", 
    "speech_emotional_WN", "narrated_emotional_WN", "speech_neutral_WN", "narrated_neutral_WN"],
    "NRC_polarity": ["section", "speech", "narrated", "emotional_NRC", "neutral_NRC",
    "positive_NRC", "negative_NRC", "speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC"],
    "NRC_all": ["section", "speech", "narrated", "emotional_NRC", "neutral_NRC",
    "positive_NRC", "negative_NRC", "speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC",
    "Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC",
    "Trust_NRC_speech", "Fear_NRC_speech", "Joy_NRC_speech", "Sadness_NRC_speech", "Anger_NRC_speech", "Disgust_NRC_speech", "Anticipation_NRC_speech", "Surprise_NRC_speech",
    "Trust_NRC_narrated", "Fear_NRC_narrated", "Joy_NRC_narrated", "Sadness_NRC_narrated", "Anger_NRC_narrated", "Disgust_NRC_narrated", "Anticipation_NRC_narrated", "Surprise_NRC_narrated"]}
    # feature set descriptions:
    feature_set_desc = {"WN_all": "SentiwordNet 3.0", "NRC_polarity": "NRC (polarity)", "NRC_all": "NRC (polarity + basic emotions)", "WN_plus_NRC": "WN + NRC (polarity + basic emotions)"}
    # targets descriptions:
    targets_desc = {"subgenre-sentimental-interp": "degree of sentimentality (0.0, 0.5, 1.0)", "subgenre-interp-group": "subgenre (costumbrista, sentimental, historical, socio-political)"}
    
    # parameters to vary:
    thresholds = [1,0]
    target_types = ["subgenre-sentimental-interp", "subgenre-interp-group"]
    feature_set_keys = ["WN_all", "NRC_polarity", "NRC_all", "WN_plus_NRC"]
    tree_depths = [4,5,6]
    # = 48 experiments
    
    counter = 0
    
    for thr in thresholds:
        for tar in target_types:
            for fs in feature_set_keys:
                for dep in tree_depths:
                    
                    counter += 1
                    print("Doing experiment no. " + str(counter))
                    print("threshold: " + str(thr))
                    print("targets: " + tar)
                    print("feature set: " + fs)
                    print("tree depth: " + str(dep))
                    
                    targets = pd.read_csv(os.path.join(wdir, "targets_" + tar + ".csv"), sep=",", encoding="utf-8", index_col=0, header=0)
                    targets = targets.applymap(str)
                    
                    features = pd.read_csv(os.path.join(wdir, "features_gt" + str(thr) + ".csv"), sep=",", encoding="utf-8", index_col=0)
                    if fs != "WN_plus_NRC":
                        features = features.loc[:, feature_sets[fs]]
                    
                    tree = DecisionTreeClassifier(max_depth=dep, random_state=0)
                    scores = cross_val_score(tree, features, targets.as_matrix().ravel(), cv=10, scoring="f1_macro")
                    F1_mean = scores.mean()
                    
                    # generate output
                    exp_dir = os.path.join(wdir, "experiments", "exp" + str(counter).zfill(2))
                    
                    if not(os.path.exists(exp_dir)):
                        os.makedirs(exp_dir)
                    
                    readme_path = os.path.join(exp_dir, "readme.md")
                        
                    
                    with open(readme_path, "a", encoding="utf-8") as textfile:
                        textfile.write("Experiment " + str(counter) + "\n")
                        textfile.write("==============================================\n")
                        textfile.write('(Data for the dh2018 proposal "Exploration of Sentiments and Genre in Spanish American Novels")\n')
                        textfile.write("\n")
                        textfile.write("## Parameters\n")
                        textfile.write("\n")
                        textfile.write("* targets: " + targets_desc[tar] + "\n")
                        textfile.write("* emotionality threshold: " + str(thr) + "\n")
                        textfile.write("* sentiment lexicon/selected features: " + feature_set_desc[fs] + "\n")
                        textfile.write("* tree depth: " + str(dep) + "\n")
                        textfile.write("\n")
                        textfile.write("## Results\n")
                        textfile.write("\n")
                        textfile.write("F1 score: " + str(F1_mean))
                        textfile.write("\n")
                        textfile.write("* [tree](tree): visualization of one tree from the experiment")

                    features.to_csv(os.path.join(exp_dir, "features.csv"), sep=",", encoding="utf-8")
                    targets.to_csv(os.path.join(exp_dir, "targets.csv"), sep=",", encoding="utf-8")
	               
                    tree_dir = os.path.join(exp_dir, "tree")
                    if not(os.path.exists(tree_dir)):
                        os.makedirs(tree_dir)
                       
                       
                    X_train, X_test, y_train, y_test = train_test_split(features, targets, stratify=targets, random_state=0)
                    tree.fit(X_train, y_train)
    
                    # print("Accuracy on training set: {:.3f}".format(tree.score(X_train, y_train)))
                    # print("Accuracy in test set: {:.3f}".format(tree.score(X_test, y_test)))
    
                    export_graphviz(tree, out_file=os.path.join(tree_dir, "tree.dot"), class_names=tree.classes_, feature_names=features.columns, impurity=False, filled=True) #class_names=list((set(targets)), 

                    with open(os.path.join(tree_dir, "tree.dot")) as f:
                        dot_graph = f.read()
                        src = graphviz.Source(dot_graph)
                        src.format = "svg"
                        src.render(os.path.join(tree_dir, "tree"))
                   
                    # plot feature importance
                    n_features = len(features.columns)
                    plt.figure(figsize=(10,12))
                    bar_range = range(n_features)
                    plt.barh(bar_range, tree.feature_importances_, align="center", color="red")
    
                    #plt.yticks(np.arange(n_features), map(choose_labels, data_core.columns))
                    plt.yticks(np.arange(n_features), features.columns)
                    plt.xlabel("Feature importance")
                    plt.ylabel("Feature")
                    plt.ylim([0,n_features])
                    plt.grid()
                    plt.tight_layout()
                    plt.savefig(os.path.join(tree_dir, "feature-importance.png"))
                    plt.close()

    print("Done!")


def classify(wdir, md_file, features_file, targets_file):
    """
    """
    md = pd.read_csv(os.path.join(wdir, md_file), sep=",", encoding="utf-8", index_col=0)
    features = pd.read_csv(os.path.join(wdir, features_file), sep=",", encoding="utf-8", index_col=0)
    # select columns to use
    # exp1/5/9/13:
    #features = features.loc[:,["section", "speech", "narrated", "emotional_WN", "neutral_WN", 
    #"positive_WN", "negative_WN", "speech_emotional_WN", "narrated_emotional_WN", "speech_neutral_WN", "narrated_neutral_WN"]]
    
    # exp2/6/10/14:
    #features = features.loc[:,["section", "speech", "narrated", "emotional_NRC", "neutral_NRC", 
    #"positive_NRC", "negative_NRC", "speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC"]]
    
    # exp3/7/11/15:
    """
    features = features.loc[:,["section", "speech", "narrated", "emotional_NRC", "neutral_NRC", 
    "positive_NRC", "negative_NRC", "speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC",
    "Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC",
    "Trust_NRC_speech", "Fear_NRC_speech", "Joy_NRC_speech", "Sadness_NRC_speech", "Anger_NRC_speech", "Disgust_NRC_speech", "Anticipation_NRC_speech", "Surprise_NRC_speech",
    "Trust_NRC_narrated", "Fear_NRC_narrated", "Joy_NRC_narrated", "Sadness_NRC_narrated", "Anger_NRC_narrated", "Disgust_NRC_narrated", "Anticipation_NRC_narrated", "Surprise_NRC_narrated"]]
    """
    
    # exp4/8/12/16: alle features
    
    targets = pd.read_csv(os.path.join(wdir, targets_file), sep=",", encoding="utf-8", index_col=0, header=0)
    targets = targets.applymap(str)

    
    #print(features.shape)
    #print(targets.shape)
    #exit()
    
    tree = DecisionTreeClassifier(max_depth=6, random_state=0)
    
    
    scores = cross_val_score(tree, features, targets.as_matrix().ravel(), cv=10, scoring="f1_macro") # 
    print(scores.mean())
    
    """
    X_train, X_test, y_train, y_test = train_test_split(features, targets, stratify=targets, random_state=0)
    
    tree.fit(X_train, y_train)
    
    
    
    print("Accuracy on training set: {:.3f}".format(tree.score(X_train, y_train)))
    print("Accuracy in test set: {:.3f}".format(tree.score(X_test, y_test)))

    
    export_graphviz(tree, out_file=os.path.join(wdir, "tree.dot"), class_names=tree.classes_, feature_names=features.columns, impurity=False, filled=True) #class_names=list((set(targets)), 

    with open(os.path.join(wdir, "tree.dot")) as f:
	    dot_graph = f.read()
    
    src = graphviz.Source(dot_graph)
    src.format = "svg"

    src.render(os.path.join(wdir, "tree"))
    
    # plot feature importance
    n_features = len(features.columns)
    plt.figure(figsize=(10,12))
    
    bar_range = range(n_features)
    
    plt.barh(bar_range, tree.feature_importances_, align="center", color="red")
    
    #plt.yticks(np.arange(n_features), map(choose_labels, data_core.columns))
    plt.yticks(np.arange(n_features), features.columns)
    plt.xlabel("Feature importance")
    plt.ylabel("Feature")
    plt.ylim([0,n_features])
    plt.grid()
    plt.tight_layout()
    plt.savefig(os.path.join(wdir, "feature-importance.png"))
    
    
    print("Done!")
    """
	

	
    

## -----------------------------------------------
## FREELING: Set desired options for morphological analyzer
## -----------------------------------------------
def my_maco_options(lang,lpath) :

    # create options holder 
    opt = freeling.maco_options(lang);

    # Provide files for morphological submodules. Note that it is not 
    # necessary to set file for modules that will not be used.
    opt.UserMapFile = "";
    opt.LocutionsFile = lpath + "locucions.dat"; 
    opt.AffixFile = lpath + "afixos.dat";
    opt.ProbabilityFile = lpath + "probabilitats.dat"; 
    opt.DictionaryFile = lpath + "dicc.src";
    opt.NPdataFile = lpath + "np.dat"; 
    opt.PunctuationFile = lpath + "../common/punct.dat"; 
    return opt;
    

def fl_process_sentence(text):
    """
    Process a sentence with Freeling.
    Arguments:
    text (str): sentence text
    """
    
    freeling.util_init_locale("default");
    lang = "es"
    ipath = "/usr"
    lpath = ipath + "/share/freeling/" + lang + "/"

    # create analyzers
    tk=freeling.tokenizer(lpath+"tokenizer.dat");
    sp=freeling.splitter(lpath+"splitter.dat");
    
    # create the analyzer with the required set of maco_options  
    morfo=freeling.maco(my_maco_options(lang,lpath));
    
    morfo.set_active_options (False,  # UserMap 
                          True,  # NumbersDetection,  
                          True,  # PunctuationDetection,   
                          True,  # DatesDetection,    
                          True,  # DictionarySearch,  
                          True,  # AffixAnalysis,  
                          False, # CompoundAnalysis, 
                          True,  # RetokContractions,
                          True,  # MultiwordsDetection,  
                          True,  # NERecognition,     
                          False, # QuantitiesDetection,  
                          True); # ProbabilityAssignment
    
    # create tagger
    tagger = freeling.hmm_tagger(lpath+"tagger.dat",True,2)
    
    
    # tokenize input line into a list of words
    lw = tk.tokenize(text)
    # split list of words in sentences, return list of sentences
    ls = sp.split(lw)
    
    # perform morphosyntactic analysis and disambiguation
    ls = morfo.analyze(ls)
    ls = tagger.analyze(ls)
    
    return ls
    
    
## -----------------------------------------------
## FREELING: Do whatever is needed with analyzed sentences
## -----------------------------------------------
def ProcessSentences(ls):

    # for each sentence in list
    for s in ls :
        # for each word in sentence
        for w in s :
            # print word form  
            print("word '"+w.get_form()+"'")
            # print possible analysis in word, output lemma and tag
            print("  Possible analysis: {",end="")
            for a in w :
                print(" ("+a.get_lemma()+","+a.get_tag()+")",end="")
            print(" }")
            #  print analysis selected by the tagger 
            print("  Selected Analysis: ("+w.get_lemma()+","+w.get_tag()+")")
        # sentence separator
        print("")  


   
############### MAIN ################

wdir = "/home/ulrike/Dokumente/Konferenzen/DH/2018"

#get_metadata(wdir, "corpus_tei_2", "metadata.csv")

#get_speech_proportions(wdir, "corpus_tei_2", "metadata.csv")

#read_tei.from_TEIP5(os.path.join(wdir, "corpus_tei", "*.xml"),os.path.join(wdir, "corpus_txt/"),"bodytext")

#spellcheck_nrc_lex(wdir)

#annotate_paragraphs(wdir, "corpus_tei")

#split_paragraphs(wdir, "annotated_paragraphs")


#analyze_sentiments(wdir, "annotated_sentences")


#create_sections(wdir, "sentiments_gt1.csv")

############# BAR CHARTS ######################

#bar_chart_emotional_simple(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_emotional(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_negative_sp(wdir, "metadata.csv", "sentiments.csv", "visuals")
#bar_chart_negative(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_positive_sp(wdir, "metadata.csv", "sentiments.csv", "visuals")
#bar_chart_positive(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_emotions(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_trust(wdir, "metadata.csv", "sentiments.csv", "visuals")
#bar_chart_trust_sp(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_fear(wdir, "metadata.csv", "sentiments.csv", "visuals")
#bar_chart_fear_sp(wdir, "metadata.csv", "sentiments.csv", "visuals")


#bar_chart_joy(wdir, "metadata.csv", "sentiments.csv", "visuals")
#bar_chart_joy_sp(wdir, "metadata.csv", "sentiments.csv", "visuals")


#bar_chart_emotion_type(wdir, "metadata.csv", "sentiments.csv", "visuals", "Sadness")
#bar_chart_emotion_type_sp(wdir, "metadata.csv", "sentiments.csv", "visuals", "Sadness")

#bar_chart_emotion_type(wdir, "metadata.csv", "sentiments.csv", "visuals", "Anger")
#bar_chart_emotion_type_sp(wdir, "metadata.csv", "sentiments.csv", "visuals", "Anger")

#bar_chart_emotion_type(wdir, "metadata.csv", "sentiments.csv", "visuals", "Disgust")
#bar_chart_emotion_type_sp(wdir, "metadata.csv", "sentiments.csv", "visuals", "Disgust")

#bar_chart_emotion_type(wdir, "metadata.csv", "sentiments.csv", "visuals", "Anticipation")
#bar_chart_emotion_type_sp(wdir, "metadata.csv", "sentiments.csv", "visuals", "Anticipation")

#bar_chart_emotion_type(wdir, "metadata.csv", "sentiments.csv", "visuals", "Surprise")
#bar_chart_emotion_type_sp(wdir, "metadata.csv", "sentiments.csv", "visuals", "Surprise")

#bar_chart_speech(wdir, "metadata.csv", "sentiments.csv", "visuals")

#bar_chart_emotions_speech(wdir, "metadata.csv", "sentiments.csv", "visuals")
#bar_chart_emotions_nospeech(wdir, "metadata.csv", "sentiments.csv", "visuals")

#r = fl_process_sentence("Hola.")
#ProcessSentences(r)

############ Learning #############

#generate_features(wdir, "metadata.csv", "sentiments_gt0_sections.csv", "features_gt0.csv", ["subgenre-interp-group", "subgenre-sentimental-interp"])

#classify(os.path.join(wdir,"Analysen","exp13"), "metadata.csv", "features.csv", "targets_subgenre-interp-group.csv")

#run_classification_experiments()

#cluster(wdir, "metadata.csv", "features-emotional.csv", "targets-sentimental.csv")



