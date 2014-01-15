#!/usr/bin/ruby

# (c)2014  Jun Rekimoto
# compares your vocabulary with reference documents, 
# suggests words that you don't use in your documents.
# document types are either .txt, .tex, .pdf, .doc, and .docx

# Usage:  ruby vocab.rb YOUR-DOCUMENT-DIRECTORY REFERENCE-DOCUMENT-DIRECTORY

# Prerequisites
# TreeTagger  http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/
# pdftotxt ( brew install xpdf )

$lex = "tree-tagger/cmd/tree-tagger-english"  # English lexical analysis command (tree-tagger)

# extracd verb, adverb, adjective from given file ('fname': either pdf,text,doc,tex files)
# result is added to 'hist'
def mkhist(fname, hist)
	text = nil
	if fname =~ /\.txt$/ || fname =~ /\.tex/
		text = `cat \"#{fname}\" | #{$lex}`
	elsif fname =~ /\.pdf$/
		text = `pdftotext -q \"#{fname}\" - | #{$lex}`
	elsif fname =~ /\.doc$/ || fname =~ /\.docx$/
		text = `textutil -stdout -convert txt \"#{fname}\" | #{$lex}`
	end
	return if text == nil

	wcount = 0
	text.each_line{ |l|
		begin
			tkn = l.split
			if tkn.length >= 3 && tkn[2] != "<unknown>"
				part = nil
				part = "V" if tkn[1] =~ /^VB/ #verb
				part = "Ad" if tkn[1] =~ /^JJ/ # adjective
				part = "Adv" if tkn[1] =~ /^RB/ # adverb
				part = "N" if tkn[1] =~ /^NN/ # noun
				part = "C" if tkn[1] =~ /^CC/ || tkn[1] =~ /^IN/ # conjunction/preposition
				if part
					word = tkn[2]   # verb base form
					hist[part][word] = 0 if hist[part][word] == nil
					hist[part][word] += 1
					wcount += 1
				end
			end
		rescue
		end
	}

	$stderr.print "#{wcount} word(s) are extracted\n\n"
	return wcount
end

$part = ["V", "Ad", "Adv", "N", "C"]

# scan directories recursively and create a word histgram
def scandir(dir)
	filecount = 0
	wordcount = 0
	hist = {}
	$part.each{|p| hist[p] = {}}
	Dir::glob("#{dir}/**/*.{tex,txt,doc,docx,pdf}").each {|fname|
		$stderr.print ">>>> #{fname}\n"
		begin
 			wordcount += mkhist(fname, hist)
 			filecount += 1
 		rescue
 		end
 	}
 	return hist, filecount, wordcount
end

# save histgram to files
def savehist(hist, name) 
	hist_sort = {}
	hist.each {|part, h|
		hist_sort[part] = h.to_a.sort{ |a, b| b[1]<=>a[1]}
		File.open("#{name}#{part}.txt", "w") {|f| 
			hist_sort[part].each {|word, occurrence|
				f.print "#{word} #{occurrence}\n"
			}
		}
	}
	return hist_sort
end

yourdir = nil
refdir = nil
numsuggest = 100

if ARGV.length == 2
	yourdir = ARGV[0]
	refdir = ARGV[1]
else
	print "Usage: ruby vocab.rb YOUR_DIRECTORY REFERENCE_DIRECTORY\n"
	exit
end

yourhist, yourcount, yourwords = scandir(yourdir)
yourhist_sort = savehist(yourhist, "your")

refhist, refcount, refwords = scandir(refdir)
refhist_sort = savehist(refhist, "ref")

# Create a suggestions file containing words that you don't use in your documents
File.open("suggestions.txt", "w") { |f|
	refhist_sort.each {|part, hist|
		index = 0
		n = 0
		f.print "*** suggestions for #{part}\n"
		f.print "word ranking occurrence part\n"
		f.print "---------------------------\n"
		hist.each {|word, count|
			index += 1
			if yourhist[part][word] == nil
				f.print "#{word} #{index} #{count} #{part}\n"
				n += 1
			end
			break if n >= numsuggest
		}
		f.print "\n"
	}
}

printf "Yours: %4d files ", yourcount
yourhist.each{|part, hist| printf " %s(%4d)", part, hist.length}
print "\n"
printf "Ref  : %4d files ", refcount
refhist.each{|part, hist| printf " %s(%4d)", part, hist.length}
print " \n"
printf "Ref/Yours:       "
yourhist.each{|part, hist| printf " %s  %1.2f", " "*part.length, refhist[part].length.to_f / hist.length}
print "\n\n"

print "your{#{$part.join(',')}}.txt: your word histgram\n"
print "ref{#{$part.join(',')}}.txt: reference word histgram\n"
print "suggestions.txt: suggestions\n"
