# DCS_RadarSurveillanceScript
DCSで使用できる、レーダー監視用のスクリプトです。<br><br>
レーダーで探知中の敵機が指定したエリア（トリガーゾーン）に侵入すると、以下のアクションを実行します。<br>
・指定した非アクティブ状態のグループを活性化<br>
・指定したユーザーフラグをtrueに変更<br>
<br>
スクランブル機を自動で発進させたり、ユーザーフラグを使って独自の処理を発火させることができるようになります。<br>
低空侵入の訓練や作戦で使うと面白いかもしれません。<br>
<br>
追記：デバッグモードをONの状態で配布しています。<br>
解除する場合、ファイルをテキストエディタなどで開き、debugModeの値をfalseにしてください<br>
![手当マシマシのレーダーサイト](https://user-images.githubusercontent.com/30495755/170861966-479c1ea8-a15b-4637-b62b-7bda114dada2.png)


# 使い方
▼準備<br>
1.ミッションエディタでluaファイルを読み込ませる。（設定は画像参照）<br>
2.トリガーゾーンを配置し、名前を以下のように変更する。<br>
  ・RED陣営用の場合、"AirDefenceZone_Red"<br>
  ・BLUE陣営用の場合、"AirDefenceZone_Blue"<br>
3.レーダーを配置する。<br>
  ・グループ名に"EWR"を含めるとスクリプトの対象になります。<br>
![Digital Combat Simulator  Black Shark Screenshot 2022 05 29 - 17 05 32 08](https://user-images.githubusercontent.com/30495755/170858522-eeb64c5a-cccb-48bb-ada2-7a739006c893.png)

■仕様<br>
利用できる機能は、<br>
・非活性のオブジェクトを活性化<br>
・ユーザーフラグをONにする<br>
の2つあり、どちらか、または両方使えます<br>

▼非活性のオブジェクトの配置<br>
グループ名を編集し、非活性の状態にします。<br>
1.グループ名に"SC"が含まれる。<br>
2.非活性の状態である。（LATE ACTIVATIONにチェックが入っているなど）<br>

![Inkedオブジェクト_LI](https://user-images.githubusercontent.com/30495755/170858600-b53e0a1d-75dd-41c5-8f98-314e30343af9.jpg)

<br>
▼ユーザーフラグの設定<br>
本スクリプトファイルをテキストエディタなどで開いて編集します。<br>
使いたいユーザーフラグを_userFlagListに入力する。<br>
（入力例）flagName1、flagName2、100、101という名前のユーザーフラグを使用したい場合、以下のように編集<br><br>

local _userFlagList = { "flagName1", "flagName2", 100, 101 }

<br>
ユーザーフラグの活用例：レーダーに引っかかったらユニットを爆破する<br><br>
ファイルの編集<br>

local _userFlagList = { "探知されたか" }


画像のようにトリガーを設定<br>
![ユーザーフラグ活用例](https://user-images.githubusercontent.com/30495755/170859046-300766a4-313b-403c-ad98-483cc8a25819.png)




