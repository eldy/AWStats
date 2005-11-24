----- README.txt about AWStats XSLT demo -----
This directory is absolutely not required to make AWStats working.
All files here are demo files you can use if you want to manipulate AWStats XML
database to build report by yourself and without using AWStats output features.


The following file describe the structure of the AWStats XML database (built
when BuildHistoryOutput is set to 'xml').
* awstats.xsd               File descriptor for AWStats xml database schema.


The following two files can be used to test a xslt processing to
transform an AWStats XML database (built when BuildHistoryOutput is set to 'xml').
into a report.
* awstats.datademo1.xml     A xml data demo file to test xslt transform with style sheet.
* awstats.datademo1.xslt    A demo xsl style sheet to transform de xml data demo file.



To build a report using this 2 files and a xslt processor, you must run the command:

xsltproc  awstats.datademo1.xslt  awstats.datademo1.xml  > output.html

