#import "../packages/typst-fletcher.typ": *
#import "../packages/zebraw.typ": *
#import "@preview/shiroa:0.2.3": (
  is-html-target, is-pdf-target, is-web-target, plain-text, templates,
)
#import templates: *
#import "mod.typ": *
#import "theme.typ": *
#import "blog-preview.typ": preview_bool

#import "math-baseline.typ": (
  assistive-mathml,
  visible-mathml,
  inline-math-count, math-bot-label, math-ref-bot-label, shift-inline-math,
  shift-inline-math-themed, y-shifts,
)

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
  "Libertinus",
  // "STIX Two Text",
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
  let cjk-break-space-regex = regex("([\p{Han}，。；：！？‘’“”（）「」【】…—\p{Hiragana}\p{Katakana}]) +([\p{Han}，。；：！？‘’“”（）「」【】…—\p{Hiragana}\p{Katakana}])")
  show cjk-break-space-regex: it => {
    let m = it.text.match(cjk-break-space-regex)
    m.captures.at(0) + m.captures.at(1)
  }

  show heading: it => {
    set text(size: heading-sizes.at(it.level))

    block(
      spacing: 0.55em,
      below: 0.18em,
      {
        if is-web-target {
          show link: static-heading-link(it)
        }

        it
      },
    )
  }

  body
}

#let equation-rules(body) = {
  show math.equation: set text(font: math-font)
  show math.equation.where(block: false): it => context if sys-is-html-target {
    set text(size: math-size, font: math-font)
    visible-mathml(
      it,
      attrs: (class: "typst-inline-math typst-native-math"),
    )
  } else {
    it
  }
  show math.equation.where(block: true): it => context if sys-is-html-target {
    set text(size: math-size, font: math-font)
    visible-mathml(
      it,
      tag: "div",
      attrs: (class: "typst-display-math typst-native-math"),
    )
  } else {
    it
  }
  body
  context if sys-is-html-target {
    let math-bots = query(math-bot-label)
    let math-ref-bots = query(math-ref-bot-label)
    if math-bots.len() == inline-math-count.get().first() {
      assert(math-bots.len() == math-ref-bots.len())
      let new-y-shifts = math-bots
        .zip(math-ref-bots, exact: true)
        .map(pair => {
          let (math-bot, math-ref-bot) = pair
          let y1 = math-bot.location().position().y
          let y2 = math-ref-bot.location().position().y
          y1 - y2
        })
      y-shifts.update(old => new-y-shifts)
    }
  }
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
  show-outline: false,
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
    show: equation-rules
    // code block setting
    show: code-block-rules
    // visualization setting
    show: visual-rules

    show: it => if sys-is-html-target {
      show footnote: it => context {
        let num = counter(footnote).get().at(0)
        super(str(num))
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
    inset: (left: 9pt, right: 0pt, top: 0pt, bottom: 0pt),
    radius: 0pt,
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
        let text-color = if theme.is-dark {
          if theme.code-extra-colors.fg != none {
            theme.code-extra-colors.fg.to-hex()
          } else { "#bbbbbb" }
        } else { "#666666" }

        let style-str = (
          "margin:1em 0;padding:0 0 0 0.9em;"
            + "border-left:3px solid "
            + str(border-color)
            + ";"
            + "background:transparent;"
            + "border-radius:0;"
            + "box-shadow:none;"
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
      inset: (left: 9pt, right: 0pt, top: 0pt, bottom: 0pt),
      radius: 0pt,
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
        let text-color = if theme.is-dark {
          if theme.code-extra-colors.fg != none {
            theme.code-extra-colors.fg.to-hex()
          } else { "#e8e8e8" }
        } else { "#2c3e50" }

        let title-color = border-color

        let style-str = (
          "margin:1em 0;padding:0 0 0 0.9em;"
            + "font-size:0.95em;line-height:1.5"
            + ";border-left:4px solid "
            + str(border-color)
            + ";"
            + "background:transparent;"
            + "border-radius:0;"
            + "color:"
            + str(text-color)
            + ";"
            + "box-shadow:none;"
        )

        let title-style = (
          "display:flex;align-items:center;gap:0.5em;"
            + "padding:0;margin:0 0 0.25em 0;"
            + "font-weight:700;font-size:1em;"
            + "color:"
            + str(title-color)
            + ";"
            + "border-bottom:0;"
        )

        let content-style = (
          "padding:0;"
        )

        html.elem(
          "div",
          attrs: (
            class: "colored-block",
            style: style-str,
          ),
          [
            #html.elem("div", attrs: (style: title-style), [
              #html.elem("span", title)
            ])
            #html.elem("div", attrs: (style: content-style), content)
          ],
        )
      },
    )
  } else {
    let border-color = dash-color
    let text-color = if is-dark-theme {
      if code-extra-colors.fg != none { code-extra-colors.fg } else {
        "#e8e8e8"
      }
    } else { "#2c3e50" }

    block(
      width: 100%,
      inset: (left: 9pt, right: 0pt, top: 0pt, bottom: 0pt),
      radius: 0pt,
      stroke: (left: 4pt + border-color),
      [
        #text(fill: border-color, weight: "bold", size: 1em)[#title]
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
// - width-ratio (float): Maximum content-column width ratio (0.0-1.0, default: 1.0 = text width).
//   Images render as min(intrinsic image width, this maximum width) to avoid blurry upscaling.
#let image_viewer(
  path: "",
  desc: "",
  dark-adapt: false,
  adapt-mode: "darken",
  width-ratio: 1.0,
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

        // Calculate the maximum width percentage relative to the article text column.
        let width-percent = calc.max(10, calc.min(100, width-ratio * 100))
        let content-width = str(width-percent) + "%"

        html.elem(
          "div",
          attrs: (
            class: "image-viewer",
            style: "width:100%;height:auto;margin:1.15em 0;display:flex;flex-direction:column;align-items:center;justify-content:center;overflow:visible;padding:0;box-sizing:border-box;",
          ),
          [
            #html.elem(
              "img",
              attrs: (
                src: path,
                style: "width:auto;max-width:"
                  + content-width
                  + ";height:auto;display:block;object-fit:contain;border-radius:0.5em;filter:"
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
                  style: "margin-top:0.55em;font-size:0.9em;color:"
                    + desc-color
                    + ";text-align:center;max-width:"
                    + content-width
                    + ";transition:color 0.3s ease;",
                ),
                [#desc],
              )
            }
          ],
        )
      },
    )
  } else {
    path = "../../content/article/en/" + path
    if desc != "" {
      image(path)
    } else {
      image(path, alt: desc)
    }
  }
}

