#import "@preview/shiroa:0.2.3": (
  is-html-target, is-pdf-target, is-web-target, plain-text, templates,
)
#import "./shared.typ": translation-disclaimer
#import "./target.typ": *
#let sys-is-html-target = ("target" in dictionary(std))
#let is-html-target = is-html-target()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target() or sys-is-html-target
#let is-md-target = target == "md"

// Translation disclaimer template for blog localization
// Generates disclaimer notices for LLM-translated content
#let language-switch(lang: "en") = {
  if lang == "zh" { return "en" } else { "zh" }
}

#let translation-disclaimer-old(original-path: "", lang: "en") = {
  let out-lang = language-switch(lang: lang)
  let path = original-path + "?lang=" + out-lang
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

#let translation-disclaimer-new(
  original-path: "",
  lang: "en",
  target: "pdf",
) = {
  let out-lang = language-switch(lang: lang)
  let path = "../../" + out-lang + "/" + original-path + "/?lang=" + out-lang

  if target == "web" {
    if lang == "zh" {
      html.elem(
        "div",
        attrs: (
          class: "translation-disclaimer",
          style: "margin:0.75em 0;padding:0.75em 0.9em;border-left:3px solid #007acc;background:#f8f9fa;border-radius:6px;color:#666;font-size:0.9em;line-height:1.35",
        ),
        [
          📝 #emph[翻译声明：] 本文由 LLM 从原文翻译而来，可能存在翻译不准确之处。建议阅读 #link(path)[原文] 以获得最准确的内容。
        ],
      )
    } else {
      html.elem(
        "div",
        attrs: (
          class: "translation-disclaimer",
          style: "margin:0.75em 0;padding:0.75em 0.9em;border-left:3px solid #007acc;background:#f8f9fa;border-radius:6px;color:#666;font-size:0.9em;line-height:1.35",
        ),
        [
          📝 #emph[Translation Notice:] This article was translated from the original by LLM and may contain inaccuracies. Please refer to the #link(path)[original article] for the most accurate content.
        ],
      )
    }
  } else {
    let disclaimer-text = if lang == "zh" [
      #text(fill: rgb("#888"), size: 0.9em)[
        📝 *翻译声明：* 本文由 LLM 从原文翻译而来，可能存在翻译不准确之处。建议阅读 #link(path)[原文] 以获得最准确的内容。
      ]
    ] else [
      #text(fill: rgb("#888"), size: 0.9em)[
        📝 *Translation Notice:* This article was translated from the original by LLM and may contain inaccuracies. Please refer to the #link(path)[original article] for the most accurate content.
      ]
    ]

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
}

#let get-target() = {
  let target = if is-html-target {
    return "html"
  } else if is-web-target {
    return "web"
  } else if is-pdf-target {
    return "pdf"
  } else {
    return "other"
  }
}

#let translation-disclaimer(original-path: "", lang: "en") = {
  translation-disclaimer(
    original-path: original-path,
    lang: lang,
    target: get-target(),
  )
}
