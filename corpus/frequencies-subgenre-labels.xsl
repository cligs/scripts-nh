<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
    @author: Ulrike Henny-Krahmer
    
    This script generates several csv files with frequencies of subgenre labels in the bibliography Bib-ACMé.
    As input, it takes the file "works.xml" from Bib-ACMé.
    
    How to call the script:
        java -jar saxon9he.jar /home/ulrike/Git/bibacme/app/data/works.xml /home/ulrike/Git/scripts-nh/corpus/frequencies-subgenre-labels.xsl
    -->
    
    <xsl:variable name="data-dir" select="'/home/ulrike/Git/data-nh/corpus/bibliography-subgenre-labels/'"/>
    
    <xsl:template match="/">
        <xsl:variable name="num-bibls" select="count(//bibl)"/>
        
        <!-- the following templates / instructions can be called one after the other: -->
        
        <!-- create a list of the top most frequent explicit subgenre labels;
        output file: frequencies-explicit-labels.csv -->
        <!--<xsl:call-template name="frequencies-explicit-labels"/>-->
        
        <!-- create a list of the top most frequent explicit thematic subgenre labels;
        output file: frequencies-explicit-thematic-labels.csv -->
        <!--<xsl:call-template name="frequencies-explicit-thematic-labels"/>-->
        
        <!-- how many novels do not have any explicit subgenre label? -->
        <!--<xsl:variable name="without-explicit-label" select="count(//bibl[not(term[contains(@type,'subgenre.summary') and contains(@type,'explicit')])])"/>
        <xsl:value-of select="$without-explicit-label"/><xsl:text>
</xsl:text>
        <xsl:value-of select="$without-explicit-label div $num-bibls"/>-->
        
        <!-- how many novels have explicit thematic subgenre labels? (in % of all the novels in the bibliography) -->
        <!-- <xsl:value-of select="count(//bibl[term[@type='subgenre.summary.theme.explicit']]) div $num-bibls"/>-->
        
        <!-- create a list of the top most frequent subgenre labels (including implicit and literary historical labels);
        output file: frequencies-subgenre-labels.csv -->
        <!--<xsl:call-template name="frequencies-subgenre-labels"/>-->
        
        <!-- how many novels do not have any subgenre label? -->
        <xsl:variable name="without-label" select="count(//bibl[not(term[contains(@type,'subgenre.summary')])])"/>
        <xsl:value-of select="$without-label"/><xsl:text>
</xsl:text>
        <xsl:value-of select="$without-label div $num-bibls"/>
        
        <!-- create a list of the top most frequent subgenre labels related to themes (including implicit and literary historical labels);
        output file: frequencies-thematic-labels.csv -->
        <!--<xsl:call-template name="frequencies-thematic-labels"/>-->
        
        <!-- how many novels do not have any thematic subgenre label? -->
        <!--<xsl:variable name="without-theme" select="count(//bibl[not(term[contains(@type,'subgenre.summary.theme')])])"/>
        <xsl:value-of select="$without-theme"/><xsl:text>
</xsl:text>
        <xsl:value-of select="$without-theme div $num-bibls"/>-->
        
        <!-- create a list of the top most frequent subgenre labels related to literary currents (including implicit and literary historical labels);
        output file: frequencies-labels-currents.csv -->
        <!--<xsl:call-template name="frequencies-labels-currents"/>-->
        
        <!-- how many novels do not have any subgenre label related to the literary current? -->
        <!--<xsl:variable name="without-current" select="count(//bibl[not(term[contains(@type,'subgenre.summary.current')])])"/>
        <xsl:value-of select="$without-current"/><xsl:text>
</xsl:text>
        <xsl:value-of select="$without-current div $num-bibls"/>-->
        
        <!-- how many novels do not have any subgenre label derived from literary histories? -->
        <!--<xsl:variable name="without-litHist" select="count(//bibl[not(term[contains(@type,'subgenre.summary') and contains(@type,'litHist')])])"/>
        <xsl:value-of select="$without-litHist"/><xsl:text>