#let image_gallery(
  paths: (),
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

        let desc-color = if theme.is-dark { "#aaa" } else { "#888" }

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
                  style: "max-width:300px;max-height:200px;width:auto;height:auto;display:block;object-fit:contain;border-radius:0.5em;flex:0 0 auto;filter:"
                    + img-filter
                    + ";transition:filter 0.3s ease;",
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
                style: "margin-top:1em;font-size:1em;color:"
                  + desc-color
                  + ";text-align:center;width:100%;transition:color 0.3s ease;",
              ),
              [#desc],
            )
          ]
        } else {
          gallery
        }
      },
    )
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
  let icon = ""
  let target = get-target()
  if target == "web" or target == "html" {
    context {
      theme-frame(
        tag: "div",
        theme => {
          let border-color = if theme.is-dark { "#cf829e" } else { "#d3006a" }

          let button-color = if theme.is-dark {
            "#cf829e"
          } else {
            "#d3006a"
          }

          let style-str = (
            "margin:1em 0;padding:0 0 0 0.9em;"
              + "border-left:3px solid "
              + str(border-color)
              + ";"
              + "background:transparent;"
              + "border-radius:0;"
              + "box-shadow:none;"
          )

          let title-style = (
            "display:flex;align-items:center;gap:0.4em;"
              + "padding:0;margin:0 0 0.25em 0;"
              + "font-weight:700;font-size:1em;"
              + "color:"
              + str(border-color)
              + ";"
              + "border-bottom:0;"
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

          let content-style = "padding:0;line-height:inherit;font-size:1em;"

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
    let border-color = if is-dark-theme or preview_bool { rgb("#cf829e") } else { rgb("#d3006a") }

    let full-title = if number != none {
      title + " " + str(number)
    } else {
      title
    }

    block(
      width: 100%,
      inset: (left: 9pt, right: 0pt, top: 0pt, bottom: 0pt),
      radius: 0pt,
      stroke: (left: 3pt + border-color),
      [
        #text(
          fill: border-color,
          weight: "bold",
          size: 1em,
        )[#full-title]
        #v(0.2em)
        #content
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
  title: "Theorem " + if title != "" { "(" + title + ")" } else { "" },
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

// Definition
#let definition(
  content,
  number: none,
  collapsible: false,
  collapsed: false,
  title: "Definition",
) = theorem-block(
  content,
  title: "Definition",
  icon: "📖",
  number: number,
  border-color-light: rgb("#27ae60"),
  border-color-dark: rgb("#52be80"),
  bg-color-light: rgb("#e8f8f5"),
  bg-color-dark: rgb("#1a2e27"),
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

// Proposition
#let proposition(
  content,
  title: "",
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Proposition " + title,
  icon: "🔷",
  number: number,
  border-color-light: rgb("#27ae60"),
  border-color-dark: rgb("#52be80"),
  bg-color-light: rgb("#e8f8f5"),
  bg-color-dark: rgb("#1a2e27"),
  collapsible: collapsible,
  collapsed: collapsed,
)

// Fact
#let fact(
  content,
  title: "",
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Fact " + title,
  icon: "📌",
  number: number,
  border-color-light: rgb("#3498db"),
  border-color-dark: rgb("#5dade2"),
  bg-color-light: rgb("#e8f4f8"),
  bg-color-dark: rgb("#1a2332"),
  collapsible: collapsible,
  collapsed: collapsed,
)

// Corollary
#let corollary(
  content,
  title: "",
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Corollary " + title,
  icon: "✨",
  number: number,
  border-color-light: rgb("#e74c3c"),
  border-color-dark: rgb("#ec7063"),
  bg-color-light: rgb("#fadbd8"),
  bg-color-dark: rgb("#2b1a19"),
  collapsible: collapsible,
  collapsed: collapsed,
)

// Example
#let example(
  content,
  title: "",
  number: none,
  collapsible: false,
  collapsed: false,
) = theorem-block(
  content,
  title: "Example " + title,
  icon: "📝",
  number: number,
  border-color-light: rgb("#e67e22"),
  border-color-dark: rgb("#f39c12"),
  bg-color-light: rgb("#fef5e7"),
  bg-color-dark: rgb("#2e2416"),
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

          let button-color = if theme.is-dark {
            "#95a5a6"
          } else {
            "#7f8c8d"
          }

          let style-str = (
            "margin:1em 0;padding:0 0 0 0.9em;"
              + "border-left:2px solid "
              + str(border-color)
              + ";"
              + "background:transparent;"
              + "border-radius:0;"
              + "box-shadow:none;"
          )

          let header-style = (
            "display:flex;justify-content:space-between;align-items:center;"
              + "padding:0;margin:0 0 0.25em 0;"
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

          let content-style = "padding:0;"

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
                  //  #html.elem("span", attrs: (style: "font-size:1em;"), "📓")
                  #html.elem("span", attrs: (style: "font-weight:400;"), title)
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
                ],
              )
            ],
          )
        },
      )
    }
  } else {
    let border-color = if is-dark-theme or preview_bool {
      rgb("#7f8c8d")
    } else {
      rgb("#95a5a6")
    }

    block(
      width: 100%,
      inset: (left: 9pt, right: 0pt, top: 0pt, bottom: 0pt),
      radius: 0pt,
      stroke: (left: 2pt + border-color),
      [
        #text(fill: border-color, weight: "bold", size: 1em)[#title.]
        #v(0.1em)
        #text(style: "italic")[#content]
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
