<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- @author: Ulrike Henny-Krahmer -->
    
    <!-- With this script, the gaps contained in the TEI files of the corpus are analyzed. -->
    
    <!-- How to call the script: 
    java -jar saxon9he.jar "/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master/nh0001.xml"  "/home/ulrike/Git/scripts-nh/corpus/text_treatment/gaps.xsl" > "/home/ulrike/Git/data-nh/corpus/text-treatment/gaps.txt"-->
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:variable name="data-dir">/home/ulrike/Git/data-nh/corpus/text-treatment/</xsl:variable>
    <xsl:variable name="collection" select="collection('/home/ulrike/Git/hennyu/novelashispanoamericanas/corpus/master')//TEI"/>
    
    <xsl:template match="/">
        <!-- count the number of gaps -->
        <xsl:value-of select="count($collection//gap)"/>
        <xsl:text> gaps were detected in </xsl:text>
        <xsl:value-of select="count($collection[.//gap])"/>
        <xsl:text> texts.</xsl:text>
        
        <!-- create a bar chart showing the number of missing pages, lines, words, and characters -->
        <xsl:result-document href="{concat($data-dir, 'gaps.html')}" encoding="UTF-8" method="html">
            <html>
                <head>
                    <!-- Plotly.js -->
                    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
                </head>
                <body>
                    <!-- Plotly chart will be drawn inside this DIV -->
                    <div id="myDiv" style="width: 600px"></div>
                    <script>
                        var data = [
                        {
                        x: ['pages', 'lines', 'words', 'characters'],
                        y: [<xsl:value-of select="sum($collection//gap[@unit='page']/@extent/number(.))"/>,
                        <xsl:value-of select="sum($collection//gap[@unit='line']/@extent/number(.))"/>,
                        <xsl:value-of select="sum($collection//gap[@unit='word']/@extent/number(.))"/>,
                        <xsl:value-of select="sum($collection//gap[@unit='char']/@extent/number(.))"/>],
                        type: 'bar'
                        }
                        ];
                        
                        Plotly.newPlot('myDiv', data);
                    </script>
                </body>
            </html>
        </xsl:result-document>
        
    </xsl:template>
    
    
</xsl:stylesheet>
