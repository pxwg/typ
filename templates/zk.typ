// Zettelkasten template
// This template is designed for creating and managing Zettelkasten notes. It includes features for linking notes together and displaying backlinks.

// Show backlinks for a given target label, which is the label of the note we want to find references to.
// Example:
// ```typ
// = 20260206Test <20260206Test>
// #show-backlinks(<20260206Test>)
// ```
// After compiling the above code, it will display all the notes that reference the note with the label `<20260206Test>`, along with the headings of those notes for context.
#let show-backlinks(target-label) = context {
  let all-refs = query(selector(ref))

  let backlinks = all-refs.filter(it => it.target == target-label)

  if backlinks.len() > 0 {
    let seen = ()
    text(gray)[
      _Referenced in:_
      #for backlink in backlinks [
        #let heading = query(
          selector(heading).before(backlink.location()),
        ).last()
        #if heading != none {
          let key = if heading.has("label") { heading.label } else {
            heading.location()
          }
          if not seen.contains(key) {
            let _ = seen.push(key)
            [[#link(backlink.location())[#heading.body]]]
          }
        }
      ]
    ]
  }
}

#let show-reference(it) = {
  if it.element != none and it.element.func() == heading {
    let children = it.element.body
    link(it.target)[[#children]]
  } else {
    it
  }
}

// Display a warning for archived notes with a link to the alternative note
// Example:
// ```typ
// = Old Wrong Thought <2602082130>
// #tag.archived
// #alternative_link(<2602112309>)
// ```
#let alternative_link(target-label) = {
  (
    "\n"
      + box(
        fill: orange.lighten(90%),
        stroke: orange,
        radius: 4pt,
        inset: 8pt,
        width: 100%,
      )[
        #text(fill: orange.darken(20%))[Archived: ]#text(
          fill: gray,
        )[This note has been replaced by a newer version. Please refer to: #ref(target-label)
        ]
      ]
  )
}

// Display a evolution link for legacy notes, indicating that there are newer insights available
// Example:
// ```typ
// = Old Valid Thought <2602082130>
// #tag.idea #tag.legacy
// #evolution_link(<2602112330>)
// ```
#let evolution_link(target-label) = {
  (
    "\n"
      + box(
        fill: blue.lighten(90%),
        stroke: blue,
        radius: 4pt,
        inset: 8pt,
        width: 100%,
      )[
        #text(fill: blue.darken(20%))[Legacy Note: ]#text(
          fill: gray,
        )[Newer insights available. Please refer to: #ref(target-label)
        ]
      ]
  )
}

// Build a back-link list for the current note, which is determined by the nearest preceding heading. This allows us to see which notes link to the current note based on its heading.
#let zettel-theme(body) = {
  body
}

#let _chip(color, icon, label) = box(
  fill: color.lighten(80%),
  stroke: color,
  radius: 4pt,
  inset: (x: 4pt, y: 2pt),
  outset: (y: 2pt),
)[
  #text(fill: color, size: 0.8em, weight: "bold")[#icon #label]
]

#let tag = (
  todo: _chip(red, "💫", "TODO"),
  idea: _chip(yellow.darken(20%), "💡", "IDEA"),
  wip: _chip(blue, "🚧", "WIP"),
  done: _chip(green, "✅", "DONE"),
  archived: _chip(gray, "📦", "ARCHIVED"),
  legacy: _chip(eastern, "📜", "LEGACY"),
  sync: _chip(olive, "🔄", "SYNC-NEEDED"),
  // below are custom tags for various use cases
  zk: _chip(purple, "🗂️", "ZK"),
  neovim: _chip(fuchsia, "🖥️", "NEOVIM"),
  typst: _chip(navy, "📄", "TYPST"),
  coding: _chip(orange.darken(20%), "💻", "CODING"),
  physics: _chip(orange, "🔬", "PHYSICS"),
  math: _chip(teal, "📐", "MATH"),
  qft: _chip(red.darken(20%), "⚛️", "QFT"),
  classical-mechanics: _chip(blue.darken(20%), "⚙️", "CLASSICAL MECHANICS"),
  quantum-mechanics: _chip(green.darken(20%), "🔮", "QUANTUM MECHANICS"),
  voa: _chip(olive, "🔗", "VOA"),
  rep-theory: _chip(eastern, "📊", "REP-THEORY"),
  topology: _chip(blue.darken(20%), "🔗", "TOPOLOGY"),
  geometry: _chip(teal, "📐", "GEOMETRY"),
  thinking: _chip(purple.darken(20%), "🤔", "THINKING"),
  root: _chip(green, "🌳", "ROOT"),
  ag: _chip(orange, "🧠", "ALGEBRAIC-GEOMETRY"),
  by-ai: _chip(gray, "🤖", "BY-AI"),
)
