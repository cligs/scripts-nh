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
    <xsl:variable name="nationalities" select="doc('/home/ulrike/Git/bibacme/app/data/nationalities.xml')//term[@type='general']"/>
    <xsl:variable name="birth-places" select="distinct-values($bibacme-authors/birth/placeName[last()])"/>
    <xsl:variable name="death-places" select="distinct-values($bibacme-authors/death/placeName[last()])"/>
    
    
    <xsl:template match="/">
        
        <!--<xsl:call-template name="numbers"/>-->
        
        <!-- ##### Authors ##### -->
        <!--<xsl:call-template name="plot-works-per-author"/>-->
        <!--<xsl:call-template name="list-works-per-author-top"/>-->
        
        <!--<xsl:call-template name="plot-editions-per-author"/>-->
        <!--<xsl:call-template name="list-editions-per-author-top"/>-->
        
        <!--<xsl:call-template name="plot-author-gender"/>-->
        
        <!--<xsl:call-template name="plot-author-births-deaths"/>-->
        <!--<xsl:call-template name="plot-author-births-deaths-decades"/>-->
        <!--<xsl:call-template name="plot-authors-alive"/>-->
        <!--<xsl:call-template name="plot-authors-active"/>-->
        <!--<xsl:call-template name="plot-authors-age"/>-->
        <!--<xsl:call-template name="plot-authors-age-decades"/>-->
        
        <!--<xsl:call-template name="plot-authors-by-country"/>-->
        <!--<xsl:call-template name="plot-authors-by-nationality"/>-->
        <!--<xsl:call-template name="plot-authors-by-birth-place"/>-->
        <!--<xsl:call-template name="plot-authors-by-death-place"/>-->
        
    </xsl:template>
    
    <!-- ########### TEMPLATES ############ -->
    
    <xsl:template name="numbers">
        <!-- overall counts of authors, works, editions, etc. -->
        <xsl:result-document href="{concat($output-dir,'numbers.txt')}" method="text" encoding="UTF-8">
            
            <!-- number of different works -->
            <xsl:text>Number of different works in Bib-ACMé: </xsl:text>
            <xsl:variable name="num-works-bib" select="count($bibacme-works)"/>
            <xsl:value-of select="$num-works-bib"/>
            
            <xsl:text>
</xsl:text>
            <xsl:text>Number of different works in Conha19: </xsl:text>
            <xsl:variable name="num-works-corp" select="count($corpus)"/>
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
                        xaxis: {tickmode: "linear", dtick: 10},
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
                        xaxis: {tickmode: "linear", dtick: 10},
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
                    <div id="myDiv" style="width: 1200px; height: 800px;"></div>
                    <script>
                        var trace1 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="string-join(cligs:get-num-authors-active($labels-x, $bibacme-authors),',')"/>],
                        name: "authors active Bib-ACMé",
                        type: "bar"
                        };
                        
                        var trace2 = {
                        x: [<xsl:value-of select="string-join($labels-x,',')"/>],
                        y: [<xsl:value-of select="string-join(cligs:get-num-authors-active($labels-x, $corpus-authors),',')"/>],
                        name: "authors active Conha19",
                        type: "bar"
                        };
                        
                        var data = [trace1, trace2];
                        
                        var layout = {
                        xaxis: {tickmode: "linear", dtick: 10},
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
    
    <xsl:template name="plot-authors-age">
        <!-- how old were the authors when they published their works? creates a blox plot -->
        <!-- for each work in Bib-ACMé/Conha19: how old was the author when it was published? -->
        <xsl:variable name="author-ages-bib" select="cligs:get-author-ages($bibacme-works)"/>
        <xsl:variable name="author-ages-corp" select="cligs:get-author-ages($corpus-works)"/>
        
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
                        name: "authors Bib-ACMé"
                        };
                        
                        var trace2 = {
                        y: [<xsl:value-of select="string-join($author-ages-corp,',')"/>],
                        type: 'box',
                        name: "authors Conha19"
                        };
                        
                        
                        var data = [trace1, trace2];
                        
                        Plotly.newPlot('myDiv', data);
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
    
    <xsl:function name="cligs:get-author-ages">
        <!-- 1-param-version of the previous function -->
        <xsl:param name="works"/>
        <xsl:value-of select="cligs:get-author-ages($works, 'none')"/>
    </xsl:function>
    
    <xsl:function name="cligs:get-box-group-labels">
        <xsl:param name="y"/>
        <xsl:param name="label"/>
        <!-- return a set of x labels for a set of y values corresponding to a certain label (e.g. decade) -->
        <xsl:value-of select="string-join(for $i in 1 to count($y) return $label,',')"/>
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
    
    
    
</xsl:stylesheet>