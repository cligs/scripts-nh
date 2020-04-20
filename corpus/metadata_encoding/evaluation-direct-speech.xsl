<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        @author: Ulrike Henny-Krahmer
        
        This script produces:
        
        (1) a box plot displaying the proportion of paragraphs containing direct speech
        but no initial speech sign compared to all paragraphs containing direct speech, for each novel
        in the corpus with annotated direct speech. The goal is to estimate how much direct speech is missed
        if only initial speech signs are used to detect it. The information is also stored in a CSV file
        to be able to inspect individual cases.
        
        (2) a box plot displaying the proportion of the number of tokens of direct speech contained 
        in paragraphs with no initial speech sign compared to the overall number of tokens of direct speech.
        The information is also stored in a CSV file to be able to inspect individual cases.
        
        (3) a box plot showing the proportion of tokens of narrated text in paragraphs containing direct speech 
        that would have been mistaken as direct speech if the whole paragraph would have been marked as such,
        compared to the overall number of tokens of narrated text, for each novel in the corpus with annotated direct speech.
        The information is also stored in a CSV file to be able to inspect individual cases.
        
        (4) estimated precision, recall, and F1 scores are calculated for all the novels with checked direct speech
        annotation and stored as a CSV file.
        
        How to call the script:
        java -jar /home/ulrike/Programme/saxon/saxon9he.jar /home/ulrike/Git/conha19/tei/nh0001.xml /home/ulrike/Git/scripts-nh/corpus/metadata_encoding/evaluation-direct-speech.xsl
    -->
    
    <xsl:variable name="data-dir" select="'/home/ulrike/Git/conha19/tei/'"/>
    <xsl:variable name="out-html-paragraphs" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-paragraphs.html'"/>
    <xsl:variable name="out-csv-paragraphs" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-paragraphs.csv'"/>
    <xsl:variable name="out-html-tokens-sp" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-tokens-sp.html'"/>
    <xsl:variable name="out-csv-tokens-sp" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-tokens-sp.csv'"/>
    <xsl:variable name="out-html-tokens-narr" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-tokens-narr.html'"/>
    <xsl:variable name="out-csv-tokens-narr" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-tokens-narr.csv'"/>
    <xsl:variable name="out-csv-F1" select="'/home/ulrike/Git/data-nh/corpus/metadata-encoding/direct-speech-evaluation-F1.csv'"/>
    
    <!-- CLIGS IDs of TEI files with checked direct speech annotations -->
    <xsl:variable name="cligs-idnos-speech" select="('nh0001','nh0002','nh0003','nh0004','nh0005','nh0006','nh0007','nh0008','nh0009','nh0010',
        'nh0011','nh0012','nh0013','nh0014','nh0015','nh0016','nh0017','nh0018','nh0019','nh0020','nh0021','nh0022','nh0023','nh0024','nh0025',
        'nh0026','nh0027','nh0028','nh0037','nh0040','nh0042','nh0048','nh0049','nh0054','nh0055','nh0056','nh0057','nh0058','nh0059','nh0060',
        'nh0061','nh0062','nh0065','nh0070','nh0073','nh0077','nh0083','nh0091','nh0096','nh0102','nh0147','nh0163','nh0219','nh0220','nh0223',
        'nh0229','nh0232','nh0235','nh0236','nh0237','nh0238','nh0239','nh0241','nh0242','nh0243','nh0244','nh0245','nh0246','nh0248')"/>
    
    
    <xsl:template match="/">
        <!-- paragraph analysis -->
        <xsl:result-document href="{$out-csv-paragraphs}" method="text" encoding="UTF-8">
            <xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                <xsl:variable name="idno" select=".//idno[@type='cligs']"/>
                <xsl:value-of select="$idno"/><xsl:text>,</xsl:text>
                <xsl:variable name="paragraphs-with-speech" select="count(//p[said])"/>
                <xsl:variable name="speech-paragraphs-without-initial-speech-sign" select="count(//p[said][(.//text()[normalize-space(.)!=''])[1][not(starts-with(.,'—') or starts-with(.,'«') or starts-with(.,'='))]])"/>
                <xsl:value-of select="$speech-paragraphs-without-initial-speech-sign div $paragraphs-with-speech"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{$out-html-paragraphs}" method="html" encoding="UTF-8">
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
                        y: [<xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                            <xsl:variable name="paragraphs-with-speech" select="count(//p[said])"/>
                            <xsl:variable name="speech-paragraphs-without-initial-speech-sign" select="count(//p[said][(.//text()[normalize-space(.)!=''])[1][not(starts-with(.,'—') or starts-with(.,'«') or starts-with(.,'='))]])"/>
                            <xsl:value-of select="$speech-paragraphs-without-initial-speech-sign div $paragraphs-with-speech"/>
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
                        range: [0,1]
                        }
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
        
        <!-- token analysis, direct speech -->
        <xsl:result-document href="{$out-csv-tokens-sp}" method="text" encoding="UTF-8">
            <xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                <xsl:variable name="idno" select=".//idno[@type='cligs']"/>
                <xsl:value-of select="$idno"/><xsl:text>,</xsl:text>
                <xsl:variable name="tokens-speech" select="count(//body//said/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:variable name="tokens-speech-in-paragraphs-without-speech-sign" select="count(//body//p[said][(.//text()[normalize-space(.)!=''])[1][not(starts-with(.,'—') or starts-with(.,'«') or starts-with(.,'='))]]/said/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:value-of select="$tokens-speech-in-paragraphs-without-speech-sign div $tokens-speech"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{$out-html-tokens-sp}" method="html" encoding="UTF-8">
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
                        y: [<xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                            <xsl:variable name="tokens-speech" select="count(//body//said/text()/tokenize(normalize-space(.),' '))"/>
                            <xsl:variable name="tokens-speech-in-paragraphs-without-speech-sign" select="count(//body//p[said][(.//text()[normalize-space(.)!=''])[1][not(starts-with(.,'—') or starts-with(.,'«') or starts-with(.,'='))]]/said/text()/tokenize(normalize-space(.),' '))"/>
                            <xsl:value-of select="$tokens-speech-in-paragraphs-without-speech-sign div $tokens-speech"/>
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
                        range: [0,1]
                        }
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
        
        <!-- token analysis, narrated text -->
        <xsl:result-document href="{$out-csv-tokens-narr}" method="text" encoding="UTF-8">
            <xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                <xsl:variable name="idno" select=".//idno[@type='cligs']"/>
                <xsl:value-of select="$idno"/><xsl:text>,</xsl:text>
                <xsl:variable name="tokens-narrated-text" select="count(//body//p/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:variable name="tokens-narrated-in-speech-paragraphs" select="count(//body//p[said]/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:value-of select="$tokens-narrated-in-speech-paragraphs div $tokens-narrated-text"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{$out-html-tokens-narr}" method="html" encoding="UTF-8">
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
                        y: [<xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                            <xsl:variable name="tokens-narrated-text" select="count(//body//p/text()/tokenize(normalize-space(.),' '))"/>
                            <xsl:variable name="tokens-narrated-in-speech-paragraphs" select="count(//body//p[said]/text()/tokenize(normalize-space(.),' '))"/>
                            <xsl:value-of select="$tokens-narrated-in-speech-paragraphs div $tokens-narrated-text"/>
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
                        range: [0,1]
                        }
                        };
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
        <!-- token analysis, calculate estimated precision, recall, and F1 score -->
        <xsl:result-document href="{$out-csv-F1}" method="text" encoding="UTF-8">
            <xsl:text>idno,precision,recall,F1</xsl:text><xsl:text>
</xsl:text>
            <xsl:for-each select="collection($data-dir)//TEI[.//idno[@type='cligs'] = $cligs-idnos-speech]">
                <xsl:variable name="idno" select=".//idno[@type='cligs']"/>
                <xsl:value-of select="$idno"/><xsl:text>,</xsl:text>
                <!-- precision: correctly identified direct speech tokens, divided by all direct speech tokens that would have been returned counting 
                all tokens in paragraphs beginning with a speech sign -->
                <xsl:variable name="all-ds" select="count(//body//said/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:variable name="tokens-in-paragraphs-with-speech-sign" select="count(//body//p[said][(.//text()[normalize-space(.)!=''])[1][starts-with(.,'—') or starts-with(.,'«') or starts-with(.,'=')]]/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:variable name="precision" select="$tokens-in-paragraphs-with-speech-sign div $all-ds"/>
                <!-- recall: correctly identified direct speech tokens, divided by all actual direct speech tokens -->
                <xsl:variable name="tokens-speech-in-paragraphs-with-speech-sign" select="count(//body//p[said][(.//text()[normalize-space(.)!=''])[1][starts-with(.,'—') or starts-with(.,'«') or starts-with(.,'=')]]/said/text()/tokenize(normalize-space(.),' '))"/>
                <xsl:variable name="recall" select="$tokens-speech-in-paragraphs-with-speech-sign div $all-ds"/>
                <xsl:variable name="F1" select="2 * (($precision * $recall) div ($precision + $recall))"/>
                <xsl:value-of select="$precision"/><xsl:text>,</xsl:text>
                <xsl:value-of select="$recall"/><xsl:text>,</xsl:text>
                <xsl:value-of select="$F1"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>