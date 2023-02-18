<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:cligs="https://cligs.hypotheses.org/ns/cligs"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        @author: Ulrike Henny-Krahmer
        
        This script produces:
        
        (1) Tokenized versions of the novels in TEI with stand-off markup for direct speech annotation. This is 
        done for the subset of TEI files where checked direct speech is available. The first set of stand-off
        annotation is for the direct speech gold standard (DS_gold), the second one for the speech annotation
        based on regular expressions, applied to the same files (DS_reg).
        
        (2) Precision, recall, and F1 scores are calculated for all the novels with checked direct speech
        annotation, comparing it to the regular expression annotation. The results are stored as a CSV file.
        
        (3) A box plot showing the F1 scores for speech recognition in all the novels that were checked for it.
        
        (4) A box plot showing the F1 scores for speech recognition in all the novels that were checked for it, 
        differentiating by type of edition (modern, historical + first, unknown)
        
        (5) A box plot showing the F1 scores for speech recognition in all the novels that were checked for it, 
        differentiating by type of speech sign (single, double)
        
        How to call the script:
        java -jar /home/ulrike/Programme/saxon/saxon9he.jar /home/ulrike/Git/conha19/tei/nh0001.xml /home/ulrike/Git/scripts-nh/corpus/metadata_encoding/evaluation-direct-speech.xsl
   
    -->
    
    <!-- ### some variables to be set ### -->
    
    <!-- the TEI master collection (including gold standard direct speech annotation) -->
    <xsl:variable name="path_TEI_collection">/home/ulrike/Git/conha19/tei</xsl:variable>
    <!-- subcollection of TEI files with regex direct speech annotation -->
    <xsl:variable name="path_TEI_collection_ds">/home/ulrike/Git/conha19/tei_ds/</xsl:variable>
    <!-- directory and files for output -->
    <xsl:variable name="path_TEI_out">/home/ulrike/Git/conha19/tei_tokenized_ds/</xsl:variable>
    <xsl:variable name="out-csv-F1">/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-F1.csv</xsl:variable>
    <xsl:variable name="out-html-F1">/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-F1.html</xsl:variable>
    <xsl:variable name="out-html-F1-edition-type">/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-F1-edition-type.html</xsl:variable>
    <xsl:variable name="out-html-F1-speech-sign">/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-F1-speech-sign.html</xsl:variable>
    
  
    <xsl:template match="/">
        <!-- choose what to do here -->
        
        <!--<xsl:call-template name="stand-off">
            <xsl:with-param name="narr_speech">off</xsl:with-param>
            <!-\- The parameter "narr_speech" determines if "narrative speech" should be ignored ("off") or 
            included ("on") into the direct speech annnotation. -\->
        </xsl:call-template>-->
        
        <!--<xsl:call-template name="csv-f1"/>-->
        
        <xsl:call-template name="box-f1"/>
        
        <!--<xsl:call-template name="box-f1-edition-type"/>-->
        
        <!--<xsl:call-template name="box-f1-speech-sign"/>-->
        
        
    </xsl:template>
    
    
    <!--A box plot showing the F1 scores for speech recognition in all the novels that were checked for it, 
    differentiating by type of edition (modern, historical + first, unknown)-->
    <xsl:template name="box-f1-edition-type">
        <xsl:variable name="scores" select="unparsed-text($out-csv-F1,'UTF-8')"/>
        <xsl:variable name="TEIs" select="collection($path_TEI_out)//TEI"/>
        <xsl:result-document href="{$out-html-F1-edition-type}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 709px; height: 800px;"></div>
                    <script>
                        var trace1 = 
                        {
                        y: [<xsl:variable name="idnos-hist" select="$TEIs[.//term[@type='text.source.edition'][.=('first','historical')]]//idno[@type='cligs']"/>
                        <xsl:analyze-string select="$scores" regex="^(nh\d+),[\d\.]+,[\d\.]+,[\d\.]+,([\d\.]+)$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:if test="regex-group(1)=$idnos-hist">
                                        <xsl:value-of select="regex-group(2)"/>
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'historical'
                        };
                        
                        var trace2 = 
                        {
                        y: [<xsl:variable name="idnos-modern" select="$TEIs[.//term[@type='text.source.edition'][.='modern']]//idno[@type='cligs']"/>
                        <xsl:analyze-string select="$scores" regex="^(nh\d+),[\d\.]+,[\d\.]+,[\d\.]+,([\d\.]+)$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:if test="regex-group(1)=$idnos-modern">
                                        <xsl:value-of select="regex-group(2)"/>
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'modern'
                        };
                        
                        var trace3 = 
                        {
                        y: [<xsl:variable name="idnos-unknown" select="$TEIs[.//term[@type='text.source.edition'][.='unknown']]//idno[@type='cligs']"/>
                        <xsl:analyze-string select="$scores" regex="^(nh\d+),[\d\.]+,[\d\.]+,[\d\.]+,([\d\.]+)$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:if test="regex-group(1)=$idnos-unknown">
                                        <xsl:value-of select="regex-group(2)"/>
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'unknown'
                        };
                        
                        
                        var layout = {
                        title: {
                        text: "F1 scores for direct speech recognition by kind of edition",
                        font: {size: 14}},
                        font: {
                        family: "Libertine, serif",
                        color: "#000000",
                        size: 14
                        },
                        showlegend: false,
                        margin: {l: 100, r: 100},
                        //legend: {font: {size: 14}},
                        yaxis: {
                        range: [0,1],
                        title: { text: 'F1 score', font: {size: 14}},
                        tickfont: {size: 14}
                        },
                        xaxis: {tickfont: {size: 14}}
                        };
                        
                        var data = [trace1,trace2,trace3];
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- A box plot showing the F1 scores for speech recognition in all the novels that were checked for it, 
    differentiating by type of speech sign (single, double) -->
    <xsl:template name="box-f1-speech-sign">
        <xsl:variable name="scores" select="unparsed-text($out-csv-F1,'UTF-8')"/>
        <xsl:variable name="TEIs" select="collection($path_TEI_out)//TEI"/>
        <xsl:result-document href="{$out-html-F1-speech-sign}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 709px; height: 800px;"></div>
                    <script>
                        var trace1 = 
                        {
                        y: [<xsl:variable name="idnos-single" select="$TEIs[.//term[@type='text.speech.sign.type'][.='single']]//idno[@type='cligs']"/>
                        <xsl:analyze-string select="$scores" regex="^(nh\d+),[\d\.]+,[\d\.]+,[\d\.]+,([\d\.]+)$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:if test="regex-group(1)=$idnos-single">
                                        <xsl:value-of select="regex-group(2)"/>
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'single'
                        };
                        
                        var trace2 = 
                        {
                        y: [<xsl:variable name="idnos-double" select="$TEIs[.//term[@type='text.speech.sign.type'][.='double']]//idno[@type='cligs']"/>
                        <xsl:analyze-string select="$scores" regex="^(nh\d+),[\d\.]+,[\d\.]+,[\d\.]+,([\d\.]+)$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:if test="regex-group(1)=$idnos-double">
                                        <xsl:value-of select="regex-group(2)"/>
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:matching-substring>
                            </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'double'
                        };
                        
                        var layout = {
                        title: {
                        text: "F1 scores for direct speech recognition by type of speech sign",
                        font: {size: 14}},
                        font: {
                        family: "Libertine, serif",
                        color: "#000000",
                        size: 14
                        },
                        showlegend: false,
                        margin: {l: 100, r: 100},
                        //legend: {font: {size: 14}},
                        yaxis: {
                        range: [0,1],
                        title: { text: 'F1 score', font: {size: 14}},
                        tickfont: {size: 14}
                        },
                        xaxis: {tickfont: {size: 14}}
                        };
                        
                        var data = [trace1, trace2];
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- A box plot showing the F1 scores for speech recognition in all the novels that were checked for it. -->
    <xsl:template name="box-f1">
        <xsl:variable name="scores" select="unparsed-text($out-csv-F1,'UTF-8')"/>
        <xsl:result-document href="{$out-html-F1}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 709px; height: 800px;"></div>
                    <script>
                        var data = [
                        {
                        y: [
                        <xsl:analyze-string select="$scores" regex="^nh\d+,([\d\.]+),[\d\.]+,[\d\.]+,[\d\.]+$" flags="m">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)"/>
                                    <xsl:text>,</xsl:text>
                                </xsl:matching-substring>
                            </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'precision'
                        },
                        {
                        y: [
                        <xsl:analyze-string select="$scores" regex="^nh\d+,[\d\.]+,([\d\.]+),[\d\.]+,[\d\.]+$" flags="m">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>,</xsl:text>
                            </xsl:matching-substring>
                        </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'recall'
                        },
                        {
                        y: [
                        <xsl:analyze-string select="$scores" regex="^nh\d+,[\d\.]+,[\d\.]+,([\d\.]+),[\d\.]+$" flags="m">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>,</xsl:text>
                            </xsl:matching-substring>
                        </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'accuracy'
                        },
                        {
                        y: [
                        <xsl:analyze-string select="$scores" regex="^nh\d+,[\d\.]+,[\d\.]+,[\d\.]+,([\d\.]+)$" flags="m">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>,</xsl:text>
                            </xsl:matching-substring>
                        </xsl:analyze-string>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'F1'
                        }
                        ];
                        
                        var layout = {
                            title: {
                                text: "Scores for direct speech recognition (gold standard vs. regular expression approach).",
                                font: {size: 14}},
                            font: {
                                family: "Libertine, serif",
                                color: "#000000",
                                size: 14
                            },
                            showlegend: false,
                            margin: {l: 100, r: 100},
                            //legend: {font: {size: 14}},
                            yaxis: {
                                range: [0,1],
                                title: { text: 'score', font: {size: 14}},
                                tickfont: {size: 14}
                            },
                            xaxis: {tickfont: {size: 14}}
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- get the number of true values (positives or negatives) -->
    <xsl:function name="cligs:get-true-values" as="xs:integer">
        <xsl:param name="context"/>
        <xsl:param name="values"/>
        <!--<xsl:variable name="true-values" select="$values[@target = ./preceding::link/@target]"/>
        the previous line also works, but the following is more efficient: -->
        <xsl:variable name="true-values" as="xs:boolean+">
            <xsl:for-each select="$values">
                <xsl:variable name="pos" select="count(./preceding-sibling::link) + 1"/>
                <xsl:variable name="tar" select="@target"/>
                <xsl:if test="$context//linkGrp[@type='DS_gold']/link[position() = $pos][@target=$tar]">
                    <xsl:copy-of select="true()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="count($true-values)"/>
    </xsl:function>
    
    
    <!-- get precision score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-precision" as="xs:float">
        <xsl:param name="positives"/>
        <xsl:param name="num-true-positives"/>
        <!-- precision: correctly identified direct speech tokens, 
                    divided by all tokens that were assumed to be direct speech in the regex approach -->
        <xsl:variable name="precision" select="$num-true-positives div count($positives)"/>
        <xsl:value-of select="$precision"/>
    </xsl:function>
    
    
    <!-- get recall score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-recall" as="xs:float">
        <xsl:param name="all-ds"/>
        <xsl:param name="num-true-positives"/>
        <!-- recall: correctly identified direct speech tokens, 
                    divided by all actual direct speech tokens -->
        <xsl:variable name="recall" select="$num-true-positives div count($all-ds)"/>
        <xsl:value-of select="$recall"/>
    </xsl:function>
    
    
    <!-- get accuracy score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-accuracy" as="xs:float">
        <xsl:param name="num-all"/><!-- number of all items -->
        <xsl:param name="num-true-positives"/>
        <xsl:param name="num-true-negatives"/>
        <xsl:variable name="accuracy" select="($num-true-positives + $num-true-negatives) div $num-all"/>
        <xsl:value-of select="$accuracy"/>
    </xsl:function>
    
    
    <!-- get F1 score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-f1" as="xs:float">
        <xsl:param name="precision"/>
        <xsl:param name="recall"/>
        <xsl:variable name="F1" select="2 * (($precision * $recall) div ($precision + $recall))"/>
        <xsl:value-of select="$F1"/>
    </xsl:function>
    
    
    <!-- Precision, recall, and F1 scores are calculated for all the novels with checked direct speech
        annotation, comparing it to the regular expression annotation. The results are stored as a CSV file -->
    <xsl:template name="csv-f1">
        <xsl:result-document href="{$out-csv-F1}" method="text" encoding="UTF-8">
            <xsl:text>idno,precision,recall,accuracy,F1</xsl:text><xsl:text>
</xsl:text>
            <xsl:for-each select="collection($path_TEI_out)//TEI"> <!-- [.//idno[@type='cligs']='nh0001'] -->
                <xsl:variable name="idno" select=".//idno[@type='cligs']"/>
                <xsl:variable name="filename" select="concat($idno,'.xml')"/>
                
                <xsl:value-of select="$idno"/><xsl:text>,</xsl:text>
                
                <xsl:variable name="positives" select=".//linkGrp[@type='DS_reg']/link[ends-with(@target,'#DS')]"/>
                <xsl:variable name="all-ds" select=".//linkGrp[@type='DS_gold']/link[ends-with(@target,'#DS')]"/>
                <xsl:variable name="num-true-positives" select="cligs:get-true-values(.,$positives)"/>
                <!-- precision: correctly identified direct speech tokens, 
                    divided by all tokens that were assumed to be direct speech in the regex approach -->
                <xsl:variable name="precision" select="cligs:get-precision($positives,$num-true-positives)"/>
                <xsl:copy-of select="$precision"/><xsl:text>,</xsl:text>
                
                <!-- recall: correctly identified direct speech tokens, 
                    divided by all actual direct speech tokens -->
                <xsl:variable name="recall" select="cligs:get-recall($all-ds,$num-true-positives)"/>
                <xsl:copy-of select="$recall"/><xsl:text>,</xsl:text>
                
                <!-- accuracy: (true positives + true negatives) / all cases -->
                <xsl:variable name="num-all" select="count(.//linkGrp[@type='DS_gold']/link)"/>
                <xsl:variable name="negatives" select=".//linkGrp[@type='DS_reg']/link[ends-with(@target,'#NARR')]"/>
                <xsl:variable name="num-true-negatives" select="cligs:get-true-values(.,$negatives)"/>
                <xsl:copy-of select="cligs:get-accuracy($num-all,$num-true-positives,$num-true-negatives)"/><xsl:text>,</xsl:text>
                
                <!-- F1 score:  -->
                <xsl:copy-of select="cligs:get-f1($precision,$recall)"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
    
    
    
    <xsl:template name="stand-off">
        <!-- for each TEI file with annotated direct speech: create a TEI export with tokenized text
        and token identifiers, to which the annotation DS vs. NARR is added for the gold standard
        and for regular expression-based annotations.
        The parameter "narr_speech" determines if "narrative speech" should be ignored ("off") or 
        included ("on") into the direct speech annnotation. -->
        <xsl:param name="narr_speech"/>
        <xsl:for-each select="collection($path_TEI_collection)//TEI[.//said]">
            
            <!--<xsl:if test=".//idno[@type='cligs'][.='nh0079']">-->
                <xsl:variable name="filename" select="tokenize(base-uri(.),'/')[last()]"/>
                
                <xsl:result-document href="{concat($path_TEI_out, $filename)}" method="xml" encoding="UTF-8" indent="yes">
                    <!-- copy processing instruction -->
                    <xsl:copy-of select="preceding-sibling::processing-instruction()[2]"/>
                    <!-- copy TEI header -->
                    <xsl:copy>
                        <xsl:copy-of select="teiHeader"/>
                        <text>
                            <body>
                                <div>
                                    <p>
                                        <!-- tokenize -->
                                        <xsl:for-each select="text/body//(p|l|head[not(parent::div[@type=('part','subpart','chapter','subchapter')])])">
                                            <xsl:variable name="p_pos" select="position()"/>
                                            <!-- get the words of the current paragraph / verse line -->
                                            <xsl:variable name="words" select="cligs:get-words(.)"/>
                                            <xsl:for-each select="$words">
                                                <w xml:id="p{$p_pos}.w{position()}"><xsl:value-of select="."/></w>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                    </p>
                                </div>
                            </body>
                            <back>
                                <div>
                                    <p>
                                        <!-- store gold standard direct speech annotation -->
                                        <linkGrp type="DS_gold">
                                            <xsl:call-template name="ds_standoff">
                                                <xsl:with-param name="context" select="."/>
                                                <xsl:with-param name="narr_speech" select="$narr_speech"/>
                                            </xsl:call-template>
                                        </linkGrp>
                                        <!-- store regex direct speech annotation -->
                                        <linkGrp type="DS_reg">
                                            <xsl:call-template name="ds_standoff">
                                                <xsl:with-param name="context" select="doc(concat($path_TEI_collection_ds, $filename))/TEI"/>
                                                <xsl:with-param name="narr_speech" select="$narr_speech"/>
                                            </xsl:call-template>
                                        </linkGrp>
                                    </p>
                                </div>
                            </back>
                        </text>
                    </xsl:copy>
                </xsl:result-document>
            <!--</xsl:if>-->
            
        </xsl:for-each>
    </xsl:template>
    
    <!-- get the words of the current paragraph / verse line -->
    <xsl:function name="cligs:get-words">
        <xsl:param name="context"/>
        <xsl:for-each select="$context//text()[matches(.,'\S')]">
            <xsl:for-each select="tokenize(replace(.,'(\W)',' $1 '),'\s+')">
                <xsl:if test=". != ''"><xsl:value-of select="."/></xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>
    
    <!-- add stand off annotation of direct speech vs. narrated text -->
    <xsl:template name="ds_standoff">
        <xsl:param name="context"/>
        <xsl:param name="narr_speech"/>
        <xsl:for-each select="$context/text/body//(p|l|head[not(parent::div[@type=('part','subpart','chapter','subchapter')])])">
            <xsl:variable name="p_pos" select="position()"/>
            <xsl:variable name="words">
                <xsl:call-template name="get-words-DS-NARR">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="narr_speech" select="$narr_speech"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="$words//word">
                <link target="#p{$p_pos}.w{position()} #{./@type}"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- get the words of the current paragraph / verse line plus DS vs. NARR information -->
    <xsl:template name="get-words-DS-NARR">
        <xsl:param name="context"/>
        <xsl:param name="narr_speech"/>
        <words>
            <xsl:for-each select="$context//text()[matches(.,'\S')]">
                <xsl:variable name="DS">
                    <xsl:choose>
                        <xsl:when test="$narr_speech = 'off'">
                            <xsl:choose>
                                <xsl:when test="ancestor::said[not(@ana='#narration')] or (ancestor::sp and not(ancestor::speaker) and not(ancestor::stage))">DS</xsl:when>
                                <xsl:otherwise>NARR</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="ancestor::said or (ancestor::sp and not(ancestor::speaker) and not(ancestor::stage))">DS</xsl:when>
                                <xsl:otherwise>NARR</xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="tokenize(replace(.,'(\W)',' $1 '),'\s+')">
                    <xsl:if test=". != ''">
                        <word type="{$DS}"><xsl:value-of select="."/></word>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </words>
    </xsl:template>
    
    
</xsl:stylesheet>