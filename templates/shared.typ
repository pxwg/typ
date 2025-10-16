#import "../packages/typst-fletcher.typ": *
#import "../packages/zebraw.typ": *
#import "@preview/shiroa:0.2.3": (
  is-html-target, is-pdf-target, is-web-target, plain-text, templates,
)
#import templates: *
#import "mod.typ": *
#import "theme.typ": *

// Settings
// todo: load from env or config?
#let use-mathyml = false

#import "../packages/mathyml.typ": prelude
#import "empty.typ" as _empty
#import if use-mathyml { prelude } else { _empty }: *

// Metadata
#let is-html-target = is-html-target()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target() or sys-is-html-target
#let is-md-target = target == "md"
#let sys-is-html-target = ("target" in dictionary(std))

#let default-kind = "post"
// #let default-kind = "monthly"

#let build-kind = sys.inputs.at("build-kind", default: default-kind)

#let pdf-fonts = (
  "STIX Two Text",
  // todo: exclude it if language is not Chinese.
  "Source Han Serif SC",
)

#let math-font = "STIX Two Math"

#let code-font = (
  "DejaVu Sans Mono",
)

// Sizes
#let main-size = if sys-is-html-target {
  16.5pt
} else {
  10.5pt
}
// ,
#let heading-sizes = (22pt, 18pt, 14pt, 12pt, main-size)
#let list-indent = 0.5em
#let math-size = 12pt

/// Creates an embedded block typst frame.
#let div-frame(content, attrs: (:), tag: "div") = html.elem(
  tag,
  html.frame(content),
  attrs: attrs,
)
#let span-frame = div-frame.with(tag: "span")
#let p-frame = div-frame.with(tag: "p")

// defaults
#let (
  style: theme-style,
  is-dark: is-dark-theme,
  is-light: is-light-theme,
  main-color: main-color,
  dash-color: dash-color,
  code-extra-colors: code-extra-colors,
) = default-theme

#let markup-rules(body, lang: none, region: none) = {
  set text(lang: lang) if lang != none
  set text(region: region) if region != none
  set text(font: pdf-fonts)

  set text(main-size) if sys-is-html-target
  set text(fill: rgb("dfdfd6")) if is-dark-theme and sys-is-html-target
  show link: set text(fill: dash-color)

  show heading: it => {
    set text(size: heading-sizes.at(it.level))

    block(
      spacing: 0.7em * 1.5 * 1.2,
      below: 0.7em * 1.2,
      {
        if is-web-target {
          show link: static-heading-link(it)
          heading-hash(it, hash-color: dash-color)
        }

        it
      },
    )
  }

  body
}

#let equation-rules(body) = {
  show math.equation: set text(font: math-font)
  show math.equation.where(block: true): it => context if (
    shiroa-sys-target() == "html"
  ) {
    theme-frame(
      tag: "div",
      theme => {
        set text(fill: theme.main-color, size: math-size, font: math-font)
        p-frame(attrs: ("class": "block-equation", "role": "math"), it)
      },
    )
  } else {
    it
  }
  show math.equation.where(block: false): it => context if (
    shiroa-sys-target() == "html"
  ) {
    theme-frame(
      tag: "span",
      theme => {
        set text(fill: theme.main-color, size: math-size, font: math-font)
        span-frame(attrs: (class: "inline-equation"), it)
      },
    )
  } else {
    it
  }
  body
}

// https://codeberg.org/akida/mathyml
#let mathyml-equation-rules(body) = {
  // import "../packages/mathyml.typ" as mathyml: try-to-mathml
  //
  // // math rules
  // show math.equation: try-to-mathml
  // show math.equation: set text(weight: 500)
  // // show math.equation: to-mathml
  // mathyml.stylesheets(include-fonts: false)


  body
}

