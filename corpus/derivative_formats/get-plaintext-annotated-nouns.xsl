<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        
    @author: Ulrike Henny-Krahmer
    
    This script produces a plain text version of a single TEI corpus file, 
    based on the version annotated with FreeLing. Only nouns are kept and named entities are replaced.
        
    How to call the script (to process the whole corpus):
    java -jar /home/ulrike/Programme/saxon/saxon9he.jar -s:/home/ulrike/Git/conha19/annotated/ -o:/home/ulrike/Git/conha19/txt_annotated_nouns/ -xsl:/home/ulrike/Git/scripts-nh/corpus/derivative_formats/get-plaintext-annotated-nouns.xsl
   
    -->
    
    <xsl:strip-space elements="*"/>
    
    <xsl:output method="text" media-type="text/plain" encoding="UTF-8"/>
    
    <!-- ### COPY ### -->
   
    <!-- insert blank line for paragraph boundaries -->
    <xsl:template match="p">
        <xsl:apply-templates/><xsl:text>
            
</xsl:text>
    </xsl:template>
    
    <!-- copy word text of nouns -->
    <xsl:template match="w[@pos='noun']">
        <xsl:value-of select="."/><xsl:text> </xsl:text>
    </xsl:template>
    
    
    <!-- ### IGNORE ### -->
    <!-- ignore proper nouns -->
    <xsl:template match="w[@pos='noun'][@type='proper']" priority="1"/>
    
    <!-- ignore the TEI header, front, back parts, and words that are not nouns -->
    <xsl:template match="teiHeader | front | back | w[@pos!='noun']"/>
    
</xsl:stylesheet>