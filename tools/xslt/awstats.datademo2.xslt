<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="text"/>

<!-- 
	This xsl parses a awstats xml "history file" and generates a small
	plaintext report, nicely suited for cron and mail. some decisions have been
	made regarding what to display - pages or hits, etc. You are free to tweak.

	Commissioned by LabforCulture
	*pike@labforculture.org 20060708
	
	usage:	
	mail -s stats yourboss@yoursite < xsltproc thisfile.xsl database.xml
	
	build for AWSTATS DATA FILE 6.5 (build 1.857)
	
	
-->	

    <xsl:template match="/">
       	
	<xsl:for-each select="/xml/section[@id='general']/table/tr">

		<xsl:text>&#xa;----------------</xsl:text>	  

		<xsl:for-each select="td[text()='FirstTime']">
			<xsl:text>&#xa;Period			</xsl:text>

			<xsl:for-each select="./following-sibling::node()">
				<xsl:value-of select="concat(': ',substring(.,1,4),'/',substring(.,5,2),'/',substring(.,7,2))" />
			</xsl:for-each>
			<xsl:for-each select="../../tr/td[text()='LastTime']/following-sibling::node()">
				<xsl:value-of select="concat(' - ',substring(.,1,4),'/',substring(.,5,2),'/',substring(.,7,2))" />
      			</xsl:for-each>
      		</xsl:for-each>
      		
      		<xsl:for-each select="td[text()='TotalUnique']/following-sibling::node()">
			<xsl:text>&#xa;Total unique visitors	: </xsl:text>

			<xsl:value-of select="." />
		</xsl:for-each>
		
		<xsl:for-each select="td[text()='TotalVisits']/following-sibling::node()">
			<xsl:text>&#xa;Total visits		: </xsl:text>
			<xsl:value-of select="." />
		</xsl:for-each>
			
      	</xsl:for-each>
      	
      	<xsl:for-each  select="/xml/section[@id='time']/table">

		<xsl:text>&#xa;Total viewed pages	: </xsl:text><xsl:value-of select="sum(tr/td[2])" />
		<xsl:text>&#xa;Total viewed hits	: </xsl:text><xsl:value-of select="sum(tr/td[3])" />
		<xsl:text>&#xa;Total not viewed pages	: </xsl:text><xsl:value-of select="sum(tr/td[5])" />
		<xsl:text>&#xa;Total not viewed hits	: </xsl:text><xsl:value-of select="sum(tr/td[6])" />
      		
      	</xsl:for-each>
      	
		<xsl:for-each  select="/xml/section[@id='misc']/table">

			<xsl:for-each select="tr/td[text()='AddToFavourites']/following-sibling::node()[2]">
				<xsl:text>&#xa;Added to favourites (?)	: </xsl:text>
				<xsl:value-of select="." />
			</xsl:for-each>
		</xsl:for-each>

		<xsl:text>&#xa;----------------</xsl:text>	 


		<xsl:for-each  select="/xml/section[@id='session']/table">
			<xsl:text>&#xa;Visit duration:</xsl:text>

			<xsl:for-each select="tr/td[text()='0s-30s']/following-sibling::node()">
				<xsl:text>&#xa;	0s-30s		: </xsl:text>
				<xsl:value-of select="." />
			</xsl:for-each>
			<xsl:for-each select="tr/td[text()='30s-2mn']/following-sibling::node()">
				<xsl:text>&#xa;	30s-2mn		: </xsl:text>
				<xsl:value-of select="." />

			</xsl:for-each>
			<xsl:for-each select="tr/td[text()='2mn-5mn']/following-sibling::node()">
				<xsl:text>&#xa;	2mn-5mn		: </xsl:text>
				<xsl:value-of select="." />
			</xsl:for-each>
			<xsl:for-each select="tr/td[text()='5mn-15mn']/following-sibling::node()">
				<xsl:text>&#xa;	5mn-15mn	: </xsl:text>

				<xsl:value-of select="." />
			</xsl:for-each>
			<xsl:for-each select="tr/td[text()='15mn-30mn']/following-sibling::node()">
				<xsl:text>&#xa;	15mn-30mn	: </xsl:text>
				<xsl:value-of select="." />
			</xsl:for-each>		
			<xsl:for-each select="tr/td[text()='30mn-1h']/following-sibling::node()">
				<xsl:text>&#xa;	30mn-1h		: </xsl:text>

				<xsl:value-of select="." />
			</xsl:for-each>	
			<xsl:for-each select="tr/td[text()='1h+']/following-sibling::node()">
				<xsl:text>&#xa;	1h+		: </xsl:text>
				<xsl:value-of select="." />
			</xsl:for-each>
			
		</xsl:for-each>

		<xsl:text>&#xa;----------------</xsl:text>	 

		
		<xsl:for-each  select="/xml/section[@id='domain']/table">

			<xsl:text>&#xa;Countries top 5:</xsl:text>
			<xsl:for-each select="tr">
				<xsl:sort select="td[2]" data-type="number" order="descending"/>
				<xsl:if test="position()&lt;=5">
					<xsl:text>&#xa;	</xsl:text>
					<xsl:value-of select="td[1]" />
					<xsl:text>		: </xsl:text>

					<xsl:value-of select="td[2]" />
					<xsl:text> pages</xsl:text>
				</xsl:if>
			</xsl:for-each>
			
		</xsl:for-each>

		<xsl:text>&#xa;----------------</xsl:text>	 