#let code-block-rules(body) = {
  let init-with-theme((code-extra-colors, is-dark)) = if is-dark {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      highlight-color: rgb("#3d59a1"),
      comment-color: rgb("#394b70"),
      lang-color: rgb("#3d59a1"),
      lang: false,
      numbering: false,
    )
  } else {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      lang: false,
      numbering: false,
    )
  }

  /// HTML code block supported by zebraw.
  show: init-with-theme(default-theme)


  let mk-raw(
    it,
    tag: "div",
    inline: false,
  ) = theme-frame(
    tag: tag,
    theme => {
      show: init-with-theme(theme)
      let code-extra-colors = theme.code-extra-colors
      let use-fg = not inline and code-extra-colors.fg != none
      set text(fill: code-extra-colors.fg) if use-fg
      set text(fill: if theme.is-dark { rgb("dfdfd6") } else {
        black
      }) if not use-fg
      set raw(theme: theme-style.code-theme) if theme.style.code-theme.len() > 0
      set par(justify: false)
      zebraw(
        block-width: 100%,
        // line-width: 100%,
        wrap: false,
        it,
      )
    },
  )

  show raw: set text(font: code-font)
  show raw.where(block: false): it => context if (
    shiroa-sys-target() == "paged"
  ) {
    it
  } else {
    mk-raw(it, tag: "span", inline: true)
  }
  show raw.where(block: true): it => context if shiroa-sys-target() == "paged" {
    set raw(theme: theme-style.code-theme) if theme-style.code-theme.len() > 0
    rect(
      width: 100%,
      inset: (x: 4pt, y: 5pt),
      radius: 4pt,
      fill: code-extra-colors.bg,
      [
        #set text(fill: code-extra-colors.fg) if code-extra-colors.fg != none
        #set par(justify: false)
        // #place(right, text(luma(110), it.lang))
        #it
      ],
    )
  } else {
    mk-raw(it)
  }
  body
}

#let visual-rules(body) = {
  import "env.typ": url-base
  // Resolves the path to the image source
  let resolve(path) = (
    path.replace(
      // Substitutes the paths with some assumption.
      // In the astro sites, the assets are store in `public/` directory.
      regex("^[./]*/public/"),
      url-base,
    )
  )

  show image: it => context if shiroa-sys-target() == "paged" {
    it
  } else {
    html.elem("img", attrs: (src: resolve(it.source)))
  }

  body
}

#let default-archive-creator = (indices, body) => {
  indices
    .map(fname => include "/content/article/" + fname + ".typ")
    .join(pagebreak(weak: true))
}

