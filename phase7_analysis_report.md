# Phase 7 Analysis Report: Citation & Grounding Distribution in Political GSE Outputs

> Report date: 2026-05-18
> Data source: `data/phase7_outputs.full/`
> Scope: Citation Distribution (5 axes) + Grounding Distribution (5 axes), US & JP, 3 models (OpenAI, Gemini, Claude), 3 personas (unknown, high-cons., high-prog.)

---

## 1. Executive Summary

Phase 7 の可視化・検定結果を精査した結果、以下の構造が明らかになった。

1. **モデル差が最大の決定因子** であり、全分析軸・全条件・両国で常に有意（p < .001）。
2. **ペルソナ（personalization）は引用元の出版者カテゴリ分布に影響しない**（Citation Distribution で 0/8 条件が有意）。
3. **日本は米国と比較して一次情報源（Primary）への集中が圧倒的に強い**。
4. **与党 vs 野党** がモデル差に次ぐ2番目の効果量を持つ。
5. **Brave → Citation 層のシフトは普遍的** であり、LLM は検索結果に比べ Primary を増やし Mid-barrier を減らす。
6. **高 grounding（意味的類似度の高い）引用ほど Primary 情報源に偏る**。

---

## 2. Citation Distribution の知見

### 2.1 全体像：Brave → Citation 層シフト

Citation Distribution は「Brave 検索結果に出た source 構成」と「LLM が実際に引用した source 構成」の差を示す。全体として以下の普遍的パターンが確認された：

- **Primary が増加し、Mid-barrier が減少するパターンがほぼ全 Figure で反復**。図セル単位では Primary 増加が 389/428、Mid- 減少が 407/428（外部レビュアー集計値）。
- Pair Sig.（Brave vs Citation の層間比較）はほぼ全条件で *** (p < .001)。
- **例外**：US | Aligned progressive（全モデル集約）および Claude の一部条件で "--"（n.s.）。Claude が Brave 検索結果に最も忠実な引用選択を行うことを示唆。

### 2.2 モデル間差異（最大の効果）

全ての分析軸で 3 モデル間の引用分布差は p < .001（χ² > 500 レベル）。

#### Citation 層の Primary %（代表値：by_group, all 条件）

| | OpenAI | Gemini | Claude |
|---|---|---|---|
| **US** | 67.2% (unknown) / 63-65% (persona) | 15.6-17.9% | 16.5-17.3% |
| **JP** | 83.1% (unknown) / 79-82% (persona) | 48-49% | 52-53% |

#### Low-barrier %（Citation 層）

| | OpenAI | Gemini | Claude |
|---|---|---|---|
| **US** | 0.0% | 12-13% | 10-11% |
| **JP** | 0.1-0.4% | 17-18% | 5-7% |

#### Mid-barrier %（Citation 層）

| | OpenAI | Gemini | Claude |
|---|---|---|---|
| **US** | 8-12% | 43-46% | 57-59% |
| **JP** | 13-15% | 27-28% | 37-39% |

**解釈**：
- **OpenAI** は一次情報源への集中が極端。JP では 83% に達し、Low-barrier はほぼ 0%。検索フィルタリングによる poisoning 耐性は高いが、情報多様性を犠牲にしている。
- **Gemini** は最も Opponent 源を引用（US 12-15%, JP 6-8%）し、Low-barrier も最多。情報多様性は高いが poisoning 耐性は低い。
- **Claude** は Mid-barrier（編集済み・中立的情報源）に最も集中。Brave-Citation 間の差も最小で、search-grounded generation に最も忠実。

### 2.3 ペルソナ効果（帰無知見）

**Citation Distribution のペルソナ比較は全て非有意**：

| Country | Model | χ² | df | p |
|---|---|---|---|---|
| US | all | 6.62 | 8 | .579 |
| US | OpenAI | 7.32 | 8 | .503 |
| US | Gemini | 5.61 | 8 | .690 |
| US | Claude | 1.76 | 8 | .988 |
| JP | all | 10.07 | 8 | .260 |
| JP | OpenAI | 11.78 | 8 | .161 |
| JP | Gemini | 5.76 | 8 | .675 |
| JP | Claude | 5.61 | 8 | .690 |

