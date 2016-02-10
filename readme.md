see original description at: http://d.hatena.ne.jp/rkmt/20140114/1389687306

■ 自分の英語文書をマイニングして次に学ぶべき単語リストを自動生成する方法(暦本式語彙増強法)

英単語の語彙をどうやって増やしたらいいだろうか。やみくもに単語集みたいなものを順に覚えていくのも道程が長そうだ。また、一般論ではなく自分がよく書く分野に特化して語彙を増やしたい。ということで、テキストマイニングを使ってやる方法を考えてみた。方針は以下の通りである：

自分が今までに書いたすべての（英語）の文書を解析して、品詞ごとに出現回数でソートする。
つぎに、自分の所属するコミュニティの文書（たとえば自分がよく参加する学会に掲載される論文など）をなるべく大量にあつめて、同じように品詞ごとに出現回数でソートしておく。
両者を比較して、そのコミュニティでは使用頻度が高いにも関わらず、まだ使ったことのない単語を抽出して自分専用の「単語集」をつくる。
こうやって抽出された単語集を勉強すれば、一般的な単語集を使うよりも効率がいいのではないだろうかという目論みだ。対象となる分野を選んでいるのは、たとえば情報科学で使われる単語と、政治学で使われる単語は傾向も違うだろうから、なるべく自分が書きそうな分野の語彙を増やすのが得策ではないかと考えたわけだ。

実際にやってみた。実現は簡単なrubyスクリプトと、既存のTextTaggerという形態素解析(品詞解析)ソフトとの組み合わせである。インストール方法は後述する。

同じファイルが異なる形式で保存されている場合も構わず調査対象としていたり、PDFをテキストにしたときに正しくテキストが抽出されていない場合もあるので、マイニングの精度はまだ未検証だが、 私の全論文テキスト（LaTeXだったりwordだったりPDFだったり）から抽出された動詞、形容詞、副詞、名詞と、学会（2013年のCHI, UIST, ISWC, ITS, Ubicomp の電子予稿集に含まれているファイル）から抽出された動詞、形容詞、副詞、名詞の数と比率は以下のようだった：

動詞	形容詞	副詞	名詞
自分の文書	1467	1857	548	3750
参照文書	4123	6704	1596	12618
参照/自分	2.81	3.61	2.91	3.36
意外だったのは、形容詞の語彙数が、自分と学会論文全体とで結構開いていること(3.61倍)。名詞よりも開きが大きい。ということは、形容詞をより集中的に勉強して差を縮めると、もっと表現力のある英文が書けるようになるかもしれないということだろうか。

上位にくる単語はだいたい予想通りの感じになっている：

動詞(自分):	be, use, have, sense, show, ...
動詞(参照):	be, use, have, do, provide, ...
形容詞(自分):	such, other, physical, tactile, mobile, ...
形容詞(参照):	such, other, different, social, mobile, ...
副詞(自分):	also, not, as, however, more, ...
副詞(参照):	not, also, as, more, however, ...
名詞(自分):	device, user, system, information, example, ...
名詞(参照):	user, participant, system, design, time, ...
さて、このようにして抽出された「私が使っていないが私が関係する分野での使用頻度が高い」単語集は、以下のようになった。見るとそんなには難しい単語がないので自分の語彙がないことを露呈している感じだが...

動詞：

validate, impact, fund, analyse, uncover, debug, maximize, mitigate, earn, quantify, outperform, replicate, customize, empower, forage, contrast, recognise, discard, tackle, craft, ...
※ analyse, recognise は、それぞれ analyze, recognize を使うようにしているからだろう。ちなみにvalidateは参照文書中のランキングでは352位。

形容詞：

mean, domestic, false, persuasive, challenging, ethical, demographic, inherent, fine-grained, median, comprehensive, playful, reflective, salient, semi-structured, user-defined, longitudinal, interpersonal, narrative, ethnographic, ...
※ なんと統計の基本用語であるmeanとかmedianを使っていない.. 語彙力というよりも定量的ユーザー評価をしない論文ばかり書いているのがばれてしまっている..

副詞：

interestingly, empirically, critically, truly, emotionally, Nonetheless, seemingly, apparently, last, nowadays, aloud, accidentally, quantitatively, upwards, subjectively, progressively, marginally, aesthetically, severely, ...
※ 興味深いことに、interestinglyを使ったことがないらしい。

名詞：

sustainability, assessment, narrative, risk, persona, bias, provider, dog, truth, gas, planning, garment, subset, stakeholder, diversity, bus, therapist, textile, experimenter, interviewee, ...
※ これはCHIの中でもエスノグラフィー系の論文や環境もので使われている語彙かもしれない。


インストール・利用方法（MacOSでのみ確認）

スクリプトのダウンロード：

$ git clone https://github.com/rkmt/vocab.git
vocabというディレクトリが出来る。

品詞判定ソフト(TreeTagger)のインストール：

vocab/tree-tagger というサブディレクトリに移動して、

http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/

から tree-tagger-MacOSX-3.2-intel.tar.gz, tagger-scripts.tar.gz, install-tagger.sh, english-par-linux-3.2.bin.gz

をダウンロードし、

$ sh install-tagger.sh 
を実行する。これで

$ echo “A quick brown fox jumps over the lazy black dog.” | tree-tagger/cmd/tree-tagger-english
などとすると品詞が解析されているのがわかるはずだ。

pdftotext のインストール：

PDFファイルからテキストを抽出するためにpdftotextをインストールする。

これはxpdfパッケージに含まれているので、homebrewを使っている場合は

$ brew install xpdf  
でインストールする。( /usr/local/bin/pdftotext が出来ているはず）

文書解析

以上の準備ができたら、vocabディレクトリ上で

$ ruby vocab.rb  自分の文書ディレクトリ 参考にしたい文書ディレクトリ
で解析を開始する。解析可能なファイルタイプは .tex, .txt, .pdf, .doc, .docx 。サブディレクトリ内に置かれたものも階層的に解析する。

結果は yourV.txt, yourA.txt, yourAdv.txt, yourN.txt がそれぞれ自分の文書から抽出された動詞、形容詞、副詞、名詞の頻度順のリスト、refV.txt refA.txt, refAdv.txt, refN.txt が同様に参考にした文書から抽出した頻度順リストになる。自分が使っていない中でランキングの高い品詞が、suggestions.txt にセーブされる。