</xsl:text>
        <xsl:value-of select="$without-litHist div $num-bibls"/>-->
    </xsl:template>
    
    
    <xsl:template name="frequencies-explicit-labels">
        <!-- creates a list of the top most frequent explicit subgenre labels;
        output file: frequencies-explicit-labels.csv -->
        <xsl:result-document href="{concat($data-dir, 'frequencies-explicit-labels.csv')}" method="text" encoding="UTF-8">
            <xsl:variable name="num-bibls" select="count(//bibl)"/>
            <xsl:text>"subgenre label", "frequency absolute", "frequency relative", "frequency absolute normalized", "frequency relative normalized"</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:for-each-group select="//term[@type='subgenre.title.explicit.norm']" group-by="normalize-space(.)">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:text>",</xsl:text>
                <xsl:variable name="freq" select="count(//term[@type='subgenre.title.explicit'][contains(normalize-space(.),current-grouping-key())])"/>
                <xsl:value-of select="$freq"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq div $num-bibls"/>
                <xsl:text>,</xsl:text>
                <xsl:variable name="freq-norm" select="count(current-group())"/>
                <xsl:value-of select="$freq-norm"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq-norm div $num-bibls"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="frequencies-explicit-thematic-labels">
        <!-- creates a list of the top most frequent explicit thematic subgenre labels;
        output file: frequencies-explicit-thematic-labels.csv -->
        <xsl:result-document href="{concat($data-dir, 'frequencies-explicit-thematic-labels.csv')}" method="text" encoding="UTF-8">
            <xsl:variable name="num-bibls" select="count(//bibl)"/>
            <xsl:text>"subgenre label", "frequency absolute", "frequency relative", "frequency absolute normalized", "frequency relative normalized"</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:for-each-group select="//term[@type='subgenre.summary.theme.explicit']" group-by="normalize-space(.)">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:text>",</xsl:text>
                <xsl:variable name="freq" select="count(//term[@type='subgenre.title.explicit'][contains(normalize-space(.),current-grouping-key())])"/>
                <xsl:value-of select="$freq"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq div $num-bibls"/>
                <xsl:text>,</xsl:text>
                <xsl:variable name="freq-norm" select="count(current-group())"/>
                <xsl:value-of select="$freq-norm"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq-norm div $num-bibls"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="frequencies-subgenre-labels">
        <!-- creates a list of the top most frequent subgenre labels (including implicit and literary historical labels);
        output file: frequencies-subgenre-labels.csv -->
        <xsl:result-document href="{concat($data-dir, 'frequencies-subgenre-labels.csv')}" method="text" encoding="UTF-8">
            <xsl:variable name="num-bibls" select="count(//bibl)"/>
            <xsl:text>"subgenre label", "frequency absolute", "frequency relative"</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:for-each-group select="//term[contains(@type,'subgenre.summary')]" group-by="normalize-space(.)">
                <xsl:sort select="count(//bibl[.//term[contains(@type,'subgenre.summary')][normalize-space(.)=current-grouping-key()]])" data-type="number" order="descending"/>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:text>",</xsl:text>
                <xsl:variable name="freq" select="count(//bibl[.//term[contains(@type,'subgenre.summary')][normalize-space(.)=current-grouping-key()]])"/>
                <xsl:value-of select="$freq"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq div $num-bibls"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="frequencies-thematic-labels">
        <!-- creates a list of the top most frequent subgenre labels related to themes (including implicit and literary historical labels);
        output file: frequencies-thematic-labels.csv -->
        <xsl:result-document href="{concat($data-dir, 'frequencies-thematic-labels.csv')}" method="text" encoding="UTF-8">
            <xsl:variable name="num-bibls" select="count(//bibl)"/>
            <xsl:text>"subgenre label", "frequency absolute", "frequency relative"</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:for-each-group select="//term[contains(@type,'subgenre.summary.theme')]" group-by="normalize-space(.)">
                <xsl:sort select="count(//bibl[.//term[contains(@type,'subgenre.summary.theme')][normalize-space(.)=current-grouping-key()]])" data-type="number" order="descending"/>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:text>",</xsl:text>
                <xsl:variable name="freq" select="count(//bibl[.//term[contains(@type,'subgenre.summary.theme')][normalize-space(.)=current-grouping-key()]])"/>
                <xsl:value-of select="$freq"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq div $num-bibls"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="frequencies-labels-currents">
        <!-- create a list of the top most frequent subgenre labels related to literary currents (including implicit and literary historical labels);
        output file: frequencies-labels-currents.csv -->
        <xsl:result-document href="{concat($data-dir, 'frequencies-labels-currents.csv')}" method="text" encoding="UTF-8">
            <xsl:variable name="num-bibls" select="count(//bibl)"/>
            <xsl:text>"subgenre label", "frequency absolute", "frequency relative"</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:for-each-group select="//term[contains(@type,'subgenre.summary.current')]" group-by="normalize-space(.)">
                <xsl:sort select="count(//bibl[.//term[contains(@type,'subgenre.summary.current')][normalize-space(.)=current-grouping-key()]])" data-type="number" order="descending"/>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:text>",</xsl:text>
                <xsl:variable name="freq" select="count(//bibl[.//term[contains(@type,'subgenre.summary.current')][normalize-space(.)=current-grouping-key()]])"/>
                <xsl:value-of select="$freq"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$freq div $num-bibls"/>
                <xsl:if test="position() != last()">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>