/// sub-chapters is only used in monthly (archive) build.
#let shared-template(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "2024-08-15",
  tags: (),
  kind: "post",
  lang: none,
  region: none,
  show-outline: true,
  archive-indices: (),
  archive-creator: default-archive-creator,
  llm-translated: false,
  translationKey: "",
  body,
) = {
  let is-same-kind = build-kind == kind

  show: it => if is-same-kind {
    // set basic document metadata
    set document(
      author: ("Xinyu Xiang",),
      ..if not is-web-target { (title: title) },
    )

    // markup setting
    show: markup-rules.with(
      lang: lang,
      region: region,
    )
    // math setting
    show: if use-mathyml { mathyml-equation-rules } else { equation-rules }
    // code block setting
    show: code-block-rules
    // visualization setting
    show: visual-rules

    show: it => if sys-is-html-target {
      show footnote: it => context {
        let num = counter(footnote).get().at(0)
        link(label("footnote-" + str(num)), super(str(num)))
      }

      it
    } else {
      it
    }

    // Main body.
    set par(justify: true)
    it
  } else {
    it
  }

  show: it => if build-kind == "monthly" and is-same-kind {
    set page(numbering: "i")
    set heading(numbering: "1.1")
    it
  } else if build-kind == "monthly" and kind == "post" {
    set page(
      numbering: "1",
      header: context align(
        if calc.even(here().page()) { right } else { left },
        emph[
          #date -- #title
        ],
      ),
    ) if not sys-is-html-target
    set heading(offset: 1) if not sys-is-html-target // globally increase offset
    it
  } else {
    it
  }

  if is-same-kind and kind == "monthly" {
    align(
      center,
      {
        text(12pt, date)
        linebreak()
        strong(text(26pt, title))
        linebreak()
        text(16pt, desc)
      },
    )
    v(16pt)

    outline()
    pagebreak()
  }

  if build-kind == "monthly" and kind == "post" {
    show heading: set block(above: 0.2em, below: 0em)
    show heading: set text(size: 26pt)
    align(
      center,
      {
        text(12pt, date)
        linebreak()
        heading(numbering: none, title)
        counter(heading).step()
        linebreak()
        text(16pt, desc)
      },
    )
    v(16pt)
  }


  // todo monthly hack
  if kind == "monthly" or is-same-kind [
    #metadata((
      title: plain-text(title),
      author: "Xinyu Xiang",
      description: plain-text(desc),
      date: date,
      tags: tags,
      lang: lang,
      region: region,
      llm-translated: llm-translated,
      translationKey: translationKey,
      ..if kind == "monthly" {
        (indices: archive-indices)
      },
    )) <frontmatter>
  ]

  // Add llm-translated metadata as HTML data attribute for Astro
  context if is-same-kind and sys-is-html-target and llm-translated {
    html.elem(
      "meta",
      attrs: (
        name: "llm-translated",
        content: "true",
      ),
    )
  }

  context if show-outline and is-same-kind and sys-is-html-target {
    if query(heading).len() == 0 {
      return
    }

    let outline-counter = counter("html-outline")
    outline-counter.update(0)
    show outline.entry: it => html.elem(
      "div",
      attrs: (
        class: "outline-item x-heading-" + str(it.level),
      ),
      {
        outline-counter.step(level: it.level)
        static-heading-link(
          it.element,
          body: [#sym.section#context outline-counter.display(
              "1.",
            ) #it.element.body],
        )
      },
    )
    html.elem(
      "div",
      attrs: (
        class: "outline",
      ),
      outline(title: none),
    )
    html.elem("hr")
  }

  if kind == "monthly" {
    archive-creator(archive-indices, body)
  } else {
    body
  }

  context if is-same-kind and sys-is-html-target {
    query(footnote)
      .enumerate()
      .map(((idx, it)) => {
        enum.item[
          #html.elem(
            "div",
            attrs: ("data-typst-label": "footnote-" + str(idx + 1)),
            it.body,
          )
        ]
      })
      .join()
  }
}

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

  // HTML / web target: use theme-frame so colors follow dynamic theme switching (like code blocks)
  if target == "web" or target == "html" {
    theme-frame(
      tag: "div",
      theme => {
        // derive colors from theme (fallbacks similar to code block logic)
        let border-color = theme.dash-color.to-hex()
        let bg-color = if theme.is-dark {
          if theme.code-extra-colors.bg != none {
            theme.code-extra-colors.bg.to-hex()
          } else { "#202225" }
        } else {
          if theme.code-extra-colors.bg != none {
            theme.code-extra-colors.bg.to-hex()
          } else { "#f8f9fa" }
        }
        let text-color = if theme.is-dark {
          if theme.code-extra-colors.fg != none {
            theme.code-extra-colors.fg.to-hex()
          } else { "#bbbbbb" }
        } else { "#666666" }

        let style-str = (
          "margin:0.75em 0;padding:0.75em 0.9em;"
            + "border-left:3px solid "
            + str(border-color)
            + ";"
            + "background:"
            + str(bg-color)
            + ";"
            + "border-radius:6px;"
            + "color:"
            + str(text-color)
            + ";"
            + "font-size:0.9em;line-height:1.35"
        )

        html.elem(
          "div",
          attrs: (
            class: "translation-disclaimer",
            style: style-str,
          ),
          if lang == "zh" [
            📝 #emph[翻译声明：] 本文由 LLM 从原文翻译而来，可能存在翻译不准确之处。建议阅读 #link(path)[原文] 以获得最准确的内容。
          ] else [
            📝 #emph[Translation Notice:] This article was translated from the original by LLM and may contain inaccuracies. Please refer to the #link(path)[original article] for the most accurate content.
          ],
        )
      },
    )
  } else {
    let border-color = dash-color
    let bg-color = if is-dark-theme {
      if code-extra-colors.bg != none { code-extra-colors.bg } else {
        "#202225"
      }
    } else {
      if code-extra-colors.bg != none { code-extra-colors.bg } else {
        "#f8f9fa"
      }
    }
    let text-color = if is-dark-theme {
      if code-extra-colors.fg != none { code-extra-colors.fg } else {
        "#bbbbbb"
      }
    } else { "#666666" }

    let disclaimer-text = if lang == "zh" [
      #text(fill: text-color, size: 0.9em)[
        📝 *翻译声明：* 本文由 LLM 从原文翻译而来，可能存在翻译不准确之处。建议阅读 #link(path)[原文] 以获得最准确的内容。
      ]
    ] else [
      #text(fill: text-color, size: 0.9em)[
        📝 *Translation Notice:* This article was translated from the original by LLM and may contain inaccuracies. Please refer to the #link(path)[original article] for the most accurate content.
      ]
    ]

    v(0.5em)
    block(
      width: 100%,
      inset: 12pt,
      radius: 6pt,
      fill: bg-color,
      stroke: (left: 3pt + border-color),
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
  let target = get-target()
  if original-path.starts-with("../../") {
    translation-disclaimer-old(
      original-path: original-path,
      lang: lang,
    )
  } else {
    translation-disclaimer-new(
      original-path: original-path,
      lang: lang,
      target: target,
    )
  }
}

