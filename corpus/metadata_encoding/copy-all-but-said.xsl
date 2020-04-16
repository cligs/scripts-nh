<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
        @author: Ulrike Henny-Krahmer
        
        With this script, the encoding of direct speech in the novels is prepared as far as possible.
        
        How to call the script (for an individual file):
        java -jar saxon9he.jar /home/ulrike/Git/conha19/tei/nh0001.xml /home/ulrike/Git/scripts-nh/corpus/metadata_encoding/copy-all-but-said.xsl > /home/ulrike/Git/conha19/out.xml
    -->
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <!-- apply templates of the different modes ("first" marks all paragraphs beginning with a speech sign as direct speech, 
            "second-a" refines the encoding, "second-b" is a variant doing the same, and so on) -->
        <xsl:apply-templates mode="second-b" select="."/>
    </xsl:template>
    
    
    <!-- copy everything from the source document to the output document,
    change the mode to the current one here, as well -->
    <xsl:template match="node() | @* | comment() | processing-instruction()" mode="second-b">
        <xsl:copy>
            <xsl:apply-templates select="node() | @* | comment() | processing-instruction()" mode="second-b"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- all paragraphs beginning with a speech sign are marked as direct speech -->
    <xsl:template match="p[not(said)][starts-with(.,'—')]" mode="first"><!-- the sign indicating speech may have to be changed from novel to novel -->
        <p xmlns="http://www.tei-c.org/ns/1.0">
            <said xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates/>
            </said>
        </p>
    </xsl:template>
    
    <!-- ##### second a ##### -->
    
    <!-- covers cases like:
        <p><said>—¡Qué linda! ¡qué linda!—repetí embelesado.</said></p>
        
        Works only if there are no further child nodes inside of <said>.
    -->
    <xsl:template match="p/said[not(child::*)][matches(.,'^—[^—]+—[^—]+$')]" mode="second-a">
        <said xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="replace(.,'(^—[^—]+)—[^—]+$','$1')"/></said><xsl:value-of select="replace(.,'^—[^—]+(—[^—]+$)','$1')"/>
    </xsl:template>
    
    
    
    <!-- covers cases like:
        <p><said>—¡Quién sabe...! — suspiró. — ¿Quieres creer una cosa, Daniel? No sé por
                        qué me figuro que yo no he nacido para ser feliz.</said></p>
                        
         Works only if there are no further child nodes inside of <said>.
    -->
    <xsl:template match="p/said[not(child::*)][matches(.,'^—[^—]+—[^—]+—[^—]+$')]" mode="second-a">
        <said xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="replace(.,'(^—[^—]+)—[^—]+—[^—]+$','$1')"/></said><xsl:value-of select="replace(.,'^—[^—]+(—[^—]+)—[^—]+$','$1')"/><said xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="replace(.,'^—[^—]+—[^—]+(—[^—]+$)','$1')"/></said>
    </xsl:template>
    
    
    <!-- covers cases like:
        <p><said>—¡Ay! sí—exclamó Adoración lanzando un suspiro.—¡Hemos llorado tanto...!
                        Pero bien, escucha.—Me tomó las manos y empezó a hablarme muy bajito, con
                        aquel acento cariñoso y dulce que aún recuerdo hoy con lágrimas en los
                        ojos.</said></p>
                        
         Works only if there are no further child nodes inside of <said>.
    -->
    <xsl:template match="p/said[not(child::*)][matches(.,'^—[^—]+—[^—]+—[^—]+—[^—]+$')]" mode="second-a">
        <said xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="replace(.,'(^—[^—]+)—[^—]+—[^—]+—[^—]+$','$1')"/></said><xsl:value-of select="replace(.,'^—[^—]+(—[^—]+)—[^—]+—[^—]+$','$1')"/><said xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="replace(.,'^—[^—]+—[^—]+(—[^—]+)—[^—]+$','$1')"/></said><xsl:value-of select="replace(.,'^—[^—]+—[^—]+—[^—]+(—[^—]+$)','$1')"/>
    </xsl:template>
    
    
    
    <!-- ##### second b ##### -->
    
    <!-- covers cases like:
        <p>
            <said>—¿Ha venido ya? preguntóle en voz baja.</said>
        </p>
        <p>
            <said>—Aún no, contestó el criado con una respetuosa cortesía.</said>
        </p>
        
        Works only if there are no further child nodes inside of <said>.
    -->
    
    <xsl:template match="p/said[not(child::*)][matches(.,'^—[^—]+\s(agregó|añadió|concluyó|contestó|continuó|dijo|exclamó|gimió|gritó|insinuó|insistió|interpuso|interrumpió|murmuró|observó|pensó|preguntó|prorrumpió|prosiguió|refunfuñó|repitió|replicó|repuso|respondió|siguió|suplicó)[^—]+$')]" mode="second-b">
        <said xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="replace(.,'(^—[^—]+)\s(agregró|añadió|concluyó|contestó|continuó|dijo|exclamó|gimió|gritó|insinuó|insistió|interpuso|interrumpió|murmuró|observó|pensó|preguntó|prorrumpió|prosiguió|refunfuñó|repitió|replicó|repuso|respondió|siguió|suplicó)[^—]+$','$1')"/></said>
        <xsl:value-of select="replace(.,'^—[^—]+(\s(agregó|añadió|concluyó|contestó|continuó|dijo|exclamó|gimió|gritó|insinuó|insistió|interpuso|interrumpió|murmuró|observó|pensó|preguntó|prorrumpió|prosiguió|refunfuñó|repitió|replicó|repuso|respondió|siguió|suplicó)[^—]+$)','$1')"/>
    </xsl:template>
    
    
</xsl:stylesheet>