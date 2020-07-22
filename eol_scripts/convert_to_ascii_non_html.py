#!/usr/bin/python
# ***************************************************************
# Name:     parse_json.py
#           
# Purpose:  This scripts takes a list of unique EOL Taxa Ids
#           and retrieves all the EOL Text clauses available for that species
# Output:   a tab separated file of the format:
#           Taxon EOL ID\t Text
#           
# Version:   1.1
#           
# Authors:  Evangelos Pafilis (vagpafilis@gmail.com, http://epafilis.info)
#           Hellenic Center for Marine Research, Greece
#
#           Lars Juhl Jensen (lars.juhl.jensen@cpr.ku.dk)
#           Novo Nordisk Foundation - Center for Protein Research, Denmark
#
#           Sune Pletscher-Frankild (sune.frankild@cpr.ku.dk)
#           Novo Nordisk Foundation - Center for Protein Research, Denmark
#
# Usage:    ./convert_to_ascii_non_html.py eol_documents_utf8_html.tsv
#
#
# Created:  2013-Mar-21
# Modified: 2013-May-02
#           
# License:  CC-BY-NC-SA
#           
# **************************************************************/     

import sys
import unidecode # Custom lib installed on green.
import HTMLParser
import htmlentitydefs



# Based on code from: http://stackoverflow.com/questions/753052
class HTMLTextExtractor(HTMLParser.HTMLParser):
	
	def __init__(self):
		HTMLParser.HTMLParser.__init__(self)
		self.result = [ ]

	def handle_data(self, d):
		self.result.append(d)

	def handle_charref(self, number):
		codepoint = int(number[1:], 16) if number[0] in (u'x', u'X') else int(number)
		self.result.append(unichr(codepoint))

	def handle_entityref(self, name):
		try:
			codepoint = htmlentitydefs.name2codepoint[name]
			self.result.append(unichr(codepoint))
		except KeyError:
			self.result.append(u"#")

	def get_text(self):
		return u"".join(self.result)


def html_to_text(html):
	s = HTMLTextExtractor()
	s.feed(html)
	return s.get_text()

if __name__ == "__main__":
	filename = sys.argv[1]
	
	ERROR = open("eol_parse_log.tsv", "w")
	OUT   = open("eol_documents_ascii_nonHTML.tsv", "w")
	
	line_counter = 0
	error_counter = 0
	with open(filename) as f:
		for line in f:
			
			line_counter += 1
			if line_counter % 100000 == 0:
				print "Line:", line_counter
				
			line = unicode(line, "utf8", "replace")
			try:
				OUT.write(unidecode.unidecode(html_to_text(line)))
			except Exception, e:
				error_counter += 1
				print "Error: ", error_counter, ", line: ", line_counter, "\t", line[0:14], "\t", str(e)
				ERROR.write("Error: " + str(error_counter) + ", line: " + str(line_counter) + "\t" + line[0:14] + "\t" + str(e) + "\n")
				
			
	ERROR.close
	OUT.close