#let block_with_color(
  content: "",
  icon: "📌",
  title: "本节概要",
) = {
  let target = get-target()
  // html / web target: use theme-frame so colors follow dynamic theme switching (like code blocks)
  if target == "web" or target == "html" {
    theme-frame(
      tag: "div",
      theme => {
        let border-color = theme.dash-color.to-hex()
        let bg-color = if theme.is-dark {
          if theme.code-extra-colors.bg != none {
            theme.code-extra-colors.bg.to-hex()
          } else { "#202225" }
        } else {
          if theme.code-extra-colors.bg != none {
            theme.code-extra-colors.bg.to-hex()
          } else { "#f8f9fa" }
        }
        let text-color = if theme.is-dark {
          if theme.code-extra-colors.fg != none {
            theme.code-extra-colors.fg.to-hex()
          } else { "#e8e8e8" }
        } else { "#2c3e50" }

        let title-color = if theme.is-dark { "#5dade2" } else { "#3498db" }

        let style-str = (
          "margin:0.75em 0;padding:0;"
            + "font-size:0.95em;line-height:1.5"
            + ";border-left:4px solid "
            + str(border-color)
            + ";"
            + "background:"
            + str(bg-color)
            + ";"
            + "border-radius:8px;"
            + "color:"
            + str(text-color)
            + ";"
            + "box-shadow:0 2px 8px rgba(0,0,0,0.08);"
        )

        let title-style = (
          "display:flex;align-items:center;gap:0.5em;"
            + "padding:0.6em 0.9em;margin:0;"
            + "font-weight:600;font-size:0.95em;"
            + "color:"
            + str(title-color)
            + ";"
            + "border-bottom:1px solid rgba(128,128,128,0.15);"
        )

        let content-style = (
          "padding:0.75em 0.9em;"
        )

        html.elem(
          "div",
          attrs: (
            class: "colored-block",
            style: style-str,
          ),
          [
            #html.elem("div", attrs: (style: title-style), [
              #html.elem("span", attrs: (style: "font-size:1.1em;"), icon)
              #html.elem("span", title)
            ])
            #html.elem("div", attrs: (style: content-style), content)
          ],
        )
      },
    )
  } else {
    let border-color = dash-color
    let bg-color = if is-dark-theme {
      if code-extra-colors.bg != none { code-extra-colors.bg } else {
        "#202225"
      }
    } else {
      if code-extra-colors.bg != none { code-extra-colors.bg } else {
        "#f8f9fa"
      }
    }
    let text-color = if is-dark-theme {
      if code-extra-colors.fg != none { code-extra-colors.fg } else {
        "#e8e8e8"
      }
    } else { "#2c3e50" }

    block(
      width: 100%,
      inset: (left: 12pt, right: 12pt, top: 10pt, bottom: 10pt),
      radius: 8pt,
      fill: bg-color,
      stroke: (left: 4pt + border-color),
      [
        #text(fill: rgb("#3498db"), weight: "bold", size: 0.95em)[#icon #title]
        #v(0.3em)
        #text(fill: text-color, size: 0.95em)[#content]
      ],
    )
  }
}


#let pdf_viewer(path: "") = {
  let target = get-target()
  if target == "html" or target == "web" {
    html.elem(
      "div",
      attrs: (
        class: "pdf-viewer",
        style: "width:auto;height:auto;margin:0.1rem;display:flex;align-items:center;justify-content:center;overflow:auto;background:transparent;",
      ),
      [
        #html.elem(
          "iframe",
          attrs: (
            src: path,
            type: "application/pdf",
            style: "max-width:70vw;width:auto;height:60vh;min-height:40vh;border:none;display:block;overflow:auto;",
            allowfullscreen: "true",
          ),
        )
      ],
    )
  } else {
    link(path)[Open PDF]
  }
}

