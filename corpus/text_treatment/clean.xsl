<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- @author: Ulrike Henny-Krahmer -->
    
    <!-- converts Abbyy-HTML-output, so that elements unnecessary for a basic TEI structure are removed -->
    
    <!-- Default: copy all element and attribute nodes, continue by applying other templates -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- the formatting is removed for spans that are not in italics -->
    <xsl:template match="span[matches(@class,'^font[0-9]+$')][not(contains(@style,'italic'))]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- spans that are in italics are changed to a TEI element -->
    <xsl:template match="span[contains(@style,'italic')]">
        <seg rend="italic">
            <xsl:apply-templates/>
        </seg>
    </xsl:template>
    
    <xsl:template match="a[normalize-space(.)='']|img|br"/>
    
    
</xsl:stylesheet>
