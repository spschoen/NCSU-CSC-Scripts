<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="yes"/>
    
<xsl:template match="checkstyle">
    <html>
    <body>
    <h2>Style Guideline Errors</h2>
    <table border="1">
        <tr style="page-break-inside: avoid;">
            <th>Line</th>
            <th>Column</th>
            <th>Message</th>
        </tr>
        <xsl:for-each select="file/error">
        <tr style="page-break-inside: avoid;">
            <td><xsl:value-of select="@line"/></td>
            <td><xsl:value-of select="@column"/></td>
            <td><xsl:value-of select="@message"/></td>
        </tr>
        </xsl:for-each>
    </table>
    </body>
    </html>
</xsl:template>

</xsl:stylesheet> 
