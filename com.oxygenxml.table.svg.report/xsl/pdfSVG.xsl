<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    version="2.0">
    
    <xsl:import href="tableToSVGReport.xsl"/>
    
    <xsl:template match="*[contains(@class, ' topic/table ')][contains(@outputclass, 'embed-svg-report')]" priority="10">
        <fo:block>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
            <fo:instream-foreign-object>
                <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]" mode="embed-svg-report"/>
            </fo:instream-foreign-object>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>