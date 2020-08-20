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
        
        <!--<xsl:call-template name="stand-off"/>-->
        
        <!--<xsl:call-template name="csv-f1"/>-->
        
        <xsl:call-template name="box-f1"/>
        
        <!--<xsl:call-template name="box-f1-edition-type"/>-->
        
        <!--<xsl:call-template name="box-f1-speech-sign"/>-->
        
        
    </xsl:template>
    
    
    <!--A box plot showing the F1 scores for speech recognition in all the novels that were checked for it, 
    differentiating by type of edition (modern, historical + first, unknown)-->
    <xsl:template name="box-f1-edition-type">
        <xsl:result-document href="{$out-html-F1-edition-type}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var trace1 = 
                        {
                        y: [<xsl:for-each select="collection($path_TEI_out)//TEI[.//term[@type='text.source.edition'][.=('first','historical')]]">
                            <xsl:value-of select="cligs:get-f1(.)"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'historical'
                        };
                        
                        var trace2 = 
                        {
                        y: [<xsl:for-each select="collection($path_TEI_out)//TEI[.//term[@type='text.source.edition'][.='modern']]">
                            <xsl:value-of select="cligs:get-f1(.)"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'modern'
                        };
                        
                        var trace3 = 
                        {
                        y: [<xsl:for-each select="collection($path_TEI_out)//TEI[.//term[@type='text.source.edition'][.='unknown']]">
                            <xsl:value-of select="cligs:get-f1(.)"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'unknown'
                        };
                        
                        var layout = {
                        yaxis: {
                        range: [0,1]
                        }
                        };
                        
                        var data = [trace1, trace2, trace3];
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- A box plot showing the F1 scores for speech recognition in all the novels that were checked for it, 
    differentiating by type of speech sign (single, double) -->
    <xsl:template name="box-f1-speech-sign">
        <xsl:result-document href="{$out-html-F1-speech-sign}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var trace1 = 
                        {
                        y: [<xsl:for-each select="collection($path_TEI_out)//TEI[.//term[@type='text.speech.sign.type'][.='single']]">
                            <xsl:value-of select="cligs:get-f1(.)"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'single'
                        };
                        
                        var trace2 = 
                        {
                        y: [<xsl:for-each select="collection($path_TEI_out)//TEI[.//term[@type='text.speech.sign.type'][.='double']]">
                            <xsl:value-of select="cligs:get-f1(.)"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'double'
                        };
                        
                        var layout = {
                        yaxis: {
                        range: [0,1]
                        }
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
        <xsl:result-document href="{$out-html-F1}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 800px; height: 800px;"></div>
                    <script>
                        var data = [
                        {
                        y: [<xsl:for-each select="collection($path_TEI_out)//TEI">
                            <xsl:value-of select="cligs:get-f1(.)"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>],
                        boxpoints: 'all',
                        jitter: 0.3,
                        pointpos: -1.8,
                        type: 'box',
                        name: 'novels'
                        }
                        ];
                        
                        var layout = {
                            yaxis: {
                                range: [0,1],
                                title: { text: 'F1 score'}
                            }
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    <!-- get precision score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-precision">
        <xsl:param name="context"/>
        <!-- precision: correctly identified direct speech tokens, 
                    divided by all tokens that were assumed to be direct speech in the regex approach -->
        <xsl:variable name="positives" select="$context//linkGrp[@type='DS_reg']/link[contains(@target,'#DS')]"/>
        <!--<xsl:variable name="true-positives" select="$positives[@target = ./preceding::link/@target]"/>
        the previous line also works, but the following is more efficient: -->
        <xsl:variable name="true-positives">
            <xsl:for-each select="$positives">
                <xsl:variable name="pos" select="count(./preceding-sibling::link) + 1"/>
                <xsl:variable name="tar" select="@target"/>
                <xsl:if test="$context//linkGrp[@type='DS_gold']/link[position() = $pos][@target=$tar]">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="precision" select="count($true-positives//link) div count($positives)"/>
        <xsl:value-of select="$precision"/>
    </xsl:function>
    
    
    <!-- get recall score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-recall">
        <xsl:param name="context"/>
        <!-- recall: correctly identified direct speech tokens, 
                    divided by all actual direct speech tokens -->
        <xsl:variable name="positives" select="$context//linkGrp[@type='DS_reg']/link[contains(@target,'#DS')]"/>
        <!--<xsl:variable name="true-positives" select="$positives[@target = ./preceding::link/@target]"/>
        the previous line also works, but the following is more efficient: -->
        <xsl:variable name="true-positives">
            <xsl:for-each select="$positives">
                <xsl:variable name="pos" select="count(./preceding-sibling::link) + 1"/>
                <xsl:variable name="tar" select="@target"/>
                <xsl:if test="$context//linkGrp[@type='DS_gold']/link[position() = $pos][@target=$tar]">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="all-ds" select="$context//linkGrp[@type='DS_gold']/link[contains(@target,'#DS')]"/>
        <xsl:variable name="recall" select="count($true-positives//link) div count($all-ds)"/>
        <xsl:value-of select="$recall"/>
    </xsl:function>
    
    
    <!-- get F1 score for direct speech annotation for the current TEI file -->
    <xsl:function name="cligs:get-f1">
        <xsl:param name="context"/>
        <xsl:variable name="precision" select="cligs:get-precision($context)"/>
        <xsl:variable name="recall" select="cligs:get-recall($context)"/>
        <xsl:variable name="F1" select="2 * (($precision * $recall) div ($precision + $recall))"/>
        <xsl:value-of select="$F1"/>
    </xsl:function>
    
    
    <!-- Precision, recall, and F1 scores are calculated for all the novels with checked direct speech
        annotation, comparing it to the regular expression annotation. The results are stored as a CSV file -->
    <xsl:template name="csv-f1">
        <xsl:result-document href="{$out-csv-F1}" method="text" encoding="UTF-8">
            <xsl:text>idno,precision,recall,F1</xsl:text><xsl:text>
</xsl:text>
            <xsl:for-each select="collection($path_TEI_out)//TEI">
                <xsl:variable name="idno" select=".//idno[@type='cligs']"/>
                <xsl:variable name="filename" select="concat($idno,'.xml')"/>
                
                <xsl:value-of select="$idno"/><xsl:text>,</xsl:text>
                
                <!-- precision: correctly identified direct speech tokens, 
                    divided by all tokens that were assumed to be direct speech in the regex approach -->
                <xsl:value-of select="cligs:get-precision(.)"/><xsl:text>,</xsl:text>
                
                <!-- recall: correctly identified direct speech tokens, 
                    divided by all actual direct speech tokens -->
                <xsl:value-of select="cligs:get-recall(.)"/><xsl:text>,</xsl:text>
                
                <!-- F1 score:  -->
                <xsl:value-of select="cligs:get-f1(.)"/>
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
        and for regular expression-based annotations -->
        <xsl:for-each select="collection($path_TEI_collection)//TEI[.//said]">
            
            <xsl:if test=".//idno[@type='cligs'][.='nh0002']">
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
                                        <xsl:for-each select="text/body//(p|l)">
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
                                            </xsl:call-template>
                                        </linkGrp>
                                        <!-- store regex direct speech annotation -->
                                        <linkGrp type="DS_reg">
                                            <xsl:call-template name="ds_standoff">
                                                <xsl:with-param name="context" select="doc(concat($path_TEI_collection_ds, $filename))/TEI"/>
                                            </xsl:call-template>
                                        </linkGrp>
                                    </p>
                                </div>
                            </back>
                        </text>
                    </xsl:copy>
                </xsl:result-document>
            </xsl:if>
            
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
        <xsl:for-each select="$context/text/body//(p|l)">
            <xsl:variable name="p_pos" select="position()"/>
            <xsl:variable name="words">
                <xsl:call-template name="get-words-DS-NARR">
                    <xsl:with-param name="context" select="."/>
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
        <words>
            <xsl:for-each select="$context//text()[matches(.,'\S')]">
                <xsl:variable name="DS">
                    <xsl:choose>
                        <xsl:when test="ancestor::said or (ancestor::sp and not(ancestor::speaker) and not(ancestor::stage))">DS</xsl:when>
                        <xsl:otherwise>NARR</xsl:otherwise>
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