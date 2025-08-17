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
      background: rgb("#1e1e2e"),
      text: rgb("#cdd6f4"),
      blue: rgb("#89b4fa"),
      maroon: rgb("#951f41"),
      peach: rgb("#eba0ac"),
      green: rgb("#a6e3a1"),
      flamingo: rgb("#f2cdcd"),
      lavender: rgb("#b4befe"),
      mantle: rgb("#181825"),
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
    10pt
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
  desc: "",
  date: "2025-10-01",
  tags: "",
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
  align(center, text(textsize - 1pt)[ #emph(desc) ])
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
