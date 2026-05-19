# Phase 8 仕様書：論文用 Figure / Table 生成パイプライン

> 作成日: 2026-05-19
> 対象会議: ACM CIKM（1-column format, 幅 ≈ 3.33 in = 84.7 mm）

---

## 0. 実行環境・前提

### 0.1 リポジトリ

```
/Users/moz/Desktop/QL_Reseach_ACM_CIKM26_Experiments/
```

### 0.2 入力データ

Phase 6 の JSON ファイル群。パス: `data/phase6_results.full/`

| ファイル | 用途 |
|---|---|
| `figure1_layer_breakdowns.json` | Citation Distribution の Figure + Values Table |
| `figure_word_count_distribution.json` | Word Count Distribution の Figure + Values Table |
| `figure_grounding_distribution.json` | Grounding Distribution の Figure + Values Table |
| `citation_distribution_tests.json` | Citation Distribution の Tests Table |
| `word_count_distribution_tests.json` | Word Count Distribution の Tests Table |
| `grounding_distribution_tests.json` | Grounding Distribution の Tests Table |

### 0.3 入力 JSON の構造（実装上の参照情報）

#### figure1_layer_breakdowns.json（Citation Distribution）

```json
{
  "condition_axis": {
    "us": {
      "all": {                          // ← "All" モデル集約。Phase 8 では使わない
        "personas": {
          "unknown": {
            "layers": {
              "P_Brave":   { "n": 2337, "distribution": {"Primary": 0.21, "Opponent": 0.09, "High": 0.08, "Mid": 0.50, "Low": 0.09} },
              "P_Citation": { "n": 2640, "distribution": {...} }
            },
            "chi_square_tests": {
              "brave_vs_citation": { "chi2": 24.72, "dof": 4, "p_value": 5.72e-05 }
            }
          },
          "high-cons.": { ... },
          "high-prog.": { ... }
        }
      },
      "openai-gpt5__all": {             // ← モデル別。"all" は group 全体（ruling+opposition）
        "personas": { "unknown": { "layers": { ... } }, ... }
      },
      "openai-gpt5__ruling": {          // ← モデル×group
        "personas": { "unknown": { "layers": { ... } }, ... }
      },
      "openai-gpt5__opposition": { ... },
      "gemini-2.5-flash__all": { ... },
      "gemini-2.5-flash__ruling": { ... },
      ...
      "claude-sonnet-4__all": { ... },
      ...
    },
    "jp": { ... }  // 同構造
  }
}
```

キーのパターン: `{model}__{condition}`。model は `openai-gpt5`, `gemini-2.5-flash`, `claude-sonnet-4`。condition は `all`（group 全体）, `ruling`, `opposition`。

#### figure_word_count_distribution.json

`figure1_layer_breakdowns.json` と同一構造。値は word count / character count ベースの barrier 別配分。

#### figure_grounding_distribution.json

```json
{
  "bins": { "low": [0.0, 0.3333], "mid": [0.3333, 0.6667], "high": [0.6667, 1.0001] },
  "condition_axes": {
    "group": {
      "us": {
        "all": {                        // ← "All" モデル。Phase 8 では使わない
          "bins": {
            "low":  { "n": 9243,  "distribution": {"Primary": 0.16, ...} },
            "mid":  { "n": 69382, "distribution": {...} },
            "high": { "n": 45914, "distribution": {...} }
          }
        },
        "openai-gpt5": {                // ← モデル別
          "bins": { "low": {...}, "mid": {...}, "high": {...} }
        },
        ...
      }
    },
    "persona": { ... },
    "alignment": { ... },
    "party": { ... },
    "ideology": { ... }
  }
}
```

#### *_distribution_tests.json（検定結果）

```json
[
  {
    "axis": "group",
    "country": "us",
    "scope": "citation",        // or "grounding", "word_count"
    "test": "chi_square",
    "condition": "Model",       // 比較軸名
    "model": "all",             // "all" = 全モデルプール / 特定モデル名
    "layer": "P_Citation",
    "chi2": 568.94,
    "dof": 8,
    "p_value": 1.2e-115,
    "p_value_adjusted": null,   // Grounding のみ Holm 補正値
    "n": 2640,
    "min_expected": 12.3,
    "low_expected_cells": 0,
    "warning": null,            // or "low expected count (3 cells; min=1.65)"
    "contingency_table": { ... }
  },
  ...
]
```

### 0.4 参照コード