<!-- 
	awstats xml output is seriously bugged here in my version.
	the first 10 rows of sider has 5 columns, the rest has 4 columns .. 
	the second columns content is added as plaintext inside the first column !
	
	i will wait for a fix. meanwhile, the numbers outputted
	here are dead wrong.
	

		
		<xsl:for-each  select="/xml/section[@id='sider']/table">
	
	
			<xsl:text>&#xa;Entry pages top 10 (bugged):</xsl:text>
			<xsl:for-each select="tr">
				<xsl:sort select="td[4]" data-type="number" order="descending"/>
				<xsl:if test="position()&lt;=10">
					<xsl:text>&#xa;		</xsl:text>
					<xsl:value-of select="td[4]" />
					<xsl:text>	: </xsl:text>
					<xsl:value-of select="td[1]" />
				</xsl:if>
			</xsl:for-each>
			
			<xsl:text>&#xa;Exit pages top 10 (bugged):</xsl:text>			
			<xsl:for-each select="tr[position()&lt;=10]">
				<xsl:sort select="td[5]" data-type="number" order="descending"/>
				<xsl:if test="position()&lt;=10">
					<xsl:text>&#xa;		</xsl:text>
					<xsl:value-of select="td[5]" />
					<xsl:text>	: </xsl:text>
					<xsl:value-of select="td[1]" />
				</xsl:if>
			</xsl:for-each>
					
		</xsl:for-each>
	
-->

			
	<xsl:for-each  select="/xml/section[@id='origin']/table">
		<xsl:text>&#xa;Users arrived via:</xsl:text>
		<xsl:for-each select="tr">
			<xsl:sort select="td[2]" data-type="number" order="descending"/>
			<xsl:if test="td[1]='From0'">
				<xsl:text>&#xa;	Typed in / from bookmarks		: </xsl:text>
				<xsl:value-of select="td[2]" /><xsl:text> pages</xsl:text>

			</xsl:if>
			<xsl:if test="td[1]='From1'">
				<xsl:text>&#xa;	Unknown					: </xsl:text>
				<xsl:value-of select="td[2]" /><xsl:text> pages</xsl:text>
			</xsl:if>
			<xsl:if test="td[1]='From2'">
				<xsl:text>&#xa;	Linked from an Internet Search Engine	: </xsl:text>

				<xsl:value-of select="td[2]" /><xsl:text> pages</xsl:text>
			</xsl:if>
			<xsl:if test="td[1]='From3'">
				<xsl:text>&#xa;	Linked from an external page		: </xsl:text>
				<xsl:value-of select="td[2]" /><xsl:text> pages</xsl:text>
			</xsl:if>

			<xsl:if test="td[1]='From4'">
				<xsl:text>&#xa;	Linked from an internal page		: </xsl:text>
				<xsl:value-of select="td[2]" /><xsl:text> pages</xsl:text>
			</xsl:if>
			<xsl:if test="td[1]='From5'">
				<xsl:text>&#xa;	Linked from newsgroups			: </xsl:text>

				<xsl:value-of select="td[2]" /><xsl:text> pages</xsl:text>
			</xsl:if>
			</xsl:for-each>
	</xsl:for-each>
		
	<xsl:text>&#xa;----------------</xsl:text>	 	
	
	<xsl:for-each  select="/xml/section[@id='searchwords']/table">
		<xsl:text>&#xa;Top search phrases:</xsl:text>	
		<xsl:for-each select="tr[position()&lt;=10]">

			<xsl:text>&#xa;	</xsl:text>
			<xsl:value-of select="td[1]" />
			<xsl:text> - </xsl:text>
			<xsl:value-of select="td[2]" />
			<xsl:text> hits</xsl:text>
		</xsl:for-each>

	</xsl:for-each>
	
	
	<xsl:text>&#xa;----------------</xsl:text>	 	
	
	<xsl:for-each  select="/xml/section[@id='sereferrals']/table">
		<xsl:text>&#xa;Robots/spiders:</xsl:text>	
		<xsl:for-each select="tr">
			<xsl:sort select="td[3]" data-type="number" order="descending"/>
			<xsl:if test="position()&lt;=10">
				<xsl:text>&#xa;	</xsl:text>

				<xsl:value-of select="td[1]" />
				<xsl:text> - </xsl:text>
				<xsl:value-of select="td[3]" />
				<xsl:text> hits</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:for-each>

	
	
	<xsl:text>&#xa;----------------&#xa;</xsl:text>	    

    </xsl:template>
</xsl:stylesheet>
