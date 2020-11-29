<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" 
    xmlns:cligs="https://cligs.hypotheses.org/ns/cligs" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:variable name="works" select="doc('/home/ulrike/Git/bibacme/app/data/works.xml')"/>
    
    <xsl:template match="/">
        <xsl:variable name="sent">
            <xsl:for-each select="$works//tei:bibl[tei:term[starts-with(@type,'subgenre.summary.theme')]/normalize-space(.)='novela sentimental']">
                <xsl:choose>
                    <xsl:when test="tei:term[starts-with(@type,'subgenre.summary.theme')][normalize-space(.)='novela sentimental'][@cligs:importance='2']">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="not(tei:term[starts-with(@type,'subgenre.summary.theme')][2])">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:text>primary sentimental:</xsl:text>
        <xsl:value-of select="count($sent//tei:bibl)"/>
        <xsl:text>
            no current:</xsl:text>
        <xsl:value-of select="count($sent//tei:bibl[not(tei:term[starts-with(@type,'subgenre.summary.current')])])"/>
        <xsl:text>
            also romantic:</xsl:text>
        <xsl:value-of select="count($sent//tei:bibl[tei:term[starts-with(@type,'subgenre.summary.current')][normalize-space(.)='novela romántica']])"/>
        <xsl:text>
            also realistic:</xsl:text>
        <xsl:value-of select="count($sent//tei:bibl[tei:term[starts-with(@type,'subgenre.summary.current')][normalize-space(.)='novela realista']])"/>
        <xsl:text>
            also naturalistic:</xsl:text>
        <xsl:value-of select="count($sent//tei:bibl[tei:term[starts-with(@type,'subgenre.summary.current')][normalize-space(.)='novela naturalista']])"/>
        <xsl:text>
            also modernist:</xsl:text>
        <xsl:value-of select="count($sent//tei:bibl[tei:term[starts-with(@type,'subgenre.summary.current')][normalize-space(.)='novela modernista']])"/>
        
    </xsl:template>
    
</xsl:stylesheet>