Phase 7 の実装を参照しつつ、Phase 8 用に新規作成する:

| Phase 7 ファイル | 参照ポイント |
|---|---|
| `pipeline/phase7_visualize/figures/common.py` | カラースキーム (`BARRIER_COLORS`)、matplotlib 設定、棒グラフ描画関数 |
| `pipeline/phase7_visualize/figures/fig1_layer_breakdowns.py` | `_item_for()` のキー解決ロジック、`stacked_layer_pairh()` / `stacked_barh()` |
| `pipeline/phase7_visualize/figures/fig4_grounding_heatmap.py` | Marimekko chart 描画ロジック |
| `pipeline/phase7_visualize/figures/fig5_word_count_distribution.py` | Word count 棒グラフ |
| `pipeline/phase7_visualize/tables/common.py` | `format_p()`, `stars()`, `write_latex_table()`, `BARRIERS` 定数 |
| `pipeline/phase7_visualize/tables/distribution_tests.py` | 検定 JSON → LaTeX 変換ロジック |
| `pipeline/phase7_visualize/tables/figure_values.py` | 数値テーブル生成 |
| `pipeline/phase7_visualize/runner.py` | Phase 7 のオーケストレーション |
| `pipeline/phase7_visualize/__main__.py` | CLI 引数パース (`--variant`, `--config` 等) |

### 0.5 依存ライブラリ

既に pyproject.toml にあるもののみ使用（追加インストール不要）:
- matplotlib >= 3.8.0
- pandas >= 2.2.0
- numpy >= 1.26.0
- scipy >= 1.12.0

### 0.6 出力先

```
data/phase8_outputs/
├── figures/
│   ├── citation_distribution_by_group.pdf
│   ├── citation_distribution_by_persona.pdf
│   ├── word_count_distribution_by_group.pdf
│   ├── word_count_distribution_by_persona.pdf
│   ├── grounding_distribution_by_group.pdf
│   └── grounding_distribution_by_persona.pdf
└── tables/
    ├── citation_distribution_tests.tex
    ├── citation_distribution_values.tex
    ├── word_count_distribution_tests.tex
    ├── word_count_distribution_values.tex
    ├── grounding_distribution_tests.tex
    └── grounding_distribution_values.tex
```

### 0.7 実行方法

Phase 7 と同じパターンで実行できるようにする:

```bash
python -m pipeline.phase8_paper_figures --variant full --config configs/settings.yaml
```

CLI 引数:
- `--variant` (default: `full`): データセット variant
- `--config` (default: `configs/settings.yaml`): 設定ファイル
- `--results` (optional): 入力 JSON ディレクトリの上書き（デフォルト: `data/phase6_results.{variant}/`）
- `--output` (optional): 出力ディレクトリの上書き（デフォルト: `data/phase8_outputs/`）

### 0.8 推奨コード構成

```
pipeline/phase8_paper_figures/
├── __init__.py
├── __main__.py             # CLI エントリポイント（argparse）
├── runner.py               # オーケストレーション（JSON 読み込み → Figure/Table 生成）
├── config.py               # 全定数（サイズ、フォント、カラー、モデル順序等）
├── figures/
│   ├── __init__.py
│   ├── common.py           # 共通描画ユーティリティ（棒グラフ、Marimekko）
│   ├── citation.py         # F1（by_group）、F2（by_persona）
│   ├── word_count.py       # F3（by_group）、F4（by_persona）
│   └── grounding.py        # F5（by_group）、F6（by_persona）
└── tables/
    ├── __init__.py
    ├── common.py            # LaTeX テーブル書式ユーティリティ
    ├── tests.py             # T1, T2, T3（検定結果テーブル）
    └── values.py            # T4, T5, T6（数値テーブル）
```

---

## 1. Phase 7 → Phase 8 の主な変更点

| 項目 | Phase 7 | Phase 8 |
|---|---|---|
| 目的 | 著者の探索的分析用（全軸×全条件） | 論文掲載用（必要な軸のみ厳選） |
| モデル列 | 4 列（All, OpenAI, Gemini, Claude） | **3 列（OpenAI, Gemini, Claude のみ。"All" 列は全 Figure/Table で廃止）** |
| 出力 Figure 数 | 15 PDF | **6 PDF** |
| 出力 Table 数 | 30 tex | **6 tex** |
| Figure 幅 | 7.0–8.8 in（2-column 想定） | **3.33 in 固定（ACM 1-column）** |
| Figure 高さ | 固定 or 行数×固定係数 | **表示項目数に応じて柔軟に決定（§3.3 参照）** |
| フォントサイズ | 6–7 pt | **最小 7 pt（本文）、6.5 pt（tick/legend）。これ以下は不可** |
| 棒の太さ | 0.72 in | **0.18 in（最小限に縮小）** |
| 余白 | 広め | **最小限。ただしラベル切れ・重なりがないこと** |