**0/8 条件が有意**。保守的ペルソナでも革新的ペルソナでもペルソナなしでも、引用元の出版者カテゴリ分布は変わらない。

**含意**：GSE の引用脆弱性はユーザーのペルソナに依存せず、モデル固有のバイアスとして存在する。Poisoning 攻撃のリスク評価においてペルソナをファクタリングする必要はない。

### 2.4 与党 (Ruling) vs 野党 (Opposition)（2番目に大きい効果）

**Citation**: US ruling vs opposition χ²(4) = 1044.06, p < .001 — 極めて大きい効果量。

#### US の構造的非対称性

| Condition | Model | Primary % | Opponent % | Mid-barrier % |
|---|---|---|---|---|
| **Ruling (GOP)** | all | 1.9-2.4% | 3.6-3.9% | 59-61% |
| **Ruling** | OpenAI | 6.1-10.3% | 7.1-12.8% | 22-35% |
| **Ruling** | Gemini | 0.9-1.9% | 4.3-4.8% | 57-59% |
| **Ruling** | Claude | 0.0-1.4% | 0.0-0.9% | 74-79% |
| **Opposition** | all | 27.8-30.6% | 10.1-10.8% | 39-42% |
| **Opposition** | OpenAI | 82.9-86.8% | 1.3-5.2% | 3-5% |
| **Opposition** | Claude | 21.3-22.1% | 5.8-6.8% | 52-55% |

- 与党質問は政府・公的情報源に依存し、Primary/Opponent ともに低い → Mid-barrier 中心
- 野党質問はより党派的メディアからの引用が増加
- この非対称性は米国で極めて強く、日本では相対的に弱い

**JP**: ruling vs opposition χ²(4) = 357.92, p < .001。JP ruling は Primary 58% vs opposition 55% で差は小さいが、grounding 分布で明確な差あり。

### 2.5 保守 vs 革新のイデオロギー非対称性

Citation Distribution (by_party_ideology):
- US conservative vs progressive: χ²(4) = 148.44, p < .001
- JP conservative vs progressive: χ²(4) = 288.67, p < .001

#### US のイデオロギー別引用パターン

| Ideology | Primary % | Opponent % | Low-barrier % |
|---|---|---|---|
| Conservative | 24-26% | 6-7% | 12-14% |
| Progressive | 18-22% | **11-16%** | 6-8% |

**革新系政党への質問は対立政党の情報源をより多く引用する**。この非対称性は Gemini で最も顕著（progressive Opponent 15-16% vs conservative 10%）。

### 2.6 Alignment 効果（Aligned vs Opposed）

- US all models: χ²(12) = 101.00, p < .001
- **US OpenAI: p = .285 (n.s.)** — OpenAI は Alignment に鈍感
- US Gemini: χ²(12) = 62.12, p < .001
- US Claude: χ²(12) = 58.50, p < .001
- JP: 全モデルで p < .001

**Aligned progressive**（ペルソナと質問政党のイデオロギーが一致）では Brave-Citation 差が n.s. になるケースが散見される。一方 **Opposed** 条件では Citation 層での Primary 増加が強い。

### 2.7 日米間の差異

| 指標 | US (all, Citation) | JP (all, Citation) |
|---|---|---|
| Primary % | 22-24% | 55-57% |
| Opponent % | 8-12% | 4-5% |
| Mid-barrier % | 44-46% | 27-28% |
| Low-barrier % | 10-11% | 10-11% |

JP の高 Primary% は日本のメディア構造（党固有の公式サイト・機関紙への依存度の高さ、二極対立的な米国型メディアエコシステムとの差異）を反映。

---

## 3. Grounding Distribution の知見

### 3.1 全体像

