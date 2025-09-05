// Translation disclaimer template for blog localization
// Generates disclaimer notices for LLM-translated content
#let language-switch(lang: "en") = {
  if lang == "zh" { return "en" } else { "zh" }
}

#let translation-disclaimer-old(original-path: "", lang: "en") = {
  let out-lang = language-switch(lang: lang)
  let path = original-path + "?explicit_lang=" + out-lang
  let disclaimer-text = if lang == "zh" [
    #text(fill: rgb("#888"), size: 0.9em)[
      📝 *翻译声明：* 本文由 LLM 从原文翻译而来，可能存在翻译不准确之处。建议阅读 #link(path)[原文] 以获得最准确的内容。
    ]
  ] else [
    #text(fill: rgb("#888"), size: 0.9em)[
      📝 *Translation Notice:* This article was translated from the original by LLM and may contain inaccuracies. Please refer to the #link(path)[original article] for the most accurate content.
    ]
  ]

  // Add some spacing and styling
  v(0.5em)
  block(
    width: 100%,
    inset: 12pt,
    radius: 6pt,
    fill: rgb("#f8f9fa"),
    stroke: (left: 3pt + rgb("#007acc")),
    disclaimer-text,
  )
  v(1em)
}

#let translation-disclaimer-new(original-path: "", lang: "en") = {
  let out-lang = language-switch(lang: lang)
  let path = (
    "../../" + out-lang + "/" + original-path + "?explicit_lang=" + out-lang
  )
  let disclaimer-text = if lang == "zh" [
    #text(fill: rgb("#888"), size: 0.9em)[
      📝 *翻译声明：* 本文由 LLM 从原文翻译而来，可能存在翻译不准确之处。建议阅读 #link(path)[原文] 以获得最准确的内容。
    ]
  ] else [
    #text(fill: rgb("#888"), size: 0.9em)[
      📝 *Translation Notice:* This article was translated from the original by LLM and may contain inaccuracies. Please refer to the #link(path)[original article] for the most accurate content.
    ]
  ]

  // Add some spacing and styling
  v(0.5em)
  block(
    width: 100%,
    inset: 12pt,
    radius: 6pt,
    fill: rgb("#f8f9fa"),
    stroke: (left: 3pt + rgb("#007acc")),
    disclaimer-text,
  )
  v(1em)
}

#let translation-disclaimer(original-path: "", lang: "en") = {
  if original-path.starts-with("../../") {
    translation-disclaimer-old(
      original-path: original-path,
      lang: lang,
    )
  } else {
    translation-disclaimer-new(original-path: original-path, lang: lang)
  }
}
