#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
@author: Ulrike Henny-Krahmer
@filename: validate_tei.py

Submodule to validate TEI files against the CLiGS RELAX NG schema. This script is based
on a previous version authored by Christof Schöch and Ulrike Henny-Krahmer and published in the CLiGS Toolbox
repository. See https://github.com/cligs/toolbox/blob/master/check_quality/validate_tei.py.
"""

import os
import glob
from lxml import etree


def validate_RNG(teipath, rngfile, logfile):
	"""
	Arguments:
	teipath (str): path to the TEI files, e.g. /home/ulrike/Git/conha19/tei/*.xml
	rngfile (str): path to the RELAX NG schema file, e.g. /home/ulrike/Git/reference/tei/cligs.rng
	logfile (str): path to an output text file, in which the results of the validation are stored, e.g. /home/ulrike/Git/conha19/schema/log-rng.txt
	
	Example call:
    from corpus.metadata_encoding import validate_tei
    validate_tei.validate_RNG("/home/ulrike/Git/conha19/tei/*.xml", "/home/ulrike/Git/reference/tei/cligs.rng", "/home/ulrike/Git/conha19/schema/log-rng.txt")
	"""
	print("starting validation...")
	
	# delete old log, if present
	if os.path.isfile(logfile):
		os.remove(logfile)
		print("old logfile removed")
	
	for teifile in glob.glob(teipath): 
		
		idno = os.path.basename(teifile)
		print("doing " + idno + "...")
        
		parser = etree.XMLParser(recover=True)
		teiparsed = etree.parse(teifile, parser)

		# RelaxNG validation
		rngparsed = etree.parse(rngfile)
		rngvalidator = etree.RelaxNG(rngparsed)
		validation_rng = rngvalidator.validate(teiparsed)
		log_rng = rngvalidator.error_log
		
		with open(logfile, "a", encoding="UTF-8") as outfile:
			if validation_rng == True: 
				outfile.write(idno + ": valid with RNG\n")
			else:
				outfile.write(idno + ": not valid with RNG\n")
				outfile.write(str(log_rng) + "\n")
	print("Done!")


