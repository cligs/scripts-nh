<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        
    @author: Ulrike Henny-Krahmer
    
    This script produces a plain text version of a single TEI corpus file.
        
    How to call the script (to process the whole corpus):
    java -jar /home/ulrike/Programme/saxon/saxon9he.jar -s:/home/ulrike/Git/conha19/tei/ -o:/home/ulrike/Git/conha19/txt/ -xsl:/home/ulrike/Git/scripts-nh/corpus/derivative_formats/get-plaintext.xsl
   
    -->
    
    <xsl:output method="text" media-type="text/plain" encoding="UTF-8"/>
    
    <!-- ### COPY ### -->
   
    <!-- copy paragraph text -->
    <xsl:template match="p">
        <xsl:copy-of select="normalize-space(.)"/><xsl:text>
            
</xsl:text>
    </xsl:template>
    
    <!-- copy verse line text -->
    <xsl:template match="lg">
        <xsl:apply-templates/><xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="l">
        <xsl:copy-of select="normalize-space(.)"/><xsl:text>
</xsl:text>
    </xsl:template>
    
    <!-- copy the text of headings other than chapter headings -->
    <xsl:template match="head[not(parent::div[@type=('part','subpart','chapter','subchapter')])]">
        <xsl:copy-of select="normalize-space(.)"/><xsl:text>
            
</xsl:text>
    </xsl:template>
    
    
    
    
    <!-- ### IGNORE ### -->
    
    <!-- ignore the TEI header, front, back parts -->
    <xsl:template match="teiHeader | front | back"/>
        
    <!-- ignore chapter headings -->
    <xsl:template match="head[parent::div[@type=('part','subpart','chapter','subchapter')]]"/>
    
    <!-- ignore speaker names -->
    <xsl:template match="speaker"/>
    
    <!-- ignore remaining text nodes -->
    <xsl:template match="text()"/>
    
</xsl:stylesheet>