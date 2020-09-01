#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Annotation Workflow

- converts TEI master files to annotated TEI files
- annotation with Freeling and WordNet

The final results are stored in a folder "teia".
Run this file directly.


@author: Ulrike Henny-Krahmer, José Calvo Tello
@filename: workflow_teifw.py 


Check for existing FreeLing servers from the command line:
netstat -tlnp | grep analyzer
Kill existing FreeLing server:
kill 6899 (for example)

"""

import prepare_tei
import annotate_fw

############ Options ##############

# where the TEI master files are

infolder = "/home/ulrike/Git/conha19/tei/"

# where the annotation working files and results should go
outfolder = "/home/ulrike/Git/conha19/annotated/"

# language of the texts (possible up to now: fr, es, it, pt)
lang = "es"

server = True

print(infolder)
import sys
import os
import time
start_time = time.time()


# by default, it should be enough to change the options above and leave this as is

#prepare_tei.prepare("split-p", infolder, outfolder)
#annotate_fw.annotate_fw(os.path.join(outfolder, "txt/*.txt"), os.path.join(outfolder, "fl/"), os.path.join(outfolder, "annotated_temp/"), lang, server)
prepare_tei.prepare("merge-p", outfolder, os.path.join(outfolder, "annotated"))

print("--- %s seconds ---" % (time.time() - start_time))