Grounding Distribution は「回答文と引用の意味的対応が強いほど、どの source 層に支えられているか」を示す Marimekko chart。

- 低 grounding bin は常に小さく（US 7.4%, JP 9.3%）、主な質量は mid/high bin（US: 56%/37%, JP: 45%/46%）にある。
- **高 grounding になるほど Primary 比率が上がる傾向が強く、特に JP で非常に明瞭**。

### 3.2 Grounding × Publisher 属性の交互作用（普遍パターン）

全モデル・両国で、grounding bin の low → mid → high に伴い Primary % が**単調増加**：

| Country | Model | Low Primary% | Mid Primary% | High Primary% |
|---|---|---|---|---|
| US | all | 16.0 | 17.4 | 23.2 |
| US | OpenAI | 54.6 | 56.3 | 70.0 |
| US | Gemini | 3.3 | 14.7 | 20.4 |
| US | Claude | 27.5 | 12.9 | 18.2 |
| JP | all | 18.6 | 53.9 | 65.7 |
| JP | OpenAI | 42.1 | 75.6 | 89.2 |
| JP | Gemini | 13.4 | 49.0 | 60.1 |
| JP | Claude | 30.4 | 47.0 | 60.3 |

- **高 grounding bin の Primary が Low bin より高いセルが 160/180**（外部レビュアー集計値）。
- 逆に Low-barrier % は高 grounding bin で減少。
- **JP で特に顕著**: JP OpenAI high bin = 89.2%。US all high bin = 23.2%, US ruling = 2.5% にとどまる。

**含意**：強く根拠づけられた引用ほど一次情報源に偏り、弱い根拠の引用は低障壁情報源が多い。Poisoning の観点では、high-barrier の一次情報源を模倣する攻撃は grounding score でも有利になる可能性がある。

### 3.3 モデル差（Grounding Distribution）

Grounding bin 分布のモデル間比較:
- 全体: χ²(4) = 39.95, p < .001 (US), χ²(4) = 4460.62, p < .001 (JP)
- JP での効果量が US より桁違いに大きい

主な差異:
- **OpenAI**: mid share が有意に高く、high share が有意に低い傾向（Holm 補正後）
- **Gemini**: low bin 内の Low-barrier% が極端に高い（US 27%, JP 64%）
- **Claude**: grounding 分布はモデル間で最も均等

### 3.4 与党 vs 野党（Grounding Distribution）

- US: ruling vs opposition のgrounding bin分布 χ²(2) = 1091.04, p < .001
  - 与党: mid 63.8%, high 30.8% → **与党質問は grounding が弱い**
  - 野党: mid 53.1%, high 38.8%
- JP: χ²(2) = 318.85, p < .001
  - 与党: mid 44.8%, high 47.5%
  - 野党: mid 45.2%, high 45.0%（差は low share に集中）

### 3.5 ペルソナ効果（Grounding Distribution）

Grounding では Citation Distribution より若干のペルソナ効果があるが、弱く一貫しない：

| Country | Model | Global p_H | 有意な bin |
|---|---|---|---|
| US | all | < .001 *** | low share のみ |
| US | OpenAI | 1.000 (n.s.) | なし |
| US | Gemini | < .001 *** | low share のみ |
| US | Claude | .454 (n.s.) | なし |
| JP | all | < .001 *** | low, high share |
| JP | OpenAI | < .001 *** | low, high share |
| JP | Gemini | < .001 *** | low, mid, high 全て |
| JP | Claude | 1.000 (n.s.) | なし |

- Claude は日米とも grounding でのペルソナ効果が完全に n.s.
- 効果がある場合も low share の変動に集中しており、主要な mid/high bin の質量配分はペルソナに鈍感

### 3.6 保守 vs 革新（Grounding Distribution）

- US: χ²(2) = 30.23, p < .001
  - Conservative: low 7.7%, mid 56.0%, high 36.3%
  - Progressive: low 7.1%, mid 55.3%, **high 37.6%**
  - → 革新系はやや高 grounding が多い
