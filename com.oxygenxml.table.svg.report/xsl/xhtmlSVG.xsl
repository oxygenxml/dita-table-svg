<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Table to SVG sample conversion plugin
Copyright (c) 1998-2019 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file LICENSE 
available in the base directory of this plugin.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  
  <xsl:import href="tableToSVGReport.xsl"/>
  
  <xsl:template match="*[contains(@class, ' topic/table ')][contains(@outputclass, 'embed-svg-report')]" priority="10">
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]" mode="embed-svg-report"/>
    </div>
  </xsl:template>
</xsl:stylesheet>