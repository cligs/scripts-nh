#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Calls functions from hispam modules

@author: Ulrike Henny-Krahmer
"""

import sys
import os
from os.path import join

sys.path.append(os.path.abspath("/home/ulrike/Git/scripts-nh/corpus"))

from corpus.text_treatment import spellchecking
from corpus.metadata_encoding import corpus_copyright
from corpus.metadata_encoding import validate_tei
from features import bow

### spell checking ###
wdir="/home/ulrike/Git/conha19/"
wdir_2 = "/home/ulrike/Git/data-nh/corpus/text-treatment/"
exdir = "/home/ulrike/Git/data-nh/corpus/text-treatment/exception-words/source-lists/" 

ex_lists = [join(exdir, "../exceptions-proper-names_ext.txt"), join(exdir,"../exceptions-surnames_ext.txt"), join(exdir,"../exceptions-countries_ext.txt"),  join(exdir, "capitals-es.txt"),
join(exdir, "../exceptions-diminutives.txt"), join(exdir, "../exceptions-superlatives.txt"), join(exdir, "../exceptions-adverbs.txt"), join(exdir, "../exceptions-verb-forms.txt"),
join(exdir, "../exceptions-foreign.txt"), join(exdir, "../exceptions-oral.txt"), join(exdir, "../exceptions-places.txt"), join(exdir, "../exceptions-special.txt"),
join(exdir, "../exceptions-archaic.txt"), join(exdir, "../exceptions-other.txt")]

#spellchecking.check_collection(wdir, "txt/*.txt", "spellcheck.csv", "es", ex_lists)

for filename in os.listdir(join(wdir,"txt")):
	idno = filename[:-4]
	spellchecking.check_collection(wdir, join("txt", idno + ".txt"), "spellcheck_" + idno + ".csv", "es", ex_lists)

#spellchecking.plot_error_distribution(wdir_2, "spellcheck_exc.csv") # log="yes"
#spellchecking.plot_top_errors(wdir_2, "spellcheck_exc.csv", 30)
#spellchecking.plot_errors_per_file(wdir_2, "spellcheck_exc.csv", "both", "relative")
#spellchecking.plot_errors_per_file_grouped(wdir_2, "spellcheck_exc.csv", "/home/ulrike/Git/data-nh/corpus/metadata_sources.csv", "sources_edition", "relative")



"""
spellchecking.plot_errors_covered_exceptions(wdir_2, "spellcheck.csv", ["exception-words/exceptions-places.txt", "exception-words/exceptions-countries_ext.txt", 
"exception-words/exceptions-foreign.txt", "exception-words/exceptions-oral.txt", "exception-words/exceptions-archaic.txt", "exception-words/exceptions-other.txt",
"exception-words/exceptions-proper-names_ext.txt", "exception-words/exceptions-special.txt", "exception-words/exceptions-surnames.txt",
"exception-words/exceptions-diminutives.txt", "exception-words/exceptions-verb-forms.txt", "exception-words/exceptions-adverbs.txt",
"exception-words/exceptions-superlatives.txt", "exception-words/exceptions-capitals.txt"], 
["places", "countries", "foreign words", "oral speech", "archaic vocabulary", "other", "proper names", "specialized vocabulary", "surnames", "diminutives", 
"verb forms with pronoun suffixes", "adverbs", "superlatives", "capitals"])
"""

#spellchecking.count_errors(wdir_2, "spellcheck_exc.csv")
#spellchecking.generate_exception_list(wdir, join(exdir, "diminutive-patterns-es.txt"), join(wdir, "spellcheck.csv"), "exceptions-diminutives.txt", "ending")
#spellchecking.interprete_exception_list(wdir, join(exdir, "../exceptions-archaic.txt"), join(exdir, "../exceptions-archaic.txt"), join(wdir, "spellcheck.csv"))


### copyright ###

wdir = "/home/ulrike/Git/data-nh/corpus/metadata-encoding/"
#corpus_copyright.plot_author_death_years(wdir, "../metadata_copyright.csv", "authors-death-years.html")
#corpus_copyright.plot_edition_years(wdir, "../metadata_copyright.csv", "base-publication-years.html", "base")
#corpus_copyright.plot_copyright_status(wdir, "../metadata_copyright.csv", "copyright-status.html")


### validation ###
#validate_tei.validate_RNG("/home/ulrike/Git/conha19/tei/*.xml", "/home/ulrike/Git/reference/tei/cligs.rng", "/home/ulrike/Git/conha19/schema/log-rng.txt")


### other ###

#bow.create_bow_model(wdir, "txt", "bow.csv")