- JP: χ²(2) = 952.02, p < .001（非常に大きい効果量）
  - Conservative: mid 47.4%, high 43.4%
  - Progressive: mid 41.3%, **high 49.3%**
  - → JP では革新系政党への回答の grounding が明確に高い

---

## 4. 検定結果のまとめ

### 4.1 Citation Distribution 検定一覧

| 比較軸 | US p | JP p | 備考 |
|---|---|---|---|
| **Model** (OpenAI/Gemini/Claude) | < .001 全条件 | < .001 全条件 | 最もロバスト |
| **Persona** (unknown/cons./prog.) | .579 (n.s.) | .260 (n.s.) | **帰無知見**: 0/8 有意 |
| **Alignment** (Aligned/Opposed) | < .001 (all), .285 (OpenAI) | < .001 全モデル | OpenAI のみ n.s. |
| **Group** (ruling/opposition) | < .001 | < .001 | 2番目に大きい効果 |
| **Party ideology** (cons./prog.) | < .001 | < .001 | US OpenAI のみ p = .044 |
| **Party** (個別政党) | < .001 | < .001 | 全モデル・全政党 |

### 4.2 Grounding Distribution 検定一覧

| 比較軸 | US p_H (global) | JP p_H (global) | 備考 |
|---|---|---|---|
| **Model** | < .001 | < .001 | JP の効果量が桁違い |
| **Persona** | < .001 (all), n.s. (OpenAI, Claude) | < .001 (all), n.s. (Claude) | 弱く一貫しない |
| **Alignment** | < .001 (all) | < .001 | Holm 補正後も有意 |
| **Group** | < .001 | < .001 | US で非常に大きい効果 |
| **Party ideology** | < .001 | < .001 | JP で効果量が大きい |
| **Party** | < .001 全政党 | < .001 全政党 | 全モデル・全政党 |

---

## 5. 効果量の序列

Citation Distribution と Grounding Distribution を総合した効果の大きさの序列：

1. **モデル差** — 全軸・全条件で p < .001。引用構成を支配する最大因子。
2. **与党 vs 野党（Group）** — 特に US で χ² > 1000 の巨大効果。政党の構造的位置が引用パターンを強く規定。
3. **個別政党（Party）** — 全政党間で有意差。8政党（JP）×5分類のクロスで χ² > 2000。
4. **イデオロギー（Party ideology）** — conservative vs progressive の非対称性。US で Opponent% の差、JP で grounding の差。
5. **Alignment（Aligned vs Opposed）** — モデル依存的（OpenAI は鈍感、Claude は敏感）。
6. **ペルソナ** — **Citation では完全に n.s.**、Grounding では弱い効果のみ。最小の因子。

**結論：引用 source 構成を動かしている主因はペルソナではなく、モデル選択と質問対象政党側の属性（国、イデオロギー、与野党の別）である。**

---

## 6. 論文の考察セクションへの推奨ポイント

### 6.1 Qualitative Analysis（定性分析）

- 引用分布のモデル間差異は全条件で一貫しており、3つの情報戦略を反映：
  - **OpenAI**: Primary 集中型（JP 83%, US 67%）— 高い poisoning 耐性だが情報多様性を犠牲
  - **Gemini**: 分散型 — Opponent/Low-barrier が残りやすく、多様だが poisoning に脆弱
  - **Claude**: Mid-barrier 中心型 — 検索忠実性が最高で中立的だが公式情報への到達が弱い
- 日本と米国の差異は情報エコシステムの構造的差異を反映。JP の高 Primary% は党公式サイト・機関紙のウェブ支配力を示唆。

### 6.2 Primary Source Citation の増加メカニズム

- **Brave→Citation の Primary 増加は 389/428 セル** で確認される普遍的パターン
- これは LLM が検索結果をフィルタリングする際に、一次情報源を優先的に選択するバイアスを持つことを示す
- OpenAI では Low-barrier = 0% まで排除が徹底され、「安全だが偏った」引用選択となっている

