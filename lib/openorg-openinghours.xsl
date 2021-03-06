<?xml version="1.0" encoding='utf-8'?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://purl.org/openorg/grinder/ns/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:gr="http://purl.org/goodrelations/v1#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:spatialrelations="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
    xmlns:oo="http://purl.org/openorg/">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />

  <xsl:variable name='base-pos-uri' select='/g:grinder-data/g:set[@name="base-pos-uri"]' />
  <xsl:variable name='base-offers-uri' select='/g:grinder-data/g:set[@name="base-offers-uri"]' />
  <xsl:variable name='base-building-uri' select='/g:grinder-data/g:set[@name="base-building-uri"]' />

  <xsl:variable name='valid-from' select='/g:grinder-data/g:set[@name="VALID_FROM"]' />
  <xsl:variable name='valid-through' select='/g:grinder-data/g:set[@name="VALID_THROUGH"]' />
  <xsl:variable name='timezone' select='/g:grinder-data/g:set[@name="TIMEZONE"]' />

  <xsl:template match="/g:grinder-data">
    <rdf:RDF>
      <xsl:comment>TOP</xsl:comment>
      <xsl:apply-templates select="g:row" /> 
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="g:row">
    <xsl:variable name='uri' select='concat( $base-pos-uri , string(g:code) )' />
    <rdf:Description rdf:about="{$uri}">
      <rdf:type rdf:resource="http://purl.org/goodrelations/v1#LocationOfSalesOrServiceProvisioning" />
      <xsl:apply-templates />
    </rdf:Description>
    <xsl:for-each select="*">
      <xsl:if test="substring( name(.), 1, 7 ) = 'offers-'">
        <rdf:Description rdf:about="{$base-offers-uri}{substring( name(.), 8 )}">
          <rdf:type rdf:resource="http://purl.org/goodrelations/v1#Offering" />
          <gr:availableAtOrFrom rdf:resource="{$uri}" />
        </rdf:Description>
      </xsl:if> 
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="g:name">
    <rdfs:label><xsl:value-of select="string(.)"/></rdfs:label>
  </xsl:template>
  
  <xsl:template match="g:building">
    <spatialrelations:within rdf:resource='{$base-building-uri}{string(.)}' />
  </xsl:template>

  <xsl:template match="g:mon"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Monday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:tue"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Tuesday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:wed"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Wednesday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:thu"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Thursday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:fri"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Friday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:sat"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Saturday</xsl:with-param>
  </xsl:call-template></xsl:template> 
  <xsl:template match="g:sun"><xsl:call-template name="open-hours-spec">
    <xsl:with-param name="day">Sunday</xsl:with-param>
  </xsl:call-template></xsl:template> 

  <xsl:template name="open-hours-spec">
    <xsl:param name="day"/>
    <gr:hasOpeningHoursSpecification>
      <rdf:Description rdf:about="{$base-pos-uri}{string(../g:code)}#{$day}-{string(.)}-{$valid-from}">
        <rdf:type rdf:resource="http://purl.org/goodrelations/v1#OpeningHoursSpecification" />
        <gr:opens rdf:datatype="http://www.w3.org/2001/XMLSchema#time">
          <xsl:value-of select="concat( substring(string(.),1,2), ':', substring(string(.),3,2), ':00' )"/>
        </gr:opens>
        <gr:closes rdf:datatype="http://www.w3.org/2001/XMLSchema#time">
          <xsl:value-of select="concat( substring(string(.),6,2), ':', substring(string(.),8,2), ':00' )"/>
        </gr:closes>
        <gr:hasOpeningHoursDayOfWeek rdf:resource="http://purl.org/goodrelations/v1#{$day}" />
        <gr:validFrom rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
          <xsl:value-of select="concat( $valid-from, 'T00:00:00', $timezone )" />
        </gr:validFrom>
        <gr:validThrough rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
          <xsl:value-of select="concat( $valid-through, 'T23:59:59', $timezone )" />
        </gr:validThrough>
      </rdf:Description>
    </gr:hasOpeningHoursSpecification>
  </xsl:template>

  <xsl:template match="*" priority="-1">
     <!--<xsl:value-of select="concat( name(.), ':', string(.) )" />-->
  </xsl:template>

</xsl:stylesheet>
