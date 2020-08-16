<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        @author: Ulrike Henny-Krahmer
        
        With this script, the encoding of direct speech in the novels is prepared,
        relying on typographical speech signs.
        
        The script differentiates between single and double speech marks. Speech is encoded on 
        a paragraph basis. For single marks, only paragraphs beginning with them are marked 
        as direct speech. For double marks, all stretches surrounded by them are marked as 
        speech, independently of their position in the paragraph. Only one principal speech sign 
        is evaluated per novel.
        
        How to call the script 
        - for an individual file:
        java -jar /home/ulrike/Programme/saxon/saxon9he.jar /home/ulrike/Git/conha19/tei/nh0001.xml /home/ulrike/Git/scripts-nh/corpus/metadata_encoding/copy-all-but-said.xsl > /home/ulrike/Git/conha19/tei_ds/nh0025.xml
        - for a whole collection of files:
        java -jar /home/ulrike/Programme/saxon/saxon9he.jar -s:/home/ulrike/Git/conha19/tei -o:/home/ulrike/Git/conha19/tei_new -xsl:/home/ulrike/Git/scripts-nh/corpus/metadata_encoding/copy-all-but-said.xsl
    -->
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <!-- get the main speech sign of this novel -->
    <xsl:variable name="speech-sign" select="//term[@type='text.speech.sign']"/>
    <!-- opening speech sign -->
    <xsl:variable name="sp_op">
        <xsl:choose>
            <xsl:when test="$speech-sign = '—'">—</xsl:when>
            <xsl:when test="$speech-sign = '«'">«</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <!-- closing speech sign -->
    <xsl:variable name="sp_cl">
        <xsl:choose>
            <xsl:when test="$speech-sign = '—'">—</xsl:when>
            <xsl:when test="$speech-sign = '«'">»</xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <!-- call different templates depending of the speech sign -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$speech-sign = '—'">
                <xsl:apply-templates mode="single" select="."/>
            </xsl:when>
            <xsl:when test="$speech-sign = '«'">
                <xsl:apply-templates mode="double" select="."/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- copy everything from the source document to the output document -->
    <xsl:template match="node() | @* | comment() | processing-instruction()" mode="single">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()" mode="single"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @* | comment() | processing-instruction()" mode="double">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()" mode="double"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ##################### single marks ###################### -->
    
    <xsl:template match="p[matches(.,concat('^(',$speech-sign,'[^',$speech-sign,']+)+$'))]" mode="single">
        <xsl:variable name="num-parts" select="count(tokenize(.,$speech-sign))"/>
        <p><xsl:for-each select="tokenize(.,$speech-sign)">
                <xsl:choose>
                    <!-- speech part -->
                    <xsl:when test="position() = 1"/>
                    <xsl:when test="position() = 2">
                        <said><xsl:value-of select="$speech-sign"/><xsl:copy-of select="."/></said>
                    </xsl:when>
                    <xsl:when test="(position() > 2) and (position() mod 2 = 0)">
                        <said><xsl:copy-of select="."/></said>
                    </xsl:when>
                    <!-- narrative part -->
                    <xsl:when test="(position() > 2) and (position() mod 2 != 0) and (position() &lt; $num-parts)">
                        <xsl:value-of select="$speech-sign"/><xsl:copy-of select="."/><xsl:value-of select="$speech-sign"/>
                    </xsl:when>
                    <xsl:when test="(position() > 2) and (position() mod 2 != 0) and (position() = $num-parts)">
                        <xsl:value-of select="$speech-sign"/><xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>ERROR</xsl:otherwise>
                </xsl:choose>
        </xsl:for-each></p>
    </xsl:template>
    
    
    <!-- ##################### double marks ###################### -->
    
    <xsl:template match="p[matches(.,concat('^([^',$sp_op,$sp_cl,']+)?(',$sp_op,'[^',$sp_op,$sp_cl,']+',$sp_cl,'([^',$sp_op,$sp_cl,']+)?)+$'))]" mode="double">
        <p><xsl:copy-of select="replace(.,concat('^([^',$sp_op,$sp_cl,']+)?(',$sp_op,'[^',$sp_op,$sp_cl,']+',$sp_cl,'([^',$sp_op,$sp_cl,']+)?)+$'),'$1')"/><xsl:for-each select="tokenize(.,$sp_op)">
            <xsl:if test="position() != 1">
                <said><xsl:value-of select="$sp_op"/><xsl:copy-of select="replace(.,concat('(^[^',$sp_op,$sp_cl,']+',$sp_cl,')([^',$sp_op,$sp_cl,']+)?'),'$1')"/></said><xsl:copy-of select="replace(.,concat('^[^',$sp_op,$sp_cl,']+',$sp_cl,'([^',$sp_op,$sp_cl,']+)?'),'$1')"/>
            </xsl:if>
            </xsl:for-each></p>
    </xsl:template>
    
    
    
</xsl:stylesheet>