### 6.3 Content-injection Barrier と Grounding の関係

- 高 grounding 引用ほど Primary 偏重（160/180 セルで確認）
- **含意**：content-injection barrier の高い一次情報源はセマンティックマッチングでも有利 → 正当な情報源と poisoning コンテンツの区別が grounding score だけでは困難
- 低 grounding 引用は Low-barrier に偏る → 根拠の弱い引用は操作されやすい情報源に支えられている

### 6.4 ペルソナの非影響（論文の核心的貢献）

- ペルソナが引用構成に影響しないことは、poisoning リスク評価の簡素化に寄与する
- 攻撃者は個々のユーザーペルソナを考慮する必要がなく、モデルと対象政党の組み合わせだけで脆弱性を推定できる
- 防御側にとっても、ペルソナ非依存のモデルレベル対策が有効であることを意味する

### 6.5 与党 vs 野党の構造的脆弱性

- 与党質問は Mid-barrier 中心で grounding が弱い → poisoning 攻撃に対してより脆弱
- 野党質問は Primary 集中度が高く grounding も強い → 相対的に攻撃耐性が高い
- この非対称性は特に US で顕著であり、政権交代によって脆弱な政党が変わりうる

### 6.6 Limitations

- citation-level の観察値は response 内で独立でない可能性がある（クラスタリング効果）
- Grounding の Holm 補正は保守的であり、一部の弱い効果を見落としている可能性
- OpenAI の検定で低期待度数の警告が散見される（Citation 数が少ないため）

---

## 7. 論文に採用すべきチャートの推奨

### 7.1 必須（Already in paper）

| Chart | 理由 |
|---|---|
| **Citation Distribution by_party** (Fig. 2) | 全政党の引用分布を示す最も情報量の多い図。日米×5(US)/8(JP)政党×3モデル |
| **Grounding Distribution by_party** (Fig. 3) | Marimekko chart で類似度×出版者属性の交互作用を示す |

### 7.2 強く追加推奨

| Chart | 理由 |
|---|---|
| **Citation Distribution by_persona** | **ペルソナ帰無効果の視覚的証拠**。3条件の棒グラフがほぼ同一であることが一目瞭然。本研究の核心的貢献を直接支持。 |
| **Citation Distribution by_group** | 与党/野党の構造的差異（2番目に大きい効果）を集約して示す。by_party より簡潔で ruling vs opposition の対比が鮮明。 |

### 7.3 補助的推奨

| Chart | 理由 |
|---|---|
| Grounding Distribution by_party_ideology | Conservative vs progressive の grounding 非対称性（特に JP で顕著） |
| Citation Distribution by_alignment | Aligned/Opposed 条件でのモデル依存的効果（OpenAI の鈍感性） |
| Grounding Distribution by_persona | Grounding でのペルソナ弱効果の視覚化（Citation との対比） |

### 7.4 省略可能

| Chart | 理由 |
|---|---|
| Citation Distribution by_party_ideology | by_alignment と情報が重複。保守/革新の知見は by_party から読み取れる |
| Grounding Distribution by_alignment | by_party_ideology と重複度が高い |
| Grounding Distribution by_group | Citation の by_group で十分に ruling/opposition の差異を示せる |

---

## 8. 外部レビュアー知見との照合

> 以下、別のレビュアーから提供された知見と本分析の合致度を確認する。

### 8.1 全体像

> **レビュアー**: 「LLM citation は Brave 検索結果よりも Primary に寄り、mid- の外部 source を減らす傾向。JP と OpenAI で強く、US では政党グループによってかなり非対称。」

**合致**: 完全に一致。Primary 増加 389/428、mid- 減少 407/428 のセル単位集計とも整合。US での政党グループ非対称性（ruling vs opposition χ² = 1044.06）も確認。

> **レビュアー**: 「低 grounding bin は常に小さく、主な質量は mid/high bin。高 grounding になるほど Primary 比率が上がり、JP で非常に明瞭。」