---

## 2. 出力一覧

### 2.1 Figures（6 枚）

| Figure ID | 分布種別 | 分析軸 | 行構成 | 列構成 | チャート種別 |
|---|---|---|---|---|---|
| F1 | Citation Distribution | by_group | US ruling / US opposition / JP ruling / JP opposition（4 行）。各行内で Brave 棒と Citation 棒のペア | OpenAI / Gemini / Claude（3 列） | Stacked horizontal bar pair（Brave vs Citation） |
| F2 | Citation Distribution | by_persona | US unknown / US high-cons. / US high-prog. / JP unknown / JP high-cons. / JP high-prog.（6 行）。Citation 層のみ | OpenAI / Gemini / Claude（3 列） | Stacked horizontal bar（Citation のみ） |
| F3 | Word Count Distribution | by_group | F1 と同じ 4 行。Citation 層の 1 本棒のみ | OpenAI / Gemini / Claude（3 列） | Stacked horizontal bar |
| F4 | Word Count Distribution | by_persona | F2 と同じ 6 行。Citation 層のみ | OpenAI / Gemini / Claude（3 列） | Stacked horizontal bar |
| F5 | Grounding Distribution | by_group | F1 と同じ 4 行 | OpenAI / Gemini / Claude（3 列） | Marimekko chart |
| F6 | Grounding Distribution | by_persona | F2 と同じ 6 行 | OpenAI / Gemini / Claude（3 列） | Marimekko chart |

**補足**:
- by_party, by_alignment, by_party_ideology の Figure は Phase 8 では生成しない。知見は本文中で p 値を引用して述べる（Table で統計検定結果を提供）。
- F2, F4, F6（by_persona）は「ペルソナ帰無知見」の視覚的証拠として必須。

### 2.2 Tables（6 枚）

| Table ID | 対象 | 内容 |
|---|---|---|
| T1 | Citation Distribution | 全分析軸の χ² 検定結果 |
| T2 | Word Count Distribution | 全分析軸の χ² 検定結果 |
| T3 | Grounding Distribution | 全分析軸の χ² 検定結果（Holm 補正付き） |
| T4 | Citation Distribution | 代表セルの barrier 別構成比（%） |
| T5 | Word Count Distribution | 代表セルの barrier 別構成比（%） |
| T6 | Grounding Distribution | grounding bin 別構成比 + bin 内 barrier 構成比（%） |

---

## 3. Figure の詳細仕様

### 3.1 共通レイアウト仕様

| 項目 | 値 | 備考 |
|---|---|---|
| Figure 幅 | **3.33 in 固定** | 全 Figure で統一。ACM 1-column 幅 |
| Figure 高さ | **表示項目数に応じて柔軟に決定** | §3.3 の計算式に従う。Figure ごとに異なる |
| フォント | Times New Roman | `"font.family": "serif", "font.serif": ["Times New Roman", "Times", "DejaVu Serif"]` |
| 本文フォント | **7 pt** | axes.titlesize, axes.labelsize |
| Tick フォント | **6.5 pt** | xtick.labelsize, ytick.labelsize |
| Legend フォント | **6.5 pt** | legend.fontsize |
| PDF fonttype | 42 | TrueType（LaTeX 埋め込み互換） |
| DPI | 300 | |
| axes.linewidth | 0.5 | |

#### カラースキーム（Phase 7 と同一）

```python
BARRIER_COLORS = {
    "Primary":  "#9EC9F3",   # 水色
    "Opponent": "#F8CFD2",   # 薄ピンク
    "High":     "#F2868A",   # 赤
    "Mid":      "#EF3337",   # 濃赤
    "Low":      "#BD171A",   # 暗赤
}
```

#### 棒グラフの寸法

