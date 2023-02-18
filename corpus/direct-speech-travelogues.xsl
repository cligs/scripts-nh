<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        @author: Ulrike Henny-Krahmer
        
        This script produces a box plot displaying the 
        proportion of paragraphs containing direct speech
        for the three travelogues "Una excursión a los indios ranqueles", "La tierra natal", and "Mis montañas"
        vs. all the other novels in the corpus.
        
        How to call the script:
        java -jar /home/ulrike/Programme/saxon/saxon9he.jar /home/ulrike/Git/conha19/tei/nh0001.xml /home/ulrike/Git/scripts-nh/corpus/direct-speech-travelogues.xsl > /home/ulrike/Git/data-nh/corpus/direct-speech-travelogues.html
    -->
    
    <xsl:variable name="wdir">/home/ulrike/Git/conha19/</xsl:variable>
    
    <xsl:template match="/">
        <html>
            <head>
                <!-- Plotly.js -->
                <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
            </head>
            <body>
                <!-- Plotly chart will be drawn inside this DIV -->
                <div id="myDiv" style="width: 709px; height: 390px;"></div> 
                <!-- web-html: width: 709px; height: 480px; 
                print: width: 1417px; height: 1000px; -->
                <!-- Plotly chart will be exported to this tag -->
                <img id="png-export"/>
                <script>
                    
                    var d3 = Plotly.d3;
                    var img_png= d3.select('#png-export');
                    
                    var data = [
                    {
                    y: [<xsl:for-each select="collection(concat($wdir, 'tei'))//TEI[.//body//p[said]]">
                        <xsl:variable name="num_p" select="count(.//body//p)"/>
                        <!-- paragraphs containing direct speech -->
                        <xsl:variable name="num_p_speech" select="count(.//body//p[said])"/>
                        <!-- share of paragraphs containing direct speech in relationship to all paragraphs -->
                        <xsl:variable name="rel_p_speech" select="$num_p_speech div $num_p"/>
                        <xsl:value-of select="$rel_p_speech"/>
                        <xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>],
                    boxpoints: 'all',
                    jitter: 0.3,
                    pointpos: -1.8,
                    type: 'box',
                    name: 'novels'
                    },
                    {
                    y: [<xsl:for-each select="collection(concat($wdir, 'travelogues'))//TEI">
                        <xsl:variable name="num_p" select="count(.//body//p)"/>
                        <!-- paragraphs containing direct speech -->
                        <xsl:variable name="num_p_speech" select="count(.//body//p[said])"/>
                        <!-- share of paragraphs containing direct speech in relationship to all paragraphs -->
                        <xsl:variable name="rel_p_speech" select="$num_p_speech div $num_p"/>
                        <xsl:value-of select="$rel_p_speech"/>
                        <xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>],
                    boxpoints: 'all',
                    jitter: 0.3,
                    pointpos: -1.8,
                    type: 'box',
                    name: 'travelogues'
                    }
                    ];
                    
                    var layout = {
                    /*
                    title: {
                        text: "Proportion of paragraphs containing direct speech, travelogues vs. novels",
                        font: {size: 14}},
                    */
                    font: {
                        family: "Libertine, serif",
                        color: "#000000",
                        size: 14
                        },
                    showlegend: false,
                    //legend: {font: {size: 14}},
                    margin: {t: 30, b: 40, l: 100, r: 80},
                    yaxis: {
                        range: [0,1],
                        tickfont: {size: 14},
                        title: {
                            text: "paragraphs with direct speech (relative)",
                            font: {size: 14}
                            }
                    },
                    xaxis: {tickfont: {size: 14}}
                    };
                    
                    Plotly.newPlot('myDiv', data, layout);<!--.then(
                        function(gd)
                        {
                        Plotly.toImage(gd,{width:1654,height:1034}) 
                        .then(
                        function(url)
                        {
                        img_png.attr("src", url);
                        }
                        )
                        });-->
                </script>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>