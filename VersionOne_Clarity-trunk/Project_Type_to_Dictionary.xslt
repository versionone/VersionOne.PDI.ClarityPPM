<xsl:stylesheet version="1.0" exclude-result-prefixes="msxsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="ProjectInformation">
    <Asset>
      <xsl:apply-templates select="@*|node()"/>
      <Relation name="Parent" act="set">
        <Asset idref="Scope:0"/>
      </Relation>
    </Asset>
  </xsl:template>
  <xsl:template match="lastUpdatedDate"/>
  <xsl:template match="template"/>
  <xsl:template match="*">
    <Attribute name="{name()}" act="set">
      <xsl:value-of select="text()"/>
    </Attribute>
  </xsl:template>
</xsl:stylesheet>