| パラメータ | 値 | 説明 |
|---|---|---|
| `BAR_HEIGHT` | **0.18 in** | 棒 1 本の太さ。カラー区分が視認できる最小限 |
| `PAIR_GAP` | **0.02 in** | Brave 棒と Citation 棒の間隔（F1 のみ使用） |
| `GROUP_GAP` | **0.08 in** | 行と行の間隔 |
| `COUNTRY_GAP` | **0.14 in** | US と JP の境界の追加間隔（F2, F4, F6 のみ） |
| `LEGEND_HEIGHT` | **0.30 in** | 凡例 + 列タイトル領域 |

**設計意図**: 棒内部にテキストを配置しない。N 値・Sig. マークは棒の右外に配置する。

### 3.2 共通グリッド構成

```python
MODEL_ORDER = ["openai-gpt5", "gemini-2.5-flash", "claude-sonnet-4"]
MODEL_LABELS = {"openai-gpt5": "GPT-5", "gemini-2.5-flash": "Gemini 2.5", "claude-sonnet-4": "Claude Sonnet 4"}
```

- **列**: 3 列固定。**"all" キーのデータは読み込まない。**
- **列タイトル**: 各列の上部に 1 回だけモデル名を表示
- **行ラベル**: 各行の左端に条件名
- **凡例**: Figure 最上部に 1 行で横並び（5 barrier）。各 Figure で 1 回のみ
- **x 軸**: 0–100%。目盛りは 0, 25, 50, 75, 100 の 5 点。ラベルは最下行の列のみ表示

### 3.3 各 Figure の高さ計算

**横幅は全 Figure で 3.33 in 固定。縦幅は表示項目数に応じて柔軟に決定する。**

計算式:
```
height = LEGEND_HEIGHT + (n_bars × BAR_HEIGHT) + (n_pairs × PAIR_GAP) + (n_group_gaps × GROUP_GAP) + (n_country_gaps × COUNTRY_GAP)
```

| Figure | 棒数 | 計算 | 高さ |
|---|---|---|---|
| F1（by_group, paired bars） | 8 棒, 4 ペア, 3 group gap | 0.30 + 8×0.18 + 4×0.02 + 3×0.08 | **2.02 in** |
| F2（by_persona, single bars） | 6 棒, 5 group gap, 1 country gap | 0.30 + 6×0.18 + 5×0.08 + 1×0.14 | **1.92 in** |
| F3（by_group, single bars） | 4 棒, 3 group gap | 0.30 + 4×0.18 + 3×0.08 | **1.26 in** |
| F4（by_persona, single bars） | 6 棒, 5 group gap, 1 country gap | F2 と同一 | **1.92 in** |
| F5（by_group, Marimekko） | 4 セル (高さ 0.30 in/セル), 3 group gap | 0.30 + 4×0.30 + 3×0.08 | **1.74 in** |
| F6（by_persona, Marimekko） | 6 セル, 5 group gap, 1 country gap | 0.30 + 6×0.30 + 5×0.08 + 1×0.14 | **2.54 in** |

**注意**: 上記は目安。ラベル切れ・フォントの潰れがあれば微調整する。ただし不必要に大きくしない。

### 3.4 F1: Citation Distribution by Group

- 各セル（行×列）に水平積み上げ棒グラフを **2 本**表示:
  - 上の棒: **Brave**（P_Brave の distribution）
  - 下の棒: **Citation**（P_Citation の distribution）
- 棒の右端に N（引用数）を小フォント（6.5 pt）で表示
- Brave 棒と Citation 棒の間に Pair Sig.（`***` / `n.s.`）を表示（chi_square_tests.brave_vs_citation から取得）
- ペルソナは **unknown のみ**を使用
- 行順: US ruling → US opposition → JP ruling → JP opposition
- 行ラベル: `US rul.` / `US opp.` / `JP rul.` / `JP opp.`（各棒の左に `Brave` / `Cite` の 2 行ラベル）

**データ取得キー**:
```python
# US ruling × OpenAI の例
data["condition_axis"]["us"]["openai-gpt5__ruling"]["personas"]["unknown"]["layers"]["P_Brave"]
data["condition_axis"]["us"]["openai-gpt5__ruling"]["personas"]["unknown"]["layers"]["P_Citation"]
```

### 3.5 F2: Citation Distribution by Persona

- 各セルに水平積み上げ棒グラフを **1 本**表示（P_Citation 層のみ。Brave 不要）
- 棒の右端に N を表示
- 行順: US unknown → US high-cons. → US high-prog. → （country gap） → JP unknown → JP high-cons. → JP high-prog.
- 行ラベル: `US unkn.` / `US cons.` / `US prog.` / `JP unkn.` / `JP cons.` / `JP prog.`

