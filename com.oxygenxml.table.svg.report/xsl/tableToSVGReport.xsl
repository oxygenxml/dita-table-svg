<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2000/svg" exclude-result-prefixes="xs">    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="axisPadding" select="xs:integer('100')" as="xs:integer"/>
    <xsl:variable name="axisXPadding" select="xs:integer('20')" as="xs:integer"/>
    <xsl:variable name="svgWidth" select="xs:integer('1000')" as="xs:integer"/>
    <xsl:variable name="graphWidth" select="$svgWidth - $axisXPadding - 100" as="xs:integer"/>    
    <xsl:variable name="svgHeight" select="xs:integer('500')" as="xs:integer"/>
    <xsl:variable name="graphHeight" select="$svgHeight - $axisPadding" as="xs:integer"/>    
    <xsl:variable name="numberHeaderColumns" select="xs:integer(1)" as="xs:integer"/>
    <xsl:variable name="colors" select="('red', 'green', 'blue', 'orange', 'purple', 'pink', 'brown', 'black')"/>
    
    <!--Insert ticks on the horizontal axis-->
    <xsl:template name="InsertHorizontalTick">
        <xsl:param name="index" select="1"/>
        <xsl:param name="interval" select="1"/>
        <xsl:param name="count" select="1"/>
        
        <xsl:if test="$index &lt;= $count - 1">
            <line class="strokeAxis" x1="{$axisXPadding + $index * $interval}" x2="{$axisXPadding + $index * $interval}" 
                y1="{$graphHeight - 5}"
                y2="{$graphHeight}"/>
            <line class="strokeAxis" x1="{$axisXPadding + $index * $interval}" x2="{$axisXPadding + $index * $interval}" 
                y1="0"
                y2="{$graphHeight}" stroke-dasharray="1 8"/>
            <xsl:call-template name="InsertHorizontalTick">
                <xsl:with-param name="index" select="$index + 1" />
                <xsl:with-param name="count" select="$count" />
                <xsl:with-param name="interval" select="$interval" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- Insert ticks on the vertical axis -->
    <xsl:template name="InsertVerticalTick">
        <xsl:param name="index" select="1"/>
        <xsl:param name="interval" select="1"/>
        <xsl:param name="intervalTable" select="1"/>
        <xsl:param name="count" select="1"/>
        
        <xsl:if test="$index &lt;= $count">
            <text x="{$axisXPadding}" y="{$graphHeight - $index * $interval - 2}" class="ticksFont">
                <xsl:value-of select="$index * $intervalTable"/>
            </text>
            <line class="strokeAxis" x1="{$axisXPadding}" x2="{$axisXPadding + 10}" 
                y1="{$graphHeight - $index * $interval}"
                y2="{$graphHeight - $index * $interval}"></line>
            <xsl:call-template name="InsertVerticalTick">
                <xsl:with-param name="index" select="$index + 1" />
                <xsl:with-param name="count" select="$count" />
                <xsl:with-param name="interval" select="$interval" />
                <xsl:with-param name="intervalTable" select="$intervalTable" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- Convert a DITA tgroup to an SVG -->
    <xsl:template match="tgroup" mode="embed-svg-report">
        <svg height="{$svgHeight}" width="{$svgWidth}">
            <style type="text/css">
                .textFont{
                    font-size:20px;
                    font-family:Dialog;
                    color:black;
                }
                .dotTextFont{
                    font-size:12px;
                    font-family:Dialog;
                    color:gray;
                    stroke:gray;
                }
                .ticksFont{
                    font-size:15px;
                    font-family:Dialog;
                    font-style:italic;
                    color:black;
                }
                .strokeAxis {
                    stroke-width:2; 
                    stroke:black;
                }
                .graphStroke {
                    stroke-width:2; 
                }
            </style>
            <g transform="translate(0,20)">
                <xsl:variable name="numberColumns" select="count(thead/row/entry)" as="xs:integer"/>
                <xsl:variable name="intervalsBetweenCols" select="$graphWidth div $numberColumns" as="xs:double"/>
                <!-- The x and y axes  -->
                <line class="strokeAxis" x1="{$axisXPadding}" x2="{$graphWidth}" y1="{$graphHeight}" y2="{$graphHeight}"></line>
                <line class="strokeAxis" x1="{$axisXPadding}" x2="{$axisXPadding}" y1="{$graphHeight}" y2="0"></line>
                
                <xsl:variable name="maxValue" select="max(tbody/row/entry[text() castable as xs:double])" as="xs:double"/>
                <xsl:variable name="closestNumberEndingWithZero" select="xs:integer($maxValue + (10 - $maxValue mod 10) mod 10)" as="xs:integer"/>
                <xsl:variable name="interval" select="$graphHeight div 10"/>
                <xsl:variable name="intervalTable" select="$closestNumberEndingWithZero div 10"/>
                <xsl:variable name="graphHeightOverMax" select="$graphHeight div $closestNumberEndingWithZero" as="xs:double"/>
                
                <!-- Insert vertical ticks -->
                <xsl:call-template name="InsertVerticalTick">
                    <xsl:with-param name="count" select="10" />
                    <xsl:with-param name="interval" select="$interval" />
                    <xsl:with-param name="intervalTable" select="$intervalTable" />
                </xsl:call-template>
                
                <!-- Insert horizontal ticks -->
                <xsl:call-template name="InsertHorizontalTick">
                    <xsl:with-param name="count" select="$numberColumns" />
                    <xsl:with-param name="interval" select="$graphWidth div $numberColumns" />
                </xsl:call-template>
                
                <!-- Add text on the horizontal axis for each column -->
                <xsl:for-each select="thead/row/entry">
                    <xsl:variable name="position" select="position()"/>
                    <xsl:if test="$position != 1">
                        <text x="{($position - 1) * $intervalsBetweenCols}" y="{$svgHeight - $axisPadding + 20}" 
                            class="textFont">
                            <xsl:value-of select="."/>
                        </text>
                    </xsl:if>
                </xsl:for-each>
                <!-- Plot for each line the header text -->
                <xsl:if test="$numberHeaderColumns > 0">
                    <xsl:for-each select="tbody/row">
                        <xsl:variable name="position" select="position()"/>
                        <text x="{$svgWidth - 200}" y="{$position * 20 + 10}" class="textFont">
                            <xsl:value-of select="entry[1]"/>
                        </text>
                        <line x1="{$svgWidth - 225}"
                            y1="{$position * 20 + 2}"
                            x2="{$svgWidth - 210}"
                            y2="{$position * 20 + 2}"
                            stroke="{$colors[$position]}" class="graphStroke"
                        />
                    </xsl:for-each>
                </xsl:if>
                <!-- Plot for each line the graph -->
                <xsl:for-each select="tbody/row">
                    <xsl:variable name="rowPosition" select="position()"/>
                    <xsl:for-each select="entry">
                        <xsl:if test="position() > (1 + $numberHeaderColumns)">
                            <xsl:variable name="previousValue" select="xs:double(preceding-sibling::entry[1]/text())"/>
                            <xsl:variable name="currentValue" select="xs:double(text())"/>
                            <xsl:variable name="position" select="position()"/>
                            <line x1="{$axisXPadding + ($position - 2) * $intervalsBetweenCols}"
                                y1="{$graphHeight - $previousValue * $graphHeightOverMax}"
                                x2="{$axisXPadding + ($position - 1) * $intervalsBetweenCols}"
                                y2="{$graphHeight - $currentValue * $graphHeightOverMax}"
                                stroke="{$colors[$rowPosition]}" class="graphStroke"
                            />
                            <text x="{$axisXPadding + ($position - 2) * $intervalsBetweenCols}"
                                y="{$graphHeight - $previousValue * $graphHeightOverMax - 2}" class="dotTextFont">
                                <xsl:value-of select="$previousValue"/></text>
                            <text x="{$axisXPadding + ($position - 1) * $intervalsBetweenCols}"
                                y="{$graphHeight - $currentValue * $graphHeightOverMax - 2}" class="dotTextFont">
                                <xsl:value-of select="$currentValue"/></text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </g>
        </svg>
    </xsl:template>
    
    
</xsl:stylesheet>
