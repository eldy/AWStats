<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:template match="/">
        <html>
            <head />
            <body>
                <br />
                <xsl:for-each select="xml">
                    <br />
                    <xsl:for-each select="version">
                        <xsl:for-each select="lib">
                            <xsl:apply-templates />
                        </xsl:for-each>
                    </xsl:for-each>
                    <br />
                    <br />
                    <xsl:for-each select="section">
                        <xsl:for-each select="@id">
                            <xsl:value-of select="." />
                        </xsl:for-each>
                        <p>
                            <xsl:for-each select="table">
                                <xsl:for-each select="tr">
                                    <xsl:for-each select="td">
                                        <xsl:apply-templates />&#160;</xsl:for-each>
                                    <br />
                                </xsl:for-each>
                                <br />
                            </xsl:for-each>
                        </p>
                    </xsl:for-each>
                    <br />
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
