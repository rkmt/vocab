#!/usr/bin/ruby

# (c)2014  Jun Rekimoto
# compares your vocabulary with reference documents, 
# suggest words that you don't use in your documents.
# document types are either .txt, .tex, .pdf, .doc, and .docx
# usage:  ruby vocab.rb YOUR-DOCUMENT-DIRECTORY REFERENCE-DOCUMENT-DIRECTORY

# prerequisites
# TreeTagger 
# pdftotxt (contained in xpdf package)


$lex = "tree-tagger/cmd/tree-tagger-english"  # English lexical analysis command (tree-tagger)

# extracd verb, adverb, adjective from given file ('fname': either pdf,text,doc,tex files)
# result is added to 'hist'
def mkhist(fname, hist)
	text = nil
	if fname =~ /\.txt$/ || fname =~ /\.tex/
		text = `cat \"#{fname}\" | #{$lex}`
	elsif fname =~ /\.pdf$/
		text = `pdftotext -q \"#{fname}\" - | #{$lex}`
		print "Text size #{text.length}\n"
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
end


$suffix = "tex,txt,doc,docx,pdf"
$yourdir = nil
$refdir = nil
$numsuggest = 100

if ARGV.length == 2
	$yourdir = ARGV[0]
	$refdir = ARGV[1]
else
	print "Usage: ruby vocab.rb YOUR_DIRECTORY REFERENCE_DIRECTORY\n"
	exit
end

$yourhist = {}
$yourhist["V"] = {}
$yourhist["Ad"] = {}
$yourhist["Adv"] = {}
$yourhist["N"] = {}
yourcount = 0
Dir::glob("#{$yourdir}/**/*.{#{$suffix}}").each {|fname|
	$stderr.print "***** #{fname}\n"
	begin
 		mkhist(fname, $yourhist)
 		yourcount += 1
 	rescue
 	end
}


$yourhist_sort = {}
$yourhist.each {|part, hist|
	$yourhist_sort[part] = hist.to_a.sort{ |a, b| b[1]<=>a[1]}
	File.open("your#{part}.txt", "w") {|f| 
		$yourhist_sort[part].each {|word, occurrence|
			f.print "#{word} #{occurrence}\n"
		}
	}
}


$refhist = {}
$refhist["V"] = {}
$refhist["Ad"] = {}
$refhist["Adv"] = {}
$refhist["N"] = {}
refcount = 0
Dir::glob("#{$refdir}/**/*.{#{$suffix}}").each {|fname|
	$stderr.print ">>>>> #{fname}\n"
	begin
 		mkhist(fname, $refhist)
 		refcount += 1
 	rescue
 	end
}
$refhist_sort = {}
$refhist.each {|part, hist|
	$refhist_sort[part] = hist.to_a.sort{ |a, b| b[1]<=>a[1]}
	File.open("ref#{part}.txt", "w") {|f| 
		$refhist_sort[part].each {|word, occurrence|
			f.print "#{word} #{occurrence}\n"
		}
	}
}


File.open("suggestions.txt", "w") { |f|
	$refhist_sort.each {|part, hist|
		index = 0
		n = 0
		f.print "*** suggestions for #{part}\n"
		f.print "word ranking occurrence part\n"
		f.print "---------------------------\n"
		hist.each {|word, count|
			index += 1
			if $yourhist[part][word] == nil
				f.print "#{word} #{index} #{count} #{part}\n"
				n += 1
			end
			break if n >= $numsuggest
		}
		f.print "\n"
	}
}


printf "Your documents: %4d files ", yourcount
$yourhist.each{|part, hist| printf " %s(%4d)", part, hist.length}
print " words\n"
printf "Ref  documents: %4d files ", refcount
$refhist.each{|part, hist| printf " %s(%4d)", part, hist.length}
print " words\n"
printf "                          "
$yourhist.each{|part, hist| printf " %s  %1.2f", " "*part.length, $refhist[part].length.to_f / hist.length}
print "\n\n"

print "your{V,Ad,Adv,N}.txt: your word histgram\n"
print "ref{V,Ad,Adv}.txt: reference word histgram\n"
print "suggestions.txt: suggestions\n"