**データ取得キー**:
```python
# US × OpenAI × persona=unknown の例（group は "all" = ruling+opposition プール）
data["condition_axis"]["us"]["openai-gpt5__all"]["personas"]["unknown"]["layers"]["P_Citation"]
# persona=high-cons. の例
data["condition_axis"]["us"]["openai-gpt5__all"]["personas"]["high-cons."]["layers"]["P_Citation"]
```

### 3.6 F3: Word Count Distribution by Group

- F1 と同じ 4 行構成だが **Citation 層の 1 本棒のみ**（Brave ペアなし）
- 値は word count / character count の barrier 別配分
- ペルソナは unknown のみ
- 棒の右端に総 word/character count を表示
- 行ラベル: `US rul.` / `US opp.` / `JP rul.` / `JP opp.`

**データ取得**: `figure_word_count_distribution.json` から同じキーパターンで取得。

### 3.7 F4: Word Count Distribution by Persona

- F2 と同じ 6 行レイアウト。値は word count / character count ベース。

### 3.8 F5: Grounding Distribution by Group

- Marimekko chart（比例面積グラフ）
- x 軸: grounding bin（Low / Mid / High）。各 bin の幅が bin 内の citation 件数に比例
- y 軸: barrier 別構成比（0–100%）
- ペルソナは unknown のみ
- 行順: F1 と同一
- 各セルの高さ: 0.30 in

**データ取得キー**:
```python
# US × OpenAI の ruling の例
data["condition_axes"]["group"]["us"]["openai-gpt5"]["bins"]["low"]   # {"n": ..., "distribution": {...}}
data["condition_axes"]["group"]["us"]["openai-gpt5"]["bins"]["mid"]
data["condition_axes"]["group"]["us"]["openai-gpt5"]["bins"]["high"]
```

**注意**: grounding JSON の condition_axes 構造は citation/word_count と異なる。`condition_axes.group.{country}.{model}` で group 全体データにアクセスし、ruling/opposition の分割は condition_axes 内のキーで取得する。実装時に Phase 7 の `fig4_grounding_heatmap.py` のキー解決ロジックを確認すること。

### 3.9 F6: Grounding Distribution by Persona

- F5 と同じ Marimekko レイアウト
- 行順: F2 と同一
- データは `condition_axes.persona` から取得

---

## 4. Table の詳細仕様

### 4.1 検定結果 Table（T1, T2, T3）

**目的**: 論文本文で「χ²(df) = X, p < .001」と引用するための根拠テーブル。

#### 共通フォーマット

```latex
\begin{table}[t]
\centering
\footnotesize
\setlength{\tabcolsep}{3pt}
\caption{...}
\label{...}
\begin{tabular}{llrrrrl}       % T3 は llrrrrrl（p_H 列追加）
\toprule
\textbf{Country} & \textbf{Comparison} & \textbf{N} & \textbf{df} & \textbf{$\chi^2$} & \textbf{$p$} & \textbf{Sig.} \\
\midrule
US & Model & 2{,}640 & 8 & 568.94 & $<$.001 & $^{***}$ \\
   & Model (ruling) & 614 & 8 & 143.98$^\dagger$ & $<$.001 & $^{***}$ \\
...
\cmidrule(lr){1-7}
JP & Model & 4{,}604 & 8 & 574.80 & $<$.001 & $^{***}$ \\
...
\bottomrule
\end{tabular}
\begin{minipage}{\columnwidth}
\footnotesize \textit{Notes.} ...
\end{minipage}
\end{table}
```

**列仕様**:

| 列名 | 内容 | 書式 |
|---|---|---|
| Country | `US` / `JP` | 各国の最初の行のみ表示、以降は空欄 |
| Comparison | 比較軸の名称（下記参照） | テキスト |
| N | 観測数 | 整数、カンマ区切り（`2{,}640`） |
| df | 自由度 | 整数 |
| χ² | カイ二乗統計量 | 小数点以下 2 桁。期待度数警告がある場合は `$^\dagger$` を付加 |
| p | p 値 | `$<$.001` or 小数点以下 3 桁 |
| Sig. | 有意性マーク | `$^{***}$` (p<.001) / `$^{**}$` (p<.01) / `$^{*}$` (p<.05) / n.s. |

