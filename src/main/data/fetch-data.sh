#!/bin/sh -x
USER_AGENT="Mozilla/5.0 (Windows NT 5.2; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"

for bookid in 4300 5000 20417
do
	wget -c o pg$bookid.txt http://www.gutenberg.org/cache/epub/$bookid/pg$bookid.txt \
	--referer="http://www.google.com" \
	--user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6" \
	--header="Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5" \
	--header="Accept-Language: en-us,en;q=0.5" \
	--header="Accept-Encoding: gzip,deflate" \
	--header="Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7" \
	--header="Keep-Alive: 300"
done

# or download all german books from the site
# wget -w 2 -m -H "http://www.gutenberg.org/robot/harvest?filetypes[]=html&langs[]=de"