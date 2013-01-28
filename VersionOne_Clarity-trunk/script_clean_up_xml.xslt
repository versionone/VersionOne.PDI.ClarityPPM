<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="Asset[Attribute[@name='AssetType']]">
    <xsl:element name="{Attribute[@name='AssetType']}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="Attribute[@name='AssetType']"/>
  <xsl:template match="Attribute">
    <xsl:element name="{@name}">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="Relation">
    <xsl:element name="{@name}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="@name"/>
</xsl:stylesheet>
