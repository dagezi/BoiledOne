# BoiledOne

ためしに BoiledOneを使ってこの文章を打ってみている。やはりやや面倒臭いところはある。
ということで、これは BoiledOneという OS-X用日本語IMです。

古に [BoiledEgg](https://web.archive.org/web/20110313143504/http://usir.kobe-c.ac.jp/boiled-egg/) という
日本語入力システムというか UIがありました。
Emacsの上で動き、英字モードとか意識せずに打てるのが魅力でした。
そしてこの BoiledOneはそれをオマージュして OS-X上でちょっと真似した物です。

当世風の AIなどとは駆けはなれたものであるが、個人的には手になじんでそこそこ使えなくないので
公開してみる次第。
御笑覧いただければ幸いです。

## Usage
各自、buildして `~/Library/Input\ Methods` に `cp -r` してください。

### 辞書
Bundleされた辞書しか読めないので、build前に Resources/skk-dic.txtを用意する必要があります。

[SKK-JISYO.L](http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK%BC%AD%BD%F1) を持って来て、`convertSkkDict` で変換できます:
```
./BoiledOne/buildtool/convertSkkDict ~/Downloads/SKK-JISYO.L > BoiledOne/Resources/skk-dic.txt
```

## LICENSE
MIT LICENSE
