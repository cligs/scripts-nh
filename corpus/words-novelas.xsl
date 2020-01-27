<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
    @author: Ulrike Henny-Krahmer
    
    The goal of this script is to analyze the length of typical Spanish American 19th century "novelas" and "novelas cortas".
    
    This script collects bibliographic entries of works carrying the label "novela" from 
    (1) a preliminary full text corpus
    (2) a preliminary bibliographic database
    
    The number of words of these texts is then determined (for the full texts by counting the words,
    for the bibliographic entries by converting numbers of pages into numbers of words).
    
    The results are plotted as box plots.
    
    As a second step, the same is done for works carrying the label "novela corta".
    
    How to call the script:
        java -jar saxon9he.jar /home/ulrike/Git/bibacme/app/data/editions.xml /home/ulrike/Git/scripts-nh/corpus/words-novelas.xsl
    -->
    
    <xsl:variable name="input-editions" select="doc('/home/ulrike/Git/bibacme/app/data/editions.xml')"/>
    <xsl:variable name="input-works" select="doc('/home/ulrike/Git/bibacme/app/data/works.xml')"/>
    <xsl:variable name="data-dir" select="'/home/ulrike/Git/data-nh/corpus/words-novelas/'"/>
    <xsl:variable name="median-words-per-page" select="191"/>
    
    <xsl:template match="/">
        <!-- the following templates can be called one after the other: -->
        
        <!-- collect CLiGS identifiers of works carrying the label "novela";
        Output files: cligs-idnos.csv, cligs-idnos.xml -->
        <!--<xsl:call-template name="collect-idnos"/>-->
        
        <!-- create a box plot showing the number of words of the full texts;
        Output files: fulltexts-word-count.csv, fulltexts-word-count.html -->
        <!--<xsl:call-template name="plot-fulltexts"/>-->
        
        <!-- collect bibliographic entries of works carrying the label "novela";
        Output file: bibls.xml -->
        <!--<xsl:call-template name="collect-bibls"/>-->
        
        <!-- create a box plot showing the number of words of "novelas" for the bibliographic entries;
        Output file: bibls-word-count.html -->
        <!--<xsl:call-template name="plot-bibls"/>-->
        
        <!-- create a box plot showing the number of words and pages of "novelas" for the bibliographic entries;
        Output file: bibls-page-count.html -->
        <!--<xsl:call-template name="plot-bibls-pages"/>-->
        
        <!-- create a box plot combining the number of words of "novelas" for full texts and bibliographic entries;
        Output files: fulltexts-bibls-word-count.csv, fulltexts-bibls-word-count.html -->
        <!--<xsl:call-template name="plot-fulltexts-bibls-words"/>-->
        
        <!-- collect CLiGS identifiers of works carrying the label "novela corta";
        Output files: cligs-idnos-short.csv, cligs-idnos-short.xml -->
        <!--<xsl:call-template name="collect-idnos-short"/>-->
        
        <!-- collect bibliographic entries of works carrying the label "novela corta", 
        Output file: bibls-short.xml -->
        <!--<xsl:call-template name="collect-bibls-short"/>-->
        
        <!-- create a box plot combining the number of words of "novelas cortas" for full texts and bibliographic entries;
        Output files: fulltexts-bibls-short-word-count.csv -->
        <!--<xsl:call-template name="plot-fulltexts-bibls-short-words"/>-->
        
        <!-- for the purpose of documentation: generate a table containing an overview of the 
        novels used in this analysis -->
        <xsl:call-template name="generate-table"/>
    </xsl:template>
    
    <xsl:template name="collect-idnos">
        <!-- find all works which are available as full texts, only those labeled as "novela" -->
        <xsl:result-document href="{concat($data-dir,'cligs-idnos.csv')}" method="text">
            <xsl:for-each select="$input-works//bibl[idno[@type='cligs'][not(starts-with(.,'nh07'))][not(starts-with(.,'nh08'))]]">
                <xsl:sort select="idno[@type='cligs']"/>
                <xsl:variable name="work-id" select="@xml:id"/>
                <xsl:if test="$input-editions//biblStruct[@corresp=$work-id][.//title[matches(.,'(n|N)ovela')][not(matches(.,'(n|N)ovelas? (c|C)ortas?'))]]">
                    <xsl:value-of select="idno[@type='cligs']"/><xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{concat($data-dir, 'cligs-idnos.xml')}" method="xml" encoding="UTF-8">
            <idnos xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="$input-works//bibl[idno[@type='cligs'][not(starts-with(.,'nh07'))][not(starts-with(.,'nh08'))]]">
                    <xsl:sort select="idno[@type='cligs']"/>
                    <xsl:variable name="work-id" select="@xml:id"/>
                    <xsl:if test="$input-editions//biblStruct[@corresp=$work-id][.//title[matches(.,'(n|N)ovela')][not(matches(.,'(n|N)ovelas? (c|C)ortas?'))]]">
                        <idno><xsl:value-of select="idno[@type='cligs']"/></idno>
                    </xsl:if>
                </xsl:for-each>
            </idnos>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-fulltexts">
        <!-- this function creates a box plot showing the number of words of the full texts -->
        <!-- extract the word count value from the full texts (in TEI) -->
        <xsl:result-document href="{concat($data-dir, 'fulltexts-word-count.csv')}" method="text" encoding="UTF-8">
            <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos.xml'))//idno">
                <xsl:value-of select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/',.,'.xml'))//measure[@unit='words']"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{concat($data-dir, 'fulltexts-word-count.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        var data = [
                        {
                        y: [
                        <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos.xml'))//idno">
                            <xsl:value-of select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/',.,'.xml'))//measure[@unit='words']"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ],
                        boxpoints: 'all',
                        jitter: 1,
                        pointpos: -2,
                        type: 'box',
                        name: 'novelas'
                        }
                        ];
                        
                        layout = {
                        yaxis: {
                        dtick: 50000,
                        title: 'number of words'
                        }
                        };
                        
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="collect-bibls">
        <!-- find all works that carry the label "novela" and that are not available as CLiGS full texts
        and for which information about the number of pages is available -->
        <xsl:result-document href="{concat($data-dir, 'bibls.xml')}" method="html" encoding="UTF-8">
            <listBibl xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="$input-works//bibl[not(idno[@type='cligs'][not(starts-with(.,'nh07'))][not(starts-with(.,'nh08'))])]">
                    <xsl:variable name="work-id" select="@xml:id"/>
                    <xsl:for-each select="$input-editions//biblStruct[@corresp=$work-id][.//title[matches(.,'(n|N)ovela')][not(matches(.,'(n|N)ovelas? (c|C)ortas?'))]]">
                        <xsl:choose>
                            <xsl:when test="analytic">
                                <xsl:if test="monogr//biblScope/@n">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="monogr/extent/@n">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </listBibl>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-bibls">
        <!-- create a box plot showing the number of words for the bibliographic entries -->
        <xsl:result-document href="{concat($data-dir, 'bibls-word-count.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 1000px;"></div>
                    <script>
                        var data = [
                        {
                        y: [
                        <!-- if there are several editions of one work, take the mean of the page numbers -->
                        <xsl:for-each-group select="doc(concat($data-dir, 'bibls.xml'))//biblStruct" group-by="@corresp">
                            <xsl:variable name="num-bibls" select="count(current-group())"/>
                            <xsl:variable name="page-nums">
                                <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each select="current-group()">
                                        <xsl:choose>
                                            <xsl:when test="analytic">
                                                <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </pagenums>
                            </xsl:variable>
                            <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                            <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                            <xsl:value-of select="$word-num"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each-group>
                        ],
                        boxpoints: 'all',
                        jitter: 1,
                        pointpos: -2,
                        type: 'box',
                        name: 'novelas'
                        }
                        ];
                        
                        layout = {
                        yaxis: {
                        dtick: 10000,
                        title: 'number of words'
                        }
                        };
                        
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-bibls-pages">
        <!-- create a box plot showing the number of words and pages for the bibliographic entries -->
        <xsl:result-document href="{concat($data-dir, 'bibls-page-count.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 1000px;"></div>
                    <script>
                        var trace1 = {
                        y: [
                        <!--<xsl:for-each-group select="doc('bibls.xml')//biblStruct" group-by="@corresp">
                            <xsl:variable name="num-bibls" select="count(current-group())"/>
                            <xsl:variable name="page-nums">
                                <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each select="current-group()">
                                        <xsl:choose>
                                            <xsl:when test="analytic">
                                                <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </pagenums>
                            </xsl:variable>
                            <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                            <xsl:value-of select="$mean-page-num"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each-group>-->
                        ],
                        boxpoints: 'all',
                        jitter: 1,
                        pointpos: -2,
                        type: 'box',
                        name: 'novelas2'
                        };
                        var trace2 = {
                        y: [
                        <xsl:for-each-group select="doc(concat($data-dir, 'bibls.xml'))//biblStruct" group-by="@corresp">
                            <xsl:variable name="num-bibls" select="count(current-group())"/>
                            <xsl:variable name="page-nums">
                                <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each select="current-group()">
                                        <xsl:choose>
                                            <xsl:when test="analytic">
                                                <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </pagenums>
                            </xsl:variable>
                            <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                            <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                            <xsl:value-of select="$word-num"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each-group>
                        ],
                        boxpoints: 'all',
                        jitter: 1,
                        pointpos: -2,
                        type: 'box',
                        name: 'novelas',
                        yaxis: 'y2'
                        };
                        var data = [trace1, trace2];
                        
                        layout = {
                        yaxis: {
                        dtick: 100,
                        title: 'pages',
                        range: [0,1800],
                        showgrid: false
                        },
                        yaxis2: {
                        dtick: 10000,
                        title: 'words',
                        side: 'right',
                        overlaying: 'y',
                        range: [0,340000]
                        }
                        };
                        
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-fulltexts-bibls-words">
        <!-- create a box plot combining the number of words for full texts and bibliographic entries -->
        <xsl:result-document href="{concat($data-dir, 'fulltexts-bibls-word-count.csv')}" method="text" encoding="UTF-8">
            <xsl:for-each-group select="doc(concat($data-dir, 'bibls.xml'))//biblStruct" group-by="@corresp">
                <xsl:variable name="num-bibls" select="count(current-group())"/>
                <xsl:variable name="page-nums">
                    <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="current-group()">
                            <xsl:choose>
                                <xsl:when test="analytic">
                                    <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                </xsl:when>
                                <xsl:otherwise>
                                    <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </pagenums>
                </xsl:variable>
                <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                <xsl:value-of select="$word-num"/><xsl:text>
</xsl:text>
            </xsl:for-each-group>
            <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos.xml'))//idno">
                <xsl:value-of select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/',.,'.xml'))//measure[@unit='words']"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{concat($data-dir, 'fulltexts-bibls-word-count.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 1000px;"></div>
                    <script>
                        var data = [
                        {
                        y: [
                        <xsl:for-each-group select="doc(concat($data-dir, 'bibls.xml'))//biblStruct" group-by="@corresp">
                            <xsl:variable name="num-bibls" select="count(current-group())"/>
                            <xsl:variable name="page-nums">
                                <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each select="current-group()">
                                        <xsl:choose>
                                            <xsl:when test="analytic">
                                                <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </pagenums>
                            </xsl:variable>
                            <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                            <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                            <xsl:value-of select="$word-num"/><xsl:text>,</xsl:text>
                        </xsl:for-each-group>
                        <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos.xml'))//idno">
                            <xsl:value-of select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/',.,'.xml'))//measure[@unit='words']"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ],
                        boxpoints: 'all',
                        jitter: 1,
                        pointpos: -2,
                        type: 'box',
                        name: 'novelas'
                        }
                        ];
                        
                        layout = {
                        yaxis: {
                        dtick: 10000,
                        title: 'number of words',
                        range: [0,350000]
                        }
                        };
                        
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="collect-idnos-short">
        <!-- find all works which are available as full texts, only those labeled as "novela corta" -->
        <xsl:result-document href="{concat($data-dir, 'cligs-idnos-short.csv')}" method="text">
            <xsl:for-each select="$input-works//bibl[idno[@type='cligs'][not(starts-with(.,'nh07'))][not(starts-with(.,'nh08'))]]">
                <xsl:sort select="idno[@type='cligs']"/>
                <xsl:variable name="work-id" select="@xml:id"/>
                <xsl:if test="$input-editions//biblStruct[@corresp=$work-id][.//title[matches(.,'(n|N)ovelas? (c|C)ortas?')]]">
                    <xsl:value-of select="idno[@type='cligs']"/><xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{concat($data-dir, 'cligs-idnos-short.xml')}" method="xml" encoding="UTF-8">
            <idnos xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="$input-works//bibl[idno[@type='cligs'][not(starts-with(.,'nh07'))][not(starts-with(.,'nh08'))]]">
                    <xsl:sort select="idno[@type='cligs']"/>
                    <xsl:variable name="work-id" select="@xml:id"/>
                    <xsl:if test="$input-editions//biblStruct[@corresp=$work-id][.//title[matches(.,'(n|N)ovelas? (c|C)ortas?')]]">
                        <idno><xsl:value-of select="idno[@type='cligs']"/></idno>
                    </xsl:if>
                </xsl:for-each>
            </idnos>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="collect-bibls-short">
        <!-- find all works which carry the label "novela corta" and are not available as full texts -->
        <xsl:result-document href="{concat($data-dir, 'bibls-short.xml')}" method="html" encoding="UTF-8">
            <listBibl xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="$input-works//bibl[not(idno[@type='cligs'][not(starts-with(.,'nh07'))][not(starts-with(.,'nh08'))])]">
                    <xsl:variable name="work-id" select="@xml:id"/>
                    <xsl:for-each select="$input-editions//biblStruct[@corresp=$work-id][.//title[matches(.,'(n|N)ovelas? (c|C)ortas?')]]">
                        <xsl:choose>
                            <xsl:when test="analytic">
                                <xsl:if test="monogr//biblScope/@n">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="monogr/extent/@n">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </listBibl>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="plot-fulltexts-bibls-short-words">
        <!-- create a box plot combining the number of words of "novelas cortas" for full texts and bibliographic entries -->
        <xsl:result-document href="{concat($data-dir, 'fulltexts-bibls-short-word-count.csv')}" method="text" encoding="UTF-8">
            <xsl:for-each-group select="doc('bibls-short.xml')//biblStruct" group-by="@corresp">
                <xsl:variable name="num-bibls" select="count(current-group())"/>
                <xsl:variable name="page-nums">
                    <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="current-group()">
                            <xsl:choose>
                                <xsl:when test="analytic">
                                    <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                </xsl:when>
                                <xsl:otherwise>
                                    <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </pagenums>
                </xsl:variable>
                <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                <xsl:value-of select="$word-num"/><xsl:text>
</xsl:text>
            </xsl:for-each-group>
            <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos-short.xml'))//idno">
                <xsl:value-of select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/',.,'.xml'))//measure[@unit='words']"/>
                <xsl:if test="position() != last()"><xsl:text>
</xsl:text></xsl:if>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="{concat($data-dir, 'fulltexts-bibl-short-word-count.html')}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px; height: 600px;"></div>
                    <script>
                        var data = [
                        {
                        y: [
                        <xsl:for-each-group select="doc(concat($data-dir, 'bibls-short.xml'))//biblStruct" group-by="@corresp">
                            <xsl:variable name="num-bibls" select="count(current-group())"/>
                            <xsl:variable name="page-nums">
                                <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each select="current-group()">
                                        <xsl:choose>
                                            <xsl:when test="analytic">
                                                <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </pagenums>
                            </xsl:variable>
                            <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                            <xsl:variable name="word-num" select="$mean-page-num * 189"/>
                            <xsl:value-of select="$word-num"/><xsl:text>,</xsl:text>
                        </xsl:for-each-group>
                        <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos-short.xml'))//idno">
                            <xsl:value-of select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/',.,'.xml'))//measure[@unit='words']"/>
                            <xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>
                        ],
                        boxpoints: 'all',
                        jitter: 1,
                        pointpos: -2,
                        type: 'box',
                        name: 'novelas'
                        }
                        ];
                        
                        layout = {
                        yaxis: {
                        dtick: 10000,
                        title: 'number of words'
                        }
                        };
                        
                        
                        Plotly.newPlot('myDiv', data, layout);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="generate-table">
        <!-- for the purpose of documentation: generate a table containing an overview of the 
        novels used in this analysis -->
        
        <xsl:result-document href="{concat($data-dir, 'novelas-length.csv')}" method="text" encoding="UTF-8">
<xsl:text>author-name,work-title,work-type,bibacme-work-id,cligs-idno,num-pages,num-words</xsl:text><xsl:text>
</xsl:text>
            <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos.xml'))//idno">
                <xsl:variable name="cligs-file" select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/', current(), '.xml'))//TEI"/>
                <xsl:text>"</xsl:text><xsl:value-of select="$cligs-file//author/name[@type='full']"/><xsl:text>",</xsl:text>
                <xsl:text>"</xsl:text><xsl:value-of select="$cligs-file//title[@type='main']"/><xsl:text>",</xsl:text>
                <xsl:text>novela</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="$input-works//bibl[idno[@type='cligs'] = current()]/@xml:id"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current()"/><xsl:text>,</xsl:text>
                <xsl:text>-</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="$cligs-file//measure[@unit='words']"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <xsl:for-each select="doc(concat($data-dir, 'cligs-idnos-short.xml'))//idno">
                <xsl:variable name="cligs-file" select="doc(concat('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/', current(), '.xml'))//TEI"/>
                <xsl:text>"</xsl:text><xsl:value-of select="$cligs-file//author/name[@type='full']"/><xsl:text>",</xsl:text>
                <xsl:text>"</xsl:text><xsl:value-of select="$cligs-file//title[@type='main']"/><xsl:text>",</xsl:text>
                <xsl:text>novela corta</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="$input-works//bibl[idno[@type='cligs'] = current()]/@xml:id"/><xsl:text>,</xsl:text>
                <xsl:value-of select="current()"/><xsl:text>,</xsl:text>
                <xsl:text>-</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="$cligs-file//measure[@unit='words']"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <xsl:for-each-group select="doc(concat($data-dir, 'bibls.xml'))//biblStruct" group-by="@corresp">
                <xsl:variable name="num-bibls" select="count(current-group())"/>
                <xsl:variable name="page-nums">
                    <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="current-group()">
                            <xsl:choose>
                                <xsl:when test="analytic">
                                    <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                </xsl:when>
                                <xsl:otherwise>
                                    <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </pagenums>
                </xsl:variable>
                <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                <xsl:text>"</xsl:text><xsl:value-of select="current-group()[1]//author"/><xsl:text>",</xsl:text>
                <xsl:text>"</xsl:text><xsl:value-of select="(current-group()[1]//title[@type='main'])[1]"/><xsl:text>",</xsl:text>
                <xsl:text>novela</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="current-grouping-key()"/><xsl:text>,</xsl:text>
                <xsl:text>-</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="$mean-page-num"/><xsl:text>,</xsl:text>
                <xsl:value-of select="$word-num"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each-group>
            <xsl:for-each-group select="doc(concat($data-dir, 'bibls-short.xml'))//biblStruct" group-by="@corresp">
                <xsl:variable name="num-bibls" select="count(current-group())"/>
                <xsl:variable name="page-nums">
                    <pagenums xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="current-group()">
                            <xsl:choose>
                                <xsl:when test="analytic">
                                    <num><xsl:value-of select=".//biblScope[@unit='page']/number(@n)"/></num>
                                </xsl:when>
                                <xsl:otherwise>
                                    <num><xsl:value-of select="monogr/extent/number(@n)"/></num>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </pagenums>
                </xsl:variable>
                <xsl:variable name="mean-page-num" select="round(sum($page-nums//num/number(.)) div $num-bibls)"/>
                <xsl:variable name="word-num" select="$mean-page-num * $median-words-per-page"/>
                <xsl:text>"</xsl:text><xsl:value-of select="current-group()[1]//author"/><xsl:text>",</xsl:text>
                <xsl:text>"</xsl:text><xsl:value-of select="(current-group()[1]//title[@type='main'])[1]"/><xsl:text>",</xsl:text>
                <xsl:text>novela corta</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="current-grouping-key()"/><xsl:text>,</xsl:text>
                <xsl:text>-</xsl:text><xsl:text>,</xsl:text>
                <xsl:value-of select="$mean-page-num"/><xsl:text>,</xsl:text>
                <xsl:value-of select="$word-num"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
     
</xsl:stylesheet>