T3（Grounding）のみ p と Sig. の間に `p_H` 列を追加（Holm 補正後 p 値）。Sig. は p_H に基づく。

**出力する行（Comparison 列の値）**:

| # | Comparison 値 | 検定 JSON 内の対応フィールド | 行数 |
|---|---|---|---|
| 1 | `Model` | condition=Model, model=all, group=pooled, persona=unknown | 2 |
| 2 | `Model (ruling)` | condition=Model, group=ruling, persona=unknown | 2 |
| 3 | `Model (opposition)` | condition=Model, group=opposition, persona=unknown | 2 |
| 4 | `Party group` | condition=Party group, model=all, persona=pooled | 2 |
| 5 | `Party group (GPT-5)` | condition=Party group, model=OpenAI | 2 |
| 6 | `Party group (Gemini)` | condition=Party group, model=Gemini | 2 |
| 7 | `Party group (Claude)` | condition=Party group, model=Claude | 2 |
| 8 | `Persona` | condition=Persona, model=all | 2 |
| 9 | `Persona (GPT-5)` | condition=Persona, model=OpenAI | 2 |
| 10 | `Persona (Gemini)` | condition=Persona, model=Gemini | 2 |
| 11 | `Persona (Claude)` | condition=Persona, model=Claude | 2 |
| 12 | `Party ideology` | condition=Party ideology, model=all | 2 |
| 13 | `Alignment` | condition=Alignment, model=all | 2 |
| 14 | `Alignment (GPT-5)` | condition=Alignment, model=OpenAI | 2 |
| 15 | `Alignment (Gemini)` | condition=Alignment, model=Gemini | 2 |
| 16 | `Alignment (Claude)` | condition=Alignment, model=Claude | 2 |

→ 合計 **32 行**（16 比較 × US/JP）

**行の並び順**: US が先、JP が後。Country 内は上記 #1–#16 の順。Country 列は最初の行のみ表示し、以降は空欄。US と JP の境界に `\cmidrule` を入れる。

**Notes の内容**:
```
Comparison column: "Model" compares OpenAI vs Gemini vs Claude; "Party group" compares ruling vs opposition; "Persona" compares unknown vs high-conservative vs high-progressive; "Party ideology" compares conservative vs progressive; "Alignment" compares aligned vs opposed. Parenthesized model names indicate the comparison is restricted to that model. $^\dagger$ indicates low expected cell counts ($<5$); interpret with caution. Tests are reported without multiplicity adjustment. Observations are citation-level and may not be fully independent within a response.
```

#### T1: Citation Distribution Tests

```latex
\caption{Chi-square tests for citation distribution.}
\label{tab:citation-tests}
```

#### T2: Word Count Distribution Tests

```latex
\caption{Chi-square tests for word count distribution.}
\label{tab:wc-tests}
```

#### T3: Grounding Distribution Tests

```latex
\caption{Chi-square tests for grounding distribution.}
\label{tab:grounding-tests}
```

列仕様: `llrrrrrl`（p_H 列追加）。Notes に Holm 補正の説明を追加。

### 4.2 数値 Table（T4, T5, T6）

**目的**: Figure の数値的裏付け。本文中で「OpenAI は US で Primary 67.2%」と述べる際の根拠。

#### T4: Citation Distribution Values

```latex
\begin{table}[t]
\centering
\footnotesize
\setlength{\tabcolsep}{3pt}
\caption{Citation distribution by model and party group (\%).}
\label{tab:citation-values}
\begin{tabular}{llrrrrr}
\toprule
\textbf{Country} & \textbf{Condition} & \textbf{Prim.} & \textbf{Opp.} & \textbf{High} & \textbf{Mid} & \textbf{Low} \\
\midrule
US & GPT-5 & 67.2 & 3.8 & 20.3 & 8.2 & 0.0 \\
   & Gemini & 15.6 & 12.6 & 14.6 & 45.7 & 12.0 \\
   & Claude & 17.3 & 4.4 & 8.6 & 59.3 & 10.6 \\
\cmidrule(lr){2-7}
   & GPT-5 (rul.) & ... \\
   & Gemini (rul.) & ... \\
   & Claude (rul.) & ... \\
\cmidrule(lr){2-7}
   & GPT-5 (opp.) & ... \\
   & Gemini (opp.) & ... \\
   & Claude (opp.) & ... \\
\cmidrule(lr){1-7}
JP & ... \\
\bottomrule
\end{tabular}
\end{table}
```

