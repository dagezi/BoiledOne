# TODO

## ~~Cancel時に未確定部分だけをローマ字にする~~
- ~~ひらがなからローマ字へのマッピングを作る [String:Index -> String:Index]~~


## 文節変換
- 付属語 (助詞、助動詞)
- マトモな辞書が必要?
- どうやって優先順位を決める?

## 再変換
- BSを送って RawModeに戻る
- 実際に漢字を逆に変換する?

## 候補選択UI
## 数字対応
漢数字も?

## 学習機能
## ~~平仮名、片仮名辞書の拡充~~
- [mozc辞書活用](https://www.sakaki.works/doku/doku.php?id=freewnn#mozc_%E3%81%AE%E8%BE%9E%E6%9B%B8%E3%81%AE%E5%88%A9%E7%94%A8) ?
- pubdic+ 
## フォーカス外れた時の動作
- GUI操作がはいったときとか。確定しちゃうべき? yes
- RawModeで GUI操作が反応しないときがある。
  - Firefox browserで formに文字を入力して予測がでてるとき、予測をクリックしても選択できない。
- Webの Formで文字が 2重にはいることがある
  - https://interviews.modernloop.io/o/anduril/login

## Cut/Copy/Paste
- キーイベントが届かない!! 確定させることもできない??
## pinyin対応?
