<xsl:stylesheet 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:yweather="http://xml.weather.yahoo.com/ns/rss/1.0" version="1.0">

        <xsl:output indent="yes" method="xml" encoding="UTF-8" omit-xml-declaration="yes" />

        <xsl:template match="/">
                <xsl:text>Ville : </xsl:text>
                <xsl:value-of select="//yweather:location/@city" />
                <xsl:text>
Condition aujourd'hui : </xsl:text>
                <xsl:value-of select="//item/yweather:condition/@text" />
                <xsl:text>
Code : </xsl:text>
                <xsl:value-of select="//item/yweather:condition/@code" />
                <xsl:text>
Levé de soleil : </xsl:text>
                <xsl:value-of select="//yweather:astronomy/@sunrise" />
                <xsl:text>
Couché de soleil : </xsl:text>
                <xsl:value-of select="//yweather:astronomy/@sunset" />
                <xsl:text>
Température : </xsl:text>
                <xsl:value-of select="//item/yweather:condition/@temp" />
        </xsl:template>

</xsl:stylesheet>
