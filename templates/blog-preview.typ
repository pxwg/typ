// Complied by: `typst --input colored=false --input preview=false main.typ` to generate the PDF
// Packages
// Custom color scheme
#let color_platte = (
  background: white,
  text: black,
  blue: rgb("#4b6bdc"),
  maroon: rgb("#a83252"),
  peach: rgb("#e67e32"),
  green: rgb("#3a8c52"),
  flamingo: rgb("#e35f84"),
  lavender: rgb("#7365ca"),
  mantle: rgb("#f3f3f3"), // light gray for block backgrounds
)

#let font = (name: "Libertinus Serif")
#let math_font = "Libertinus Math"

// Colors controled by the `--input colored` variable passed in the command line or by default which is `false` and help to manage the default (preview in url) and uncolored (published in pdf) version.
//
// Get the `colored` variable from the command line input
// Then determine the color scheme based on the `colored` variable
#let preview = "false" // default value for preview
#let colored = "false" // default value for colored
#let inputs = sys.inputs
#let get_input(input_dict) = {
  let colored = true
  let preview = true
  for (key, value) in input_dict {
    if key == "colored" {
      colored = value
    }
    if key == "preview" {
      preview = value
    }
  }
  return (colored: colored, preview: preview)
}

#let (colored, preview) = get_input(inputs)

#let preview_bool = {
  if preview == "true" {
    true
  } else {
    false
  }
}

#let get_color_scheme(input_value) = {
  if input_value == "false" {
    // identity function for the default color scheme
    (
      background: doc => doc,
      colors: color_platte,
    )
  } else {
    // use a slightly darker theme for colored scheme
    let dark_colors = (
      background: rgb("#11262d"),
      text: rgb("#c0c8cc"),
      blue: rgb("#a8cbec"),
      maroon: rgb("#e1b8d4"),
      peach: rgb("#ebb8b5"),
      green: rgb("#c6cb9f"),
      flamingo: rgb("#e1c09d"),
      lavender: rgb("#c7c0eb"),
      mantle: rgb("#051a20"),
    )
    (
      background: doc => {
        set page(fill: dark_colors.background)
        doc
      },
      colors: dark_colors,
    )
  }
}

#let color_scheme = get_color_scheme(colored).background
#let color_palette = get_color_scheme(colored).colors

#let text_color = {
  if colored == "false" {
    black
  } else {
    color_palette.text
  }
}

#let text_size = {
  if preview == "true" {
    15pt
  } else {
    11pt
  }
}

#let custume_text = (
  size: text_size,
  fill: text_color,
)

#let margin = {
  if preview == "true" {
    (left: 0.1in, right: 0.1in)
  } else {
    (left: 1in, right: 1in, top: 1in, bottom: 1in)
  }
}

// Title and author information
#let conf(
  title: "Title",
  llm-translated: none,
  author: "Xinyu Xiang",
  desc: "",
  region: none,
  date: "2025-10-01",
  tags: "",
  lang: "en",
  translationKey: none,
  doc,
) = {
  let textsize = custume_text.size
  set page(
    fill: color_palette.background,
    paper: "a4",
    margin: margin,
    header: context [
      #set text(size: textsize)
      #stack(
        spacing: textsize / 2,
        [#smallcaps[#date]
          #h(1fr)
          // #smallcaps[#title]
          #h(1fr)
          #counter(page).display(
            "1/1",
            both: true,
          )],
        line(length: 100%, stroke: 0.6pt + custume_text.fill),
      )
    ],
  )
  set par(justify: true)
  set text(
    size: textsize,
    fill: custume_text.fill,
    font: font,
  )
  align(center, text(textsize + 8pt)[ *#title* ])
  align(center, text(textsize - 2pt)[ #emph(author)])
  if desc != "" {
    align(center, text(textsize - 1pt)[ #emph(desc) ])
  }
  align(center, text(textsize - 1pt)[ #emph(date) ])
  show math.equation: set text(font: math_font)
  doc
}

// block styles
#let definition(name: none, body) = {
  box(
    stroke: 1pt + color_palette.blue,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
    [
      #if name != none [*Definition* (#emph(name))] else [*Definition*]
      #body
    ],
  )
}

#let example(name: none, body) = {
  box(
    stroke: 1pt + color_palette.peach,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
    [
      #if name != none [*Example* (#emph(name))] else [*Example*]
      #body
    ],
  )
}

#let theorem(name: none, body) = {
  box(
    stroke: 1pt + color_palette.peach,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
    [
      #if name != none [*Theorem* (#emph(name))] else [*Theorem*]
      #body
    ],
  )
}

#let proposition(name: none, body) = {
  box(
    stroke: 1pt + color_palette.green,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
    [
      #if name != none [*Proposition* (#emph(name))] else [*Proposition*]
      #body
    ],
  )
}

#let property(name: none, body) = {
  box(
    stroke: 1pt + color_palette.blue,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
    [
      #if name != none [*Property* (#emph(name))] else [*Property*]
      #body
    ],
  )
}

#let remark(name: none, body) = {
  box(
    stroke: 1pt + color_palette.flamingo,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
    [
      #if name != none [*Remark* (#emph(name))] else [*Remark*]
      #body
    ],
  )
}

#let proof(name: none, body) = {
  block(
    stroke: 1pt + color_palette.lavender,
    width: 100%,
    fill: color_palette.mantle,
    inset: (x: 8pt, y: 8pt),
  )[
    #if name != none [_Proof_. (#emph(name)). ] else [_Proof_. ]
    #body
    #h(1fr)
    $qed$
  ]
}

#let main = conf.with()
#let blog-tags = (
  macos: "macOS",
  programming: "Programming",
  software: "Software",
  network: "Network",
  software-engineering: "Software Engineering",
  tooling: "Tooling",
  linux: "Linux",
  dev-ops: "DevOps",
  compiler: "Compiler",
  music-theory: "Music Theory",
  tinymist: "Tinymist",
  golang: "Golang",
  typst: "Typst",
  misc: "Miscellaneous",
  physics: "Physics",
  math: "Math",
  quantum-field: "Quantum Field Theory",
  topology: "Topology",
  abstract-nonsense: "Abstract Nonsense",
)