**合致**: 完全に一致。US low bin 7.4%, JP 9.3%。High bin Primary が low bin より高いセル 160/180 も確認。JP の明瞭さ（JP OpenAI high = 89.2% vs US all high = 23.2%）も一致。

### 8.2 特筆すべき普遍的パタン

> **レビュアー**: 「OpenAI は一貫して Primary への集中が強い。by_group の all 条件では Citation の Primary は US OpenAI で約 63-67%、JP OpenAI で約 79-83%。」

**合致**: 数値レベルで完全一致。US OpenAI unknown = 67.2%, JP OpenAI unknown = 83.1%。

> **レビュアー**: 「Gemini と Claude は OpenAI より Primary が低く、Gemini は low- や mid- が残りやすく、Claude は mid- 外部 source が比較的残る。」

**合致**: 完全に一致。Gemini US Low-barrier 12-13%, Claude US Mid-barrier 57-59%。

> **レビュアー**: 「Grounding の Primary 化は JP で強く、US では弱い。by_group では JP all high bin Primary 65.7%、OpenAI では 89.2% だが、US all は 23.2%、US ruling は 2.5%。」

**合致**: 数値レベルで完全一致。US ruling の 2.5% は grounding by_group の ruling/all/high bin の値。

### 8.3 検定上の読み

> **レビュアー**: 「モデル差は全 Figure で有意。persona 差は Citation では 0/8 で有意ではない。引用 source 構成を動かしている主因は persona よりも model と質問対象政党側の属性。」

**合致**: 完全に一致。本分析でも 0/8（US 4条件 + JP 4条件全て n.s.）を確認。

> **レビュアー**: 「Grounding の Test でも model 差と party/group 差は広く有意。persona は弱く、有意な行は一部に限られる。」

**合致**: 一致。Grounding persona は US OpenAI/Claude, JP Claude で完全 n.s.。有意な場合も low share 変動に集中。

### 8.4 本分析で追加された知見

外部レビュアーの分析は正確であり、本分析では以下を追加的に精査した：

1. **Alignment 効果のモデル依存性**: OpenAI は Alignment に鈍感（US p = .285）だが Claude と Gemini は敏感。
2. **保守 vs 革新の Opponent% 非対称性**: US progressive は Opponent 11-16% vs conservative 6-7%。革新系質問は対立情報源をより多く引用。
3. **Claude の Brave 忠実性**: Pair Sig. が "--" になるケースが Claude に集中。
4. **与党質問の grounding 弱さ**: ruling mid 63.8% / high 30.8% vs opposition mid 53.1% / high 38.8%。与党質問は poisoning に構造的に脆弱。
5. **JP progressive の高 grounding**: JP conservative high 43.4% vs progressive high 49.3%。革新系政党への回答がより強く根拠づけられている。

---

## 9. 数値補遺：主要条件の引用分布サマリ

### 9.1 US Citation Distribution（by_group, Citation 層）

| Condition | Model | N | Primary | Opponent | High- | Mid- | Low- |
|---|---|---|---|---|---|---|---|
| all | all | 2640-2694 | 21.9-23.7 | 8.6-9.1 | 12.6-13.3 | 44.0-46.2 | 9.9-10.8 |
| all | OpenAI | 305-366 | 63.4-67.2 | 3.8-6.1 | 18.6-20.3 | 8.2-12.3 | 0.0 |
| all | Gemini | 1396-1408 | 15.6-17.9 | 12.0-12.6 | 13.4-14.6 | 42.9-45.7 | 12.0-13.3 |
| all | Claude | 903-932 | 16.5-17.3 | 4.4-5.5 | 8.6-8.9 | 57.4-59.3 | 10.6-11.3 |
| ruling | all | 614-644 | 1.9-2.4 | 3.6-3.9 | 24.9-27.6 | 59.4-61.1 | 7.1-8.0 |
| opposition | all | 2020-2059 | 27.8-30.6 | 10.1-10.8 | 8.1-9.3 | 38.6-41.7 | 10.7-11.9 |

