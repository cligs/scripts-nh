<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:cligs="https://cligs.hypotheses.org/ns/cligs"
    version="2.0">
    
    <!-- 
    @author: Ulrike Henny-Krahmer

    This script produces overviews of the contents in the bibliography Bib-ACMé and the corpus Conha19 (in numbers and plots).
    
    How to call the script:
        java -jar /home/ulrike/Programme/saxon/saxon9he.jar /home/ulrike/Git/conha19/tei/nh0001.xml /home/ulrike/Git/scripts-nh/corpus/overview.xsl
    -->
    
    <xsl:variable name="output-dir">/home/ulrike/Git/data-nh/corpus/overview/</xsl:variable>
    <xsl:variable name="bibacme-authors" select="doc('/home/ulrike/Git/bibacme/app/data/authors.xml')//person"/>
    <xsl:variable name="bibacme-works" select="doc('/home/ulrike/Git/bibacme/app/data/works.xml')//bibl"/>
    <xsl:variable name="bibacme-editions" select="doc('/home/ulrike/Git/bibacme/app/data/editions.xml')//biblStruct"/>
    <xsl:variable name="corpus" select="collection('/home/ulrike/Git/conha19/tei/')//TEI"/>
    <xsl:variable name="corpus-authors-ids" select="distinct-values($corpus//titleStmt/author/idno[@type='bibacme'])"/>
    <xsl:variable name="corpus-authors" select="$bibacme-authors[@xml:id=$corpus-authors-ids]"/>
    <xsl:variable name="corpus-works" select="$bibacme-works[idno[@type='cligs']]"/>
    <xsl:variable name="corpus-editions" select="$bibacme-editions[substring-after(@corresp,'#') = $corpus-works/@xml:id]"/>
    <xsl:variable name="nationalities" select="doc('/home/ulrike/Git/bibacme/app/data/nationalities.xml')//term[@type='general']"/>
    <xsl:variable name="countries" select="doc('/home/ulrike/Git/bibacme/app/data/countries.xml')//place"/>
    <xsl:variable name="birth-places" select="distinct-values($bibacme-authors/birth/placeName[last()])"/>
    <xsl:variable name="death-places" select="distinct-values($bibacme-authors/death/placeName[last()])"/>
    <xsl:variable name="decades" select="(1830,1840,1850,1860,1870,1880,1890,1900,1910)"/>
    <xsl:variable name="num-works-bib" select="count($bibacme-works)"/>
    <xsl:variable name="num-works-corp" select="count($corpus)"/>
    
    <xsl:template match="/">
        
        <!-- Choose the overviews to be generated here by taking out comments of 
        template calls. Additional overviews that could be (but have not been) created (yet)
        are given in comments enclosed by ## ... ##. -->
        
        <xsl:call-template name="numbers"/>
        
        <!-- ##### AUTHORS ##### -->
        
        <!--<xsl:call-template name="plot-works-per-author"/>-->
        <!--<xsl:call-template name="list-works-per-author-top"/>-->
        <!-- ## works per author 1880 ## -->
        <!-- ## works per author by country ## -->
        
        <!--<xsl:call-template name="plot-editions-per-author"/>-->
        <!--<xsl:call-template name="list-editions-per-author-top"/>-->
        <!-- ## editions per author 1880 ## -->
        <!-- ## editions per author by country ## -->
        
        <!--<xsl:call-template name="plot-author-gender"/>-->
        
        <!--<xsl:call-template name="plot-author-dates-known"/>-->
        <!--<xsl:call-template name="plot-author-births-deaths"/>-->
        <!--<xsl:call-template name="plot-author-births-deaths-decades"/>-->
        <!-- ## authors births deaths by country ## -->
        <!--<xsl:call-template name="plot-authors-alive"/>-->
        <!-- ## authors alive 1880 ## -->
        <!--<xsl:call-template name="plot-authors-active"/>-->
        <!--<xsl:call-template name="plot-authors-active-1880"/>-->
        <!-- ## authors active gender ## -->
        <!--<xsl:call-template name="plot-authors-age"/>-->
        <!--<xsl:call-template name="plot-authors-age-decades"/>-->
        <!--<xsl:call-template name="plot-authors-age-1880"/>-->
        <!--<xsl:call-template name="plot-authors-age-death"/>-->
        <!-- ## authors age death by decade ## -->
        <!-- ## authors age death by country ## -->
        
        <!--<xsl:call-template name="plot-authors-by-country"/>-->
        <!--<xsl:call-template name="plot-authors-by-nationality"/>-->
        <!--<xsl:call-template name="plot-authors-by-birth-place"/>-->
        <!--<xsl:call-template name="plot-authors-by-death-place"/>-->
        
        
        <!-- ##### WORKS ##### -->
        <!--<xsl:call-template name="plot-works-per-year"/>-->
        <!--<xsl:call-template name="plot-works-per-decade"/>-->
        <!--<xsl:call-template name="plot-works-1880"/>-->
        
        <!--<xsl:call-template name="plot-works-by-country"/>-->
        <!--<xsl:call-template name="plot-works-by-country-year"/>-->
        <!--<xsl:call-template name="plot-works-by-country-decade"/>-->
        <!--<xsl:call-template name="plot-works-by-country-1880"/>-->
        <!--<xsl:call-template name="plot-works-by-country-first-edition"/>-->        
        
        <!-- ## corpus-specific overviews ## -->
        <!--<xsl:call-template name="plot-corpus-works-length"/>-->
        <!--<xsl:call-template name="plot-corpus-works-length-decade"/>-->
        <!--<xsl:call-template name="plot-corpus-works-length-1880"/>-->
        <!--<xsl:call-template name="plot-corpus-works-length-country"/>-->
        
        <!--<xsl:call-template name="plot-corpus-narrative-perspective-decade"/>-->
        <!--<xsl:call-template name="plot-corpus-narrative-perspective-1880"/>-->
        <!--<xsl:call-template name="plot-corpus-narrative-perspective-country"/>-->
        
        <!--<xsl:call-template name="plot-corpus-prestige-decade"/>-->
        <!--<xsl:call-template name="plot-corpus-prestige-1880"/>-->
        <!--<xsl:call-template name="plot-corpus-prestige-country"/>-->
        
        <!--<xsl:call-template name="plot-corpus-setting"/>-->
        <!--<xsl:call-template name="plot-corpus-setting-continent-decade"/>-->
        <!--<xsl:call-template name="plot-corpus-setting-continent-1880"/>-->
        <!--<xsl:call-template name="plot-corpus-setting-continent-country"/>-->
        
        <!--<xsl:call-template name="plot-corpus-time-period"/>-->
        <!--<xsl:call-template name="plot-corpus-time-period-publication-decade"/>-->
        <!--<xsl:call-template name="plot-corpus-time-period-publication-1880"/>-->
        <!--<xsl:call-template name="plot-corpus-time-period-publication-country"/>-->
        
        
        <!-- ##### EDITIONS ##### -->
        <!--<xsl:call-template name="plot-editions-per-work"/>-->
        <!--<xsl:call-template name="plot-editions-by-year"/>-->
        <!--<xsl:call-template name="plot-editions-by-decade"/>-->
        <!--<xsl:call-template name="plot-editions-1880"/>-->
        <!--<xsl:call-template name="plot-editions-by-country"/>-->
        <!-- ## editions by country year, decade, 1880 ## -->
        <!--<xsl:call-template name="plot-editions-publication-place"/>-->
        
        <!-- ##### SUBGENRES ##### -->
        <!--<xsl:call-template name="plot-subgenres-novela-by-decade"/>-->
        <!--<xsl:call-template name="plot-subgenres-explicit-signals"/>-->
        <!--<xsl:call-template name="plot-subgenres-explicit-signals-corpus"/>-->
        <!--<xsl:call-template name="plot-subgenres-identity-by-decade"/>-->
        <!--<xsl:call-template name="plot-subgenres-signals"/>-->
        <!--<xsl:call-template name="plot-subgenres-signals-corpus"/>-->
        <!--<xsl:call-template name="plot-subgenres-litHist"/>-->
        <!--<xsl:call-template name="plot-subgenres-litHist-corpus"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-labels-number-bib"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-number-corpus"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-amount-bib"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-amount-corpus"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-labels-number-explicit-bib"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-number-explicit-corp"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-number-litHist-bib"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-number-litHist-corp"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-amount-explicit-bib"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-amount-explicit-corp"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-amount-litHist-bib"/>-->
        <!--<xsl:call-template name="plot-subgenres-labels-amount-litHist-corp"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-theme"/>-->
        <!--<xsl:call-template name="plot-subgenres-theme-bib-sources"/>-->
        <!--<xsl:call-template name="plot-subgenres-num-thematic-labels-work"/>-->
        <!--<xsl:call-template name="plot-subgenres-thematic-primary"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-current"/>-->
        <!--<xsl:call-template name="plot-subgenres-current-bib-sources"/>-->
        <!--<xsl:call-template name="plot-subgenres-current-years"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-mode-representation"/>-->
        <!--<xsl:call-template name="plot-subgenres-mode-representation-bib-sources"/>-->
        <!--<xsl:call-template name="label-combinations-mode-representation"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-mode-reality"/>-->
        <!--<xsl:call-template name="plot-subgenres-mode-reality-bib-sources"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-identity"/>-->
        <!--<xsl:call-template name="plot-subgenres-identity-bib-sources"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-mode-medium"/>-->
        <!--<xsl:call-template name="plot-subgenres-mode-medium-bib-sources"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-mode-attitude"/>-->
        <!--<xsl:call-template name="plot-subgenres-mode-attitude-bib-sources"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-mode-intention"/>-->
        <!--<xsl:call-template name="plot-subgenres-mode-intention-bib-sources"/>-->
        
        <!--<xsl:call-template name="plot-subgenres-num-works-label"/>-->
        <!--<xsl:call-template name="list-subgenres-num-works-label"/>-->
    </xsl:template>
    
    <!-- ########### TEMPLATES ############ -->
    
    <xsl:template name="numbers">
        <!-- overall counts of authors, works, editions, etc. -->
        <xsl:result-document href="{concat($output-dir,'numbers.txt')}" method="text" encoding="UTF-8">
            
            <!-- number of different works -->
            <xsl:text>Number of different works in Bib-ACMé: </xsl:text>
            <xsl:value-of select="$num-works-bib"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different works in Conha19: </xsl:text>
            <xsl:value-of select="$num-works-corp"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-corp div ($num-works-bib div 100)"/><xsl:text> %)</xsl:text>
            
            <!-- number of different authors -->
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different authors in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-authors-bib" select="count($bibacme-authors)"/>
            <xsl:value-of select="$num-authors-bib"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different authors in Conha19: </xsl:text>
            <xsl:variable name="num-authors-corp" select="count(distinct-values($corpus//titleStmt/author/idno[@type='bibacme']))"/>
            <xsl:value-of select="$num-authors-corp"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-authors-corp div ($num-authors-bib div 100)"/><xsl:text> %)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Mean number of works per author in Bib-ACMé: </xsl:text>
            <xsl:variable name="mean-num-works-per-author-bib" select="count($bibacme-works) div $num-authors-bib"/>
            <xsl:value-of select="$mean-num-works-per-author-bib"/>
            <xsl:text>
</xsl:text>
            <xsl:text>Mean number of works per author in Conha19: </xsl:text>
            <xsl:variable name="mean-num-works-per-author-corp" select="count($corpus) div $num-authors-corp"/>
            <xsl:value-of select="$mean-num-works-per-author-corp"/>
            
            <!-- author gender, Bib-ACMé -->
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works written by male authors in Bib-ACMé: </xsl:text>
            <xsl:variable name="male-author-ids" select="$bibacme-authors[sex='masculino']/@xml:id"/>
            <xsl:variable name="num-works-male-authors-bib" select="count($bibacme-works[author/@key=$male-author-ids])"/>
            <xsl:value-of select="$num-works-male-authors-bib"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-male-authors-bib div (count($bibacme-works) div 100)"/><xsl:text> %)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works written by female authors in Bib-ACMé: </xsl:text>
            <xsl:variable name="female-author-ids" select="$bibacme-authors[sex='femenino']/@xml:id"/>
            <xsl:variable name="num-works-female-authors-bib" select="count($bibacme-works[author/@key=$female-author-ids])"/>
            <xsl:value-of select="$num-works-female-authors-bib"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-female-authors-bib div (count($bibacme-works) div 100)"/><xsl:text> %)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works written by authors of unknown gender in Bib-ACMé: </xsl:text>
            <xsl:variable name="unknown-gender-author-ids" select="$bibacme-authors[sex='desconocido']/@xml:id"/>
            <xsl:variable name="num-works-unknown-gender-authors-bib" select="count($bibacme-works[author/@key=$unknown-gender-author-ids])"/>
            <xsl:value-of select="$num-works-unknown-gender-authors-bib"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-unknown-gender-authors-bib div (count($bibacme-works) div 100)"/><xsl:text> %)</xsl:text>
            
            <!-- author gender, Conha19 -->
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works written by male authors in Conha19: </xsl:text>
            <xsl:variable name="male-author-ids" select="$bibacme-authors[sex='masculino']/@xml:id"/>
            <xsl:variable name="num-works-male-authors-corp" select="count($corpus[.//titleStmt/author/idno[@type='bibacme'] = $male-author-ids])"/>
            <xsl:value-of select="$num-works-male-authors-corp"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-male-authors-corp div (count($corpus) div 100)"/><xsl:text> %)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works written by female authors in Conha19: </xsl:text>
            <xsl:variable name="female-author-ids" select="$bibacme-authors[sex='femenino']/@xml:id"/>
            <xsl:variable name="num-works-female-authors-corp" select="count($corpus[.//titleStmt/author/idno[@type='bibacme'] = $female-author-ids])"/>
            <xsl:value-of select="$num-works-female-authors-corp"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-female-authors-corp div (count($corpus) div 100)"/><xsl:text> %)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works written by authors of unknown gender in Conha19: </xsl:text>
            <xsl:variable name="unknown-gender-author-ids" select="$bibacme-authors[sex='desconocido']/@xml:id"/>
            <xsl:variable name="num-works-unknown-gender-authors-corp" select="count($corpus[.//titleStmt/author/idno[@type='bibacme'] = $unknown-gender-author-ids])"/>
            <xsl:value-of select="$num-works-unknown-gender-authors-corp"/>
            <xsl:text> (</xsl:text><xsl:value-of select="$num-works-unknown-gender-authors-corp div (count($corpus) div 100)"/><xsl:text> %)</xsl:text>
            
            <!-- author, births and deaths -->
            <xsl:variable name="author-birth-unknown-bib" select="count($bibacme-authors[birth/date='desconocido'])"/>
            <xsl:variable name="author-death-unknown-bib" select="count($bibacme-authors[death/date='desconocido'])"/>
            <xsl:variable name="author-birth-unknown-corp" select="count($bibacme-authors[@xml:id = $corpus-authors-ids][birth/date='desconocido'])"/>
            <xsl:variable name="author-death-unknown-corp" select="count($bibacme-authors[@xml:id = $corpus-authors-ids][death/date='desconocido'])"/>
            <xsl:text>
</xsl:text>
            <xsl:text>Number of authors with unknown birth date (Bib-ACMé): </xsl:text>
            <xsl:value-of select="$author-birth-unknown-bib"/>
            <xsl:text>
</xsl:text>
            <xsl:text>Number of authors with unknown birth date (Conha19): </xsl:text>
            <xsl:value-of select="$author-birth-unknown-corp"/>
            <xsl:text>
</xsl:text>
            <xsl:text>Number of authors with unknown death date (Bib-ACMé): </xsl:text>
            <xsl:value-of select="$author-death-unknown-bib"/>
            <xsl:text>
</xsl:text>
            <xsl:text>Number of authors with unknown death date (Conha19): </xsl:text>
            <xsl:value-of select="$author-death-unknown-corp"/>
            
            <!-- corpus: narrative perspective -->
            <xsl:text>
</xsl:text>
            <xsl:text>Novels in Conha19 with first person narrator: </xsl:text>
            <xsl:variable name="num-first-person" select="count($corpus[.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
            <xsl:value-of select="$num-first-person"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-first-person div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:text>Novels in Conha19 with third person narrator: </xsl:text>
            <xsl:variable name="num-third-person" select="count($corpus[.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
            <xsl:value-of select="$num-third-person"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-third-person div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <!-- corpus: narrative prestige -->
            <xsl:text>
</xsl:text>
            <xsl:text>Novels in Conha19 that are high prestige: </xsl:text>
            <xsl:variable name="num-high-prestige" select="count($corpus[.//term[@type='text.prestige'] = 'high'])"/>
            <xsl:value-of select="$num-high-prestige"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-high-prestige div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Novels in Conha19 that are low prestige: </xsl:text>
            <xsl:variable name="num-low-prestige" select="count($corpus[.//term[@type='text.prestige'] = 'low'])"/>
            <xsl:value-of select="$num-low-prestige"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-low-prestige div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <!-- editions -->
            <xsl:text>
</xsl:text>
            <xsl:text>Number of editions in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-editions-bib" select="count($bibacme-editions)"/>
            <xsl:value-of select="$num-editions-bib"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of editions in Conha19: </xsl:text>
            <xsl:variable name="num-editions-corp" select="count($corpus-editions)"/>
            <xsl:value-of select="$num-editions-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-editions-corp div ($num-editions-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <!-- subgenres -->
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with explicit subgenre signal in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-explicit-bib" select="count($bibacme-works[term[@type='subgenre.summary.signal.explicit']])"/>
            <xsl:value-of select="$num-explicit-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-explicit-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with explicit subgenre signal Conha19: </xsl:text>
            <xsl:variable name="num-explicit-corp" select="count($corpus-works[term[@type='subgenre.summary.signal.explicit']])"/>
            <xsl:value-of select="$num-explicit-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-explicit-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels carrying the explicit label "novela" in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-novela-bib" select="count($bibacme-works[term[@type='subgenre.summary.signal.explicit'] = 'novela'])"/>
            <xsl:value-of select="$num-novela-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-novela-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels carrying the explicit label "novela" in Conha19: </xsl:text>
            <xsl:variable name="num-novela-corp" select="count($corpus-works[term[@type='subgenre.summary.signal.explicit'] = 'novela'])"/>
            <xsl:value-of select="$num-novela-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-novela-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with "identity labels" in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-identity-bib" select="count($bibacme-works[term[@type='subgenre.summary.identity.explicit']])"/>
            <xsl:value-of select="$num-identity-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-identity-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with "identity labels" in Conha19: </xsl:text>
            <xsl:variable name="num-identity-corp" select="count($corpus-works[term[@type='subgenre.summary.identity.explicit']])"/>
            <xsl:value-of select="$num-identity-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-identity-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with implicit signals in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-implicit-bib" select="count($bibacme-works[term[@type='subgenre.summary.signal.implicit']])"/>
            <xsl:value-of select="$num-implicit-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-implicit-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with implicit signals in Conha19: </xsl:text>
            <xsl:variable name="num-implicit-corp" select="count($corpus-works[term[@type='subgenre.summary.signal.implicit']])"/>
            <xsl:value-of select="$num-implicit-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-implicit-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with signals in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-signals-bib" select="count($bibacme-works[term[starts-with(@type,'subgenre.summary.signal')]])"/>
            <xsl:value-of select="$num-signals-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-signals-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with signals in Conha19: </xsl:text>
            <xsl:variable name="num-signals-corp" select="count($corpus-works[term[starts-with(@type,'subgenre.summary.signal')]])"/>
            <xsl:value-of select="$num-signals-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-signals-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with literary historical subgenre assignments in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-litHist-bib" select="count($bibacme-works[term[starts-with(@type,'subgenre.litHist')]])"/>
            <xsl:value-of select="$num-litHist-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-litHist-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of novels with literary historical subgenre assignments in Conha19: </xsl:text>
            <xsl:variable name="num-litHist-corp" select="count($corpus-works[term[starts-with(@type,'subgenre.litHist')]])"/>
            <xsl:value-of select="$num-litHist-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-litHist-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall number of different subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-labels-bib" select="distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-bib)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall number of different subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="set-labels-corp" select="distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-corp)"/>
            
            <xsl:text>