// Display an image with adaptive dark mode support.
//
// Parameters:
// - path (str): Path to the image file
// - desc (str): Optional description text below the image
// - dark-adapt (bool): Whether to apply dark mode adaptation (default: false)
// - adapt-mode (str): Dark mode adaptation strategy (default: "darken")
//   * "invert": Full inversion with hue rotation (best for pure white backgrounds)
//   * "invert-no-hue": Invert brightness only, preserving hue (best for colored diagrams)
//   * "darken": Reduce brightness and increase contrast (best for general use)
#let image_viewer(
  path: "",
  desc: "",
  dark-adapt: false,
  adapt-mode: "darken",
) = {
  let target = get-target()
  if target == "html" or target == "web" {
    theme-frame(
      tag: "div",
      theme => {
        let img-filter = if dark-adapt and theme.is-dark {
          if adapt-mode == "invert" {
            "invert(1) hue-rotate(180deg)"
          } else if adapt-mode == "invert-no-hue" {
            "invert(1)"
          } else if adapt-mode == "darken" {
            "brightness(0.8) contrast(1.1)"
          } else {
            "none"
          }
        } else {
          "none"
        }

        // Description text color follows theme
        let desc-color = if theme.is-dark {
          "#aaa"
        } else {
          "#888"
        }

        html.elem(
          "div",
          attrs: (
            class: "image-viewer",
            style: "width:auto;height:auto;margin:min(0.5em,max(0.1em,3vw));display:flex;flex-direction:column;align-items:center;justify-content:center;overflow:auto;padding:0.5em;",
          ),
          [
            #html.elem(
              "img",
              attrs: (
                src: path,
                style: "max-width:60vw;max-height:200px;width:auto;height:auto;display:block;object-fit:contain;border-radius:0.5em;filter:"
                  + img-filter
                  + ";transition:filter 0.3s ease;",
                loading: "lazy",
                alt: "image",
              ),
            )
            #if desc != "" {
              html.elem(
                "div",
                attrs: (
                  class: "image-desc",
                  style: "margin-top:0.5em;font-size:0.9em;color:"
                    + desc-color
                    + ";text-align:center;max-width:33vw;transition:color 0.3s ease;",
                ),
                [#desc],
              )
            }
          ],
        )
      },
    )
  } else {
    if desc != "" {
      link(path)[open image] + [ (#desc)]
    } else {
      link(path)[open image]
    }
  }
}

#let image_gallery(paths: (), desc: "") = {
  let target = get-target()
  if target == "html" or target == "web" {
    let gallery = html.elem(
      "div",
      attrs: (
        class: "image-gallery",
        style: "display:flex;flex-direction:row;overflow-x:auto;gap:1em;"
          + "padding:0.5em 0;background:transparent;align-items:center;justify-content:center;",
      ),
      paths
        .map(path => {
          html.elem(
            "img",
            attrs: (
              src: path,
              style: "max-width:300px;max-height:200px;width:auto;height:auto;display:block;object-fit:contain;border-radius:0.5em;flex:0 0 auto;",
              loading: "lazy",
              alt: "gallery image",
            ),
          )
        })
        .join(),
    )
    if desc != "" {
      [
        #gallery
        #html.elem(
          "div",
          attrs: (
            class: "gallery-desc",
            style: "margin-top:1em;font-size:1em;color:#888;text-align:center;width:100%;",
          ),
          [#desc],
        )
      ]
    } else {
      gallery
    }
  } else {
    let imgs = paths.map(path => link(path)[open image]).join([ ])
    if desc != "" {
      [#imgs (#desc)]
    } else {
      imgs
    }
  }
}

// Theorem-like environments with theme support
#let theorem-block(
  content,
  title: "Theorem",
  icon: "📐",
  number: none,
  border-color-light: rgb("#3498db"),
  border-color-dark: rgb("#5dade2"),
  bg-color-light: rgb("#e8f4f8"),
  bg-color-dark: rgb("#1a2332"),
  collapsible: false,
  collapsed: false,
) = {
  let target = get-target()
  if target == "web" or target == "html" {
    context {
      theme-frame(
        tag: "div",
        theme => {
          let border-color = if theme.is-dark {
            border-color-dark.to-hex()
          } else {
            border-color-light.to-hex()
          }

          let bg-color = if theme.is-dark {
            bg-color-dark.to-hex()
          } else {
            bg-color-light.to-hex()
          }

          let text-color = if theme.is-dark {
            "#e8e8e8"
          } else {
            "#2c3e50"
          }

          let title-color = if theme.is-dark {
            border-color-dark.to-hex()
          } else {
            border-color-light.to-hex()
          }

          let button-color = if theme.is-dark {
            "#95a5a6"
          } else {
            "#7f8c8d"
          }

          let style-str = (
            "margin:0.5em 0;padding:0;"
              + "border-left:3px solid "
              + str(border-color)
              + ";"
              + "background:"
              + str(bg-color)
              + ";"
              + "border-radius:4px;"
              + "color:"
              + str(text-color)
              + ";"
              + "box-shadow:0 1px 4px rgba(0,0,0,0.06);"
              + "transition:all 0.3s ease;"
          )

          let title-style = (
            "display:flex;align-items:center;gap:0.4em;"
              + "padding:0.4em 0.7em;margin:0;"
              + "font-weight:600;font-size:0.95em;"
              + "color:"
              + str(title-color)
              + ";"
              + "border-bottom:1px solid rgba(128,128,128,0.1);"
              + (
                if collapsible { "cursor:pointer;user-select:none;" } else {
                  ""
                }
              )
          )

          let button-style = (
            "border:none;background:transparent;"
              + "color:"
              + str(button-color)
              + ";"
              + "font-size:1.2em;padding:0;margin:0 0 0 auto;"
              + "transition:transform 0.2s ease,opacity 0.3s ease;"
              + "opacity:0.7;line-height:1;"
              + "pointer-events:none;"
          )

          let content-wrapper-style = if collapsible and collapsed {
            (
              "overflow:hidden;transition:max-height 0.3s ease,opacity 0.3s ease;"
                + "max-height:0px;opacity:0;"
            )
          } else {
            (
              "overflow:hidden;transition:max-height 0.3s ease,opacity 0.3s ease;"
                + "max-height:1000px;opacity:1;"
            )
          }

          let content-style = "padding:0.3em 0.7em;line-height:1.5;font-size:0.95em;"

          let full-title = if number != none {
            title + " " + str(number)
          } else {
            title
          }

          let initial-button-text = if collapsed { "+" } else { "−" }

          if collapsible {
            html.elem(
              "div",
              attrs: (
                class: "theorem-block",
                style: style-str,
              ),
              [
                #html.elem(
                  "div",
                  attrs: (
                    style: title-style,
                    onclick: "
                    const content = this.nextElementSibling;
                    const button = this.querySelector('button');
                    const isCollapsed = content.style.maxHeight === '0px';
                    if (isCollapsed) {
                      content.style.maxHeight = '1000px';
                      content.style.opacity = '1';
                      button.textContent = '−';
                      button.style.transform = 'rotate(0deg)';
                    } else {
                      content.style.maxHeight = '0px';
                      content.style.opacity = '0';
                      button.textContent = '+';
                      button.style.transform = 'rotate(90deg)';
                    }
                  ",
                    onmouseover: "this.querySelector('button').style.opacity='1';",
                    onmouseout: "if(this.nextElementSibling.style.maxHeight!=='0px')this.querySelector('button').style.opacity='0.7';",
                  ),
                  [
                    #html.elem("span", attrs: (style: "font-size:1em;"), icon)
                    #html.elem("span", full-title)
                    #html.elem(
                      "button",
                      attrs: (
                        style: button-style
                          + (
                            if collapsed { "transform:rotate(90deg);" } else {
                              ""
                            }
                          ),
                        "aria-label": "Toggle content",
                      ),
                      initial-button-text,
                    )
                  ],
                )
                #html.elem(
                  "div",
                  attrs: (style: content-wrapper-style),
                  [
                    #html.elem("div", attrs: (style: content-style), content)
                  ],
                )
              ],
            )
          } else {
            html.elem(
              "div",
              attrs: (
                class: "theorem-block",
                style: style-str,
              ),
              [
                #html.elem("div", attrs: (style: title-style), [
                  #html.elem("span", attrs: (style: "font-size:1em;"), icon)
                  #html.elem("span", full-title)
                ])
                #html.elem("div", attrs: (style: content-style), content)
              ],
            )
          }
        },
      )
    }
  } else {
    let border-color = if is-dark-theme {
      border-color-dark
    } else {
      border-color-light
    }

    let bg-color = if is-dark-theme {
      bg-color-dark
    } else {
      bg-color-light
    }

    let text-color = if is-dark-theme {
      rgb("#e8e8e8")
    } else {
      rgb("#2c3e50")
    }

    let full-title = if number != none {
      title + " " + str(number)
    } else {
      title
    }

    block(
      width: 100%,
      inset: (left: 10pt, right: 10pt, top: 6pt, bottom: 6pt),
      radius: 4pt,
      fill: bg-color,
      stroke: (left: 3pt + border-color),
      [
        #text(
          fill: border-color,
          weight: "bold",
          size: 0.95em,
        )[#icon #full-title]
        #v(0.2em)
        #text(fill: text-color, size: 0.95em)[#content]
      ],
    )
  }
}

