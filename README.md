# QL Research ACM WWW Paper

検索機能を備えた生成エンジン GES (Generative Search Engine) における引用情報の信頼性評価に関する研究論文

## 概要

本研究では、Web 検索機能を備えた生成エンジン GES (Generative Search Engine) の回答信頼性を評価するフレームワーク「CiEval」を提案し、日米の政治分野を対象に実証分析を行います。

## ディレクトリ構成

```
.
├── src_ja/           # 日本語LaTeXソースファイル
├── src_en/           # 英語LaTeXソースファイル (今後作成予定)
├── bib/              # BibTeXファイル
├── figs/             # 図表ファイル
├── sty/              # スタイルファイル
├── out/              # 出力PDF格納ディレクトリ
├── tmp/              # 一時ファイル格納ディレクトリ
└── Makefile          # ビルド設定
```

## 必要な環境

### LaTeX 環境

- LuaLaTeX (日本語文書用)
- pdfLaTeX (英語文書用)
- BibTeX / pBibTeX

### textlint (オプション)

文章の品質チェックツール

## セットアップ

### 1. LaTeX 環境のインストール

#### macOS

```bash
brew install texlive-full
```

#### Ubuntu/Debian

```bash
sudo apt-get install texlive-full
```

#### Windows

[TeX Live](https://www.tug.org/texlive/)をインストール

### 2. textlint のインストール (オプション)

```bash
# Node.jsが必要
npm install -g textlint

# 日本語用プラグイン
npm install -g textlint-rule-preset-ja-technical-writing
npm install -g textlint-rule-preset-ja-spacing
npm install -g textlint-rule-prh

# 英語用プラグイン
npm install -g textlint-rule-write-good
npm install -g textlint-rule-alex
npm install -g textlint-rule-rousseau
npm install -g textlint-rule-no-dead-link
npm install -g textlint-rule-terminology
```

## ビルド方法

### Makefile の構成

本プロジェクトの Makefile は以下のターゲットを提供しています：

| ターゲット    | 説明                                  | コマンド                      |
| ------------- | ------------------------------------- | ----------------------------- |
| `all`         | デフォルトターゲット（PDF をビルド）  | `make`                        |
| `pdf`         | LaTeX 文書をコンパイルして PDF を生成 | `make pdf`                    |
| `clean`       | 一時ファイルと出力ファイルを削除      | `make clean`                  |
| `diff`        | 指定したコミットとの差分 PDF を生成   | `make diff COMMITHASH=<hash>` |
| `textlint-ja` | 日本語文書の品質チェック              | `make textlint-ja`            |
| `textlint-en` | 英語文書の品質チェック                | `make textlint-en`            |
| `textlint`    | 日英両方の文書をチェック              | `make textlint`               |

### PDF の生成

```bash
# 通常のビルド（日本語文書）
make pdf

# または単に
make
```

ビルドプロセス：

1. `tmp/`ディレクトリに必要なファイルをコピー
2. LuaLaTeX（日本語）または pdfLaTeX（英語）でコンパイル
3. BibTeX で参考文献を処理
4. 再度 LaTeX でコンパイル（相互参照の解決）
5. 最終 PDF を`out/`ディレクトリに出力

### 文章の品質チェック（textlint）

textlint は文章の品質を自動チェックするツールです。

#### 日本語文書のチェック

```bash
make textlint-ja
```

チェック項目（`.textlintrc.ja`で設定）：

- 文の長さ（最大 120 文字）
- 読点の数（最大 4 個）
- 句点の一貫性
- 助詞の連続使用
- ら抜き言葉
- 二重否定
- です・ます調とである調の混在
- 全角・半角文字間のスペース

#### 英語文書のチェック

```bash
make textlint-en
```

チェック項目（`.textlintrc.en`で設定）：

- 受動態の使用
- 冗長な表現
- 曖昧な表現（weasel words）
- クリシェ（決まり文句）
- 包括的な言語使用（alex）
- デッドリンクのチェック
- 専門用語の一貫性

#### 両方の文書をチェック

```bash
make textlint
```

### クリーンアップ

```bash
# 一時ファイルと出力ファイルを削除
make clean
```

削除対象：

- `tmp/`ディレクトリ内のすべてのファイル
- `out/`ディレクトリ内のすべてのファイル

### 差分 PDF 生成

特定の Git コミットとの差分を視覚化した PDF を生成：

```bash
# 特定のコミットとの差分
make diff COMMITHASH=abc123

# HEADの1つ前のコミットとの差分
make diff COMMITHASH=HEAD~1
```

差分の表示：

- 追加部分：青色で表示
- 削除部分：赤色の取り消し線で表示（設定により非表示）

## textlint の設定ファイル

### `.textlintrc.ja` - 日本語用設定

日本語の技術文書向けの設定で、以下のルールセットを使用：

- `preset-ja-technical-writing`: 技術文書向けの日本語ルール
- `preset-ja-spacing`: スペーシングルール
- `prh`: 表記ゆれチェック

### `.textlintrc.en` - 英語用設定

英語の学術文書向けの設定で、以下のルールを使用：

- `write-good`: 文章改善の提案
- `alex`: 包括的な言語使用のチェック
- `rousseau`: 読みやすさの改善
- `no-dead-link`: リンク切れチェック
- `terminology`: 専門用語の一貫性

### フィルター設定

両設定ファイルとも LaTeX コマンドを除外：

- `\cite{}`、`\ref{}`、`\label{}`などの LaTeX コマンド
- コメント行（`%`で始まる行）
- 数式（`$...$`）

## ファイル構成

### メインファイル

- `QL_Research_WWW_Paper.tex` - メインの LaTeX ファイル

### 章構成 (src_ja/)

1. `1_introduction.tex` - はじめに
2. `2_generative_engine.tex` - Generative Search Engine の概要
3. `3_relatedworks_and_motivation.tex` - 関連研究と動機
4. `4_proposed_framework.tex` - 提案フレームワーク
5. `5_experiment.tex` - 実験
6. `6_discussion.tex` - 議論
7. `7_conclusion.tex` - 結論
8. `a_prompts.tex` - 付録：プロンプト

### その他

- `title.tex` - タイトルページ
- `abst.tex` - 概要
- `ccs.tex` - CCS 概念

## 主要な研究内容

### CiEval フレームワーク

- 引用情報の属性分析
- 回答への反映率の定量評価
- セキュリティ観点での評価

### 実験対象

- 日本とアメリカの政治分野
- 政党公式 Web サイトの引用率・反映率の分析
- 非権威的情報源の影響評価

## トラブルシューティング

### makeコマンドが.styファイルエラーで失敗する場合

TeX Live 2025 Basic版を使用している場合、必要なパッケージが不足している可能性があります。以下の手順で解決できます：

#### 1. 不足パッケージの一括インストール

```bash
# 管理者権限で必要なパッケージをインストール
sudo tlmgr install comment enumitem algorithms algorithmic multirow tcolorbox \
                 hyperxmp xstring pbalance xifthen totpages ifmtarg luacode
```

#### 2. LaTeXファイルの設定修正

`QL_Research_WWW_Paper.tex`の冒頭部分に以下を追加：

```latex
\documentclass[sigconf,balance=false]{sty/acmart}

%% 必要なパッケージを先に読み込み
\usepackage{xifthen}
\usepackage{ifthen}
```

#### 3. Makefileの修正（コンパイル中断を回避）

Makefileの`pdf`ターゲットを以下のように修正：

```makefile
pdf: tmp
	cd ${TMPDIR} && ${PDFLATEX} -interaction=nonstopmode ${MAINFILE}
	cd ${TMPDIR} && ${BIBTEX} ${FILENAME} 
	cd ${TMPDIR} && ${PDFLATEX} -interaction=nonstopmode ${FILENAME} 
	cd ${TMPDIR} && ${PDFLATEX} -interaction=nonstopmode ${FILENAME}
	cp ${TMPDIR}/${PDFNAME} ${OUTDIR}
```

#### 4. ACMartクラスファイルの修正（manyfootエラー対応）

`sty/acmart.cls`の794行目付近を以下のように修正：

```latex
%\RequirePackage{manyfoot}
%\SelectFootnoteRule[2]{copyrightpermission}
%\DeclareNewFootnote{authorsaddresses}
%\SelectFootnoteRule[2]{copyrightpermission}
%\DeclareNewFootnote{copyrightpermission}
% Simplified footnote handling without manyfoot
\newcommand{\footnotetextcopyrightpermission}[1]{\footnotetext{#1}}
\newcommand{\footnotetextauthorsaddresses}[1]{\footnotetext{#1}}
```

### よくあるエラーと対処法

| エラーメッセージ | 原因 | 対処法 |
|---|---|---|
| `File 'XXX.sty' not found` | パッケージ未インストール | `sudo tlmgr install XXX` |
| `Undefined control sequence \@ifmtarg` | xifthen未読み込み | プリアンブルに`\usepackage{xifthen}`追加 |
| コンパイル中にプロンプト待ち | エラーで停止 | Makefileに`-interaction=nonstopmode`追加 |

### 環境確認コマンド

```bash
# TeX Liveバージョン確認
lualatex --version

# インストール済みパッケージ確認
tlmgr list --only-installed | grep -E "(comment|enumitem|algorithm)"
```

## 注意事項

- 日本語文書は LuaLaTeX でコンパイルされます
- 英語文書は pdfLaTeX でコンパイルされます
- BibTeX ファイルは`bib/cites.bib`に集約されています
- TeX Live Basic版では追加パッケージのインストールが必要な場合があります

## ライセンス

[ライセンス情報を追加してください]

## 著者

[著者情報を追加してください]

## 連絡先

[連絡先情報を追加してください]
