# CIKM 2026 Paper: Exposing Citation Vulnerabilities in Generative Search Engines

ACM CIKM 2026 投稿論文。GSE (Generative Search Engine) の引用選択における攻撃面を、content-injection barrier とユーザプロファイルの観点から評価するフレームワークを提案する。

## Build

### macOS / Linux (Make)

```bash
make        # PDF生成 → out/QL_Research_CIKM_Paper.pdf
make clean  # 一時ファイル削除
```

### Windows / Cross-platform (latexmk)

```bash
latexmk QL_Research_CIKM_Paper.tex   # PDF生成
latexmk -c                            # 一時ファイル削除
```

### Requirements

- TeX Live (pdfLaTeX, BibTeX)
- macOS: `brew install texlive`
- Windows: [TeX Live](https://www.tug.org/texlive/) をインストール

## Directory Structure

```
src/          # LaTeX source files
bib/          # BibTeX files
figs/         # Figures and tables
sty/          # ACM acmart style files
out/          # Output PDF
```