// Theorem
#let theorem(
  content,
  title: "",
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Theorem " + title,
  icon: "📐",
  number: number,
  border-color-light: rgb("#3498db"),
  border-color-dark: rgb("#5dade2"),
  bg-color-light: rgb("#e8f4f8"),
  bg-color-dark: rgb("#1a2332"),
  collapsible: collapsible,
  collapsed: collapsed,
)

// Claim
#let claim(
  content,
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Claim",
  icon: "💡",
  number: number,
  border-color-light: rgb("#f39c12"),
  border-color-dark: rgb("#f4b350"),
  bg-color-light: rgb("#fef5e7"),
  bg-color-dark: rgb("#2d2416"),
  collapsible: collapsible,
  collapsed: collapsed,
)

// Remark
#let remark(
  content,
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Remark",
  icon: "💭",
  number: number,
  border-color-light: rgb("#9b59b6"),
  border-color-dark: rgb("#bb8fce"),
  bg-color-light: rgb("#f4ecf7"),
  bg-color-dark: rgb("#231c26"),
  collapsible: collapsible,
  collapsed: collapsed,
)

#let proof-counter = counter("proof-block-id")

// Proof
#let proof(content, title: "Proof", collapsed: true) = {
  proof-counter.step()
  let target = get-target()
  if target == "web" or target == "html" {
    context {
      theme-frame(
        tag: "div",
        theme => {
          let border-color = if theme.is-dark {
            "#7f8c8d"
          } else {
            "#95a5a6"
          }

          let bg-color = if theme.is-dark {
            "#1c1e20"
          } else {
            "#f9f9f9"
          }

          let text-color = if theme.is-dark {
            "#d0d0d0"
          } else {
            "#34495e"
          }

          let button-color = if theme.is-dark {
            "#95a5a6"
          } else {
            "#7f8c8d"
          }

          let style-str = (
            "margin:0.5em 0;padding:0;"
              + "border-left:2px solid "
              + str(border-color)
              + ";"
              + "background:"
              + str(bg-color)
              + ";"
              + "border-radius:4px;"
              + "color:"
              + str(text-color)
              + ";" // + "font-style:italic;"
              // + "font-size:0.95em;"
              + "transition:all 0.3s ease;"
          )

          let header-style = (
            "display:flex;justify-content:space-between;align-items:center;"
              + "padding:0.5em 0.7em;margin:0;"
              + "cursor:pointer;"
              + "user-select:none;"
          )

          let title-style = "font-weight:600;font-style:normal;"

          let button-style = (
            "border:none;background:transparent;"
              + "color:"
              + str(button-color)
              + ";"
              + "font-size:1.2em;padding:0;margin:0;"
              + "transition:transform 0.2s ease,opacity 0.3s ease;"
              + "opacity:0.7;line-height:1;"
              + "pointer-events:none;"
          )

          let content-wrapper-style = if collapsed {
            (
              "overflow:hidden;transition:max-height 0.3s ease,opacity 0.3s ease;"
                + "max-height:0px;opacity:0;"
            )
          } else {
            (
              "overflow:hidden;transition:max-height 0.3s ease,opacity 0.3s ease;"
                + "max-height:1000px;opacity:1;"
            )
          }

          let content-style = "padding:0 0.7em 0.5em 0.7em;"

          let proof-id = "proof-" + str(proof-counter.get().first())

          let initial-button-text = if collapsed { "+" } else { "−" }

          html.elem(
            "div",
            attrs: (
              class: "proof-block",
              style: style-str,
            ),
            [
              #html.elem(
                "div",
                attrs: (
                  style: header-style,
                  onclick: "
                  const content = this.nextElementSibling;
                  const button = this.querySelector('button');
                  const isCollapsed = content.style.maxHeight === '0px';
                  if (isCollapsed) {
                    content.style.maxHeight = '1000px';
                    content.style.opacity = '1';
                    button.textContent = '−';
                    button.style.transform = 'rotate(0deg)';
                  } else {
                    content.style.maxHeight = '0px';
                    content.style.opacity = '0';
                    button.textContent = '+';
                    button.style.transform = 'rotate(90deg)';
                  }
                ",
                  onmouseover: "this.querySelector('button').style.opacity='1';",
                  onmouseout: "if(this.nextElementSibling.style.maxHeight!=='0px')this.querySelector('button').style.opacity='0.7';",
                ),
                [
                  #html.elem("span", attrs: (style: "font-size:1em;"), "📓")
                  #html.elem("span", title)
                  #html.elem(
                    "button",
                    attrs: (
                      style: button-style
                        + (
                          if collapsed { "transform:rotate(90deg);" } else {
                            ""
                          }
                        ),
                      "aria-label": "Toggle proof",
                    ),
                    initial-button-text,
                  )
                ],
              )
              #html.elem(
                "div",
                attrs: (id: proof-id, style: content-wrapper-style),
                [
                  #html.elem("div", attrs: (style: content-style), content)
                  #html.elem(
                    "div",
                    attrs: (
                      style: "text-align:right;padding:0 0.7em 0.5em 0.7em;font-style:normal;",
                    ),
                    [□],
                  )
                ],
              )
            ],
          )
        },
      )
    }
  } else {
    let border-color = if is-dark-theme {
      rgb("#7f8c8d")
    } else {
      rgb("#95a5a6")
    }

    let bg-color = if is-dark-theme {
      rgb("#1c1e20")
    } else {
      rgb("#f9f9f9")
    }

    let text-color = if is-dark-theme {
      rgb("#d0d0d0")
    } else {
      rgb("#34495e")
    }

    block(
      width: 100%,
      inset: 6pt,
      radius: 4pt,
      fill: bg-color,
      stroke: (left: 2pt + border-color),
      [
        #text(fill: text-color, weight: "bold", size: 0.95em)[✅  #title.]
        #v(0.1em)
        #text(fill: text-color, style: "italic", size: 0.95em)[#content]
        #v(0.1em)
        #align(right)[#text(style: "normal")[□]]
      ],
    )
  }
}

