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
    text(gray)[
      _Referenced in:_
      #for backlink in backlinks [
        #let heading = query(
          selector(heading).before(backlink.location()),
        ).last()
        [#link(backlink.location())[#heading.body]]
      ]
    ]
  }
}

#let show-reference(it) = {
  if it.element != none and it.element.func() == heading {
    let children = it.element.body
    link(it.location())[[#children]]
  } else {
    it
  }
}

// Build a back-link list for the current note, which is determined by the nearest preceding heading. This allows us to see which notes link to the current note based on its heading.
#let zettel(body) = {
  body

  context {
    let here-loc = here()

    let all-headings = query(heading.where(level: 1))

    let prev-headings = all-headings.filter(h => {
      let h-pos = h.location().position()
      let here-pos = here-loc.position()
      (
        h-pos.page < here-pos.page
          or (h-pos.page == here-pos.page and h-pos.y < here-pos.y)
      )
    })

    if prev-headings.len() == 0 {
      text("Error: No preceding heading found.")
    } else {
      let current-note = prev-headings.last()

      if current-note.has("label") {
        let current-id = current-note.label
        show-backlinks(current-id)
      }
    }
  }
}