</xsl:text>
            
            <xsl:text>Overall amount of subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="labels-bib" select="cligs:get-labels($bibacme-works)"/>
            <xsl:value-of select="count($labels-bib)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall amount of subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="labels-corp" select="cligs:get-labels($corpus-works)"/>
            <xsl:value-of select="count($labels-corp)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall number of different explicit subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-labels-explicit-bib" select="distinct-values($bibacme-works//term[contains(@type,'summary') and contains(@type,'explicit')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-explicit-bib)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall number of different explicit subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="set-labels-explicit-corp" select="distinct-values($corpus-works//term[contains(@type,'summary') and contains(@type,'explicit')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-explicit-corp)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall amount of explicit subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="labels-explicit-bib" select="$bibacme-works//term[contains(@type,'summary') and contains(@type,'explicit') and not(contains(@type,'signal'))]/normalize-space(.)"/>
            <xsl:value-of select="count($labels-explicit-bib)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall amount of explicit subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="labels-explicit-corp" select="$corpus-works//term[contains(@type,'summary') and contains(@type,'explicit') and not(contains(@type,'signal'))]/normalize-space(.)"/>
            <xsl:value-of select="count($labels-explicit-corp)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall number of different literary historical subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-labels-litHist-bib" select="distinct-values($bibacme-works//term[contains(@type,'summary') and contains(@type,'litHist')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-litHist-bib)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall number of different literary historical subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="set-labels-litHist-corp" select="distinct-values($corpus-works//term[contains(@type,'summary') and contains(@type,'litHist')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-litHist-corp)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall amount of literary historical subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="labels-litHist-bib" select="$bibacme-works//term[contains(@type,'summary') and contains(@type,'litHist')]/normalize-space(.)"/>
            <xsl:value-of select="count($labels-litHist-bib)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Overall amount of literary historical subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="labels-litHist-corp" select="$corpus-works//term[contains(@type,'summary') and contains(@type,'litHist')]/normalize-space(.)"/>
            <xsl:value-of select="count($labels-litHist-corp)"/>
            
            <xsl:text>
</xsl:text>
            
            <xsl:text>Number of different thematic subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-thematic-labels" select="distinct-values($bibacme-works//term[contains(@type,'theme')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-thematic-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of thematic subgenre labels in Bib-ACMé that are assigned to at least 10 works: </xsl:text>
            <xsl:variable name="thematic-more-than-10" select="cligs:get-labels-least($bibacme-works,$set-thematic-labels,'theme',10)"/>
            <xsl:value-of select="count($thematic-more-than-10)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to literary currents in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-labels-current" select="distinct-values($bibacme-works//term[contains(@type,'current')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-labels-current)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to the mode of representation in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-representation-labels" select="distinct-values($bibacme-works//term[contains(@type,'mode.representation')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-representation-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of subgenre labels related to the mode of representation in Bib-ACMé that are assigned to at least 5 works: </xsl:text>
            <xsl:variable name="representation-more-than-5" select="cligs:get-labels-least($bibacme-works,$set-representation-labels,'mode.representation',5)"/>
            <xsl:value-of select="count($representation-more-than-5)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to the mode of reality in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-reality-labels" select="distinct-values($bibacme-works//term[contains(@type,'mode.reality')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-reality-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to the identity in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-identity-labels" select="distinct-values($bibacme-works//term[contains(@type,'identity')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-identity-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to the medium in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-medium-labels" select="distinct-values($bibacme-works//term[contains(@type,'mode.medium')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-medium-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to the attitude in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-attitude-labels" select="distinct-values($bibacme-works//term[contains(@type,'mode.attitude')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-attitude-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different subgenre labels related to the intention in Bib-ACMé: </xsl:text>
            <xsl:variable name="set-intention-labels" select="distinct-values($bibacme-works//term[contains(@type,'mode.intention')]/normalize-space(.))"/>
            <xsl:value-of select="count($set-intention-labels)"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with thematic subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-thematic-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.theme')]])"/>
            <xsl:value-of select="$num-works-thematic-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-thematic-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with thematic subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="num-works-thematic-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.theme')]])"/>
            <xsl:value-of select="$num-works-thematic-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-thematic-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to literary currents in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-current-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.current')]])"/>
            <xsl:value-of select="$num-works-current-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-current-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to literary currents in Conha19: </xsl:text>
            <xsl:variable name="num-works-current-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.current')]])"/>
            <xsl:value-of select="$num-works-current-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-current-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the mode of representation in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-representation-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.representation')]])"/>
            <xsl:value-of select="$num-works-representation-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-representation-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the mode of representation in Conha19: </xsl:text>
            <xsl:variable name="num-works-representation-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.representation')]])"/>
            <xsl:value-of select="$num-works-representation-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-representation-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the mode of reality in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-reality-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.reality')]])"/>
            <xsl:value-of select="$num-works-reality-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-reality-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the mode of reality in Conha19: </xsl:text>
            <xsl:variable name="num-works-reality-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.reality')]])"/>
            <xsl:value-of select="$num-works-reality-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-reality-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with identity subgenre labels in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-identity-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.identity')]])"/>
            <xsl:value-of select="$num-works-identity-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-identity-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with identity subgenre labels in Conha19: </xsl:text>
            <xsl:variable name="num-works-identity-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.identity')]])"/>
            <xsl:value-of select="$num-works-identity-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-identity-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the medium in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-medium-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.medium')]])"/>
            <xsl:value-of select="$num-works-medium-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-medium-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the medium in Conha19: </xsl:text>
            <xsl:variable name="num-works-medium-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.medium')]])"/>
            <xsl:value-of select="$num-works-medium-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-medium-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the attitude in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-attitude-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude')]])"/>
            <xsl:value-of select="$num-works-attitude-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-attitude-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the attitude in Conha19: </xsl:text>
            <xsl:variable name="num-works-attitude-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude')]])"/>
            <xsl:value-of select="$num-works-attitude-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-attitude-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the intention in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-intention-labels-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.intention')]])"/>
            <xsl:value-of select="$num-works-intention-labels-bib"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-intention-labels-bib div ($num-works-bib div 100)"/>
            <xsl:text>%)</xsl:text>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of works with subgenre labels related to the intention in Conha19: </xsl:text>
            <xsl:variable name="num-works-intention-labels-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.intention')]])"/>
            <xsl:value-of select="$num-works-intention-labels-corp"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$num-works-intention-labels-corp div ($num-works-corp div 100)"/>
            <xsl:text>%)</xsl:text>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-per-author">
        <!-- creates an overlayed histogram showing the number of works per author in Bib-ACMé and Conha19 -->
        <xsl:variable name="num-works-per-author-bib" select="cligs:get-works-per-author-bib()"/>
        <xsl:variable name="num-works-per-author-corp" select="cligs:get-works-per-author-corp()"/>
        <xsl:result-document href="{concat($output-dir,'works-per-author.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var x1 = [<xsl:value-of select="string-join($num-works-per-author-bib,',')"/>];
                        var trace1 = {
                        x: x1,
                        type: 'histogram',
                        opacity: 0.5,
                        name: 'Bib-ACMé'
                        };
                        var x2 = [<xsl:value-of select="string-join($num-works-per-author-corp,',')"/>];
                        var trace2 = {
                        x: x2,
                        type: 'histogram',
                        opacity: 0.5,
                        name: 'Conha19'
                        };
                        var data = [trace1, trace2];
                        var layout = {
                        xaxis: {title: "number of works"}, 
                        yaxis: {title: "number of authors"},
                        barmode: "overlay",
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        font: {size: 14},
                        annotations: [
                        <xsl:for-each select="1 to 5">{
                            <xsl:variable name="num-authors-per-work-num-bib" select="count(index-of($num-works-per-author-bib,string(.)))"/>
                            <xsl:variable name="num-authors-per-work-num-corp" select="count(index-of($num-works-per-author-corp,string(.)))"/>
                            x: <xsl:value-of select="."/>,
                            y: <xsl:value-of select="$num-authors-per-work-num-corp"/>,
                            text: "<xsl:value-of select="round($num-authors-per-work-num-corp div ($num-authors-per-work-num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "top",
                            font: {size: 12}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="list-works-per-author-top">
        <!-- creates an overview of the top x authors regarding the number of novels written
        in Bib-ACMé and contained in Conha19 -->
        <xsl:text>
</xsl:text>
        <xsl:text>Bib-ACMé:</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:for-each-group select="$bibacme-works" group-by="author">
            <xsl:sort select="count(current-group())" order="descending"/>
            <xsl:if test="position() &lt;= 25">
                <xsl:value-of select="position()"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current-grouping-key()"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current-group()[1]/country"/><xsl:text>,</xsl:text>
                <xsl:value-of select="count(current-group())"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:if>
        </xsl:for-each-group>
        <xsl:text>
</xsl:text>
        <xsl:text>Conha19:</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:for-each-group select="$corpus" group-by=".//author/name[@type='short']">
            <xsl:sort select="count(current-group())" order="descending"/>
            <xsl:sort select=".//author/name[@type='full']"/>
            <xsl:if test="position() &lt;= 30">
                <xsl:value-of select="position()"/><xsl:text>,</xsl:text>
                <xsl:value-of select=".//author/name[@type='full']"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current-group()[1]//term[@type='author.country']"/><xsl:text>,</xsl:text>
                <xsl:value-of select="count(current-group())"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:if>
        </xsl:for-each-group> 
    </xsl:template>
    
    <xsl:template name="plot-editions-per-author">
        <!-- creates an overlayed histogram showing the number of editions per author in Bib-ACMé and Conha19 
        -->
        <xsl:variable name="num-editions-per-author-bib" select="cligs:get-editions-per-author-bib()"/>
        <xsl:variable name="num-editions-per-author-corp" select="cligs:get-editions-per-author-corp()"/>
        <xsl:result-document href="{concat($output-dir,'editions-per-author.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var x1 = [<xsl:value-of select="string-join($num-editions-per-author-bib,',')"/>];
                        var trace1 = {
                        x: x1,
                        type: 'histogram',
                        xbins: {size: 1},
                        opacity: 0.5,
                        name: 'Bib-ACMé'
                        };
                        var x2 = [<xsl:value-of select="string-join($num-editions-per-author-corp,',')"/>];
                        var trace2 = {
                        x: x2,
                        type: 'histogram',
                        xbins: {size: 1},
                        opacity: 0.5,
                        name: 'Conha19'
                        };
                        var data = [trace1, trace2];
                        var layout = {
                        xaxis: {title: "number of editions"}, 
                        yaxis: {title: "number of authors"},
                        barmode: "overlay",
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        font: {size: 14},
                        annotations: [
                        <xsl:for-each select="1 to 5">{
                            <xsl:variable name="num-authors-per-edition-num-bib" select="count(index-of($num-editions-per-author-bib,string(.)))"/>
                            <xsl:variable name="num-authors-per-edition-num-corp" select="count(index-of($num-editions-per-author-corp,string(.)))"/>
                            x: <xsl:value-of select="."/>,
                            y: <xsl:value-of select="$num-authors-per-edition-num-corp"/>,
                            text: "<xsl:value-of select="round($num-authors-per-edition-num-corp div ($num-authors-per-edition-num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "top",
                            font: {size: 12}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="list-editions-per-author-top">
        <!-- creates an overview of the top x authors regarding the number of editions published
        in Bib-ACMé and in Conha19 -->
        <xsl:text>
</xsl:text>
        <xsl:text>Bib-ACMé:</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:for-each-group select="$bibacme-editions" group-by=".//author">
            <xsl:sort select="count(current-group())" order="descending"/>
            <xsl:variable name="author-id" select="current-group()[1]//author/@key"/>
            <xsl:variable name="author-country" select="$bibacme-authors[@xml:id=$author-id]//country"/>
            <xsl:if test="position() &lt;= 25">
                <xsl:value-of select="position()"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current-grouping-key()"/><xsl:text>,</xsl:text>
                <xsl:value-of select="$author-country"/><xsl:text>,</xsl:text>
                <xsl:value-of select="count(current-group())"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:if>
        </xsl:for-each-group>
        <xsl:text>
</xsl:text>
        <xsl:text>Conha19:</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:for-each-group select="$corpus" group-by=".//author/name[@type='short']">
            <xsl:sort select="count($bibacme-editions[substring-after(@corresp,'#') = current-group()//title/idno[@type='bibacme']])" order="descending"/>
            <xsl:sort select=".//author/name[@type='full']"/>
            <xsl:if test="position() &lt;= 30">
                <xsl:value-of select="position()"/><xsl:text>,</xsl:text>
                <xsl:value-of select=".//author/name[@type='full']"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current-group()[1]//term[@type='author.country']"/><xsl:text>,</xsl:text>
                <xsl:value-of select="count($bibacme-editions[substring-after(@corresp,'#') = current-group()//title/idno[@type='bibacme']])"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:if>
        </xsl:for-each-group> 
    </xsl:template>
    
    <xsl:template name="plot-author-gender">
        <!-- creates two donut charts showing the proportions of author gender in Bib-ACMé and Conha19 -->
        <xsl:result-document href="{concat($output-dir,'author-gender.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 500px;"></div>
                    <script>
                        var labels = ["male","female","unknown"]
                        var values_bib = [<xsl:value-of select="cligs:get-author-gender-bib('masculino')"/>,<xsl:value-of select="cligs:get-author-gender-bib('femenino')"/>,<xsl:value-of select="cligs:get-author-gender-bib('desconocido')"/>]
                        var values_corp = [<xsl:value-of select="cligs:get-author-gender-corp('masculino')"/>,<xsl:value-of select="cligs:get-author-gender-corp('femenino')"/>,<xsl:value-of select="cligs:get-author-gender-corp('desconocido')"/>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.84,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-author-dates-known">
        <!-- creates two donut charts comparing how many birth and death dates of 
        authors are known in Bib-ACMé vs. Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'author-dates-known.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 500px;"></div>
                    <script>
                        var labels = ["life dates known","only birth date known","only death date known", "life dates unknown"]
                        var values_bib = [<xsl:value-of select="cligs:get-author-dates-known('both', 'bib')"/>,
                        <xsl:value-of select="cligs:get-author-dates-known('birth', 'bib')"/>,
                        <xsl:value-of select="cligs:get-author-dates-known('death', 'bib')"/>,
                        <xsl:value-of select="cligs:get-author-dates-known('none', 'bib')"/>]
                        var values_corp = [<xsl:value-of select="cligs:get-author-dates-known('both', 'corp')"/>,
                        <xsl:value-of select="cligs:get-author-dates-known('birth', 'corp')"/>,
                        <xsl:value-of select="cligs:get-author-dates-known('death', 'corp')"/>,
                        <xsl:value-of select="cligs:get-author-dates-known('none', 'corp')"/>]
                        var data = [{
                            values: values_bib,
                            labels: labels,
                            type: "pie",
                            direction: "clockwise",
                            name: "Bib-ACMé",
                            domain: {row: 0, column: 0},
                            hole: 0.4
                        },{
                            values: values_corp,
                            labels: labels,
                            type: "pie",
                            direction: "clockwise",
                            name: "Conha19",
                            domain: {row: 0, column: 1},
                            hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.15,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.85,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-author-births-deaths">
        <!-- creates a grouped bar chart showing how many authors were born and died per year,
        in Bib-ACMé compared to Conha19 -->
        
        <xsl:variable name="birth-years-bib" select="$bibacme-authors/birth/date/@when/number(substring(.,1,4))"/>
        <xsl:variable name="death-years-bib" select="$bibacme-authors/death/date/@when/number(substring(.,1,4))"/>
        <xsl:variable name="birth-years-corp" select="$bibacme-authors[@xml:id = $corpus-authors-ids]/birth/date/@when/number(substring(.,1,4))"/>
        <xsl:variable name="death-years-corp" select="$bibacme-authors[@xml:id = $corpus-authors-ids]/death/date/@when/number(substring(.,1,4))"/>
        <xsl:variable name="earliest-birth-year-bib" select="xs:integer(min($birth-years-bib))"/>
        <xsl:variable name="latest-death-year-bib" select="xs:integer(max($death-years-bib))"/>
        
        <!-- range of years for bars -->
        <xsl:variable name="labels-x" select="$earliest-birth-year-bib to $latest-death-year-bib"/>
        
        <xsl:result-document href="{concat($output-dir,'author-births-deaths.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $birth-years-bib)"/>],
                        name: "births Bib-ACMé",
                        type: "bar",
                        marker: {color: "rgb(31, 119, 180)"}
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $birth-years-corp)"/>],
                        name: "births Conha19",
                        type: "bar",
                        marker: {color: "yellow"}
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $death-years-bib)"/>],
                        name: "deaths Bib-ACMé",
                        type: "bar",
                        marker: {color: "rgb(44, 160, 44)"}
                        };
                        
                        var trace4 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $death-years-corp)"/>],
                        name: "deaths Conha19",
                        type: "bar",
                        marker: {color: "red"}
                        };
                        
                        var data = [trace1, trace2, trace3, trace4];
                        var layout = {
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 10}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-author-births-deaths-decades">
        <!-- creates a grouped bar chart showing how many authors were born and died per decade,
        in Bib-ACMé compared to Conha19 -->
        
        <xsl:variable name="birth-decades-bib" select="$bibacme-authors/birth/date/@when/number(concat(substring(.,1,3),'0'))"/>
        <xsl:variable name="death-decades-bib" select="$bibacme-authors/death/date/@when/number(concat(substring(.,1,3),'0'))"/>
        <xsl:variable name="birth-decades-corp" select="$bibacme-authors[@xml:id = $corpus-authors-ids]/birth/date/@when/number(concat(substring(.,1,3),'0'))"/>
        <xsl:variable name="death-decades-corp" select="$bibacme-authors[@xml:id = $corpus-authors-ids]/death/date/@when/number(concat(substring(.,1,3),'0'))"/>
        <xsl:variable name="earliest-birth-decade-bib" select="xs:integer(min($birth-decades-bib))"/>
        <xsl:variable name="latest-death-decade-bib" select="xs:integer(max($death-decades-bib))"/>
        
        <!-- range of years for bars -->
        <xsl:variable name="labels-x-string">
            <xsl:call-template name="get-decade-range">
                <xsl:with-param name="curr-decade" select="$earliest-birth-decade-bib"/>
                <xsl:with-param name="start-decade" select="$earliest-birth-decade-bib"/>
                <xsl:with-param name="end-decade" select="$latest-death-decade-bib"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="labels-x" select="for $i in tokenize($labels-x-string,',') return xs:integer($i)"/>
        
        <xsl:result-document href="{concat($output-dir,'author-births-deaths-decades.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $birth-decades-bib)"/>],
                        name: "births Bib-ACMé",
                        type: "bar",
                        marker: {color: "rgb(31, 119, 180)"}
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $birth-decades-corp)"/>],
                        name: "births Conha19",
                        type: "bar",
                        marker: {color: "yellow"}
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $death-decades-bib)"/>],
                        name: "deaths Bib-ACMé",
                        type: "bar",
                        marker: {color: "rgb(44, 160, 44)"}
                        };
                        
                        var trace4 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $death-decades-corp)"/>],
                        name: "deaths Conha19",
                        type: "bar",
                        marker: {color: "red"}
                        };
                        
                        var data = [trace1, trace2, trace3, trace4];
                        var layout = {
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 10, title: "decades"},
                        yaxis: {title: "number of authors"},
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        font: {size: 16}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-authors-alive">
        <!-- creates a bar chart showing how many authors were alive per year,
        in Bib-ACMé compared to Conha19 -->
        
        <xsl:variable name="birth-years-bib" select="$bibacme-authors/birth/date/@when/number(substring(.,1,4))"/>
        <xsl:variable name="death-years-bib" select="$bibacme-authors/death/date/@when/number(substring(.,1,4))"/>
        <xsl:variable name="earliest-birth-year-bib" select="xs:integer(min($birth-years-bib))"/>
        <xsl:variable name="latest-death-year-bib" select="xs:integer(max($death-years-bib))"/>
        
        <!-- range of years for bars -->
        <xsl:variable name="labels-x" select="$earliest-birth-year-bib to $latest-death-year-bib"/>
        
        <xsl:result-document href="{concat($output-dir,'authors-alive.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-authors-alive($labels-x, $bibacme-authors)"/>],
                        name: "authors alive Bib-ACMé",
                        type: "bar",
                        marker: {color: "rgb(31, 119, 180)"}
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-authors-alive($labels-x, $corpus-authors)"/>],
                        name: "authors alive Conha19",
                        type: "bar",
                        marker: {color: "yellow"}
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-authors-dead($labels-x, $bibacme-authors)"/>],
                        name: "authors dead Bib-ACMé",
                        type: "bar",
                        marker: {color: "red"}
                        };
                        
                        var trace4 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-authors-dead($labels-x, $corpus-authors)"/>],
                        name: "authors dead Conha19",
                        type: "bar",
                        marker: {color: "rgb(44, 160, 44)"}
                        };
                        
                        var trace5 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-authors-not-born($labels-x, $bibacme-authors)"/>],
                        name: "authors not yet born Bib-ACMé",
                        type: "bar",
                        marker: {color: "purple"}
                        };
                        
                        var trace6 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-authors-not-born($labels-x, $corpus-authors)"/>],
                        name: "authors not yet born Conha19",
                        type: "bar",
                        marker: {color: "brown"}
                        };
                        
                        //var data = [trace1, trace2, trace3, trace4, trace5, trace6];
                        var data = [trace5, trace1, trace3, trace6, trace2, trace4];
                        
                        var layout = {
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 10, title: "years", titlefont: {size: 16}},
                        yaxis: {title: "number of authors", titlefont: {size: 16}},
                        legend: {
                        orientation: "h",
                        font: {size: 16}
                        },
                        font: {size: 16}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-active">
        <!-- creates a bar chart showing how many authors were active per year,
        in Bib-ACMé compared to Conha19 (meaning that they already had published novels and were to publish
        novels in that year and/or that they published novels exactly in that year -->
        
        <xsl:variable name="earliest-publication-year-bib" select="min($bibacme-editions//date[@when or @to]/xs:integer(substring(@when|@to,1,4)))"/>
        <xsl:variable name="latest-publication-year-bib" select="max($bibacme-editions//date[@when or @to]/xs:integer(substring(@when|@to,1,4)))"/>
        
        <!-- range of years for bars -->
        <xsl:variable name="labels-x" select="$earliest-publication-year-bib to $latest-publication-year-bib"/>
        
        <xsl:result-document href="{concat($output-dir,'authors-active.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1000px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="string-join(cligs:get-num-authors-active($labels-x, $bibacme-authors),',')"/>],
                        name: "Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="string-join(cligs:get-num-authors-active($labels-x, $corpus-authors),',')"/>],
                        name: "Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        xaxis: {tickmode: "linear", dtick: 10, title: "years", titlefont: {size: 16}},
                        yaxis: {title: "number of authors", titlefont: {size: 16}},
                        legend: {
                        orientation: "h",
                        font: {size: 16}
                        },
                        font: {size: 16}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-active-1880">
        <!-- creates a bar chart showing how many authors were active per year,
        in Bib-ACMé compared to Conha19 (meaning that they already had published novels and were to publish
        novels in that year and/or that they published novels exactly in that year, 
        differentiating between the periods before and after 1880 -->
        
        <!-- num authors active -->
        <xsl:variable name="authors-active-before-1880-bib" select="cligs:get-num-authors-active(1880, 'before', $bibacme-authors)"/>
        <xsl:variable name="authors-active-after-1880-bib" select="cligs:get-num-authors-active(1880, 'after', $bibacme-authors)"/>
        <xsl:variable name="authors-active-before-1880-corp" select="cligs:get-num-authors-active(1880, 'before', $corpus-authors)"/>
        <xsl:variable name="authors-active-after-1880-corp" select="cligs:get-num-authors-active(1880, 'after', $corpus-authors)"/>
        
        <xsl:result-document href="{concat($output-dir,'authors-active-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="$authors-active-before-1880-bib"/>,
                        <xsl:value-of select="$authors-active-after-1880-bib"/>],
                        name: "Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="$authors-active-before-1880-corp"/>,
                        <xsl:value-of select="$authors-active-after-1880-corp"/>],
                        name: "Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                            xaxis: {tickmode: "linear", dtick: 1},
                            barmode: "group",
                            legend: {
                                orientation: "h",
                                font: {size: 16}
                                },
                            font: {size: 16},
                            annotations: [{
                                x: 0.2,
                                y: <xsl:value-of select="$authors-active-before-1880-corp"/>,
                                text: "<xsl:value-of select="round($authors-active-before-1880-corp div ($authors-active-before-1880-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "center",
                                yanchor: "bottom",
                                font: {size: 16}
                                },{
                                x: 1.2,
                                y: <xsl:value-of select="$authors-active-after-1880-corp"/>,
                                text: "<xsl:value-of select="round($authors-active-after-1880-corp div ($authors-active-after-1880-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "center",
                                yanchor: "bottom",
                                font: {size: 16}
                                }
                                
                            ]
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-age">
        <!-- how old were the authors when they published their works? creates a blox plot -->
        <!-- for each work in Bib-ACMé/Conha19: how old was the author when it was published? -->
        <xsl:variable name="author-ages-bib" select="cligs:get-author-ages($bibacme-works, 'none')"/>
        <xsl:variable name="author-ages-corp" select="cligs:get-author-ages($corpus-works, 'none')"/>
        
        <xsl:result-document href="{concat($output-dir,'authors-age.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        y: [<xsl:value-of select="string-join($author-ages-bib,',')"/>],
                        type: 'box',
                        name: "Bib-ACMé"
                        };
                        
                        var trace2 = {
                        y: [<xsl:value-of select="string-join($author-ages-corp,',')"/>],
                        type: 'box',
                        name: "Conha19"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                            showlegend: false,
                            xaxis: {title: "age"}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-age-decades">
        <!-- how old were the authors when they published their works? creates a series of blox plots
        by decade -->
        
        <xsl:result-document href="{concat($output-dir,'authors-age-decades.html')}" method="html" encoding="UTF-8">
            <xsl:variable name="ages-1830-bib" select="cligs:get-author-ages($bibacme-works, 1830)"/>
            <xsl:variable name="ages-1830-corp" select="cligs:get-author-ages($corpus-works, 1830)"/>
            <xsl:variable name="ages-1840-bib" select="cligs:get-author-ages($bibacme-works, 1840)"/>
            <xsl:variable name="ages-1840-corp" select="cligs:get-author-ages($corpus-works, 1840)"/>
            <xsl:variable name="ages-1850-bib" select="cligs:get-author-ages($bibacme-works, 1850)"/>
            <xsl:variable name="ages-1850-corp" select="cligs:get-author-ages($corpus-works, 1850)"/>
            <xsl:variable name="ages-1860-bib" select="cligs:get-author-ages($bibacme-works, 1860)"/>
            <xsl:variable name="ages-1860-corp" select="cligs:get-author-ages($corpus-works, 1860)"/>
            <xsl:variable name="ages-1870-bib" select="cligs:get-author-ages($bibacme-works, 1870)"/>
            <xsl:variable name="ages-1870-corp" select="cligs:get-author-ages($corpus-works, 1870)"/>
            <xsl:variable name="ages-1880-bib" select="cligs:get-author-ages($bibacme-works, 1880)"/>
            <xsl:variable name="ages-1880-corp" select="cligs:get-author-ages($corpus-works, 1880)"/>
            <xsl:variable name="ages-1890-bib" select="cligs:get-author-ages($bibacme-works, 1890)"/>
            <xsl:variable name="ages-1890-corp" select="cligs:get-author-ages($corpus-works, 1890)"/>
            <xsl:variable name="ages-1900-bib" select="cligs:get-author-ages($bibacme-works, 1900)"/>
            <xsl:variable name="ages-1900-corp" select="cligs:get-author-ages($corpus-works, 1900)"/>
            <xsl:variable name="ages-1910-bib" select="cligs:get-author-ages($bibacme-works, 1910)"/>
            <xsl:variable name="ages-1910-corp" select="cligs:get-author-ages($corpus-works, 1910)"/>
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="cligs:get-box-group-labels($ages-1830-bib, '1830')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1840-bib, '1840')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1850-bib, '1850')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1860-bib, '1860')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1870-bib, '1870')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1880-bib, '1880')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1890-bib, '1890')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1900-bib, '1900')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1910-bib, '1910')"/>],
                        y: [<xsl:value-of select="string-join($ages-1830-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1840-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1850-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1860-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1870-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1880-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1890-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1900-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-1910-bib,',')"/>],
                        type: 'box',
                        name: "Bib-ACMé"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="cligs:get-box-group-labels($ages-1830-corp, '1830')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1840-corp, '1840')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1850-corp, '1850')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1860-corp, '1860')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1870-corp, '1870')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1880-corp, '1880')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1890-corp, '1890')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1900-corp, '1900')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-1910-corp, '1910')"/>],
                        y: [<xsl:value-of select="string-join($ages-1830-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1840-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1850-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1860-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1870-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1880-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1890-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1900-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-1910-corp,',')"/>],
                        type: 'box',
                        name: "Conha19"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        xaxis: {tickmode: "linear", dtick: 10},
                        boxmode: "group",
                        legend: {orientation: "h"}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-age-1880">
        <!-- how old were the authors when they published their works? creates a series of blox plots
        differentiating between before and after 1880 -->
        
        <xsl:result-document href="{concat($output-dir,'authors-age-1880.html')}" method="html" encoding="UTF-8">
            <xsl:variable name="ages-1830-bib" select="cligs:get-author-ages($bibacme-works, 1830)"/>
            <xsl:variable name="ages-1830-corp" select="cligs:get-author-ages($corpus-works, 1830)"/>
            <xsl:variable name="ages-1840-bib" select="cligs:get-author-ages($bibacme-works, 1840)"/>
            <xsl:variable name="ages-1840-corp" select="cligs:get-author-ages($corpus-works, 1840)"/>
            <xsl:variable name="ages-1850-bib" select="cligs:get-author-ages($bibacme-works, 1850)"/>
            <xsl:variable name="ages-1850-corp" select="cligs:get-author-ages($corpus-works, 1850)"/>
            <xsl:variable name="ages-1860-bib" select="cligs:get-author-ages($bibacme-works, 1860)"/>
            <xsl:variable name="ages-1860-corp" select="cligs:get-author-ages($corpus-works, 1860)"/>
            <xsl:variable name="ages-1870-bib" select="cligs:get-author-ages($bibacme-works, 1870)"/>
            <xsl:variable name="ages-1870-corp" select="cligs:get-author-ages($corpus-works, 1870)"/>
            <xsl:variable name="ages-1880-bib" select="cligs:get-author-ages($bibacme-works, 1880)"/>
            <xsl:variable name="ages-1880-corp" select="cligs:get-author-ages($corpus-works, 1880)"/>
            <xsl:variable name="ages-1890-bib" select="cligs:get-author-ages($bibacme-works, 1890)"/>
            <xsl:variable name="ages-1890-corp" select="cligs:get-author-ages($corpus-works, 1890)"/>
            <xsl:variable name="ages-1900-bib" select="cligs:get-author-ages($bibacme-works, 1900)"/>
            <xsl:variable name="ages-1900-corp" select="cligs:get-author-ages($corpus-works, 1900)"/>
            <xsl:variable name="ages-1910-bib" select="cligs:get-author-ages($bibacme-works, 1910)"/>
            <xsl:variable name="ages-1910-corp" select="cligs:get-author-ages($corpus-works, 1910)"/>
            
            <xsl:variable name="ages-before-1880-bib" select="($ages-1830-bib, $ages-1840-bib, $ages-1850-bib, $ages-1860-bib, $ages-1870-bib)"/>
            <xsl:variable name="ages-after-1880-bib" select="($ages-1880-bib, $ages-1890-bib, $ages-1900-bib, $ages-1910-bib)"/>
            <xsl:variable name="ages-before-1880-corp" select="($ages-1830-corp, $ages-1840-corp, $ages-1850-corp, $ages-1860-corp, $ages-1870-corp)"/>
            <xsl:variable name="ages-after-1880-corp" select="($ages-1880-corp, $ages-1890-corp, $ages-1900-corp, $ages-1910-corp)"/>
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="cligs:get-box-group-labels($ages-before-1880-bib, 'before 1880')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-after-1880-bib, 'in or after 1880')"/>],
                        y: [<xsl:value-of select="string-join($ages-before-1880-bib,',')"/>,
                        <xsl:value-of select="string-join($ages-after-1880-bib,',')"/>],
                        type: 'box',
                        name: "Bib-ACMé"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="cligs:get-box-group-labels($ages-before-1880-corp, 'before 1880')"/>,
                        <xsl:value-of select="cligs:get-box-group-labels($ages-after-1880-corp, 'in or after 1880')"/>],
                        y: [<xsl:value-of select="string-join($ages-before-1880-corp,',')"/>,
                        <xsl:value-of select="string-join($ages-after-1880-corp,',')"/>],
                        type: 'box',
                        name: "Conha19"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        xaxis: {tickmode: "linear", dtick: 1},
                        boxmode: "group",
                        legend: {orientation: "h"}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-age-death">
        <!-- how old were the authors when they died? compare Bib-ACMé to Conha19 in two box plots -->
        <xsl:variable name="author-ages-bib" select="cligs:get-author-ages-death($bibacme-authors)"/>
        <xsl:variable name="author-ages-corp" select="cligs:get-author-ages-death($corpus-authors)"/>
        
        <xsl:result-document href="{concat($output-dir,'authors-age-death.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 500px; height: 500px;"></div>
                    <script>
                        var trace1 = {
                        y: [<xsl:value-of select="string-join($author-ages-bib,',')"/>],
                        type: 'box',
                        name: "authors Bib-ACMé"
                        };
                        
                        var trace2 = {
                        y: [<xsl:value-of select="string-join($author-ages-corp,',')"/>],
                        type: 'box',
                        name: "authors Conha19"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                            yaxis: {title: "age at death"},
                            showlegend: false
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    
    </xsl:template>
    
    <xsl:template name="plot-authors-by-country">
        <!-- creates two donut charts showing the proportions of authors by country (AR, MX, CU) -->
        <xsl:variable name="authors-AR-bib" select="count($bibacme-authors[.//country = 'Argentina'])"/>
        <xsl:variable name="authors-MX-bib" select="count($bibacme-authors[.//country = 'México'])"/>
        <xsl:variable name="authors-CU-bib" select="count($bibacme-authors[.//country = 'Cuba'])"/>
        <xsl:variable name="authors-AR-corp" select="count($corpus-authors[.//country = 'Argentina'])"/>
        <xsl:variable name="authors-MX-corp" select="count($corpus-authors[.//country = 'México'])"/>
        <xsl:variable name="authors-CU-corp" select="count($corpus-authors[.//country = 'Cuba'])"/>
        
        <xsl:result-document href="{concat($output-dir,'authors-by-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 500px;"></div>
                    <script>
                        var labels = ["Argentina","Mexico","Cuba"]
                        var values_bib = [<xsl:value-of select="$authors-AR-bib"/>,<xsl:value-of select="$authors-MX-bib"/>,<xsl:value-of select="$authors-CU-bib"/>]
                        var values_corp = [<xsl:value-of select="$authors-AR-corp"/>,<xsl:value-of select="$authors-MX-corp"/>,<xsl:value-of select="$authors-CU-corp"/>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.84,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-by-nationality">
        <!-- creates two donut charts showing the proportions of authors by nationality -->
        
        <xsl:result-document href="{concat($output-dir,'authors-by-nationality.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join(cligs:map-nationalities(),'&quot;,&quot;')"/>"]
                        var values_bib = [<xsl:value-of select="string-join(cligs:get-nationalities-bib(),',')"/>]
                        var values_corp = [<xsl:value-of select="string-join(cligs:get-nationalities-corp(),',')"/>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.84,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-by-birth-place">
        <!-- creates two donut charts showing the proportions of authors by country of birth -->
        
        <xsl:result-document href="{concat($output-dir,'authors-by-country-birth.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join(cligs:map-birth-places(),'&quot;,&quot;')"/>"]
                        var values_bib = [<xsl:value-of select="string-join(cligs:get-birth-places-bib(),',')"/>]
                        var values_corp = [<xsl:value-of select="string-join(cligs:get-birth-places-corp(),',')"/>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.15,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.85,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-authors-by-death-place">
        <!-- creates two donut charts showing the proportions of authors by country of death -->
        
        <xsl:result-document href="{concat($output-dir,'authors-by-country-death.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join(cligs:map-death-places(),'&quot;,&quot;')"/>"]
                        var values_bib = [<xsl:value-of select="string-join(cligs:get-death-places-bib(),',')"/>]
                        var values_corp = [<xsl:value-of select="string-join(cligs:get-death-places-corp(),',')"/>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.15,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.85,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-per-year">
        <!-- creates a bar chart showing the number of works per year, comparing Bib-ACMé and Conha19 -->
        
        <xsl:variable name="labels-x" select="1830 to 1910"/>
        <xsl:variable name="work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works)"/>
        <xsl:variable name="work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works)"/>
        
        <xsl:result-document href="{concat($output-dir,'works-per-year.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $work-publication-years-bib)"/>],
                        name: "Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $work-publication-years-corp)"/>],
                        name: "Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 1, title: "years", tickangle: 270, tickfont: {size: 12}},
                        yaxis: {title: "number of works"},
                        legend: {orientation: "h", font: {size: 18}},
                        font: {size: 16}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-per-decade">
        <!-- creates a bar chart showing the number of works per decade, comparing Bib-ACMé and Conha19 -->
        
        <xsl:variable name="work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works)"/>
        <xsl:variable name="work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works)"/>
        
        <xsl:result-document href="{concat($output-dir,'works-per-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $work-publication-years-bib)"/>],
                        name: "Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $work-publication-years-corp)"/>],
                        name: "Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                            barmode: "group",
                            xaxis: {tickmode: "linear", dtick: 10, title: "decades", tickfont: {size: 16}},
                            yaxis: {title: "number of works"},
                            legend: {orientation: "h", font: {size: 18}},
                            font: {size: 16},
                            annotations: [
                            <xsl:for-each select="$decades">{
                                <xsl:variable name="num-decade-bib" select="cligs:get-num-decades(.,$work-publication-years-bib)"/>
                                <xsl:variable name="num-decade-corp" select="cligs:get-num-decades(.,$work-publication-years-corp)"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$num-decade-corp"/>,
                                text: "<xsl:value-of select="round($num-decade-corp div ($num-decade-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 16}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>]
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-1880">
        <!-- creates a grouped bar chart comparing the number of works before and after 1880
        in Bib-ACMé vs. Conha19 -->
        
        <xsl:variable name="work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works)"/>
        <xsl:variable name="work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works)"/>
        <xsl:variable name="num-years-before-1880-bib" select="cligs:get-num-years(1880, $work-publication-years-bib, 'before')"/>
        <xsl:variable name="num-years-before-1880-corp" select="cligs:get-num-years(1880, $work-publication-years-corp, 'before')"/>
        <xsl:variable name="num-years-after-1880-bib" select="cligs:get-num-years(1880, $work-publication-years-bib, 'after')"/>
        <xsl:variable name="num-years-after-1880-corp" select="cligs:get-num-years(1880, $work-publication-years-corp, 'after')"/>
        
        
        <xsl:result-document href="{concat($output-dir,'works-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 500px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$num-years-before-1880-bib"/>,
                        <xsl:value-of select="$num-years-after-1880-bib"/>],
                        type: 'bar',
                        name: "Bib-ACMé"
                        };
                        
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="$num-years-before-1880-corp"/>,
                        <xsl:value-of select="$num-years-after-1880-corp"/>],
                        type: 'bar',
                        name: "Conha19"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                            xaxis: {tickmode: "linear", dtick: 1},
                            yaxis: {title: "number of works", titlefont: {size: 16}},
                            boxmode: "group",
                            legend: {orientation: "h"},
                            font: {size: 16},
                            annotations: [{
                                x: 0.25,
                                y: <xsl:value-of select="$num-years-before-1880-corp"/>,
                                text: "<xsl:value-of select="round($num-years-before-1880-corp div ($num-years-before-1880-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "center",
                                yanchor: "bottom",
                                font: {size: 16}
                                },
                                {
                                x: 1.25,
                                y: <xsl:value-of select="$num-years-after-1880-corp"/>,
                                text: "<xsl:value-of select="round($num-years-after-1880-corp div ($num-years-after-1880-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "center",
                                yanchor: "bottom",
                                font: {size: 16}
                                }
                            ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-by-country">
        <!-- creates two donut charts showing the proportion of works by country in Bib-ACMé vs. Conha19 -->
        <xsl:variable name="works-AR-bib" select="count($bibacme-works[country = 'Argentina'])"/>
        <xsl:variable name="works-MX-bib" select="count($bibacme-works[country = 'México'])"/>
        <xsl:variable name="works-CU-bib" select="count($bibacme-works[country = 'Cuba'])"/>
        <xsl:variable name="works-AR-corp" select="count($corpus-works[country = 'Argentina'])"/>
        <xsl:variable name="works-MX-corp" select="count($corpus-works[country = 'México'])"/>
        <xsl:variable name="works-CU-corp" select="count($corpus-works[country = 'Cuba'])"/>
        
        <xsl:result-document href="{concat($output-dir,'works-by-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 500px;"></div>
                    <script>
                        var labels = ["Argentina","Mexico","Cuba"]
                        var values_bib = [<xsl:value-of select="$works-AR-bib"/>,<xsl:value-of select="$works-MX-bib"/>,<xsl:value-of select="$works-CU-bib"/>]
                        var values_corp = [<xsl:value-of select="$works-AR-corp"/>,<xsl:value-of select="$works-MX-corp"/>,<xsl:value-of select="$works-CU-corp"/>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                            grid: {rows: 1, columns: 2},
                            annotations: [
                                {
                                font: {
                                size: 18
                                },
                                showarrow: false,
                                text: 'Bib-ACMé',
                                x: 0.16,
                                y: 0.5
                                },
                                {
                                font: {
                                size: 18
                                },
                                showarrow: false,
                                text: 'Conha19',
                                x: 0.84,
                                y: 0.5
                                }
                            ],
                            legend: {font: {size: 16}}
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-by-country-year">
        <!-- creates a set of three bar charts (one for each country), showing the number of works per year,
        comparing Bib-ACMé and Conha19 -->
        <xsl:variable name="labels-x" select="1830 to 1910"/>
        <xsl:variable name="AR-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='Argentina'])"/>
        <xsl:variable name="AR-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='Argentina'])"/>
        <xsl:variable name="MX-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='México'])"/>
        <xsl:variable name="MX-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='México'])"/>
        <xsl:variable name="CU-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='Cuba'])"/>
        <xsl:variable name="CU-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='Cuba'])"/>
        
        
        <xsl:result-document href="{concat($output-dir,'works-by-country-year.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1000px; height: 1000px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $AR-work-publication-years-bib)"/>],
                        xaxis: "x1",
                        yaxis: "y1",
                        name: "AR Bib-ACMé",
                        type: "bar",
                        legendgroup: "a",
                        domain: {row: 0, column: 0}
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $AR-work-publication-years-corp)"/>],
                        name: "AR Conha19",
                        type: "bar",
                        xaxis: "x1",
                        yaxis: "y1",
                        legendgroup: "a",
                        domain: {row: 0, column: 0}
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $MX-work-publication-years-bib)"/>],
                        name: "MX Bib-ACMé",
                        type: "bar",
                        xaxis: "x2",
                        yaxis: "y2",
                        legendgroup: "b",
                        domain: {row: 1, column: 0}
                        };
                        
                        var trace4 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $MX-work-publication-years-corp)"/>],
                        name: "MX Conha19",
                        type: "bar",
                        xaxis: "x2",
                        yaxis: "y2",
                        legendgroup: "b",
                        domain: {row: 1, column: 0}
                        };
                        
                        var trace5 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $CU-work-publication-years-bib)"/>],
                        name: "CU Bib-ACMé",
                        type: "bar",
                        xaxis: "x3",
                        yaxis: "y3",
                        legendgroup: "c",
                        domain: {row: 2, column: 0}
                        };
                        
                        var trace6 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $CU-work-publication-years-corp)"/>],
                        name: "CU Conha19",
                        type: "bar",
                        xaxis: "x3",
                        yaxis: "y3",
                        legendgroup: "c",
                        domain: {row: 2, column: 0}
                        };
                        
                        var data = [trace1, trace2, trace3, trace4, trace5, trace6];
                        var layout = {
                            grid: {rows: 3, columns: 1},
                            barmode: "group",
                            xaxis: {tickmode: "linear", dtick: 10, title: "years", titlefont: {size: 14}, tickfont: {size: 16}},
                            yaxis: {title: "number of works", range: [0,25], titlefont: {size: 14},},
                            xaxis2: {anchor: "y2", tickmode: "linear", dtick: 10, title: "years", titlefont: {size: 14}, tickfont: {size: 16}},
                            yaxis2: {title: "number of works", range: [0,25], titlefont: {size: 14},},
                            xaxis3: {anchor: "y3", tickmode: "linear", dtick: 10, title: "years", titlefont: {size: 14}, tickfont: {size: 16}},
                            yaxis3: {title: "number of works", range: [0,25], titlefont: {size: 14},},
                            legend: {font: {size: 14}},
                            font: {size: 14}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-by-country-decade">
        <!-- creates a set of three bar charts (one for each country), showing the number of works per decade,
        comparing Bib-ACMé and Conha19 -->
        <xsl:variable name="AR-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='Argentina'])"/>
        <xsl:variable name="AR-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='Argentina'])"/>
        <xsl:variable name="MX-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='México'])"/>
        <xsl:variable name="MX-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='México'])"/>
        <xsl:variable name="CU-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='Cuba'])"/>
        <xsl:variable name="CU-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='Cuba'])"/>
        
        
        <xsl:result-document href="{concat($output-dir,'works-by-country-decades.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1000px; height: 1000px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $AR-work-publication-years-bib)"/>],
                        xaxis: "x1",
                        yaxis: "y1",
                        name: "AR Bib-ACMé",
                        type: "bar",
                        legendgroup: "a",
                        domain: {row: 0, column: 0}
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $AR-work-publication-years-corp)"/>],
                        name: "AR Conha19",
                        type: "bar",
                        xaxis: "x1",
                        yaxis: "y1",
                        legendgroup: "a",
                        domain: {row: 0, column: 0}
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $MX-work-publication-years-bib)"/>],
                        name: "MX Bib-ACMé",
                        type: "bar",
                        xaxis: "x2",
                        yaxis: "y2",
                        legendgroup: "b",
                        domain: {row: 1, column: 0}
                        };
                        
                        var trace4 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $MX-work-publication-years-corp)"/>],
                        name: "MX Conha19",
                        type: "bar",
                        xaxis: "x2",
                        yaxis: "y2",
                        legendgroup: "b",
                        domain: {row: 1, column: 0}
                        };
                        
                        var trace5 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $CU-work-publication-years-bib)"/>],
                        name: "CU Bib-ACMé",
                        type: "bar",
                        xaxis: "x3",
                        yaxis: "y3",
                        legendgroup: "c",
                        domain: {row: 2, column: 0}
                        };
                        
                        var trace6 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $CU-work-publication-years-corp)"/>],
                        name: "CU Conha19",
                        type: "bar",
                        xaxis: "x3",
                        yaxis: "y3",
                        legendgroup: "c",
                        domain: {row: 2, column: 0}
                        };
                        
                        var data = [trace1, trace2, trace3, trace4, trace5, trace6];
                        var layout = {
                            grid: {rows: 3, columns: 1},
                            barmode: "group",
                            xaxis: {tickmode: "linear", dtick: 10, title: "decades", titlefont: {size: 14}, tickfont: {size: 16}},
                            yaxis: {title: "number of works", range: [0,100], titlefont: {size: 14},},
                            xaxis2: {anchor: "y2", tickmode: "linear", dtick: 10, title: "decades", titlefont: {size: 14}, tickfont: {size: 16}},
                            yaxis2: {title: "number of works", range: [0,100], titlefont: {size: 14},},
                            xaxis3: {anchor: "y3", tickmode: "linear", dtick: 10, title: "decades", titlefont: {size: 14}, tickfont: {size: 16}},
                            yaxis3: {title: "number of works", range: [0,100], titlefont: {size: 14},},
                            legend: {font: {size: 14}},
                            font: {size: 14},
                            annotations: [
                            <xsl:for-each select="$decades">{
                                <xsl:variable name="AR-num-decade-bib" select="cligs:get-num-decades(.,$AR-work-publication-years-bib)"/>
                                <xsl:variable name="AR-num-decade-corp" select="cligs:get-num-decades(.,$AR-work-publication-years-corp)"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$AR-num-decade-corp"/>,
                                xref: "x",
                                yref: "y",
                                text: "<xsl:value-of select="round($AR-num-decade-corp div ($AR-num-decade-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 16}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>,
                            <xsl:for-each select="$decades">{
                                <xsl:variable name="MX-num-decade-bib" select="cligs:get-num-decades(.,$MX-work-publication-years-bib)"/>
                                <xsl:variable name="MX-num-decade-corp" select="cligs:get-num-decades(.,$MX-work-publication-years-corp)"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$MX-num-decade-corp"/>,
                                xref: "x2",
                                yref: "y2",
                                text: "<xsl:value-of select="round($MX-num-decade-corp div ($MX-num-decade-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 16}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>,
                            <xsl:for-each select="$decades">{
                                <xsl:variable name="CU-num-decade-bib" select="cligs:get-num-decades(.,$CU-work-publication-years-bib)"/>
                                <xsl:variable name="CU-num-decade-corp" select="cligs:get-num-decades(.,$CU-work-publication-years-corp)"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$CU-num-decade-corp"/>,
                                xref: "x3",
                                yref: "y3",
                                text: "<xsl:value-of select="round($CU-num-decade-corp div ($CU-num-decade-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 16}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>]
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-by-country-1880">
        <!-- creates a set of three bar charts (one for each country), showing the number of works before and in/after 1880,
        comparing Bib-ACMé and Conha19 -->
        <xsl:variable name="AR-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='Argentina'])"/>
        <xsl:variable name="AR-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='Argentina'])"/>
        <xsl:variable name="MX-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='México'])"/>
        <xsl:variable name="MX-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='México'])"/>
        <xsl:variable name="CU-work-publication-years-bib" select="cligs:get-first-edition-years($bibacme-works[country='Cuba'])"/>
        <xsl:variable name="CU-work-publication-years-corp" select="cligs:get-first-edition-years($corpus-works[country='Cuba'])"/>
        
        <xsl:variable name="AR-num-years-before-1880-bib" select="cligs:get-num-years(1880, $AR-work-publication-years-bib, 'before')"/>
        <xsl:variable name="AR-num-years-before-1880-corp" select="cligs:get-num-years(1880, $AR-work-publication-years-corp, 'before')"/>
        <xsl:variable name="AR-num-years-after-1880-bib" select="cligs:get-num-years(1880, $AR-work-publication-years-bib, 'after')"/>
        <xsl:variable name="AR-num-years-after-1880-corp" select="cligs:get-num-years(1880, $AR-work-publication-years-corp, 'after')"/>
        <xsl:variable name="MX-num-years-before-1880-bib" select="cligs:get-num-years(1880, $MX-work-publication-years-bib, 'before')"/>
        <xsl:variable name="MX-num-years-before-1880-corp" select="cligs:get-num-years(1880, $MX-work-publication-years-corp, 'before')"/>
        <xsl:variable name="MX-num-years-after-1880-bib" select="cligs:get-num-years(1880, $MX-work-publication-years-bib, 'after')"/>
        <xsl:variable name="MX-num-years-after-1880-corp" select="cligs:get-num-years(1880, $MX-work-publication-years-corp, 'after')"/>
        <xsl:variable name="CU-num-years-before-1880-bib" select="cligs:get-num-years(1880, $CU-work-publication-years-bib, 'before')"/>
        <xsl:variable name="CU-num-years-before-1880-corp" select="cligs:get-num-years(1880, $CU-work-publication-years-corp, 'before')"/>
        <xsl:variable name="CU-num-years-after-1880-bib" select="cligs:get-num-years(1880, $CU-work-publication-years-bib, 'after')"/>
        <xsl:variable name="CU-num-years-after-1880-corp" select="cligs:get-num-years(1880, $CU-work-publication-years-corp, 'after')"/>
        
        
        <xsl:result-document href="{concat($output-dir,'works-by-country-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1000px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$AR-num-years-before-1880-bib"/>,<xsl:value-of select="$AR-num-years-after-1880-bib"/>],
                        xaxis: "x1",
                        yaxis: "y1",
                        name: "AR Bib-ACMé",
                        type: "bar",
                        legendgroup: "a",
                        domain: {row: 0, column: 0}
                        };
                        
                        var trace2 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$AR-num-years-before-1880-corp"/>,<xsl:value-of select="$AR-num-years-after-1880-corp"/>],
                        name: "AR Conha19",
                        type: "bar",
                        xaxis: "x1",
                        yaxis: "y1",
                        legendgroup: "a",
                        domain: {row: 0, column: 0}
                        };
                        
                        var trace3 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$MX-num-years-before-1880-bib"/>,<xsl:value-of select="$MX-num-years-after-1880-bib"/>],
                        name: "MX Bib-ACMé",
                        type: "bar",
                        xaxis: "x2",
                        yaxis: "y2",
                        legendgroup: "b",
                        domain: {row: 0, column: 1}
                        };
                        
                        var trace4 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$MX-num-years-before-1880-corp"/>,<xsl:value-of select="$MX-num-years-after-1880-corp"/>],
                        name: "MX Conha19",
                        type: "bar",
                        xaxis: "x2",
                        yaxis: "y2",
                        legendgroup: "b",
                        domain: {row: 0, column: 1}
                        };
                        
                        var trace5 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$CU-num-years-before-1880-bib"/>,<xsl:value-of select="$CU-num-years-after-1880-bib"/>],
                        name: "CU Bib-ACMé",
                        type: "bar",
                        xaxis: "x3",
                        yaxis: "y3",
                        legendgroup: "c",
                        domain: {row: 0, column: 2}
                        };
                        
                        var trace6 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$CU-num-years-before-1880-corp"/>,<xsl:value-of select="$CU-num-years-after-1880-corp"/>],
                        name: "CU Conha19",
                        type: "bar",
                        xaxis: "x3",
                        yaxis: "y3",
                        legendgroup: "c",
                        domain: {row: 0, column: 2}
                        };
                        
                        var data = [trace1, trace2, trace3, trace4, trace5, trace6];
                        var layout = {
                        grid: {rows: 1, columns: 3},
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 1, tickfont: {size: 16}},
                        yaxis: {title: "number of works", range: [0,270], titlefont: {size: 16}},
                        xaxis2: {anchor: "y2", tickmode: "linear", dtick: 1, tickfont: {size: 16}},
                        yaxis2: {title: "number of works", range: [0,270], titlefont: {size: 16},visible: false},
                        xaxis3: {anchor: "y3", tickmode: "linear", dtick: 1, tickfont: {size: 16}},
                        yaxis3: {title: "number of works", range: [0,270], titlefont: {size: 16},visible: false},
                        legend: {font: {size: 16}, orientation: "h"},
                        font: {size: 16},
                        annotations: [{
                            x: 0.25,
                            y: <xsl:value-of select="$AR-num-years-before-1880-corp"/>,
                            xref: "x",
                            yref: "y",
                            text: "<xsl:value-of select="round($AR-num-years-before-1880-corp div ($AR-num-years-before-1880-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 16}
                            },
                            {
                            x: 1.25,
                            y: <xsl:value-of select="$AR-num-years-after-1880-corp"/>,
                            xref: "x",
                            yref: "y",
                            text: "<xsl:value-of select="round($AR-num-years-after-1880-corp div ($AR-num-years-after-1880-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 16}
                            },
                            {
                            x: 0.25,
                            y: <xsl:value-of select="$MX-num-years-before-1880-corp"/>,
                            xref: "x2",
                            yref: "y2",
                            text: "<xsl:value-of select="round($MX-num-years-before-1880-corp div ($MX-num-years-before-1880-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 16}
                            },
                            {
                            x: 1.25,
                            y: <xsl:value-of select="$MX-num-years-after-1880-corp"/>,
                            xref: "x2",
                            yref: "y2",
                            text: "<xsl:value-of select="round($MX-num-years-after-1880-corp div ($MX-num-years-after-1880-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 16}
                            },
                            {
                            x: 0.25,
                            y: <xsl:value-of select="$CU-num-years-before-1880-corp"/>,
                            xref: "x3",
                            yref: "y3",
                            text: "<xsl:value-of select="round($CU-num-years-before-1880-corp div ($CU-num-years-before-1880-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 16}
                            },
                            {
                            x: 1.25,
                            y: <xsl:value-of select="$CU-num-years-after-1880-corp"/>,
                            xref: "x3",
                            yref: "y3",
                            text: "<xsl:value-of select="round($CU-num-years-after-1880-corp div ($CU-num-years-after-1880-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 16}
                            }
                        ]
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-works-by-country-first-edition">
        <!-- creates two donut charts showing how many works were first published in which country,
        comparing Bib-ACMé and Conha19 -->
        <xsl:variable name="first-edition-countries-bib" select="cligs:get-first-edition-countries($bibacme-works)"/>
        <xsl:variable name="first-edition-countries-corp" select="cligs:get-first-edition-countries($corpus-works)"/>
        
        <xsl:variable name="country-set" select="distinct-values(($first-edition-countries-bib, $first-edition-countries-corp))"/>
        
        <xsl:result-document href="{concat($output-dir,'works-by-country-first-edition.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 500px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join($country-set,'&quot;,&quot;')"/>"]
                        var values_bib = [<xsl:for-each select="$country-set">
                            <xsl:value-of select="count($first-edition-countries-bib[.=current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_corp = [<xsl:for-each select="$country-set">
                            <xsl:value-of select="count($first-edition-countries-corp[.=current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var data = [{
                        values: values_bib,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.84,
                        y: 0.5
                        }
                        ],
                        legend: {font: {size: 16}}
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-works-length">
        <!-- creates a box plot showing the length of the novels in the corpus in tokens -->
        <xsl:result-document href="{concat($output-dir,'corpus-works-length.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 400px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        y: [<xsl:value-of select="string-join($corpus//measure[@unit='words'],',')"/>],
                        type: 'box',
                        name: "works"
                        };
                        
                        var data = [trace1];
                        var layout = {
                            yaxis: {title: "number of tokens"}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-works-length-decade">
        <!-- creates a series of box plots showing the length of the novels in the corpus in tokens per decade -->
        <xsl:result-document href="{concat($output-dir,'corpus-works-length-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        <xsl:for-each select="$decades">
                            var trace<xsl:value-of select="position()"/> = {
                                <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                                <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                                y: [<xsl:value-of select="string-join($corpus[.//idno[@type='bibacme'] = $works-decade-ids]//measure[@unit='words'],',')"/>],
                                type: 'box',
                                name: "<xsl:value-of select="."/>"
                                };
                        </xsl:for-each>
                        
                        
                        var data = [<xsl:for-each select="1 to count($decades)">
                            <xsl:text>trace</xsl:text><xsl:value-of select="."/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>];
                        var layout = {
                            yaxis: {title: "number of tokens"},
                            xaxis: {title: "works per decade"},
                            showlegend: false
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-works-length-1880">
        <!-- creates two box plots showing the length of the novels in the corpus in tokens before and in/after 1880 -->
        <xsl:result-document href="{concat($output-dir,'corpus-works-length-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                            <xsl:variable name="works-before-1880" select="cligs:get-works-by-year(1880, 'before', $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-before-1880/@xml:id"/>
                            y: [<xsl:value-of select="string-join($corpus[.//idno[@type='bibacme'] = $works-decade-ids]//measure[@unit='words'],',')"/>],
                            type: 'box',
                            name: "before 1880"
                            };
                            
                        var trace2 = {
                            <xsl:variable name="works-after-1880" select="cligs:get-works-by-year(1880, 'after', $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-after-1880/@xml:id"/>
                            y: [<xsl:value-of select="string-join($corpus[.//idno[@type='bibacme'] = $works-decade-ids]//measure[@unit='words'],',')"/>],
                            type: 'box',
                            name: "in and after 1880"
                            };
                        
                        
                        var data = [trace1, trace2];
                        var layout = {
                        yaxis: {title: "number of tokens"},
                        xaxis: {title: "works"},
                        showlegend: false
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-works-length-country">
        <!-- creates a series of box plots showing work lengths in tokens by country -->
        
        <xsl:variable name="countries" select="('Argentina', 'Mexico', 'Cuba')"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-works-length-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        <xsl:for-each select="$countries">
                            var trace<xsl:value-of select="position()"/> = {
                            y: [<xsl:value-of select="string-join($corpus[.//term[@type='author.country'] = current()]//measure[@unit='words'],',')"/>],
                            type: 'box',
                            name: "<xsl:value-of select="."/>"
                            };
                        </xsl:for-each>
                        
                        
                        var data = [<xsl:for-each select="1 to count($countries)">
                            <xsl:text>trace</xsl:text><xsl:value-of select="."/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>];
                        var layout = {
                        yaxis: {title: "number of tokens"},
                        xaxis: {title: "works by country"},
                        showlegend: false
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-narrative-perspective-decade">
        <!-- creates a grouped bar chart showing the number of novels with first person and third person 
        narrator for each decade -->
        <xsl:result-document href="{concat($output-dir,'corpus-narrative-perspective-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                            x: [<xsl:value-of select="string-join($decades,',')"/>],
                            y: [<xsl:for-each select="$decades">
                                    <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                                    <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                                    <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                                    <xsl:if test="position() != last()">,</xsl:if>
                                </xsl:for-each>],
                            type: "bar",
                            name: "third"
                            
                        };
                        var trace2 = {
                            x: [<xsl:value-of select="string-join($decades,',')"/>],
                            y: [<xsl:for-each select="$decades">
                                    <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                                    <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                                    <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                                    <xsl:if test="position() != last()">,</xsl:if>
                                </xsl:for-each>],
                            type: "bar",
                            name: "first"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                            yaxis: {title: "number of works"},
                            xaxis: {title: "decades"},
                            barmode: "group",
                            annotations: [
                            <xsl:for-each select="$decades">{
                                <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                                <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                                <xsl:variable name="num-works-first-person" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                                <xsl:variable name="num-works-third-person" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$num-works-first-person"/>,
                                text: "<xsl:value-of select="round($num-works-first-person div ($num-works-third-person div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 14}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-narrative-perspective-1880">
        <!-- creates a grouped bar chart showing the number of novels with first person and third person 
        narrator before vs. in/after 1880 -->
        <xsl:variable name="works-before-1880" select="cligs:get-works-by-year(1880, 'before', $corpus-works)/@xml:id"/>
        <xsl:variable name="works-after-1880" select="cligs:get-works-by-year(1880, 'after', $corpus-works)/@xml:id"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-narrative-perspective-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 400px; height: 500px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                        ],
                        type: "bar",
                        name: "third"
                        
                        };
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                            <xsl:text>,</xsl:text>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                        ],
                        type: "bar",
                        name: "first"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        yaxis: {title: "number of works"},
                        barmode: "group",
                        annotations: [{
                            <xsl:variable name="num-works-first-person-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                            <xsl:variable name="num-works-third-person-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                            x: 0.25,
                            y: <xsl:value-of select="$num-works-first-person-before-1880"/>,
                            text: "<xsl:value-of select="round($num-works-first-person-before-1880 div ($num-works-third-person-before-1880 div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 14}
                            },
                            {
                            <xsl:variable name="num-works-first-person-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                            <xsl:variable name="num-works-third-person-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                            x: 1.25,
                            y: <xsl:value-of select="$num-works-first-person-after-1880"/>,
                            text: "<xsl:value-of select="round($num-works-first-person-after-1880 div ($num-works-third-person-after-1880 div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "bottom",
                            font: {size: 14}
                            }
                        ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-narrative-perspective-country">
        <!-- creates two donut charts comparing the proportions of works with 
        first vs. third person narrator for the three countries -->
        
        <xsl:variable name="countries" select="('Argentina', 'Mexico', 'Cuba')"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-narrative-perspective-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 400px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join($countries,'&quot;,&quot;')"/>"]
                        var values_third = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.narration.narrator.person'] = 'third person'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_first = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.narration.narrator.person'] = 'first person'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var data = [{
                        values: values_third,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "third",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_first,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "first",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'third',
                        x: 0.18,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'first',
                        x: 0.82,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-prestige-decade">
        <!-- creates a grouped bar chart showing the number of novels with high and low prestige 
        for each decade -->
        <xsl:result-document href="{concat($output-dir,'corpus-prestige-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.prestige'] = 'high'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "high"
                        
                        };
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.prestige'] = 'low'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "low"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        yaxis: {title: "number of works"},
                        xaxis: {title: "decades"},
                        barmode: "group",
                        annotations: [
                        <xsl:for-each select="$decades">{
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:variable name="num-works-low-prestige" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.prestige'] = 'low'])"/>
                            <xsl:variable name="num-works-high-prestige" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.prestige'] = 'high'])"/>
                            x: <xsl:value-of select="."/>,
                            y: <xsl:value-of select="$num-works-low-prestige"/>,
                            text: "<xsl:value-of select="round($num-works-low-prestige div ($num-works-high-prestige div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 14}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-prestige-1880">
        <!-- creates a grouped bar chart showing the number of novels with high and low prestige 
        before vs. in/after 1880 -->
        <xsl:variable name="works-before-1880" select="cligs:get-works-by-year(1880, 'before', $corpus-works)/@xml:id"/>
        <xsl:variable name="works-after-1880" select="cligs:get-works-by-year(1880, 'after', $corpus-works)/@xml:id"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-prestige-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 400px; height: 500px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.prestige'] = 'high'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.prestige'] = 'high'])"/>
                        ],
                        type: "bar",
                        name: "high"
                        
                        };
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.prestige'] = 'low'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.prestige'] = 'low'])"/>
                        ],
                        type: "bar",
                        name: "low"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        yaxis: {title: "number of works"},
                        barmode: "group",
                        annotations: [{
                        <xsl:variable name="num-works-low-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.prestige'] = 'low'])"/>
                        <xsl:variable name="num-works-high-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.prestige'] = 'high'])"/>
                        x: 0.25,
                        y: <xsl:value-of select="$num-works-low-before-1880"/>,
                        text: "<xsl:value-of select="round($num-works-low-before-1880 div ($num-works-high-before-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        },
                        {
                        <xsl:variable name="num-works-low-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.prestige'] = 'low'])"/>
                        <xsl:variable name="num-works-high-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.prestige'] = 'high'])"/>
                        x: 1.25,
                        y: <xsl:value-of select="$num-works-low-after-1880"/>,
                        text: "<xsl:value-of select="round($num-works-low-after-1880 div ($num-works-high-after-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        }
                        ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-prestige-country">
        <!-- creates two donut charts comparing the proportions of works with 
        high vs. low prestige for the three countries -->
        
        <xsl:variable name="countries" select="('Argentina', 'Mexico', 'Cuba')"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-prestige-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 400px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join($countries,'&quot;,&quot;')"/>"]
                        var values_high = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.prestige'] = 'high'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_low = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.prestige'] = 'low'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var data = [{
                        values: values_high,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "high",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_low,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "low",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'high',
                        x: 0.18,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'low',
                        x: 0.81,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-setting">
        <!-- creates two donut charts showing the proportions of works by setting.continent and setting.country -->
        
        <xsl:variable name="setting-continents" select="distinct-values($corpus//term[@type='text.setting.continent'])"/>
        <xsl:variable name="setting-countries" select="distinct-values($corpus//term[@type='text.setting.country'])"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-setting.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 700px;"></div>
                    <script>
                        var data = [{
                            values: [<xsl:for-each select="$setting-continents">
                                <xsl:value-of select="count($corpus[.//term[@type='text.setting.continent'] = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                            labels: ["<xsl:value-of select="string-join($setting-continents,'&quot;,&quot;')"/>"],
                            type: "pie",
                            direction: "clockwise",
                            name: "high",
                            legendgroup: "a",
                            domain: {row: 0, column: 0},
                            hole: 0.4
                            },{
                            values: [<xsl:for-each select="$setting-countries">
                                <xsl:value-of select="count($corpus[.//term[@type='text.setting.country'] = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                            labels: ["<xsl:value-of select="string-join($setting-countries,'&quot;,&quot;')"/>"],
                            type: "pie",
                            direction: "clockwise",
                            name: "low",
                            legendgroup: "b",
                            domain: {row: 0, column: 1},
                            hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 16
                        },
                        showarrow: false,
                        text: 'continent',
                        x: 0.17,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'country',
                        x: 0.83,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-setting-continent-decade">
        <!-- creates a grouped bar chart showing the number of novels with American and European setting
        for each decade -->
        <xsl:result-document href="{concat($output-dir,'corpus-setting-continent-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.setting.continent'] = 'America'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "America"
                        
                        };
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "Europe"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        yaxis: {title: "number of works"},
                        xaxis: {title: "decades"},
                        barmode: "group",
                        annotations: [
                        <xsl:for-each select="$decades">{
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:variable name="num-works-setting-Europe" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                            <xsl:variable name="num-works-setting-America" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.setting.continent'] = 'America'])"/>
                            x: <xsl:value-of select="."/>,
                            y: <xsl:value-of select="$num-works-setting-Europe"/>,
                            text: "<xsl:value-of select="round($num-works-setting-Europe div ($num-works-setting-America div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 14}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-setting-continent-1880">
        <!-- creates a grouped bar chart showing the number of novels with American vs. European setting 
        before vs. in/after 1880 -->
        <xsl:variable name="works-before-1880" select="cligs:get-works-by-year(1880, 'before', $corpus-works)/@xml:id"/>
        <xsl:variable name="works-after-1880" select="cligs:get-works-by-year(1880, 'after', $corpus-works)/@xml:id"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-setting-continent-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 400px; height: 500px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.setting.continent'] = 'America'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.setting.continent'] = 'America'])"/>
                        ],
                        type: "bar",
                        name: "America"
                        
                        };
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                        ],
                        type: "bar",
                        name: "Europe"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        yaxis: {title: "number of works"},
                        barmode: "group",
                        annotations: [{
                        <xsl:variable name="num-works-setting-Europe-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                        <xsl:variable name="num-works-setting-America-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.setting.continent'] = 'America'])"/>
                        x: 0.25,
                        y: <xsl:value-of select="$num-works-setting-Europe-before-1880"/>,
                        text: "<xsl:value-of select="round($num-works-setting-Europe-before-1880 div ($num-works-setting-America-before-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        },
                        {
                        <xsl:variable name="num-works-setting-Europe-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                        <xsl:variable name="num-works-setting-America-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.setting.continent'] = 'America'])"/>
                        x: 1.25,
                        y: <xsl:value-of select="$num-works-setting-Europe-after-1880"/>,
                        text: "<xsl:value-of select="round($num-works-setting-Europe-after-1880 div ($num-works-setting-America-after-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        }
                        ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-setting-continent-country">
        <!-- creates two donut charts comparing the proportions of works with 
        a American vs. European setting for the three countries -->
        
        <xsl:variable name="countries" select="('Argentina', 'Mexico', 'Cuba')"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-setting-continent-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 700px; height: 500px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join($countries,'&quot;,&quot;')"/>"]
                        var values_AM = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.setting.continent'] = 'America'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_EU = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.setting.continent'] = 'Europe'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var data = [{
                        values: values_AM,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "America",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_EU,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "Europe",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'America',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Europe',
                        x: 0.83,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-time-period">
        <!-- creates two donut charts showing the time periods covered by the novels in the corpus,
        one author-related and the other publication-related -->
        
        <xsl:variable name="time-periods-author" select="distinct-values($corpus//term[@type='text.time.period.author'])"/>
        <xsl:variable name="time-periods-publication" select="distinct-values($corpus//term[@type='text.time.period.publication'])"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-time-period.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 700px; height: 450px;"></div>
                    <script>
                        var data = [{
                        values: [<xsl:for-each select="$time-periods-author">
                            <xsl:value-of select="count($corpus[.//term[@type='text.time.period.author'] = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        labels: ["<xsl:value-of select="string-join($time-periods-author,'&quot;,&quot;')"/>"],
                        type: "pie",
                        direction: "clockwise",
                        name: "author",
                        domain: {row: 0, column: 0},
                        hole: 0.5
                        },{
                        values: [<xsl:for-each select="$time-periods-publication">
                            <xsl:value-of select="count($corpus[.//term[@type='text.time.period.publication'] = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        labels: ["<xsl:value-of select="string-join($time-periods-publication,'&quot;,&quot;')"/>"],
                        type: "pie",
                        direction: "clockwise",
                        name: "publication",
                        domain: {row: 0, column: 1},
                        hole: 0.5
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 16
                        },
                        showarrow: false,
                        text: 'author',
                        x: 0.17,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 16
                        },
                        showarrow: false,
                        text: 'publication',
                        x: 0.86,
                        y: 0.5
                        }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-corpus-time-period-publication-decade">
        <!-- creates a grouped bar chart showing the number of novels covering certain time periods
        for each decade -->
        <xsl:result-document href="{concat($output-dir,'corpus-time-period-publication-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.time.period.publication'] = 'contemporary'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "contemporary"
                        
                        };
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.time.period.publication'] = 'past'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "past"
                        };
                        var trace3 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:for-each select="$decades">
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        type: "bar",
                        name: "recent past"
                        };
                        
                        var data = [trace1, trace2, trace3];
                        var layout = {
                        yaxis: {title: "number of works"},
                        xaxis: {title: "decades"},
                        barmode: "group",
                        annotations: [
                        <xsl:for-each select="$decades">{
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:variable name="num-works-time-period-past" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.time.period.publication'] = 'past'])"/>
                            <xsl:variable name="num-works-decade" select="count($works-decade)"/>
                            x: <xsl:value-of select=". - 1.75"/>,
                            y: <xsl:value-of select="$num-works-time-period-past"/>,
                            text: "<xsl:value-of select="round($num-works-time-period-past div ($num-works-decade div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 11}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>,
                        <xsl:for-each select="$decades">{
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(., $corpus-works)"/>
                            <xsl:variable name="works-decade-ids" select="$works-decade/@xml:id"/>
                            <xsl:variable name="num-works-time-period-recent-past" select="count($corpus[.//idno[@type='bibacme'] = $works-decade-ids][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                            <xsl:variable name="num-works-decade" select="count($works-decade)"/>
                            x: <xsl:value-of select=". + 1.25"/>,
                            y: <xsl:value-of select="$num-works-time-period-recent-past"/>,
                            text: "<xsl:value-of select="round($num-works-time-period-recent-past div ($num-works-decade div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 11}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-time-period-publication-1880">
        <!-- creates a grouped bar chart showing the number of novels with past/recent past/contemporary time period 
        before vs. in/after 1880 -->
        <xsl:variable name="works-before-1880" select="cligs:get-works-by-year(1880, 'before', $corpus-works)/@xml:id"/>
        <xsl:variable name="works-after-1880" select="cligs:get-works-by-year(1880, 'after', $corpus-works)/@xml:id"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-time-period-publication-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 400px; height: 500px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.time.period.publication'] = 'contemporary'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.time.period.publication'] = 'contemporary'])"/>
                        ],
                        type: "bar",
                        name: "contemporary"
                        
                        };
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.time.period.publication'] = 'past'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.time.period.publication'] = 'past'])"/>
                        ],
                        type: "bar",
                        name: "past"
                        };
                        
                        var trace3 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                        ],
                        type: "bar",
                        name: "recent past"
                        };
                        
                        var data = [trace1, trace2, trace3];
                        var layout = {
                        yaxis: {title: "number of works"},
                        barmode: "group",
                        annotations: [{
                        <xsl:variable name="num-works-time-period-past-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.time.period.publication'] = 'past'])"/>
                        <xsl:variable name="num-works-before-1880" select="count($works-before-1880)"/>
                        x: 0.05,
                        y: <xsl:value-of select="$num-works-time-period-past-before-1880"/>,
                        text: "<xsl:value-of select="round($num-works-time-period-past-before-1880 div ($num-works-before-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        },
                        {
                        <xsl:variable name="num-works-time-period-past-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.time.period.publication'] = 'past'])"/>
                        <xsl:variable name="num-works-after-1880" select="count($works-after-1880)"/>
                        x: 1.05,
                        y: <xsl:value-of select="$num-works-time-period-past-after-1880"/>,
                        text: "<xsl:value-of select="round($num-works-time-period-past-after-1880 div ($num-works-after-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        },
                        {
                        <xsl:variable name="num-works-time-period-recent-past-before-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-before-1880][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                        <xsl:variable name="num-works-before-1880" select="count($works-before-1880)"/>
                        x: 0.35,
                        y: <xsl:value-of select="$num-works-time-period-recent-past-before-1880"/>,
                        text: "<xsl:value-of select="round($num-works-time-period-recent-past-before-1880 div ($num-works-before-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        },
                        {
                        <xsl:variable name="num-works-time-period-recent-past-after-1880" select="count($corpus[.//idno[@type='bibacme'] = $works-after-1880][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                        <xsl:variable name="num-works-after-1880" select="count($works-after-1880)"/>
                        x: 1.35,
                        y: <xsl:value-of select="$num-works-time-period-recent-past-after-1880"/>,
                        text: "<xsl:value-of select="round($num-works-time-period-recent-past-after-1880 div ($num-works-after-1880 div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 14}
                        }
                        ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-corpus-time-period-publication-country">
        <!-- creates three donut charts comparing the proportions of works with 
        a past/recent past/contemporary time period for the three countries -->
        
        <xsl:variable name="countries" select="('Argentina', 'Mexico', 'Cuba')"/>
        
        <xsl:result-document href="{concat($output-dir,'corpus-time-period-publication-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 400px;"></div>
                    <script>
                        var labels = ["<xsl:value-of select="string-join($countries,'&quot;,&quot;')"/>"]
                        var values_CT = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.time.period.publication'] = 'contemporary'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_PA = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.time.period.publication'] = 'past'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_RP = [<xsl:for-each select="$countries">
                            <xsl:value-of select="count($corpus[.//term[@type='author.country'] = current()][.//term[@type='text.time.period.publication'] = 'recent past'])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var data = [{
                        values: values_CT,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "contemporary",
                        domain: {row: 0, column: 0},
                        hole: 0.5
                        },{
                        values: values_PA,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "past",
                        domain: {row: 0, column: 1},
                        hole: 0.5
                        },{
                        values: values_RP,
                        labels: labels,
                        type: "pie",
                        direction: "clockwise",
                        name: "recent past",
                        domain: {row: 0, column: 2},
                        hole: 0.5
                        }
                        ];
                        
                        var layout = {
                        grid: {rows: 1, columns: 3},
                        legend: {orientation: "h"},
                        annotations: [
                            {
                            font: {
                            size: 18
                            },
                            showarrow: false,
                            text: 'contemp.',
                            x: 0.09,
                            y: 0.5
                            },
                            {
                            font: {
                            size: 18
                            },
                            showarrow: false,
                            text: 'past',
                            x: 0.5,
                            y: 0.5
                            },
                            {
                            font: {
                            size: 18
                            },
                            showarrow: false,
                            text: 'recent',
                            x: 0.89,
                            y: 0.5
                            }
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-editions-per-work">
        <!-- how many editions were published per work? creates a histogram comparing Bib-ACMé and Conha19 -->
        
        <xsl:variable name="num-editions-per-work-bib" select="cligs:get-editions-per-work($bibacme-works)"/>
        <xsl:variable name="num-editions-per-work-corp" select="cligs:get-editions-per-work($corpus-works)"/>
        
        <xsl:result-document href="{concat($output-dir,'editions-per-work.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        var x1 = [<xsl:value-of select="string-join($num-editions-per-work-bib,',')"/>];
                        var trace1 = {
                        x: x1,
                        type: 'histogram',
                        opacity: 0.5,
                        name: 'Bib-ACMé'
                        };
                        var x2 = [<xsl:value-of select="string-join($num-editions-per-work-corp,',')"/>];
                        var trace2 = {
                        x: x2,
                        type: 'histogram',
                        opacity: 0.5,
                        name: 'Conha19'
                        };
                        var data = [trace1, trace2];
                        var layout = {
                        xaxis: {title: "number of editions"}, 
                        yaxis: {title: "number of works"},
                        barmode: "overlay",
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        font: {size: 14},
                        annotations: [
                        <xsl:for-each select="1 to 5">{
                            <xsl:variable name="num-works-per-edition-num-bib" select="count(index-of($num-editions-per-work-bib,string(.)))"/>
                            <xsl:variable name="num-works-per-edition-num-corp" select="count(index-of($num-editions-per-work-corp,string(.)))"/>
                            x: <xsl:value-of select="."/>,
                            y: <xsl:value-of select="$num-works-per-edition-num-corp"/>,
                            text: "<xsl:value-of select="round($num-works-per-edition-num-corp div ($num-works-per-edition-num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "center",
                            yanchor: "top",
                            font: {size: 12}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-editions-by-year">
        <!-- creates a bar chart showing the number of editions per year, comparing Bib-ACMé and Conha19 -->
        
        <xsl:variable name="labels-x" select="1830 to 1910"/>
        <xsl:variable name="edition-years-bib" select="cligs:get-edition-years($bibacme-works)"/>
        <xsl:variable name="edition-years-corp" select="cligs:get-edition-years($corpus-works)"/>
        
        <xsl:result-document href="{concat($output-dir,'editions-per-year.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $edition-years-bib)"/>],
                        name: "Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-years($labels-x, $edition-years-corp)"/>],
                        name: "Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 1, title: "years", tickangle: 270, tickfont: {size: 12}},
                        yaxis: {title: "number of editions"},
                        legend: {orientation: "h", font: {size: 18}},
                        font: {size: 16}
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-editions-by-decade">
        <!-- creates a bar chart showing the number of editions per decade, comparing Bib-ACMé and Conha19 -->
        
        <xsl:variable name="edition-years-bib" select="cligs:get-edition-years($bibacme-works)"/>
        <xsl:variable name="edition-years-corp" select="cligs:get-edition-years($corpus-works)"/>
        
        <xsl:result-document href="{concat($output-dir,'editions-per-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $edition-years-bib)"/>],
                        name: "Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($decades,',')"/>],
                        y: [<xsl:value-of select="cligs:get-num-decades($decades, $edition-years-corp)"/>],
                        name: "Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        var layout = {
                        barmode: "group",
                        xaxis: {tickmode: "linear", dtick: 10, title: "decades", tickfont: {size: 16}},
                        yaxis: {title: "number of editions"},
                        legend: {orientation: "h", font: {size: 18}},
                        font: {size: 16},
                        annotations: [
                        <xsl:for-each select="$decades">{
                            <xsl:variable name="num-decade-bib" select="cligs:get-num-decades(.,$edition-years-bib)"/>
                            <xsl:variable name="num-decade-corp" select="cligs:get-num-decades(.,$edition-years-corp)"/>
                            x: <xsl:value-of select="."/>,
                            y: <xsl:value-of select="$num-decade-corp"/>,
                            text: "<xsl:value-of select="round($num-decade-corp div ($num-decade-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 16}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-editions-1880">
        <!-- creates a grouped bar chart comparing the number of editions before and after 1880
        in Bib-ACMé vs. Conha19 -->
        
        <xsl:variable name="edition-years-bib" select="cligs:get-edition-years($bibacme-works)"/>
        <xsl:variable name="edition-years-corp" select="cligs:get-edition-years($corpus-works)"/>
        <xsl:variable name="num-years-before-1880-bib" select="cligs:get-num-years(1880, $edition-years-bib, 'before')"/>
        <xsl:variable name="num-years-before-1880-corp" select="cligs:get-num-years(1880, $edition-years-corp, 'before')"/>
        <xsl:variable name="num-years-after-1880-bib" select="cligs:get-num-years(1880, $edition-years-bib, 'after')"/>
        <xsl:variable name="num-years-after-1880-corp" select="cligs:get-num-years(1880, $edition-years-corp, 'after')"/>
        
        
        <xsl:result-document href="{concat($output-dir,'editions-1880.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 500px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: ["before 1880","in or after 1880"],
                        y: [<xsl:value-of select="$num-years-before-1880-bib"/>,
                        <xsl:value-of select="$num-years-after-1880-bib"/>],
                        type: 'bar',
                        name: "Bib-ACMé"
                        };
                        
                        var trace2 = {
                        x: ["before 1880", "in or after 1880"],
                        y: [<xsl:value-of select="$num-years-before-1880-corp"/>,
                        <xsl:value-of select="$num-years-after-1880-corp"/>],
                        type: 'bar',
                        name: "Conha19"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        xaxis: {tickmode: "linear", dtick: 1},
                        yaxis: {title: "number of editions", titlefont: {size: 16}},
                        boxmode: "group",
                        legend: {orientation: "h"},
                        font: {size: 16},
                        annotations: [{
                        x: 0.25,
                        y: <xsl:value-of select="$num-years-before-1880-corp"/>,
                        text: "<xsl:value-of select="round($num-years-before-1880-corp div ($num-years-before-1880-bib div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 16}
                        },
                        {
                        x: 1.25,
                        y: <xsl:value-of select="$num-years-after-1880-corp"/>,
                        text: "<xsl:value-of select="round($num-years-after-1880-corp div ($num-years-after-1880-bib div 100))"/>%",
                        showarrow: false,
                        xanchor: "center",
                        yanchor: "bottom",
                        font: {size: 16}
                        }
                        ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-editions-by-country">
        <!-- how many editions were published by country? counts all the editions, not just
        the first ones of the works. If an edition has several places of publication, all are counted in.
        Creates two donut charts to compare the countries. -->
        
        <xsl:variable name="edition-countries-bib">
            <countries xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$bibacme-editions//pubPlace/substring-after(@corresp,'#')" group-by=".">
                    <country xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="cligs:map-country-name(current-grouping-key())"/></country>
                </xsl:for-each-group>
            </countries>
        </xsl:variable>
        
        <xsl:variable name="edition-countries-corp">
            <countries xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$corpus-editions//pubPlace/substring-after(@corresp,'#')" group-by=".">
                    <country xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="cligs:map-country-name(current-grouping-key())"/></country>
                </xsl:for-each-group>
            </countries>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'editions-by-country.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 600px;"></div>
                    <script>
                        var labels_bib = ["<xsl:value-of select="string-join($edition-countries-bib//cligs:country,'&quot;,&quot;')"/>"]
                        var values_bib = [<xsl:value-of select="string-join($edition-countries-bib//cligs:country/@n,',')"/>]
                        
                        var labels_corp = ["<xsl:value-of select="string-join($edition-countries-corp//cligs:country,'&quot;,&quot;')"/>"]
                        var values_corp = [<xsl:value-of select="string-join($edition-countries-corp//cligs:country/@n,',')"/>]
                        
                        var data = [{
                        values: values_bib,
                        labels: labels_bib,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels_corp,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.84,
                        y: 0.5
                        }
                        ],
                        legend: {font: {size: 16}}
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-editions-publication-place">
        <!-- how many editions were published where? create a grouped bar chart showing the number 
        of editions published in different places in Bib-ACMé and Conha19. Order by the place with most
        editions in Bib-ACMé. This plot includes all the editions of the works, not only the first 
        editions, and it does not refer to countries, but cities. If an edition has several places 
        of publication, all are counted in. -->
        <xsl:variable name="publication-places">
            <places xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$bibacme-editions//pubPlace" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:variable name="place-name">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key()='desconocido'">unknown</xsl:when>
                            <xsl:otherwise><xsl:value-of select="current-grouping-key()"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <place xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="$place-name"/></place>
                </xsl:for-each-group>
            </places>
        </xsl:variable>
        <xsl:result-document href="{concat($output-dir,'editions-publication-place.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($publication-places//cligs:place,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($publication-places//@n, ',')"/>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($publication-places//cligs:place,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$publication-places//cligs:place">
                                <xsl:value-of select="count($corpus-editions[.//pubPlace/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                            barmode: 'group',
                            yaxis: {title: 'number of editions'},
                            xaxis: {title: 'places', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                            legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-novela-by-decade">
        <!-- creates a series of donut charts showing the number of "novelas" per decade, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-novela-per-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 500px;"></div>
                    <script>
                        var labels = ["novela", "no label"];
                        var data = [
                        <xsl:for-each select="$decades">
                            {
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(current(), $bibacme-works)"/>
                            <xsl:variable name="works-novela" select="$works-decade[term[@type='subgenre.summary.signal.explicit']='novela']"/>
                            values: [<xsl:value-of select="count($works-novela)"/>, <xsl:value-of select="count($works-decade) - count($works-novela)"/>],
                            labels: labels,
                            type: "pie",
                            sort: false,
                            name: "<xsl:value-of select="."/>",
                            domain: {row: <xsl:choose>
                                <xsl:when test="position() &lt;= 5">0</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>, column: <xsl:choose>
                                <xsl:when test="position() &lt;= 5">
                                    <xsl:value-of select="position() - 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="position() - 6"/>
                                </xsl:otherwise>
                            </xsl:choose>},
                            hole: 0.4
                            }
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ];
                        
                        var layout = {
                        grid: {rows: 2, columns: 5},
                        legend: {orientation: "h"},
                        annotations: [
                        <xsl:for-each select="$decades">
                            {
                            font: {
                            size: 14
                            },
                            showarrow: false,
                            text: '<xsl:value-of select="."/>',
                            x: <xsl:choose>
                                <xsl:when test="position() = (1,6)">0.066</xsl:when>
                                <xsl:when test="position() = (2,7)">0.265</xsl:when>
                                <xsl:when test="position() = (3,8)">0.5</xsl:when>
                                <xsl:when test="position() = (4,9)">0.73</xsl:when>
                                <xsl:otherwise>0.935</xsl:otherwise>
                            </xsl:choose>,
                            y: <xsl:choose>
                                <xsl:when test="position() &lt;= 5">0.8</xsl:when>
                                <xsl:otherwise>0.2</xsl:otherwise>
                            </xsl:choose>
                            }
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-explicit-signals">
        <!-- creates a bar plot showing the most frequent explicit subgenre signals in Bib-ACMé and Conha19 -->
        
        <xsl:variable name="subgenre-signals-bib">
            <subgenres xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$bibacme-works//term[@type='subgenre.summary.signal.explicit']" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:if test="position() &lt;= 20">
                        <label xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></label>
                    </xsl:if>
                </xsl:for-each-group>
            </subgenres>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-explicit-signals.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-bib//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($subgenre-signals-bib//@n, ',')"/>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-bib//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$subgenre-signals-bib//cligs:label">
                            <xsl:value-of select="count($corpus-works[.//term[@type='subgenre.summary.signal.explicit']/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        yaxis: {title: 'number of assignments'},
                        xaxis: {title: 'subgenre labels', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                        legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-explicit-signals-corpus">
        <!-- creates a bar plot showing the most frequent explicit subgenre signals in Bib-ACMé and Conha19,
        ordered by top positions in the corpus -->
        
        <xsl:variable name="subgenre-signals-corp">
            <subgenres xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$corpus-works//term[@type='subgenre.summary.signal.explicit']" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:if test="position() &lt;= 20">
                        <label xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></label>
                    </xsl:if>
                </xsl:for-each-group>
            </subgenres>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-explicit-signals-corpus.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-corp//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($subgenre-signals-corp//@n, ',')"/>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-corp//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$subgenre-signals-corp//cligs:label">
                            <xsl:value-of select="count($bibacme-works[.//term[@type='subgenre.summary.signal.explicit']/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        yaxis: {title: 'number of assignments'},
                        xaxis: {title: 'subgenre labels', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                        legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-identity-by-decade">
        <!-- creates a series of donut charts showing the number of novels with identity labels per decade, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-identity-per-decade.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 500px;"></div>
                    <script>
                        var labels = ["identity label", "no identity label"];
                        var data = [
                        <xsl:for-each select="$decades">
                            {
                            <xsl:variable name="works-decade" select="cligs:get-works-by-decade(current(), $bibacme-works)"/>
                            <xsl:variable name="works-identity" select="$works-decade[term[@type='subgenre.summary.identity.explicit']]"/>
                            values: [<xsl:value-of select="count($works-identity)"/>, <xsl:value-of select="count($works-decade) - count($works-identity)"/>],
                            labels: labels,
                            type: "pie",
                            sort: false,
                            name: "<xsl:value-of select="."/>",
                            domain: {row: <xsl:choose>
                                <xsl:when test="position() &lt;= 5">0</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>, column: <xsl:choose>
                                <xsl:when test="position() &lt;= 5">
                                    <xsl:value-of select="position() - 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="position() - 6"/>
                                </xsl:otherwise>
                            </xsl:choose>},
                            hole: 0.4
                            }
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ];
                        
                        var layout = {
                        grid: {rows: 2, columns: 5},
                        legend: {orientation: "h"},
                        annotations: [
                        <xsl:for-each select="$decades">
                            {
                            font: {
                            size: 14
                            },
                            showarrow: false,
                            text: '<xsl:value-of select="."/>',
                            x: <xsl:choose>
                                <xsl:when test="position() = (1,6)">0.066</xsl:when>
                                <xsl:when test="position() = (2,7)">0.265</xsl:when>
                                <xsl:when test="position() = (3,8)">0.5</xsl:when>
                                <xsl:when test="position() = (4,9)">0.73</xsl:when>
                                <xsl:otherwise>0.935</xsl:otherwise>
                            </xsl:choose>,
                            y: <xsl:choose>
                                <xsl:when test="position() &lt;= 5">0.8</xsl:when>
                                <xsl:otherwise>0.2</xsl:otherwise>
                            </xsl:choose>
                            }
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ]
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-signals">
        <!-- creates a bar plot showing the most frequent subgenre signals (explicit and implicit) in Bib-ACMé and Conha19 -->
        
        <xsl:variable name="subgenre-signals-bib">
            <subgenres xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$bibacme-works//term[starts-with(@type,'subgenre.summary.signal')]" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:if test="position() &lt;= 20">
                        <label xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></label>
                    </xsl:if>
                </xsl:for-each-group>
            </subgenres>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-signals.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-bib//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($subgenre-signals-bib//@n, ',')"/>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-bib//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$subgenre-signals-bib//cligs:label">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.signal')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        yaxis: {title: 'number of assignments'},
                        xaxis: {title: 'subgenre labels', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                        legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-signals-corpus">
        <!-- creates a bar plot showing the most frequent subgenre signals (explicit and implicit) in Bib-ACMé and Conha19,
        ordered by top positions in the corpus -->
        
        <xsl:variable name="subgenre-signals-corp">
            <subgenres xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$corpus-works//term[starts-with(@type,'subgenre.summary.signal')]" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:if test="position() &lt;= 20">
                        <label xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></label>
                    </xsl:if>
                </xsl:for-each-group>
            </subgenres>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-signals-corpus.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-corp//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($subgenre-signals-corp//@n, ',')"/>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($subgenre-signals-corp//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$subgenre-signals-corp//cligs:label">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.signal')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        yaxis: {title: 'number of assignments'},
                        xaxis: {title: 'subgenre labels', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                        legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-litHist">
        <!-- creates a bar plot showing the most frequent literary historical subgenre labels in Bib-ACMé and Conha19 -->
        
        <xsl:variable name="subgenre-labels-bib">
            <subgenres xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$bibacme-works//term[@type='subgenre.litHist.interp']" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:if test="position() &lt;= 20">
                        <label xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></label>
                    </xsl:if>
                </xsl:for-each-group>
            </subgenres>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-litHist.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($subgenre-labels-bib//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($subgenre-labels-bib//@n, ',')"/>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($subgenre-labels-bib//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$subgenre-labels-bib//cligs:label">
                            <xsl:value-of select="count($corpus-works[.//term[@type='subgenre.litHist.interp']/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        yaxis: {title: 'number of assignments'},
                        xaxis: {title: 'subgenre labels', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                        legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-litHist-corpus">
        <!-- creates a bar plot showing the most frequent literary historical subgenre labels in Bib-ACMé and Conha19,
        ordered by top positions in the corpus -->
        
        <xsl:variable name="subgenre-labels-corp">
            <subgenres xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each-group select="$corpus-works//term[@type='subgenre.litHist.interp']" group-by="normalize-space(.)">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:if test="position() &lt;= 20">
                        <label xmlns="https://cligs.hypotheses.org/ns/cligs" n="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></label>
                    </xsl:if>
                </xsl:for-each-group>
            </subgenres>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-litHist-corpus.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 700px;"></div>
                    <script>
                        var trace1 = {
                        x: ["<xsl:value-of select="string-join($subgenre-labels-corp//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:value-of select="string-join($subgenre-labels-corp//@n, ',')"/>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: ["<xsl:value-of select="string-join($subgenre-labels-corp//cligs:label,'&quot;,&quot;')"/>"],
                        y: [<xsl:for-each select="$subgenre-labels-corp//cligs:label">
                            <xsl:value-of select="count($bibacme-works[.//term[@type='subgenre.litHist.interp']/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        yaxis: {title: 'number of assignments'},
                        xaxis: {title: 'subgenre labels', tickmode: 'linear', dtick: 1, tickangle: 270, automargin: true},
                        legend: {x: 1, y: 1, xanchor: 'right'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-number-bib">
        <!-- creates a sankey diagram showing how many different subgenre labels there are in each 
        category of the discursive subgenre model, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-number-bib.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                            type: "sankey",
                            orientation: "h",
                            arrangement: "snap",
                            node: {
                                pad: 15,
                                thickness: 30,
                                line: {
                                color: "black",
                                width: 0.5
                                },
                            label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                            color: [<xsl:for-each select="1 to 9">
                                <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                            </xsl:for-each><xsl:for-each select="1 to 8">
                                <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                                    <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>]
                        },
                        
                        link: {
                            source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                            target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                            <xsl:variable name="comm_frame" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention') or starts-with(@type,'subgenre.summary.mode.attitude') or starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.)))"/>
                            <xsl:variable name="realization" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium') or starts-with(@type,'subgenre.summary.mode.representation') or starts-with(@type,'subgenre.summary.theme')]/normalize-space(.)))"/>
                            <xsl:variable name="context" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.identity') or starts-with(@type,'subgenre.summary.current')]/normalize-space(.)))"/>
                            <xsl:variable name="medium" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.)))"/>
                            <xsl:variable name="syntactic" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.)))"/>
                            <xsl:variable name="semantic" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.)))"/>
                            <xsl:variable name="spatial" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.)))"/>
                            <xsl:variable name="temporal" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.)))"/>
                            <xsl:variable name="intention" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.)))"/>
                            <xsl:variable name="attitude" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.)))"/>
                            <xsl:variable name="reality" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.)))"/>
                            value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                                    <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of different subgenre labels",
                        font: {
                            size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-number-corpus">
        <!-- creates a sankey diagram showing how many different subgenre labels there are in each 
        category of the discursive subgenre model, for Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-number-corpus.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        arrangement: "snap",
                        orientation: "h",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention') or starts-with(@type,'subgenre.summary.mode.attitude') or starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.)))"/>
                        <xsl:variable name="realization" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium') or starts-with(@type,'subgenre.summary.mode.representation') or starts-with(@type,'subgenre.summary.theme')]/normalize-space(.)))"/>
                        <xsl:variable name="context" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.identity') or starts-with(@type,'subgenre.summary.current')]/normalize-space(.)))"/>
                        <xsl:variable name="medium" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.)))"/>
                        <xsl:variable name="syntactic" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.)))"/>
                        <xsl:variable name="semantic" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.)))"/>
                        <xsl:variable name="spatial" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.)))"/>
                        <xsl:variable name="temporal" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.)))"/>
                        <xsl:variable name="intention" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.)))"/>
                        <xsl:variable name="attitude" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.)))"/>
                        <xsl:variable name="reality" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.)))"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of different subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-amount-bib">
        <!-- creates a sankey diagram showing how many subgenre labels there are in each 
        category of the discursive subgenre model, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-amount-bib.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count($bibacme-works//(term[starts-with(@type,'subgenre.summary.mode.intention')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.mode.attitude')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.mode.reality')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.))]))"/>
                        <xsl:variable name="realization" select="count($bibacme-works//(term[starts-with(@type,'subgenre.summary.mode.medium')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.mode.representation')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.theme')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.))]))"/>
                        <xsl:variable name="context" select="count($bibacme-works//(term[starts-with(@type,'subgenre.summary.identity')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.current')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.))]))"/>
                        <xsl:variable name="medium" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.))])"/>
                        <xsl:variable name="syntactic" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.representation')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))])"/>
                        <xsl:variable name="semantic" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.theme')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.))])"/>
                        <xsl:variable name="spatial" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.identity')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.))])"/>
                        <xsl:variable name="temporal" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.current')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.))])"/>
                        <xsl:variable name="intention" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.))])"/>
                        <xsl:variable name="attitude" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.attitude')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.))])"/>
                        <xsl:variable name="reality" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.reality')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.))])"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-amount-corpus">
        <!-- creates a sankey diagram showing how many subgenre labels there are in each 
        category of the discursive subgenre model, for Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-amount-corpus.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count($corpus-works//(term[starts-with(@type,'subgenre.summary.mode.intention')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.mode.attitude')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.mode.reality')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.))]))"/>
                        <xsl:variable name="realization" select="count($corpus-works//(term[starts-with(@type,'subgenre.summary.mode.medium')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.mode.representation')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.theme')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.))]))"/>
                        <xsl:variable name="context" select="count($corpus-works//(term[starts-with(@type,'subgenre.summary.identity')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.))]|term[starts-with(@type,'subgenre.summary.current')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.))]))"/>
                        <xsl:variable name="medium" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.))])"/>
                        <xsl:variable name="syntactic" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.representation')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))])"/>
                        <xsl:variable name="semantic" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.theme')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.))])"/>
                        <xsl:variable name="spatial" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.identity')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.))])"/>
                        <xsl:variable name="temporal" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.current')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.))])"/>
                        <xsl:variable name="intention" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.))])"/>
                        <xsl:variable name="attitude" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.attitude')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.))])"/>
                        <xsl:variable name="reality" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.reality')][not(normalize-space(.) = preceding-sibling::term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.))])"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-number-explicit-bib">
        <!-- creates a sankey diagram showing how many different explicit subgenre labels there are in each 
        category of the discursive subgenre model, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-number-explicit-bib.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit') or starts-with(@type,'subgenre.summary.mode.attitude.explicit') or starts-with(@type,'subgenre.summary.mode.reality.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="realization" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit') or starts-with(@type,'subgenre.summary.mode.representation.explicit') or starts-with(@type,'subgenre.summary.theme.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="context" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.explicit') or starts-with(@type,'subgenre.summary.current.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="medium" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="syntactic" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.representation.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="semantic" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.theme.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="spatial" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="temporal" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.current.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="intention" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="attitude" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.attitude.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="reality" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.reality.explicit')]/normalize-space(.)))"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of different explicit subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-number-explicit-corp">
        <!-- creates a sankey diagram showing how many different explicit subgenre labels there are in each 
        category of the discursive subgenre model, for Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-number-explicit-corp.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit') or starts-with(@type,'subgenre.summary.mode.attitude.explicit') or starts-with(@type,'subgenre.summary.mode.reality.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="realization" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit') or starts-with(@type,'subgenre.summary.mode.representation.explicit') or starts-with(@type,'subgenre.summary.theme.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="context" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.identity.explicit') or starts-with(@type,'subgenre.summary.current.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="medium" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="syntactic" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.representation.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="semantic" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.theme.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="spatial" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.identity.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="temporal" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.current.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="intention" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="attitude" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.attitude.explicit')]/normalize-space(.)))"/>
                        <xsl:variable name="reality" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.reality.explicit')]/normalize-space(.)))"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of different explicit subgenre labels (Conha19)",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-number-litHist-bib">
        <!-- creates a sankey diagram showing how many different literary historical subgenre labels there are in each 
        category of the discursive subgenre model, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-number-litHist-bib.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist') or starts-with(@type,'subgenre.summary.mode.attitude.litHist') or starts-with(@type,'subgenre.summary.mode.reality.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="realization" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist') or starts-with(@type,'subgenre.summary.mode.representation.litHist') or starts-with(@type,'subgenre.summary.theme.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="context" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.litHist') or starts-with(@type,'subgenre.summary.current.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="medium" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="syntactic" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.representation.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="semantic" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.theme.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="spatial" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="temporal" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.current.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="intention" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="attitude" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.attitude.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="reality" select="count(distinct-values($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.reality.litHist')]/normalize-space(.)))"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of different literary historical subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-number-litHist-corp">
        <!-- creates a sankey diagram showing how many different literary historical subgenre labels there are in each 
        category of the discursive subgenre model, for Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-number-litHist-corp.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist') or starts-with(@type,'subgenre.summary.mode.attitude.litHist') or starts-with(@type,'subgenre.summary.mode.reality.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="realization" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist') or starts-with(@type,'subgenre.summary.mode.representation.litHist') or starts-with(@type,'subgenre.summary.theme.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="context" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.identity.litHist') or starts-with(@type,'subgenre.summary.current.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="medium" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="syntactic" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.representation.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="semantic" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.theme.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="spatial" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.identity.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="temporal" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.current.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="intention" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="attitude" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.attitude.litHist')]/normalize-space(.)))"/>
                        <xsl:variable name="reality" select="count(distinct-values($corpus-works//term[starts-with(@type,'subgenre.summary.mode.reality.litHist')]/normalize-space(.)))"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of different literary historical subgenre labels (Conha19)",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-amount-explicit-bib">
        <!-- creates a sankey diagram showing how many explicit subgenre labels there are in each 
        category of the discursive subgenre model, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-amount-explicit-bib.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit') or starts-with(@type,'subgenre.summary.mode.attitude.explicit') or starts-with(@type,'subgenre.summary.mode.reality.explicit')])"/>
                        <xsl:variable name="realization" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit') or starts-with(@type,'subgenre.summary.mode.representation.explicit') or starts-with(@type,'subgenre.summary.theme.explicit')])"/>
                        <xsl:variable name="context" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.explicit') or starts-with(@type,'subgenre.summary.current.explicit')])"/>
                        <xsl:variable name="medium" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit')])"/>
                        <xsl:variable name="syntactic" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.representation.explicit')])"/>
                        <xsl:variable name="semantic" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.theme.explicit')])"/>
                        <xsl:variable name="spatial" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.explicit')])"/>
                        <xsl:variable name="temporal" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.current.explicit')])"/>
                        <xsl:variable name="intention" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit')])"/>
                        <xsl:variable name="attitude" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.attitude.explicit')])"/>
                        <xsl:variable name="reality" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.reality.explicit')])"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of explicit subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-amount-explicit-corp">
        <!-- creates a sankey diagram showing how many explicit subgenre labels there are in each 
        category of the discursive subgenre model, for Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-amount-explicit-corp.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit') or starts-with(@type,'subgenre.summary.mode.attitude.explicit') or starts-with(@type,'subgenre.summary.mode.reality.explicit')])"/>
                        <xsl:variable name="realization" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit') or starts-with(@type,'subgenre.summary.mode.representation.explicit') or starts-with(@type,'subgenre.summary.theme.explicit')])"/>
                        <xsl:variable name="context" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.identity.explicit') or starts-with(@type,'subgenre.summary.current.explicit')])"/>
                        <xsl:variable name="medium" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.explicit')])"/>
                        <xsl:variable name="syntactic" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.representation.explicit')])"/>
                        <xsl:variable name="semantic" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.theme.explicit')])"/>
                        <xsl:variable name="spatial" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.identity.explicit')])"/>
                        <xsl:variable name="temporal" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.current.explicit')])"/>
                        <xsl:variable name="intention" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.explicit')])"/>
                        <xsl:variable name="attitude" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.attitude.explicit')])"/>
                        <xsl:variable name="reality" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.reality.explicit')])"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of explicit subgenre labels (Conha19)",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-amount-litHist-bib">
        <!-- creates a sankey diagram showing how many explicit subgenre labels there are in each 
        category of the discursive subgenre model, for Bib-ACMé -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-amount-litHist-bib.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist') or starts-with(@type,'subgenre.summary.mode.attitude.litHist') or starts-with(@type,'subgenre.summary.mode.reality.litHist')])"/>
                        <xsl:variable name="realization" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist') or starts-with(@type,'subgenre.summary.mode.representation.litHist') or starts-with(@type,'subgenre.summary.theme.litHist')])"/>
                        <xsl:variable name="context" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.litHist') or starts-with(@type,'subgenre.summary.current.litHist')])"/>
                        <xsl:variable name="medium" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist')])"/>
                        <xsl:variable name="syntactic" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.representation.litHist')])"/>
                        <xsl:variable name="semantic" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.theme.litHist')])"/>
                        <xsl:variable name="spatial" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.identity.litHist')])"/>
                        <xsl:variable name="temporal" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.current.litHist')])"/>
                        <xsl:variable name="intention" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist')])"/>
                        <xsl:variable name="attitude" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.attitude.litHist')])"/>
                        <xsl:variable name="reality" select="count($bibacme-works//term[starts-with(@type,'subgenre.summary.mode.reality.litHist')])"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of literary historical subgenre labels",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-labels-amount-litHist-corp">
        <!-- creates a sankey diagram showing how many explicit subgenre labels there are in each 
        category of the discursive subgenre model, for Conha19 -->
        
        <xsl:result-document href="{concat($output-dir,'subgenres-labels-amount-litHist-corp.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 900px;"></div>
                    <script>
                        var data = {
                        type: "sankey",
                        orientation: "h",
                        arrangement: "snap",
                        node: {
                        pad: 15,
                        thickness: 30,
                        line: {
                        color: "black",
                        width: 0.5
                        },
                        label: ["discursive act", "communicational frame", "realization", "context", "medium", "syntactic", "semantic", "spatial", "temporal", "mode.intention", "mode.attitude", "mode.reality", "mode.medium", "mode.representation", "theme", "identity", "current"],
                        color: [<xsl:for-each select="1 to 9">
                            <xsl:text>"rgb(31, 119, 180)",</xsl:text>
                        </xsl:for-each><xsl:for-each select="1 to 8">
                            <xsl:text>"rgb(255, 127, 14)"</xsl:text>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        },
                        
                        link: {
                        source: [0,0,0,2,2,2,3,3,1,1,1,4,5,6,7,8],
                        target: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        <xsl:variable name="comm_frame" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist') or starts-with(@type,'subgenre.summary.mode.attitude.litHist') or starts-with(@type,'subgenre.summary.mode.reality.litHist')])"/>
                        <xsl:variable name="realization" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist') or starts-with(@type,'subgenre.summary.mode.representation.litHist') or starts-with(@type,'subgenre.summary.theme.litHist')])"/>
                        <xsl:variable name="context" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.identity.litHist') or starts-with(@type,'subgenre.summary.current.litHist')])"/>
                        <xsl:variable name="medium" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.medium.litHist')])"/>
                        <xsl:variable name="syntactic" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.representation.litHist')])"/>
                        <xsl:variable name="semantic" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.theme.litHist')])"/>
                        <xsl:variable name="spatial" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.identity.litHist')])"/>
                        <xsl:variable name="temporal" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.current.litHist')])"/>
                        <xsl:variable name="intention" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.intention.litHist')])"/>
                        <xsl:variable name="attitude" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.attitude.litHist')])"/>
                        <xsl:variable name="reality" select="count($corpus-works//term[starts-with(@type,'subgenre.summary.mode.reality.litHist')])"/>
                        value: [<xsl:value-of select="$comm_frame"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$realization"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$context"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$intention"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$attitude"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$reality"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$medium"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$syntactic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$semantic"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$spatial"/><xsl:text>,</xsl:text>
                        <xsl:value-of select="$temporal"/><xsl:text>,</xsl:text>]
                        }
                        }
                        
                        var data = [data]
                        
                        var layout = {
                        title: "Number of literary historical subgenre labels (Conha19)",
                        font: {
                        size: 14
                        }
                        }
                        
                        Plotly.react('myDiv', data, layout)
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-theme">
        <!-- creates an overview of the thematic subgenres in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="thematic-labels-set" select="distinct-values($bibacme-works//term[contains(@type,'theme')]/normalize-space(normalize-space(.)))"/>
        <xsl:variable name="thematic-more-than-10" select="cligs:get-labels-least($bibacme-works,$thematic-labels-set,'theme',10)"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($thematic-more-than-10,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-theme.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$thematic-more-than-10">
                                <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.) = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$thematic-more-than-10">
                                <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.) = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                            barmode: 'group',
                            font: {size: 14},
                            title: 'Thematic subgenre labels in Bib-ACMé and Conha19',
                            xaxis: {title: 'subgenres', automargin: true},
                            yaxis: {title: 'number of works'},
                            legend: {
                                x: 1,
                                xanchor: 'right',
                                y: 1,
                                font: {size: 16}
                                },
                            annotations: [
                            <xsl:for-each select="$thematic-more-than-10">{
                                <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.) = current()])"/>
                                <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.) = current()])"/>
                                x: <xsl:value-of select="position() - 1"/>,
                                y: <xsl:value-of select="$num-corp"/>,
                                text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 12}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>]
                            };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-theme-bib-sources">
        <!-- creates an overview of the thematic subgenres in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="thematic-labels-set" select="distinct-values($bibacme-works//term[contains(@type,'theme')]/normalize-space(normalize-space(.)))"/>
        <xsl:variable name="thematic-more-than-10" select="cligs:get-labels-least($bibacme-works,$thematic-labels-set,'theme',10)"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($thematic-more-than-10,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-theme-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$thematic-more-than-10">
                                <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.theme.explicit')]/normalize-space(.) = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                        name: 'explicit signal',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$thematic-more-than-10">
                                <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.theme.implicit')]/normalize-space(.) = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                        name: 'implicit signal',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$thematic-more-than-10">
                                <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.theme.litHist')]/normalize-space(.) = current()])"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                        name: 'literary historical',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack', 
                        font: {size: 14},
                        legend: {
                            x: 1,
                            xanchor: 'right',
                            y: 1,
                            font: {size: 16}
                        },
                        title: 'Sources of thematic subgenre labels in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-num-thematic-labels-work">
        <!-- creates a histogram showing the number of thematic labels per work for Bib-ACMé and Conha19 -->
        <xsl:variable name="num-labels-per-work-bib" select="cligs:get-labels-per-work($bibacme-works,'theme')"/>
        <xsl:variable name="num-labels-per-work-corp" select="cligs:get-labels-per-work($corpus-works,'theme')"/>
        <xsl:result-document href="{concat($output-dir,'subgenres-thematic-labels-per-work.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var x1 = [<xsl:value-of select="string-join($num-labels-per-work-bib,',')"/>];
                        var trace1 = {
                        x: x1,
                        type: 'histogram',
                        xbins: {size: 1},
                        opacity: 0.5,
                        name: 'Bib-ACMé'
                        };
                        var x2 = [<xsl:value-of select="string-join($num-labels-per-work-corp,',')"/>];
                        var trace2 = {
                        x: x2,
                        type: 'histogram',
                        xbins: {size: 1},
                        opacity: 0.5,
                        name: 'Conha19'
                        };
                        var data = [trace1, trace2];
                        var layout = {
                            xaxis: {title: "number of labels"}, 
                            yaxis: {title: "number of works"},
                            barmode: "overlay",
                            legend: {
                                x: 1,
                                xanchor: 'right',
                                y: 1,
                                font: {size: 16}
                            },
                            font: {size: 14},
                            annotations: [
                            <xsl:for-each select="0 to 6">{
                                <xsl:variable name="num-works-per-label-num-bib" select="count(index-of($num-labels-per-work-bib,string(.)))"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$num-works-per-label-num-bib"/>,
                                text: "<xsl:value-of select="round($num-works-per-label-num-bib div ($num-works-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "center",
                                yanchor: "top",
                                font: {size: 12}
                                },
                            </xsl:for-each>
                            <xsl:for-each select="0 to 6">{
                                <xsl:variable name="num-works-per-label-num-corp" select="count(index-of($num-labels-per-work-corp,string(.)))"/>
                                x: <xsl:value-of select="."/>,
                                y: <xsl:value-of select="$num-works-per-label-num-corp"/>,
                                text: "<xsl:value-of select="round($num-works-per-label-num-corp div ($num-works-corp div 100))"/>%",
                                showarrow: false,
                                xanchor: "center",
                                yanchor: "top",
                                font: {size: 12}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>
                        ]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-thematic-primary">
        <!-- creates to donut charts comparing the proportions of primary thematic subgenres
        of the works in Bib-ACMé and Conha19 -->
        <xsl:variable name="primary-thematic-labels-bib" select="cligs:get-primary-labels($bibacme-works,'theme')"/>
        <xsl:variable name="primary-thematic-labels-corp" select="cligs:get-primary-labels($corpus-works,'theme')"/>
        <xsl:variable name="x-labels-bib" select="distinct-values($primary-thematic-labels-bib)"/>
        <xsl:variable name="x-labels-corp" select="distinct-values($primary-thematic-labels-corp)"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-theme-primary.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 900px; height: 950px;"></div>
                    <script>
                        var labels_bib = ["<xsl:value-of select="string-join($x-labels-bib,'&quot;,&quot;')"/>"]
                        var labels_corp = ["<xsl:value-of select="string-join($x-labels-corp,'&quot;,&quot;')"/>"]
                        var values_bib = [<xsl:for-each select="$x-labels-bib">
                            <xsl:value-of select="count(index-of($primary-thematic-labels-bib,.))"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var values_corp = [<xsl:for-each select="$x-labels-corp">
                            <xsl:value-of select="count(index-of($primary-thematic-labels-corp,.))"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        var data = [{
                        values: values_bib,
                        labels: labels_bib,
                        type: "pie",
                        direction: "clockwise",
                        name: "Bib-ACMé",
                        domain: {row: 0, column: 0},
                        hole: 0.4
                        },{
                        values: values_corp,
                        labels: labels_corp,
                        type: "pie",
                        direction: "clockwise",
                        name: "Conha19",
                        domain: {row: 0, column: 1},
                        hole: 0.4
                        }];
                        
                        var layout = {
                        grid: {rows: 1, columns: 2},
                        annotations: [
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Bib-ACMé',
                        x: 0.16,
                        y: 0.5
                        },
                        {
                        font: {
                        size: 18
                        },
                        showarrow: false,
                        text: 'Conha19',
                        x: 0.84,
                        y: 0.5
                        }
                        ],
                        legend: {font: {size: 16}}
                        };
                        
                        Plotly.newPlot("myDiv", data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-current">
        <!-- creates an overview of subgenres related to literary currents in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="current-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'current')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($current-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-current.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$current-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$current-labels-set">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                            barmode: 'group', 
                            font: {size: 14},
                            title: 'Subgenre labels related to literary currents in Bib-ACMé and Conha19',
                            xaxis: {title: 'subgenres', automargin: true},
                            yaxis: {title: 'number of works'},
                            legend: {
                            x: 1,
                            xanchor: 'right',
                            y: 1,
                            font: {size: 16}
                            },
                            annotations: [
                            <xsl:for-each select="$current-labels-set">{
                                <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.) = current()])"/>
                                <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.) = current()])"/>
                                x: <xsl:value-of select="position() - 1 + 0.05"/>,
                                y: <xsl:value-of select="$num-corp"/>,
                                text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                                showarrow: false,
                                xanchor: "left",
                                yanchor: "bottom",
                                font: {size: 14}
                                }<xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-current-bib-sources">
        <!-- creates an overview of the subgenres related to literary currents in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="current-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'current')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($current-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-current-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$current-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.current.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit signal',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$current-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.current.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit signal',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$current-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.current.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'literary historical',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        font: {size: 14},
                        barmode: 'stack',
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        title: 'Sources of subgenre labels related to literary currents in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-current-years">
        <!-- creates box plots showing when the works that were labeled with a certain literary current
        were first published -->
        
        <xsl:variable name="currents" select="('novela clasicista', 'novela romántica', 'novela realista', 'novela naturalista', 'novela verista', 'novela modernista')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-current-years.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 700px; height: 600px;"></div>
                    <script>
                        <xsl:for-each select="$currents">
                            var trace<xsl:value-of select="position()"/> = {
                            y: [<xsl:for-each select="$bibacme-works[.//term[starts-with(@type,'subgenre.summary.current')]/normalize-space(.)=current()]">
                                <xsl:value-of select="cligs:get-first-edition-year(.)"/>:
                                <xsl:value-of select="./title"/>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>],
                            type: 'box',
                            name: '<xsl:value-of select="."/>'
                            };
                        </xsl:for-each>
                        
                        var data = [<xsl:for-each select="1 to count($currents)">
                            <xsl:text>trace</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>];
                        
                        var layout = {
                            xaxis: {title: "literary currents"},
                            yaxis: {title: "works' publication years"}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-representation">
        <!-- creates an overview of subgenres related to the mode of representation in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="representation-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.representation')"/>
        <xsl:variable name="representation-more-than-5" select="cligs:get-labels-least($bibacme-works,$representation-labels-set,'mode.representation',5)"/>
        
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($representation-more-than-5,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-representation.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$representation-more-than-5">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$representation-more-than-5">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        font: {size: 14},
                        title: 'Subgenre labels related to the mode of representation in Bib-ACMé and Conha19',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'},
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        annotations: [
                        <xsl:for-each select="$representation-more-than-5">{
                            <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.) = current()])"/>
                            <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.) = current()])"/>
                            x: <xsl:value-of select="position() - 1"/>,
                            y: <xsl:value-of select="$num-corp"/>,
                            text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 12}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-representation-bib-sources">
        <!-- creates an overview of the subgenres related to the mode of representation in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="representation-labels-set" select="distinct-values($bibacme-works//term[contains(@type,'mode.representation')]/normalize-space(normalize-space(.)))"/>
        <xsl:variable name="representation-more-than-5" select="cligs:get-labels-least($bibacme-works,$representation-labels-set,'mode.representation',5)"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($representation-more-than-5,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-representation-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$representation-more-than-5">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.representation.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit signals',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$representation-more-than-5">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.representation.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit signals',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$representation-more-than-5">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.representation.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'literary historical',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack',
                        font: {size: 14},
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        title: 'Sources of subgenre labels related to the mode of representation (in Bib-ACMé)',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="label-combinations-mode-representation">
        <!-- creates a csv file listing combinations of subgenre labels related to the 
        mode of representation, in the bibliography and the corpus, and how frequent they are  -->
        <xsl:variable name="works-with-combinations-bib" select="$bibacme-works[count(distinct-values(.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))) >= 2]"/>
        <xsl:variable name="works-with-combinations-corp" select="$corpus-works[count(distinct-values(.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))) >= 2]"/>
        
        <xsl:variable name="combinations-bib">
            <list xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each select="$works-with-combinations-bib">
                    <xsl:variable name="distinct-labels">
                        <xsl:for-each select="distinct-values(.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))">
                            <xsl:sort select="."/>
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()">-</xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <item xmlns="https://cligs.hypotheses.org/ns/cligs"><xsl:value-of select="$distinct-labels"/></item>
                </xsl:for-each>
            </list>
        </xsl:variable>
        <xsl:variable name="combinations-corp">
            <list xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each select="$works-with-combinations-corp">
                    <xsl:variable name="distinct-labels">
                        <xsl:for-each select="distinct-values(.//term[starts-with(@type,'subgenre.summary.mode.representation')]/normalize-space(.))">
                            <xsl:sort select="."/>
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()">-</xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <item xmlns="https://cligs.hypotheses.org/ns/cligs"><xsl:value-of select="$distinct-labels"/></item>
                </xsl:for-each>
            </list>
        </xsl:variable>
        
        <xsl:result-document href="{concat($output-dir, 'subgenres-label-combinations-mode-representation.csv')}" method="text" encoding="UTF-8">
            <xsl:text>label_combination,amount_bib,amount_corp</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:for-each-group select="$combinations-bib" group-by=".//cligs:item">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:text>"</xsl:text><xsl:value-of select="current-grouping-key()"/><xsl:text>",</xsl:text>
                <xsl:variable name="split-key" select="tokenize(current-grouping-key(),'-')"/>
                <xsl:value-of select="count($combinations-bib//cligs:item[every $i in $split-key satisfies contains(.,$i)])"/><xsl:text>,</xsl:text>
                <xsl:value-of select="count($combinations-corp//cligs:item[every $i in $split-key satisfies contains(.,$i)])"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-reality">
        <!-- creates an overview of subgenres related to the mode of reality in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="reality-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.reality')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($reality-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-reality.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 600px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$reality-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$reality-labels-set">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group',
                        font: {size: 14},
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        title: 'Subgenre labels related to the mode of reality in Bib-ACMé and Conha19',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'},
                        annotations: [
                        <xsl:for-each select="$reality-labels-set">{
                            <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.) = current()])"/>
                            <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.reality')]/normalize-space(.) = current()])"/>
                            x: <xsl:value-of select="position() - 1"/>,
                            y: <xsl:value-of select="$num-corp"/>,
                            text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 12}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-reality-bib-sources">
        <!-- creates an overview of the subgenres related to the mode of reality in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="reality-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.reality')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($reality-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-reality-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 600px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$reality-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.reality.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit signals',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$reality-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.reality.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit signals',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$reality-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.reality.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'literary historical',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack',
                        font: {size: 14},
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        title: 'Sources of subgenre labels related to mode of reality in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-identity">
        <!-- creates an overview of subgenres related to the identity in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="identity-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'identity')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($identity-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-identity.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$identity-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$identity-labels-set">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group', 
                        title: 'Subgenre labels related to the identity in Bib-ACMé and Conha19',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'},
                        annotations: [
                        <xsl:for-each select="$identity-labels-set">{
                            <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.) = current()])"/>
                            <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.identity')]/normalize-space(.) = current()])"/>
                            x: <xsl:value-of select="position() - 1"/>,
                            y: <xsl:value-of select="$num-corp"/>,
                            text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 16}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-identity-bib-sources">
        <!-- creates an overview of the subgenres related to the identity in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="identity-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'identity')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($identity-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-identity-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$identity-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.identity.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$identity-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.identity.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$identity-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.identity.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'lit. hist.',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack', 
                        title: 'Sources of subgenre labels related to the identity in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-medium">
        <!-- creates an overview of subgenres related to the medium in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="medium-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.medium')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($medium-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-medium.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$medium-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$medium-labels-set">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group', 
                        title: 'Subgenre labels related to the medium in Bib-ACMé and Conha19',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'},
                        annotations: [
                        <xsl:for-each select="$medium-labels-set">{
                            <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.) = current()])"/>
                            <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.medium')]/normalize-space(.) = current()])"/>
                            x: <xsl:value-of select="position() - 1"/>,
                            y: <xsl:value-of select="$num-corp"/>,
                            text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 16}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-medium-bib-sources">
        <!-- creates an overview of the subgenres related to the medium in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="medium-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.medium')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($medium-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-medium-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$medium-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.medium.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$medium-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.medium.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$medium-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.medium.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'lit. hist.',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack', 
                        title: 'Sources of subgenre labels related to the medium in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-attitude">
        <!-- creates an overview of subgenres related to the attitude in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="attitude-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.attitude')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($attitude-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-attitude.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$attitude-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$attitude-labels-set">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group', 
                        title: 'Subgenre labels related to the attitude in Bib-ACMé and Conha19',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'},
                        annotations: [
                        <xsl:for-each select="$attitude-labels-set">{
                            <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.) = current()])"/>
                            <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude')]/normalize-space(.) = current()])"/>
                            x: <xsl:value-of select="position() - 1"/>,
                            y: <xsl:value-of select="$num-corp"/>,
                            text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 16}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-attitude-bib-sources">
        <!-- creates an overview of the subgenres related to the attitude in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="attitude-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.attitude')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($attitude-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-attitude-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$attitude-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$attitude-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$attitude-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.attitude.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'lit. hist.',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack', 
                        title: 'Sources of subgenre labels related to the attitude in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-intention">
        <!-- creates an overview of subgenres related to the intention in the bibliography compared to Conha19,
        a grouped bar chart, how many works have them? -->
        
        <xsl:variable name="intention-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.intention')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($intention-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-intention.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$intention-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Bib-ACMé',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$intention-labels-set">
                            <xsl:value-of select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'Conha19',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        barmode: 'group', 
                        title: 'Subgenre labels related to the intention in Bib-ACMé and Conha19',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'},
                        annotations: [
                        <xsl:for-each select="$intention-labels-set">{
                            <xsl:variable name="num-bib" select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.) = current()])"/>
                            <xsl:variable name="num-corp" select="count($corpus-works[.//term[starts-with(@type,'subgenre.summary.mode.intention')]/normalize-space(.) = current()])"/>
                            x: <xsl:value-of select="position() - 1"/>,
                            y: <xsl:value-of select="$num-corp"/>,
                            text: "<xsl:value-of select="round($num-corp div ($num-bib div 100))"/>%",
                            showarrow: false,
                            xanchor: "left",
                            yanchor: "bottom",
                            font: {size: 16}
                            }<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>]
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-mode-intention-bib-sources">
        <!-- creates an overview of the subgenres related to the intention in the bibliography,
        a stacked bar chart (including different source types: explicit, implicit, litHist), how many works have them? -->
        
        <xsl:variable name="intention-labels-set" select="cligs:get-sorted-labels-set($bibacme-works, 'mode.intention')"/>
        
        <xsl:variable name="labels-x" select="concat('&quot;',string-join($intention-labels-set,'&quot;,&quot;'),'&quot;')"/>
        
        <xsl:result-document href="{concat($output-dir,'subgenres-mode-intention-bib-sources.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        
                        var trace1 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$intention-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.intention.explicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'explicit',
                        type: 'bar'
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$intention-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.intention.implicit')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'implicit',
                        type: 'bar'
                        };
                        
                        var trace3 = {
                        x: [<xsl:value-of select="$labels-x"/>],
                        y: [<xsl:for-each select="$intention-labels-set">
                            <xsl:value-of select="count($bibacme-works[.//term[starts-with(@type,'subgenre.summary.mode.intention.litHist')]/normalize-space(.) = current()])"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        name: 'lit. hist.',
                        type: 'bar'
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        var layout = {
                        barmode: 'stack', 
                        title: 'Sources of subgenre labels related to the intention in Bib-ACMé',
                        xaxis: {title: 'subgenres', automargin: true},
                        yaxis: {title: 'number of works'}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-subgenres-num-works-label">
        <!-- creates a histogram showing how many works the labels are associated with,
        for Bib-ACMé and Conha19 -->
        <xsl:variable name="num-works-per-label-bib" select="cligs:get-works-per-label($bibacme-works)"/>
        <xsl:variable name="num-works-per-label-corp" select="cligs:get-works-per-label($corpus-works)"/>
        <xsl:result-document href="{concat($output-dir,'subgenres-works-per-label.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var x1 = [<xsl:value-of select="string-join($num-works-per-label-bib,',')"/>];
                        var trace1 = {
                        x: x1,
                        type: 'histogram',
                        xbins: {size: 10},
                        opacity: 0.5,
                        name: 'Bib-ACMé'
                        };
                        var x2 = [<xsl:value-of select="string-join($num-works-per-label-corp,',')"/>];
                        var trace2 = {
                        x: x2,
                        type: 'histogram',
                        xbins: {size: 10},
                        opacity: 0.5,
                        name: 'Conha19'
                        };
                        var data = [trace1, trace2];
                        var layout = {
                        xaxis: {title: "number of works"}, 
                        yaxis: {title: "number of labels"},
                        barmode: "overlay",
                        legend: {
                        x: 1,
                        xanchor: 'right',
                        y: 1,
                        font: {size: 16}
                        },
                        font: {size: 14},
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="list-subgenres-num-works-label">
        <!-- get the number of works for each subgenre label (for the bibliography and corpus) -->
        <xsl:for-each select="('bib','corp')">
            <xsl:variable name="works" select="if (.='corp') then $corpus-works else $bibacme-works"/>
            <xsl:variable name="label-set" select="distinct-values($works//term[starts-with(@type,'subgenre.summary')]/normalize-space(.))"/>
            
            <!-- write this also to an external file: -->
            <xsl:result-document href="{concat($output-dir,'works-per-label-',.,'.csv')}" method="text" encoding="UTF-8">
                <xsl:text>label,num_works</xsl:text>
                <xsl:text>
</xsl:text>
                <xsl:for-each select="$label-set">
                    <xsl:sort select="count($works[.//term[starts-with(@type,'subgenre.summary')]/normalize-space(.) = current()])" order="descending"/>
                    <xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="count($works[.//term[starts-with(@type,'subgenre.summary')]/normalize-space(.) = current()])"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>
</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ########### HELPER TEMPLATES ########### -->
    
    <xsl:template name="get-decade-range">
        <!-- for a specified range of decades (from-to):
        get all the decade steps inbetween -->
        <xsl:param name="curr-decade"/>
        <xsl:param name="start-decade"/>
        <xsl:param name="end-decade"/>
        
        <xsl:value-of select="$curr-decade"/>
        <xsl:if test="$curr-decade &lt; $end-decade">,</xsl:if>
        
        <xsl:variable name="next-decade" select="$curr-decade + 10"/>
        
        <xsl:if test="($next-decade >= $start-decade) and ($next-decade &lt;= $end-decade)">
            <xsl:call-template name="get-decade-range">
                <xsl:with-param name="curr-decade" select="$next-decade"/>
                <xsl:with-param name="start-decade" select="$start-decade"/>
                <xsl:with-param name="end-decade" select="$end-decade"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    
    <!-- ########### FUNCTIONS ############ -->
    
    <xsl:function name="cligs:get-primary-labels">
        <!-- for a set of works: get just the primary labels of a certain type of subgenre label -->
        <xsl:param name="works"/>
        <xsl:param name="label-type"/><!-- e.g. "theme" -->
        <xsl:for-each select="$works">
            <xsl:variable name="labels" select=".//term[starts-with(@type,concat('subgenre.summary.',$label-type))]"/>
            <xsl:variable name="num-labels" select="count($labels)"/>
            <xsl:choose>
                <xsl:when test="$num-labels=1">
                    <xsl:value-of select="normalize-space($labels)"/>
                </xsl:when>
                <xsl:when test="$num-labels>1">
                    <xsl:value-of select="$labels[@cligs:importance='2']/normalize-space(.)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-labels">
        <!-- get the overall amount of subgenre labels associated with a set of works -->
        <xsl:param name="works"/>
        <xsl:for-each select="('mode.intention','mode.attitude','mode.reality','mode.medium','mode.representation','theme','identity','current')">
            <xsl:variable name="label-type" select="."/>
            <xsl:copy-of select="$works//term[starts-with(@type, concat('subgenre.summary.',$label-type))][not(normalize-space(.) = preceding-sibling::term[starts-with(@type, concat('subgenre.summary.',$label-type))]/normalize-space(.))]/normalize-space(.)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-labels-per-work">
        <!-- for a set of works, get the number of different subgenre labels of a certain type -->
        <xsl:param name="works"/>
        <xsl:param name="label-type"/><!-- e.g. 'theme' -->
        <xsl:for-each select="$works">
            <xsl:value-of select="count(distinct-values(.//term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.)))"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-sorted-labels-set">
        <!-- for a certain subgenre type, get the set of labels, sorted by how many works have the labels -->
        <xsl:param name="works"/>
        <xsl:param name="label-type"/><!-- e.g. 'current' -->
        
        <xsl:variable name="labels-set" select="distinct-values($works//term[contains(@type,$label-type)]/normalize-space(normalize-space(.)))"/>
        <xsl:for-each select="$labels-set">
            <xsl:sort select="count($works[.//term[contains(@type,$label-type)]/normalize-space(.) = current()])" order="descending"/>
            <xsl:value-of select="."/>
        </xsl:for-each>
        
    </xsl:function>
    
    <xsl:function name="cligs:get-labels-least">
        <!-- of a set of labels, return the ones that occur at least for x works -->
        <xsl:param name="works"/><!-- set of works -->
        <xsl:param name="label-set"/><!-- set of labels -->
        <xsl:param name="label-type"/><!-- e.g. "theme" for thematic labels -->
        <xsl:param name="limit"/><!-- minimum number of works, e.g. 10 -->
        <xsl:for-each select="$label-set">
            <xsl:sort select="count($works[.//term[contains(@type,$label-type)]/normalize-space(.)=current()])" order="descending"/>
            <xsl:variable name="works-with-label" select="$works[.//term[contains(@type,$label-type)]/normalize-space(.)=current()]"/>
            <xsl:if test="count($works-with-label) >= $limit">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-author-dates-known">
        <!-- count how many authors there are with known or unknown life dates -->
        <xsl:param name="mode"/><!-- both, birth, death, none -->
        <xsl:param name="set"/><!-- bib vs. corp -->
        <xsl:choose>
            <xsl:when test="$mode = 'both'">
                <xsl:choose>
                    <xsl:when test="$set = 'bib'">
                        <xsl:value-of select="count($bibacme-authors[birth/date/@when and death/date/@when])"/>
                    </xsl:when>
                    <xsl:when test="$set = 'corp'">
                        <xsl:value-of select="count($corpus-authors[birth/date/@when and death/date/@when])"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'birth'">
                <xsl:choose>
                    <xsl:when test="$set = 'bib'">
                        <xsl:value-of select="count($bibacme-authors[birth/date/@when][not(death/date/@when)])"/>
                    </xsl:when>
                    <xsl:when test="$set = 'corp'">
                        <xsl:value-of select="count($corpus-authors[birth/date/@when][not(death/date/@when)])"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'death'">
                <xsl:choose>
                    <xsl:when test="$set = 'bib'">
                        <xsl:value-of select="count($bibacme-authors[death/date/@when][not(birth/date/@when)])"/>
                    </xsl:when>
                    <xsl:when test="$set = 'corp'">
                        <xsl:value-of select="count($corpus-authors[death/date/@when][not(birth/date/@when)])"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode = 'none'">
                <xsl:choose>
                    <xsl:when test="$set = 'bib'">
                        <xsl:value-of select="count($bibacme-authors[birth/date[.='desconocido'] and death/date[.='desconocido']])"/>
                    </xsl:when>
                    <xsl:when test="$set = 'corp'">
                        <xsl:value-of select="count($corpus-authors[birth/date[.='desconocido'] and death/date[.='desconocido']])"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="cligs:get-author-ages">
        <!-- get the ages of the author when the works were first published,
        optionally only for a specific decade -->
        <xsl:param name="works"/>
        <xsl:param name="decade"/><!-- default: none -->
        <xsl:for-each select="$works">
            <xsl:variable name="first-published-date" select="cligs:get-first-edition-year(.)"/>
            <xsl:choose>
                <!-- if the work was not published in the decade, do nothing -->
                <xsl:when test="string($decade) != 'none' and not($decade &lt;= $first-published-date and $first-published-date &lt; ($decade + 10))"/>
                <!-- if no decade is indicated or the work is in the decade, get the author's age -->
                <xsl:otherwise>
                    <!-- how old was the author when this work was first published? -->
                    <!-- in case of several authors: take the first one -->
                    <xsl:variable name="author-id" select="./author[1]/@key"/>
                    <xsl:variable name="author-birth-year" select="$bibacme-authors[@xml:id=$author-id]/birth/date[@when]/xs:integer(substring(@when,1,4))"/>
                    <xsl:variable name="author-death-year" select="$bibacme-authors[@xml:id=$author-id]/death/date[@when]/xs:integer(substring(@when,1,4))"/>
                    <!-- do only consider authors with a known birth and death year
                do not consider works published posthumously  -->
                    <xsl:if test="exists($author-birth-year) and exists($author-death-year)">
                        <xsl:if test="$first-published-date &lt;= $author-death-year">
                            <xsl:variable name="author-age" select="$first-published-date - $author-birth-year"/>
                            <xsl:value-of select="$author-age"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-author-ages-death">
        <!-- for all the authors whose life dates are known: get their age at death
        (roughly, in years) -->
        <xsl:param name="authors"/>
        <xsl:for-each select="$authors">
            <xsl:if test="birth/date/@when and death/date/@when">
                <xsl:variable name="birth-year" select="birth/date/@when/xs:integer(substring(.,1,4))"/>
                <xsl:variable name="death-year" select="death/date/@when/xs:integer(substring(.,1,4))"/>
                <xsl:value-of select="$death-year - $birth-year"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-box-group-labels">
        <xsl:param name="y"/>
        <xsl:param name="label"/>
        <!-- return a set of x labels for a set of y values corresponding to a certain label (e.g. decade) -->
        "<xsl:value-of select="string-join(for $i in 1 to count($y) return $label,'&quot;,&quot;')"/>"
    </xsl:function>
    
    <xsl:function name="cligs:get-nationalities-bib">
        <xsl:for-each select="$nationalities">
            <xsl:value-of select="count($bibacme-authors[nationality=current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-nationalities-corp">
        <xsl:for-each select="$nationalities">
            <xsl:value-of select="count($corpus-authors[nationality=current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:map-nationalities">
        <!-- return English labels for nationalities -->
        <xsl:for-each select="$nationalities">
            <xsl:choose>
                <xsl:when test=".='argentina/o'">Argentine</xsl:when>
                <xsl:when test=".='boliviana/o'">Bolivian</xsl:when>
                <xsl:when test=".='chilena/o'">Chilean</xsl:when>
                <xsl:when test=".='cubana/o'">Cuban</xsl:when>
                <xsl:when test=".='dominicana/o'">Dominican</xsl:when>
                <xsl:when test=".='español/a'">Spanish</xsl:when>
                <xsl:when test=".='francés/a'">French</xsl:when>
                <xsl:when test=".='italiana/o'">Italian</xsl:when>
                <xsl:when test=".='mexicana/o'">Mexican</xsl:when>
                <xsl:when test=".='peruana/o'">Peruvian</xsl:when>
                <xsl:when test=".='puertorriqueña/o'">Puerto Rican</xsl:when>
                <xsl:when test=".='uruguaya/o'">Uruguayan</xsl:when>
                <xsl:when test=".='desconocido'">unknown</xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:map-country-name">
        <!-- get English name for country shortcut -->
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="$id = 'AR'">Argentina</xsl:when>
            <xsl:when test="$id = 'BO'">Bolivia</xsl:when>
            <xsl:when test="$id = 'CH'">Chile</xsl:when>
            <xsl:when test="$id = 'CO'">Colombia</xsl:when>
            <xsl:when test="$id = 'CU'">Cuba</xsl:when>
            <xsl:when test="$id = 'DE'">Germany</xsl:when>
            <xsl:when test="$id = 'ES'">Spain</xsl:when>
            <xsl:when test="$id = 'FR'">France</xsl:when>
            <xsl:when test="$id = 'GU'">Guatemala</xsl:when>
            <xsl:when test="$id = 'IT'">Italy</xsl:when>
            <xsl:when test="$id = 'MX'">Mexico</xsl:when>
            <xsl:when test="$id = 'PE'">Peru</xsl:when>
            <xsl:when test="$id = 'PR'">Puerto Rico</xsl:when>
            <xsl:when test="$id = 'UR'">Uruguay</xsl:when>
            <xsl:when test="$id = 'US'">USA</xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="cligs:get-birth-places-bib">
        <xsl:for-each select="$birth-places">
            <xsl:value-of select="count($bibacme-authors[birth/placeName[last()]=current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-birth-places-corp">
        <xsl:for-each select="$birth-places">
            <xsl:value-of select="count($corpus-authors[birth/placeName[last()]=current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:map-birth-places">
        <!-- return English labels for birth country names -->
        <xsl:for-each select="$birth-places">
            <xsl:choose>
                <xsl:when test=".='Argentina'">Argentina</xsl:when>
                <xsl:when test=".='Francia'">France</xsl:when>
                <xsl:when test=".='España'">Spain</xsl:when>
                <xsl:when test=".='México'">Mexico</xsl:when>
                <xsl:when test=".='Cuba'">Cuba</xsl:when>
                <xsl:when test=".='Uruguay'">Uruguay</xsl:when>
                <xsl:when test=".='Chile'">Chile</xsl:when>
                <xsl:when test=".='Estados Unidos'">USA</xsl:when>
                <xsl:when test=".='República Dominicana'">Dominican Republic</xsl:when>
                <xsl:when test=".='Perú'">Peru</xsl:when>
                <xsl:when test=".='Bélgica'">Belgium</xsl:when>
                <xsl:when test=".='Italia'">Italy</xsl:when>
                <xsl:when test=".='Puerto Rico'">Puerto Rico</xsl:when>
                <xsl:when test=".='desconocido'">unknown</xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-death-places-bib">
        <xsl:for-each select="$death-places">
            <xsl:value-of select="count($bibacme-authors[death/placeName[last()]=current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-death-places-corp">
        <xsl:for-each select="$death-places">
            <xsl:value-of select="count($corpus-authors[death/placeName[last()]=current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:map-death-places">
        <!-- return English labels for death country names -->
        <xsl:for-each select="$death-places">
            <xsl:choose>
                <xsl:when test=".='Argentina'">Argentina</xsl:when>
                <xsl:when test=".='México'">Mexico</xsl:when>
                <xsl:when test=".='Estados Unidos'">USA</xsl:when>
                <xsl:when test=".='Cuba'">Cuba</xsl:when>
                <xsl:when test=".='España'">Spain</xsl:when>
                <xsl:when test=".='Chile'">Chile</xsl:when>
                <xsl:when test=".='Brasil'">Brazil</xsl:when>
                <xsl:when test=".='Francia'">France</xsl:when>
                <xsl:when test=".='Paraguay'">Paraguay</xsl:when>
                <xsl:when test=".='República Dominicana'">Dominican Republic</xsl:when>
                <xsl:when test=".='Italia'">Italy</xsl:when>
                <xsl:when test=".='Bolivia'">Bolivia</xsl:when>
                <xsl:when test=".='Uruguay'">Uruguay</xsl:when>
                <xsl:when test=".='desconocido'">unknown</xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-authors-active">
        <!-- for a range of years: get the number of authors that were active in each year.
        Active means: published a novel in that year, or before and after it.
        Only the first publication date of each novel is considered. -->
        <xsl:param name="years"/>
        <xsl:param name="authors"/>
        <!-- get years of activity for all authors -->
        <xsl:variable name="activity-years">
            <list xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each select="$authors">
                    <xsl:variable name="author-id" select="@xml:id"/>
                    <xsl:variable name="author-works" select="$bibacme-works[author/@key = $author-id]"/>
                    <xsl:variable name="first-edition-years" select="cligs:get-first-edition-years($author-works)"/>
                    <author xmlns="https://cligs.hypotheses.org/ns/cligs" id="{$author-id}">
                        <from xmlns="https://cligs.hypotheses.org/ns/cligs"><xsl:value-of select="min($first-edition-years)"/></from>
                        <to xmlns="https://cligs.hypotheses.org/ns/cligs"><xsl:value-of select="max($first-edition-years)"/></to>
                    </author>
                </xsl:for-each>
            </list>
        </xsl:variable>
        <xsl:for-each select="$years">
            <!-- check how many authors active -->
            <xsl:value-of select="count($activity-years//cligs:author[cligs:from &lt;= current() and current() &lt;= cligs:to])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-authors-active">
        <!-- 3 param-version of above function.
            For a certain year: 
            depending on the mode (before, after),
            get the number of authors that were active in before or in and after that year.
        Active means: published a novel in that year, or before and after it.
        Only the first publication date of each novel is considered. -->
        <xsl:param name="year"/>
        <xsl:param name="mode"/>
        <xsl:param name="authors"/>
        <!-- get years of activity for all authors -->
        <xsl:variable name="activity-years">
            <list xmlns="https://cligs.hypotheses.org/ns/cligs">
                <xsl:for-each select="$authors">
                    <xsl:variable name="author-id" select="@xml:id"/>
                    <xsl:variable name="author-works" select="$bibacme-works[author/@key = $author-id]"/>
                    <xsl:variable name="first-edition-years" select="cligs:get-first-edition-years($author-works)"/>
                    <author xmlns="https://cligs.hypotheses.org/ns/cligs" id="{$author-id}">
                        <from xmlns="https://cligs.hypotheses.org/ns/cligs"><xsl:value-of select="min($first-edition-years)"/></from>
                        <to xmlns="https://cligs.hypotheses.org/ns/cligs"><xsl:value-of select="max($first-edition-years)"/></to>
                    </author>
                </xsl:for-each>
            </list>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$mode='before'">
                <!-- check how many authors active before the year -->
                <xsl:value-of select="count($activity-years//cligs:author[cligs:from &lt; $year])"/>    
            </xsl:when>
            <xsl:when test="$mode='after'">
                <!-- check how many authors active in and after the year -->
                <xsl:value-of select="count($activity-years//cligs:author[cligs:from = $year or cligs:to &gt;= $year])"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="cligs:get-edition-country">
        <!-- get the country of an edition -->
        <xsl:param name="edition"/>
        <!-- if there are several, take the first one -->
        <xsl:variable name="country-short" select="$edition//pubPlace/@corresp/substring-after(.,'countries.xml#')"/>
        <!-- get the English name for the country  -->
        <xsl:variable name="country-name" select="cligs:map-country-name($country-short)"/>
        <xsl:value-of select="$country-name"/>
    </xsl:function>
    
    <xsl:function name="cligs:get-first-edition">
        <!-- get the first edition of a work -->
        <xsl:param name="work"/>
        <xsl:variable name="work-id" select="$work/@xml:id"/>
        <xsl:variable name="first-edition-year" select="cligs:get-first-edition-year($work)"/>
        <!-- if there are several editions in the same year, take the first one -->
        <xsl:variable name="first-edition" select="$bibacme-editions[substring-after(@corresp,'#') = $work-id][.//date[@when or @to]/xs:integer(substring(@when|@to,1,4)) = $first-edition-year][1]"/>
        <xsl:copy-of select="$first-edition"/>
    </xsl:function>
    
    <xsl:function name="cligs:get-first-edition-year">
        <!-- get the year of the first edition of a work -->
        <xsl:param name="work"/>
        <xsl:variable name="work-id" select="$work/@xml:id"/>
        <xsl:variable name="edition-year" select="$bibacme-editions[substring-after(@corresp,'#') = $work-id]//date[@when or @to]/xs:integer(substring(@when|@to,1,4))"/>
        <xsl:value-of select="min($edition-year)"/>
    </xsl:function>
    
    <xsl:function name="cligs:get-first-edition-years">
        <!-- get the years of the first edition of a set of works -->
        <xsl:param name="works"/>
        <xsl:for-each select="$works">
            <xsl:variable name="work-id" select="@xml:id"/>
            <xsl:variable name="edition-years" select="$bibacme-editions[substring-after(@corresp,'#') = $work-id]//date[@when or @to]/xs:integer(substring(@when|@to,1,4))"/>
            <xsl:value-of select="min($edition-years)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-first-edition-countries">
        <!-- get the countries of the first edition of a set of works -->
        <xsl:param name="works"/>
        <xsl:for-each select="$works">
            <xsl:variable name="first-edition" select="cligs:get-first-edition(.)"/>
            <xsl:variable name="edition-country" select="cligs:get-edition-country($first-edition)"/>
            <xsl:value-of select="$edition-country"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-authors-alive">
        <!-- return the number of authors alive for each year -->
        <xsl:param name="years"/>
        <xsl:param name="authors"/>
        <xsl:for-each select="$years">
            <xsl:value-of select="count($authors[birth/date/@when/number(substring(.,1,4)) &lt;= current()][death/date/@when/number(substring(.,1,4)) > current()])"/>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-authors-dead">
        <!-- return the number of authors that are already dead for each year -->
        <xsl:param name="years"/>
        <xsl:param name="authors"/>
        <xsl:for-each select="$years">
            <xsl:value-of select="count($authors[death/date/@when/number(substring(.,1,4)) &lt;= current()])"/>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-authors-not-born">
        <!-- return the number of authors that were not yet born for each year -->
        <xsl:param name="years"/>
        <xsl:param name="authors"/>
        <xsl:for-each select="$years">
            <xsl:value-of select="count($authors[birth/date/@when/number(substring(.,1,4)) > current()])"/>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-years">
        <!-- for a specified range of years (from-to):
            get the number a certain year in that range occurs in a data set of years.
            Return as a comma-separated list -->
        <xsl:param name="year-range"/>
        <xsl:param name="years"/>
        <xsl:for-each select="$year-range">
            <xsl:value-of select="count($years[.=current()])"/>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-years">
        <!-- three parameter version of the above function. For a certain year (e.g. 1880):
        get the number of years before or in/after it (depending on the mode)-->
        <xsl:param name="year"/><!-- year to compare with -->
        <xsl:param name="years"/><!-- set of years to count -->
        <xsl:param name="mode"/><!-- before or after -->
        <xsl:choose>
            <xsl:when test="$mode='before'">
                <xsl:value-of select="count($years[. &lt; $year])"/>
            </xsl:when>
            <xsl:when test="$mode='after'">
                <xsl:value-of select="count($years[. >= $year])"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="cligs:get-num-decades">
        <!-- for a specified set of decades:
            get the number of years that fall into that decade.
            Return as a comma-separated list -->
        <xsl:param name="decades"/>
        <xsl:param name="years"/>
        <xsl:for-each select="$decades">
            <xsl:value-of select="count($years[.>=current() and .&lt;=(current() + 9)])"/>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-editions-per-work">
        <!-- get the number of editions for each work in a set of works -->
        <xsl:param name="works"/>
        <xsl:for-each select="$works">
            <xsl:variable name="work-id" select="@xml:id"/>
            <xsl:variable name="editions" select="$bibacme-editions[substring-after(@corresp,'#') = $work-id]"/>
            <xsl:value-of select="count($editions)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-works-per-label">
        <!-- get the number of works for each subgenre label -->
        <xsl:param name="works"/>
        <xsl:variable name="label-set" select="distinct-values($works//term[starts-with(@type,'subgenre.summary')]/normalize-space(.))"/>
        <xsl:for-each select="$label-set">
            <xsl:value-of select="count($works[.//term[starts-with(@type,'subgenre.summary')]/normalize-space(.) = current()])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-works-per-author-bib">
        <!-- get the number of works per author in Bib-ACMé -->
        <xsl:for-each select="$bibacme-authors">
            <xsl:variable name="author-id" select="@xml:id"/>
            <xsl:value-of select="count($bibacme-works[author/@key = $author-id])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-works-per-author-corp">
        <!-- get the number of works per author in Conha19 -->
        <xsl:for-each select="distinct-values($corpus//titleStmt/author/idno[@type='bibacme'])">
            <xsl:variable name="author-id" select="."/>
            <xsl:value-of select="count($corpus[.//titleStmt/author/idno[@type='bibacme'] = $author-id])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-works-by-decade">
        <!-- get the works that were first published in a certain decade -->
        <xsl:param name="decade"/>
        <xsl:param name="works"/><!-- set of works (Bib-ACMé or Conha19) -->
        <!-- return only the works that were first published in that decade -->
        <xsl:for-each select="$works">
            <xsl:variable name="pub-year" select="cligs:get-first-edition-year(.)"/>
            <xsl:if test="$pub-year >= $decade and $pub-year &lt;= ($decade + 9)">
                <xsl:copy-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-works-by-year">
        <!-- get the works that were first published before or in/after a certain year -->
        <xsl:param name="year"/>
        <xsl:param name="mode"/><!-- before or after -->
        <xsl:param name="works"/><!-- set of works (Bib-ACMé or Conha19) -->
        <!-- return only the works that were first published before or in/after that year -->
        <xsl:for-each select="$works">
            <xsl:variable name="pub-year" select="cligs:get-first-edition-year(.)"/>
            <xsl:choose>
                <xsl:when test="$mode = 'before'">
                    <xsl:if test="$pub-year &lt; $year">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$mode = 'after'">
                    <xsl:if test="$pub-year >= $year">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-author-gender-bib">
        <xsl:param name="gender"/>
        <xsl:value-of select="count($bibacme-authors[sex=$gender])"/>
    </xsl:function>
    
    <xsl:function name="cligs:get-author-gender-corp">
        <xsl:param name="gender"/>
        <xsl:variable name="corpus-authors" select="distinct-values($corpus//titleStmt/author/idno[@type='bibacme'])"/>
        <xsl:value-of select="count($bibacme-authors[sex=$gender][@xml:id=$corpus-authors])"/>
    </xsl:function>
    
    <xsl:function name="cligs:get-editions-per-author-bib">
        <!-- get the number of editions per author in Bib-ACMé -->
        <xsl:for-each select="$bibacme-authors">
            <xsl:variable name="author-id" select="@xml:id"/>
            <xsl:value-of select="count($bibacme-editions[.//author/@key = $author-id])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-editions-per-author-corp">
        <!-- get the number of editions per author in Conha19 -->
        <xsl:for-each select="$corpus-authors">
            <xsl:variable name="author-id" select="@xml:id"/>
            <xsl:variable name="corpus-works" select="$bibacme-works[idno[@type='cligs']]/@xml:id"/>
            <xsl:value-of select="count($bibacme-editions[.//author/@key = $author-id][substring-after(@corresp,'#')=$corpus-works])"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="cligs:get-edition-years">
        <!-- return the years of the editions of a set of works -->
        <xsl:param name="works"/>
        <xsl:for-each select="$works">
            <xsl:variable name="work-id" select="@xml:id"/>
            <xsl:variable name="editions" select="$bibacme-editions[substring-after(@corresp,'#') = $work-id]"/>
            <!-- if the edition has a year, return it -->
            <xsl:for-each select="$editions">
                <xsl:if test=".//date[@when|@to]">
                    <!-- if there are several dates, take the last one -->
                    <xsl:value-of select="substring(.//date[last()]/(@when|@to),1,4)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>
    
</xsl:stylesheet>