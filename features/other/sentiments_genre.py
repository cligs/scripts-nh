#!/usr/bin/env python3
# file name: sentiments_genre.py

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
import scipy.stats as st

from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.tree import export_graphviz
from sklearn.model_selection import cross_val_score
from sklearn.metrics import f1_score
import graphviz

########################################################
# analyze sentiments
########################################################


def analyze_sentence(wdir, corpus_folder, sentence_id):
    """
    Analyze the annotated sentence. Return the emotion values of NRC for each word in the sentence.
    
    Arguments:
	wdir (str): working directory
	corpus_folder (str): name of the corpus folder in the wdir (with the annotated sentences)
	sentence_id (str): id of the annotated sentence
    """
    
    sentiWN = pd.read_csv(os.path.join(wdir, "../", "sentiments", "SentiWordNet_3.0.0_20130122.txt"), sep="\t")
    nrc = pd.read_csv(os.path.join(wdir, "../", "sentiments", "NRC-Emotion-Lexicon-v0.92-EN-ES.csv"), sep=",")
    
    
    for file in glob.glob(os.path.join(wdir, "../", corpus_folder, sentence_id + ".xml")):
        # file name pattern: nh0001_p_0_sp_False_s1.xml
        
        file_name = os.path.basename(file)
        print("doing " + file_name + "...")
        idno = file_name[0:6]
        p_num = re.sub(r"^.*p_(\d+)_.*$", r"\1", file_name)
        s_num = re.sub(r"^.*_s(\d+)\.xml", r"\1", file_name)
        sp = re.sub(r"^.*sp_(True|False)_.*$", r"\1", file_name)
        
        xml = etree.parse(file)
        wn_tokens = xml.xpath("//token[@wn]/@wn")
        lemmata = xml.xpath("//token/@lemma")
        
       
        # SentiWordNet
        print("SentiWordNet")
        for wn_t in wn_tokens:
            wn_num = int(wn_t[0:8])
            wn_pos = wn_t[9]
            
            WN_pos = sentiWN.loc[sentiWN.ID == wn_num][sentiWN.POS == wn_pos]["PosScore"]
            WN_neg = sentiWN.loc[sentiWN.ID == wn_num][sentiWN.POS == wn_pos]["NegScore"]
            
            print("Emotion values for lemma " + wn_t)
            
            if not(WN_pos.empty):
                print("Positive: " + str(WN_pos.iloc[0]))
            else:
                print("Error: WN ID " + str(wn_num) + " not found!")
                
            if not(WN_neg.empty):
                print("Negative: " + str(WN_neg.iloc[0]))
            else:
                print("Error: WN ID " + str(wn_num) + " not found!")
                
        
        
        # NRC Emotion Lexicon
        print("NRC Emotion Lexicon")
        for l in lemmata:
            NRC_l = nrc.loc[nrc.Spanish == l]
            
            if not(NRC_l.empty):
                print("Emotion values for lemma " + l + ":")
                
                print("Positive: " + str(NRC_l["Positive"].iloc[0]))
                print("Negative: " + str(NRC_l["Negative"].iloc[0]))
            
                print("Anger: " + str(NRC_l["Anger"].iloc[0]))
                print("Anticipation: " + str(NRC_l["Anticipation"].iloc[0]))
                print("Disgust: " + str(NRC_l["Disgust"].iloc[0]))
                print("Fear: " + str(NRC_l["Fear"].iloc[0]))
                print("Joy: " + str(NRC_l["Joy"].iloc[0]))
                print("Sadness: " + str(NRC_l["Sadness"].iloc[0]))
                print("Surprise: " + str(NRC_l["Surprise"].iloc[0]))
                print("Trust: " + str(NRC_l["Trust"].iloc[0]))
                
                #NRC_lemmata_identified_sentence.append(l)
            else:
                print("Lemma not found in NRC lexicon: " + l)
            
        """       
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
    """
    
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
     "speech_positive_WN", "narrated_positive_WN", "speech_negative_WN", "narrated_negative_WN",
     "emotional_NRC","neutral_NRC","positive_NRC","negative_NRC",
     "speech_emotional_NRC","narrated_emotional_NRC","speech_neutral_NRC","narrated_neutral_NRC",
     "speech_positive_NRC", "narrated_positive_NRC", "speech_negative_NRC", "narrated_negative_NRC",
     "Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC",
     "Trust_NRC_speech", "Trust_NRC_narrated", "Fear_NRC_speech", "Fear_NRC_narrated", "Joy_NRC_speech", "Joy_NRC_narrated", "Sadness_NRC_speech", "Sadness_NRC_narrated",
     "Anger_NRC_speech", "Anger_NRC_narrated", "Disgust_NRC_speech", "Disgust_NRC_narrated", "Anticipation_NRC_speech", "Anticipation_NRC_narrated", "Surprise_NRC_speech", "Surprise_NRC_narrated"])
    
    """
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
            
            speech_positive_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotion_sum > 1][sents.speech == True]) / num_sents) * 100 # Schwelle für positiv
            narrated_positive_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotion_sum > 1][sents.speech == False]) / num_sents) * 100 # Schwelle für positiv
            speech_negative_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotion_sum < -1][sents.speech == True]) / num_sents) * 100 # Schwelle für negativ
            narrated_negative_WN = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.WN_emotion_sum < -1][sents.speech == False]) / num_sents) * 100 # Schwelle für negativ
            
            
            emotional_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 1]) / num_sents) * 100
            neutral_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 0]) / num_sents) * 100
            positive_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum > 1]) / num_sents) * 100 # Schwelle für positiv
            negative_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum < -1]) / num_sents) * 100 # Schwelle für negativ
            
            speech_emotional_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 1][sents.speech == True]) / num_sents) * 100
            narrated_emotional_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 1][sents.speech == False]) / num_sents) * 100
            speech_neutral_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 0][sents.speech == True]) / num_sents) * 100
            narrated_neutral_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotional == 0][sents.speech == False]) / num_sents) * 100
            
            speech_positive_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum > 1][sents.speech == True]) / num_sents) * 100 # Schwelle für positiv
            narrated_positive_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum > 1][sents.speech == False]) / num_sents) * 100
            speech_negative_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum < -1][sents.speech == True]) / num_sents) * 100
            narrated_negative_NRC = (len(sents.loc[sents.text_idno == i][sents.section == sec_num][sents.NRC_emotion_sum < -1][sents.speech == False]) / num_sents) * 100
            
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
            feat_fr.set_value(idx,"speech_positive_WN",speech_positive_WN)
            feat_fr.set_value(idx,"narrated_positive_WN",narrated_positive_WN)
            feat_fr.set_value(idx,"speech_negative_WN",speech_negative_WN)
            feat_fr.set_value(idx,"narrated_negative_WN",narrated_negative_WN)
            
            feat_fr.set_value(idx,"emotional_NRC",emotional_NRC)
            feat_fr.set_value(idx,"neutral_NRC",neutral_NRC)
            feat_fr.set_value(idx,"positive_NRC",positive_NRC)
            feat_fr.set_value(idx,"negative_NRC",negative_NRC)
            feat_fr.set_value(idx,"speech_emotional_NRC",speech_emotional_NRC)
            feat_fr.set_value(idx,"narrated_emotional_NRC",narrated_emotional_NRC)
            feat_fr.set_value(idx,"speech_neutral_NRC",speech_neutral_NRC)
            feat_fr.set_value(idx,"narrated_neutral_NRC",narrated_neutral_NRC)
            feat_fr.set_value(idx,"speech_positive_NRC",speech_positive_NRC)
            feat_fr.set_value(idx,"narrated_positive_NRC",narrated_positive_NRC)
            feat_fr.set_value(idx,"speech_negative_NRC",speech_negative_NRC)
            feat_fr.set_value(idx,"narrated_negative_NRC",narrated_negative_NRC)
            
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
    
    print("Done!")




def run_classification_experiments():
    """
    Run a series of classification experiments with sentiment features and subgenre targets.
    """   
    wdir = "/home/ulrike/Dokumente/Konferenzen/DH/2018/results_2017" #results_2017
    
    # features sets:
    feature_sets = {"WN_all": ["emotional_WN", "neutral_WN", "positive_WN", "negative_WN", 
    "speech_emotional_WN", "narrated_emotional_WN", "speech_neutral_WN", "narrated_neutral_WN",
    "speech_positive_WN", "narrated_positive_WN", "speech_negative_WN", "narrated_negative_WN"],
    
    "NRC_all": ["emotional_NRC", "neutral_NRC",
    "positive_NRC", "negative_NRC", "speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC",
    "speech_positive_NRC", "narrated_positive_NRC", "speech_negative_NRC", "narrated_negative_NRC",
    "Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC",
    "Trust_NRC_speech", "Fear_NRC_speech", "Joy_NRC_speech", "Sadness_NRC_speech", "Anger_NRC_speech", "Disgust_NRC_speech", "Anticipation_NRC_speech", "Surprise_NRC_speech",
    "Trust_NRC_narrated", "Fear_NRC_narrated", "Joy_NRC_narrated", "Sadness_NRC_narrated", "Anger_NRC_narrated", "Disgust_NRC_narrated", "Anticipation_NRC_narrated", "Surprise_NRC_narrated"],
    
    "NRC_polarity": ["emotional_NRC", "neutral_NRC",
    "positive_NRC", "negative_NRC", "speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC",
    "speech_positive_NRC", "narrated_positive_NRC", "speech_negative_NRC", "narrated_negative_NRC"],
    
    "NRC_emotions": ["Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC",
    "Trust_NRC_speech", "Fear_NRC_speech", "Joy_NRC_speech", "Sadness_NRC_speech", "Anger_NRC_speech", "Disgust_NRC_speech", "Anticipation_NRC_speech", "Surprise_NRC_speech",
    "Trust_NRC_narrated", "Fear_NRC_narrated", "Joy_NRC_narrated", "Sadness_NRC_narrated", "Anger_NRC_narrated", "Disgust_NRC_narrated", "Anticipation_NRC_narrated", "Surprise_NRC_narrated"],
    
    "WN_all_bare" : ["emotional_WN", "neutral_WN", "positive_WN", "negative_WN"],
    
    "WN_all_speech" : ["speech_emotional_WN", "narrated_emotional_WN", "speech_neutral_WN", "narrated_neutral_WN", 
    "speech_positive_WN", "narrated_positive_WN", "speech_negative_WN", "narrated_negative_WN"],
    
    "NRC_all_bare" : ["emotional_NRC", "neutral_NRC",
    "positive_NRC", "negative_NRC",
    "Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC"],
    
    "NRC_all_speech" : ["speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC",
    "speech_positive_NRC", "narrated_positive_NRC", "speech_negative_NRC", "narrated_negative_NRC",
    "Trust_NRC_speech", "Fear_NRC_speech", "Joy_NRC_speech", "Sadness_NRC_speech", "Anger_NRC_speech", "Disgust_NRC_speech", "Anticipation_NRC_speech", "Surprise_NRC_speech",
    "Trust_NRC_narrated", "Fear_NRC_narrated", "Joy_NRC_narrated", "Sadness_NRC_narrated", "Anger_NRC_narrated", "Disgust_NRC_narrated", "Anticipation_NRC_narrated", "Surprise_NRC_narrated"],
    
    "NRC_polarity_bare": ["emotional_NRC", "neutral_NRC",
    "positive_NRC", "negative_NRC"],
    
    "NRC_polarity_speech": ["speech_emotional_NRC", "narrated_emotional_NRC", "speech_neutral_NRC", "narrated_neutral_NRC",
    "speech_positive_NRC", "narrated_positive_NRC", "speech_negative_NRC", "narrated_negative_NRC"],
    
    "NRC_emotions_bare": ["Trust_NRC", "Fear_NRC", "Joy_NRC", "Sadness_NRC", "Anger_NRC", "Disgust_NRC", "Anticipation_NRC", "Surprise_NRC"],
		
	"NRC_emotions_speech": ["Trust_NRC_speech", "Fear_NRC_speech", "Joy_NRC_speech", "Sadness_NRC_speech", "Anger_NRC_speech", "Disgust_NRC_speech", "Anticipation_NRC_speech", "Surprise_NRC_speech",
    "Trust_NRC_narrated", "Fear_NRC_narrated", "Joy_NRC_narrated", "Sadness_NRC_narrated", "Anger_NRC_narrated", "Disgust_NRC_narrated", "Anticipation_NRC_narrated", "Surprise_NRC_narrated"]
    
    }
    # feature set descriptions:
    feature_set_desc = {"WN_all": "WN_all", 
    "NRC_all" : "NRC_all", 
    "NRC_polarity" : "NRC_emotions", 
    "WN_all_bare" : "WN_all_bare",
    "WN_all_speech" : "WN_all_speech",
    "NRC_all_bare" : "NRC_all_bare", 
    "NRC_all_speech" : "NRC_all_speech", 
    "NRC_polarity_bare" : "NRC_polarity_bare",
    "NRC_polarity_speech" : "NRC_polarity_speech",
    "NRC_emotions_bare" : "NRC_emotions_bare",
    "NRC_emotions_speech" : "NRC_emotions_speech"} #"WN_plus_NRC": "WN + NRC (polarity + basic emotions)"
    # targets descriptions:
    targets_desc = {"subgenre-interp-group": "subgenre (costumbrista, sentimental, historical, socio-political)"}
    
    
    # parameters to vary:
    thresholds = [1]
    target_types = ["subgenre-interp-group"]
    feature_set_keys = ["WN_all", "NRC_all", "NRC_polarity", 
    "WN_all_bare", "WN_all_speech", "NRC_all_bare", "NRC_all_speech", 
    "NRC_polarity_bare", "NRC_polarity_speech", "NRC_emotions_bare", "NRC_emotions_speech"] #"WN_plus_NRC"
    tree_depths = range(1,16)
    # = 55 experiments * 5 = 275
    
    counter = 0
    
    # frame to store experiment parameters and results
    exp_fr = pd.DataFrame(columns=["feature_set_key", "tree_depth", "F1_mean", "F1_std"])
    
    
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
                    
                    features = pd.read_csv(os.path.join(wdir, "features_gt" + str(thr) + "_NEU.csv"), sep=",", encoding="utf-8", index_col=0)
                    if fs != "WN_plus_NRC":
                        features = features.loc[:, feature_sets[fs]]
                    
                    tree = DecisionTreeClassifier(max_depth=dep, random_state=0) # max_depth=dep
                    scores = cross_val_score(tree, features, targets.as_matrix().ravel(), cv=5, scoring="f1_weighted") # f1_macro - weighted
                    F1_mean = scores.mean()
                    std = scores.std()
                    
                    #https://stackoverflow.com/questions/15033511/compute-a-confidence-interval-from-sample-data
                    #conf = st.t.interval(0.95, len(scores)-1, loc=np.mean(scores), scale=st.sem(scores))
                    #print(conf)
                    #exit()
                    
                    
                    # store result to exp frame
                    exp_fr.set_value(counter,"feature_set_key",fs)
                    exp_fr.set_value(counter,"tree_depth",dep)
                    exp_fr.set_value(counter,"F1_mean",F1_mean)
                    exp_fr.set_value(counter,"F1_std",std)
                    
                    
                    X_train, X_test, y_train, y_test = train_test_split(features, targets, stratify=targets, random_state=0)
                    tree.fit(X_train, y_train)
    
                    acc_train = "Accuracy on training set: {:.3f}".format(tree.score(X_train, y_train))
                    acc_test = "Accuracy in test set: {:.3f}".format(tree.score(X_test, y_test))
                    
                    y_pred_test = tree.predict(X_test)
                    y_pred_train = tree.predict(X_train)
                    
                    tree_f1_score_test = f1_score(y_test, y_pred_test, average="weighted")
                    tree_f1_score_train = f1_score(y_train, y_pred_train, average="weighted")
                    
                    
                    """
                    for i in range(1,6):
                        ex_section = features.loc["nh0007_" + str(i)].values.reshape(1,-1)
                        pr = tree.predict(ex_section)
                        print(pr)
                    exit()
                    """
                    
                    # generate output
                    exp_dir = os.path.join(wdir, "experiments", "exp" + str(counter).zfill(2))
                    
                    if not(os.path.exists(exp_dir)):
                        os.makedirs(exp_dir)
                    
                    readme_path = os.path.join(exp_dir, "readme.md")
                        
                    
                    with open(readme_path, "w", encoding="utf-8") as textfile:
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
                        textfile.write(acc_train)
                        textfile.write("\n")
                        textfile.write(acc_test)
                        textfile.write("\n")
                        textfile.write("F1 test set for tree: " + str(tree_f1_score_test))
                        textfile.write("\n")
                        textfile.write("F1 train set for tree: " + str(tree_f1_score_train))

                    features.to_csv(os.path.join(exp_dir, "features.csv"), sep=",", encoding="utf-8")
                    targets.to_csv(os.path.join(exp_dir, "targets.csv"), sep=",", encoding="utf-8")
	               
                    tree_dir = os.path.join(exp_dir, "tree")
                    if not(os.path.exists(tree_dir)):
                        os.makedirs(tree_dir)
                       
    
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

    
    exp_fr.to_csv(os.path.join(wdir, "exp_results.csv"), sep=",", encoding="utf-8")
    print("Done!")


def results_overview(wdir, results_file):
    """
    Create a bar chart with an overview of the classification results
    
    Arguments:
	wdir (str): working directory
	results_file (str): csv file holding the results
    """
    exp_results = pd.read_csv(os.path.join(wdir, results_file), sep=",", encoding="utf-8", index_col=0, header=0)
    
    F1_WN_all_bare = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "WN_all_bare"].F1_mean)) + "]"
    std_WN_all_bare = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "WN_all_bare"].F1_std)) + "]"
    
    F1_NRC_all_bare = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "NRC_all_bare"].F1_mean)) + "]"
    std_NRC_all_bare = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "NRC_all_bare"].F1_std)) + "]"
    
    F1_WN_speech = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "WN_all_speech"].F1_mean)) + "]"
    std_WN_speech = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "WN_all_speech"].F1_std)) + "]"
    
    F1_NRC_speech = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "NRC_all_speech"].F1_mean)) + "]"
    std_NRC_speech = "[" + ",".join(str(e) for e in list(exp_results.loc[exp_results.feature_set_key == "NRC_all_speech"].F1_std)) + "]"
    
    with open(os.path.join(wdir, "barline_plotly_2.html"), "w", encoding="utf-8") as textfile:
        textfile.write("<html><head><script type='text/javascript' src='plotly-latest.min.js'></script></head>")
        textfile.write("\n")
        textfile.write("<body>")
        textfile.write("\n")
        textfile.write("<div id='chart_div' style='width: 1300px; height: 900px;'></div>")
        textfile.write("\n")
        textfile.write("<script type='text/javascript'>")
        textfile.write("\n")
        textfile.write("var WN = {")
        textfile.write("\n")
        textfile.write("x: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],")
        textfile.write("\n")
        textfile.write("y: " + F1_WN_all_bare + ",")
        textfile.write("\n")
        textfile.write("name: 'WN',")
        textfile.write("\n")
        textfile.write("error_y: {")
        textfile.write("\n")
        textfile.write("type: 'data',")
        textfile.write("\n")
        textfile.write("array: " + std_WN_all_bare + ",")
        textfile.write("\n")
        textfile.write("color: '#999999',")
        textfile.write("\n")
        textfile.write("visible: true")
        textfile.write("\n")
        textfile.write("},")
        textfile.write("\n")
        textfile.write("type: 'bar'")
        textfile.write("\n")
        textfile.write("};")
        textfile.write("\n")
        textfile.write("var NRC = {")
        textfile.write("\n")
        textfile.write("x: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],")
        textfile.write("\n")
        textfile.write("y: " + F1_NRC_all_bare + ",")
        textfile.write("\n")
        textfile.write("name: 'NRC',")
        textfile.write("\n")
        textfile.write("error_y: {")
        textfile.write("\n")
        textfile.write("type: 'data',")
        textfile.write("\n")
        textfile.write("array: " + std_NRC_all_bare + ",")
        textfile.write("\n")
        textfile.write("color: '#999999',")
        textfile.write("\n")
        textfile.write("visible: true")
        textfile.write("\n")
        textfile.write("},")
        textfile.write("\n")
        textfile.write("type: 'bar'")
        textfile.write("\n")
        textfile.write("};")
        textfile.write("\n")
        textfile.write("var WN_speech = {")
        textfile.write("\n")
        textfile.write("x: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],")
        textfile.write("\n")
        textfile.write("y: " + F1_WN_speech + ",")
        textfile.write("\n")
        textfile.write("name: 'WN_speech',")
        textfile.write("\n")
        textfile.write("error_y: {")
        textfile.write("\n")
        textfile.write("type: 'data',")
        textfile.write("\n")
        textfile.write("array: " + std_WN_speech + ",")
        textfile.write("\n")
        textfile.write("color: '#999999',")
        textfile.write("\n")
        textfile.write("visible: true")
        textfile.write("\n")
        textfile.write("},")
        textfile.write("\n")
        textfile.write("type: 'bar'")
        textfile.write("\n")
        textfile.write("};")
        textfile.write("\n")
        textfile.write("var NRC_speech = {")
        textfile.write("\n")
        textfile.write("x: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],")
        textfile.write("\n")
        textfile.write("y: " + F1_NRC_speech + ",")
        textfile.write("\n")
        textfile.write("name: 'NRC_speech',")
        textfile.write("\n")
        textfile.write("error_y: {")
        textfile.write("\n")
        textfile.write("type: 'data',")
        textfile.write("\n")
        textfile.write("array: " + std_NRC_speech + ",")
        textfile.write("\n")
        textfile.write("color: '#999999',")
        textfile.write("\n")
        textfile.write("visible: true")
        textfile.write("\n")
        textfile.write("},")
        textfile.write("\n")
        textfile.write("type: 'bar'")
        textfile.write("\n")
        textfile.write("};")
        textfile.write("\n")
        textfile.write("var Baseline_most_frequent = {")
        textfile.write("\n")
        textfile.write("x: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],")
        textfile.write("\n")
        textfile.write("y: [0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3],")
        textfile.write("\n")
        textfile.write("name: 'Baseline most frequent',")
        textfile.write("\n")
        textfile.write("type: 'scatter',")
        textfile.write("\n")
        textfile.write("line: {width: 5, color: '#333333'}")
        textfile.write("\n")
        textfile.write("};")
        textfile.write("\n")
        textfile.write("var data = [WN, NRC, WN_speech, NRC_speech, Baseline_most_frequent];")
        textfile.write("\n")
        textfile.write("var layout = {")
        textfile.write("\n")
        textfile.write("barmode: 'group',")
        textfile.write("\n")
        textfile.write("xaxis: {")
        textfile.write("\n")
        textfile.write("title: 'Tree depth',")
        textfile.write("\n")
        textfile.write("autotick: false,")
        textfile.write("\n")
        textfile.write("tickfont: { size: 22 },")
        textfile.write("\n")
        textfile.write("titlefont: { size: 24 }},")
        textfile.write("\n")
        textfile.write("yaxis: {")
        textfile.write("\n")
        textfile.write("title: 'F1 (mean)',")
        textfile.write("\n")
        textfile.write("tickfont: { size: 22 },")
        textfile.write("\n")
        textfile.write("titlefont: { size: 24 }},")
        textfile.write("\n")
        textfile.write("legend: {")
        textfile.write("\n")
        textfile.write("font: { size: 24}}")
        textfile.write("\n")
        textfile.write("};")
        textfile.write("\n")
        textfile.write("Plotly.newPlot('chart_div', data, layout);")
        textfile.write("\n")
        textfile.write("</script></body></html>")
        
    print("done")


##############################################################################

wdir = "/home/ulrike/Dokumente/Konferenzen/DH/2018/results_2017" #results_2017

# first step:
#annotate_paragraphs(wdir, "corpus_tei")

# 2:
#split_paragraphs(wdir, "annotated_paragraphs")

# 3:
#analyze_sentiments(wdir, "annotated_sentences")

# 4:
#create_sections(wdir, "sentiments_gt1.csv")

# 5:
#generate_features(wdir, "metadata.csv", "sentiments_gt1_sections.csv", "features_gt1_NEU.csv", ["subgenre-interp-group"])

# 6:
run_classification_experiments()

# extra:
#analyze_sentence(wdir, "annotated_sentences", "nh0016_p_607_sp_False_s0")

#results_overview(wdir, "exp_results.csv")