**出力する行**:

| Country | Condition | データ取得元 |
|---|---|---|
| US | GPT-5 | `openai-gpt5__all`, persona=unknown, P_Citation |
| US | Gemini | `gemini-2.5-flash__all`, persona=unknown, P_Citation |
| US | Claude | `claude-sonnet-4__all`, persona=unknown, P_Citation |
| US | GPT-5 (rul.) | `openai-gpt5__ruling`, persona=unknown, P_Citation |
| US | Gemini (rul.) | 同上パターン |
| US | Claude (rul.) | 同上パターン |
| US | GPT-5 (opp.) | `openai-gpt5__opposition`, persona=unknown, P_Citation |
| US | Gemini (opp.) | 同上パターン |
| US | Claude (opp.) | 同上パターン |
| JP | （同上 9 行） | |

→ 合計 **18 行**。値は barrier 別 %（小数点以下 1 桁）。

#### T5: Word Count Distribution Values

T4 と同一フォーマット・同一行構成。データソースは `figure_word_count_distribution.json`。

```latex
\caption{Word count distribution by model and party group (\%).}
\label{tab:wc-values}
```

#### T6: Grounding Distribution Values

```latex
\caption{Grounding distribution by model and party group (\%).}
\label{tab:grounding-values}
\begin{tabular}{llrrrrrr}
\toprule
\textbf{Country} & \textbf{Condition} & \textbf{Low} & \textbf{Mid} & \textbf{High} & \textbf{Prim.(L)} & \textbf{Prim.(M)} & \textbf{Prim.(H)} \\
\midrule
...
\bottomrule
\end{tabular}
```

| 列 | 内容 |
|---|---|
| Low, Mid, High | grounding bin の質量配分（行合計 = 100%） |
| Prim.(L), Prim.(M), Prim.(H) | 各 bin 内の Primary %（bin 内合計 = 100%） |

行構成は T4 と同一（18 行）。

---

## 5. 統計検定の仕様

### 5.1 Citation Distribution / Word Count Distribution の検定

- **検定手法**: Pearson χ² 検定
- **分割表**: 比較対象の各水準 × 5 barrier の度数表
  - Citation: 引用件数
  - Word Count: 引用に帰属する語数/文字数（整数に丸める）
- **多重比較補正**: なし（Table の notes に明記）
- **警告**: 期待度数 < 5 のセルが存在する場合、χ² の右肩に `$^\dagger$` を付加

### 5.2 Grounding Distribution の検定

- **検定手法**: Pearson χ² 検定
- **分割表**: 比較対象の各水準 × 3 grounding bin（Low / Mid / High）の度数表
- **多重比較補正**: Holm 法（Figure 単位でファミリーを構成）
- **報告値**: raw p と p_H（Holm 補正後）の両方を Table に記載

### 5.3 "All" モデルの扱い

- **Figure**: "all" キーのデータは描画しない
- **Table（数値）**: "all" 行は出力しない
- **Table（検定）**: `model=all` 条件の検定行（例: "Party group" で全モデルプールした与野党比較）は出力する。これは「全モデルを通じた差」を示すための検定であり、"All" 列の表示とは意味が異なる

---

## 6. 品質チェックリスト

生成後に以下を確認:

- [ ] 全 Figure の横幅が 3.33 in で統一されている
- [ ] 各 Figure の縦幅が表示項目数に応じて適切に異なっている（F1 ≠ F3 ≠ F5 等）
- [ ] フォントサイズが 6.5 pt 未満のテキストが存在しない
- [ ] "All" / "all" 列・行が Figure・Table のいずれにも存在しない
- [ ] 凡例が Figure 内に収まり、グラフ領域と重なっていない
- [ ] 棒グラフの N 値・Sig. マークが棒の右外にあり、隣接する棒と重なっていない
- [ ] 棒の太さが均一で 0.18 in 程度に収まっている
- [ ] Marimekko chart の bin ラベルが読める
- [ ] Table が ACM 1-column に収まっている（`table` 環境、`table*` でない）
- [ ] Table の数値が phase7_analysis_report.md の代表値と一致している
- [ ] T3 に p と p_H の両方が記載されている
- [ ] 期待度数警告のある行に `†` が付いている
- [ ] PDF が Times New Roman / TrueType fonttype 42 で出力されている
- [ ] `python -m pipeline.phase8_paper_figures --variant full` で全出力が生成される