// Question
#let question(
  content,
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Question",
  icon: "❓",
  number: number,
  border-color-light: rgb("#e74c3c"),
  border-color-dark: rgb("#ec7063"),
  bg-color-light: rgb("#fadbd8"),
  bg-color-dark: rgb("#2b1a19"),
  collapsible: collapsible,
  collapsed: collapsed,
)

// Custom block with configurable colors
#let custom-block(
  content,
  title: "Note",
  icon: "📌",
  number: none,
  border-color-light: rgb("#16a085"),
  border-color-dark: rgb("#48c9b0"),
  bg-color-light: rgb("#e8f8f5"),
  bg-color-dark: rgb("#19302b"),
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: title,
  icon: icon,
  number: number,
  border-color-light: border-color-light,
  border-color-dark: border-color-dark,
  bg-color-light: bg-color-light,
  bg-color-dark: bg-color-dark,
  collapsible: collapsible,
  collapsed: collapsed,
)

// Diagram renderer with theme support
//
// Parameters:
// - diagram-content: The diagram content or a function that takes edge style and returns the content
// Example: diagram-content = edge => ...
#let diagram-frame(diagram-content) = {
  let target = get-target()
  if target == "web" or target == "html" {
    theme-frame(
      tag: "div",
      theme => {
        let edge = edge.with(stroke: theme.main-color)
        let it = [$
            #{
              if type(diagram-content) == function {
                diagram-content(edge)
              } else { diagram-content }
            }
          $]
        set text(fill: theme.main-color, size: math-size, font: math-font)
        span-frame(attrs: (class: "block-equation"), it)
      },
    )
  } else {
    if type(diagram-content) == function {
      diagram-content(edge)
    } else {
      diagram-content
    }
  }
}