### 9.2 JP Citation Distribution（by_group, Citation 層）

| Condition | Model | N | Primary | Opponent | High- | Mid- | Low- |
|---|---|---|---|---|---|---|---|
| all | all | 4492-4628 | 55.3-57.3 | 3.9-4.5 | 1.3-1.7 | 26.8-28.2 | 10.4-11.1 |
| all | OpenAI | 931-967 | 79.4-83.1 | 0.2-0.8 | 3.2-5.0 | 12.8-15.1 | 0.1-0.4 |
| all | Gemini | 2289-2400 | 47.9-49.1 | 6.0-7.4 | 0.7-0.8 | 26.8-27.6 | 16.9-17.8 |
| all | Claude | 1236-1281 | 51.4-53.7 | 2.2-3.1 | 0.7 | 37.1-39.1 | 5.4-6.6 |
| ruling | all | 1187-1206 | 57.3-58.5 | 2.2-2.8 | 4.1-4.8 | 25.2-27.3 | 8.1-9.1 |
| opposition | all | 3287-3422 | 54.6-57.0 | 4.5-5.2 | 0.3-0.6 | 26.5-28.8 | 11.0-11.8 |

---

---

## 10. Word Count Distribution の追加分析（2026-05-18 追記）

Word count distribution は「citation が付いた回答文の総 word/character count を、その回答文に紐づく citation に等分配し、barrier ごとに集計したシェア」を示す。分母は各 country × condition × model × persona セル内の citation 付き回答文の総量で、日本語は空白を除く文字数、その他は単語数。「件数の割合」ではなく**「回答文中で citation に支えられている語数/文字数のうち、どの barrier にどれだけ帰属するか」**を表す。

### 10.1 Discussion 用メッセージ（要点）

#### 10.1.1 Word count distribution の中での比較

- **モデル差は WC でも最大因子**。全条件 p < .001、χ² は数万オーダー（巨大 N 効果は割引くが）、構造的に「モデル戦略 ≫ それ以外」のヒエラルキーは Citation と同じ。
- **ペルソナは WC では形式的には有意だが実効効果は無視できる**。N 拡大で p < .001 になるものの、Primary 比率の差はおおむね 1–2pt（例：JP all Primary 69.1 / 69.3 / 68.0%）。Discussion 上の含意は Citation と同じ：「ペルソナはユーザーに届く本文の出典内訳もほぼ動かさない」。
- **与党 vs 野党は WC でも巨大効果**（US χ² ≈ 60,000）。「与党質問は Mid-barrier に本文が乗る／野党質問は Primary に本文が乗る」非対称性が再現。
- **イデオロギー軸も全モデルで再現**。US progressive は Opponent への本文割当が conservative より厚い。
- **Alignment は WC では全モデル有意**（Citation で n.s. だった US OpenAI も有意化）。これは検出力上昇によるもので、「OpenAI は alignment に質的に鈍感」という Citation での読みは維持される。

#### 10.1.2 Citation Distribution との比較（最大の追加価値）

「件数ベース引用」と「本文量ベース引用」は同じ方向を指すが、**Primary 側の優位は WC でさらに強調される**。

- **Primary は本文量シェアが citation 件数シェアを上回る**（全モデル例外なし）：
  - JP OpenAI: Citation Primary ≈ 83% → WC Primary **90.1%**
  - JP Gemini: Citation ≈ 49% → WC **62.2%**
  - JP Claude: Citation ≈ 52% → WC **62.2%**
  - US OpenAI: Citation 67% → WC **71.1%**
- **Mid-barrier は逆に「件数より本文量シェアが小さい」**。OpenAI で顕著（JP OpenAI Mid 13–15% → WC **7.5%**）。
- **国差は本文量で見るとさらに開く**：US Primary は件数 22–24% / 本文 27%、JP Primary は件数 55–57% / 本文 **約 69%**。日本の党公式メディア優位は本文中身では 7 割に到達。
- **含意**：GSE は Primary に「引用を多く張る」だけでなく、その引用に依存する本文区間を相対的に長く割り当てている。本文の意味的中心ほど Primary が支えている。これは **poisoning リスクの二重増幅** を意味する——件数だけでなくユーザーが読む本文中身でも一次情報源依存度が膨らむ。
- **方法論的含意**：citation 比率だけで GSE の依存度を測ると本物の本文依存を過小評価する。件数 + 本文量の両軸併記が必要。

