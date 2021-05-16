anticorhtml="anticor.html"
curl https://www.anticor.org/articles/ > $anticorhtml
lineNum="$(awk '/<div class="news border-style pb-4 pt-4">/{ print NR; exit}' ${anticorhtml})"
tail -n +$lineNum $anticorhtml > tmp.html
mv tmp.html $anticorhtml
lineNum="$(awk '/<\/div><div class="pagination-container initialisation"><div class="pagination"><span aria-current="page" class="page-numbers current">1<\/span>/{ print NR; exit}' ${anticorhtml})"
head -n $lineNum $anticorhtml > tmp.html
mv tmp.html $anticorhtml

# write rss
anticorrss="anticor.xml"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $anticorrss
echo "<rss version=\"2.0\">" >> $anticorrss
echo "  <channel>" >> $anticorrss
echo "    <title>Anticor</title>" >> $anticorrss
echo "    <description>Articles d'Anticor.</description>" >> $anticorrss
echo "    <language>fr-FR</language>" >> $anticorrss
echo "    <link>https://www.anticor.org/articles/</link>" >> $anticorrss

lineNum="$(awk '/<div class="news border-style pb-4 pt-4">/{ print NR; exit}' ${anticorhtml})"
tail -n +$(($lineNum+1)) $anticorhtml > tmp.html
mv tmp.html $anticorhtml
while [[ ! -z "$lineNum" ]]
do
	echo "    <item>" >> $anticorrss
	lineNum="$(awk '/<h2>/{ print NR; exit}' ${anticorhtml})"
	title="$(head -${lineNum} ${anticorhtml} | tail +${lineNum} | sed -n -e 's/^.*<h2>\(.*\)<\/h2>/\1/p')"
	echo "      <title>${title}</title>" >> $anticorrss
	lineNum="$(awk '/<a href=/{ print NR; exit}' ${anticorhtml})"
	link="$(head -${lineNum} ${anticorhtml} | tail +${lineNum} | sed -n -e 's/^.*<a href="\(.*\)">/\1/p')"
	echo "      <link>${link}</link>" >> $anticorrss
	lineNum="$(($(awk '/<strong>/{ print NR; exit}' ${anticorhtml})+2))"
	tmp="$(head -${lineNum} ${anticorhtml} | tail +${lineNum} | sed 's/^ *//g')"
	pubdate="$(echo ${tmp:2})"
	pubdate="${pubdate//janvier/Jan}"
	pubdate="${pubdate//février/Feb}"
	pubdate="${pubdate//mars/Mar}"
	pubdate="${pubdate//avril/Apr}"
	pubdate="${pubdate//mai/May}"
	pubdate="${pubdate//juin/Jun}"
	pubdate="${pubdate//juillet/Jul}"
	pubdate="${pubdate//août/Aug}"
	pubdate="${pubdate//septembre/Sep}"
	pubdate="${pubdate//octobre/Oct}"
	pubdate="${pubdate//novembre/Nov}"
	pubdate="${pubdate//décembre/Dec}"
	echo "      <pubDate>${pubdate}</pubDate>" >> $anticorrss
	lineNum="$(awk '/<p>/{ print NR; exit}' ${anticorhtml})"
	description="$(head -${lineNum} ${anticorhtml} | tail +${lineNum} | sed 's/^ *//g')"
	echo "      <description>${description}</description>" >> $anticorrss

	echo "    </item>" >> $anticorrss

	lineNum="$(awk '/<div class="news border-style pb-4 pt-4">/{ print NR; exit}' ${anticorhtml})"
	tail -n +$(($lineNum+1)) $anticorhtml > tmp.html
	mv tmp.html $anticorhtml
done

echo "  </channel>" >> $anticorrss
echo "</rss>" >> $anticorrss
rm -f $anticorhtml