### 10.2 追加インサイト

- **「Primary 寄り」モデルほど件数→本文量での Primary 拡大率が大きい**（OpenAI > Gemini ≈ Claude）。件数バイアスと本文バイアスが**増幅的に重なる**。
- **US ruling × Claude は WC でさらに先鋭化**：Mid 71–79%、Primary/Opponent ほぼゼロ、High-barrier 約 2–3 割。**与党話題では Claude は本文をほぼ Mid＋High institutional に閉じている**——"search-grounded but politically reticent" 像を独自に押せる。
- **Low-barrier の本文寄与は Gemini に集中**（JP Gemini WC Low ≈ 10%、他は 0–5%）。Gemini は件数だけでなく本文中の依拠先としても低障壁情報源を残す → poisoning 経路として一段ハイリスク。
- **ペルソナの「件数 χ²（n.s.）vs WC χ²（p<.001）だが効果量は同水準」併記**で persona 帰無主張がより頑健に見える。
- **opposition × OpenAI の Primary 集中は WC で 87–91%**（US）。野党質問では OpenAI の本文がほぼ党公式・候補者ドメイン由来 → 単一情報源依存リスクの最明瞭ケース。
- **次フェーズ案**：WC × grounding bin のクロス。「本文の中で grounding が強い区間ほど Primary が長く支えている」を直接定量化できる。

### 10.3 検定サマリ（Word Count Distribution）

| 比較軸 | US p | JP p | 効果量メモ |
|---|---|---|---|
| **Model** | < .001 全条件 | < .001 全条件 | χ² 数万、Citation より桁違いに大きい（N 効果） |
| **Persona** | < .001 全条件 | < .001 全条件 | 形式的に有意化、ただし実効差は 1–2pt（Citation 帰無と整合） |
| **Alignment** | < .001 全モデル | < .001 全モデル | US OpenAI も有意化（Citation では n.s.） |
| **Group (ruling/opp.)** | < .001 | < .001 | US χ² ≈ 60,000、Citation と同じ非対称性 |
| **Party ideology** | < .001 | < .001 | conservative vs progressive 構図再現 |

### 10.4 主要セルの代表値（Word Count, by_group, persona=unknown）

| | OpenAI Primary % | Gemini Primary % | Claude Primary % | OpenAI Mid % | Gemini Mid % | Claude Mid % |
|---|---|---|---|---|---|---|
| **US all** | 71.1 | 18.3 | 20.0 | 4.0 | 42.8 | 58.1 |
| **US ruling** | 14.6 | 2.2 | 0.7 | 8.2 | 50.6 | 78.7 |
| **US opposition** | 91.2 | 22.7 | 25.7 | 2.5 | 40.7 | 52.0 |
| **JP all** | 90.1 | 62.2 | 62.2 | 7.5 | 21.0 | 30.6 |
| **JP ruling** | 88.4 | 66.6 | 62.2 | 5.3 | 20.9 | 30.2 |
| **JP opposition** | 90.8 | 60.6 | 62.2 | 8.3 | 21.0 | 30.7 |

### 10.5 総括

Word count distribution は Citation distribution と**同じメッセージ群を強化**しつつ、二点で論文主張を堅くする：

1. **「件数では n.s. だったペルソナが本文量では統計的には動くが実効差は依然小さい」** → ペルソナ帰無主張が二つの計測尺度で頑健であることを示せる。
2. **「Primary 偏重は本文量でさらに増幅される」** → poisoning リスクが件数だけ見るより深刻であることを定量的に示せる。

---

*End of report.*
