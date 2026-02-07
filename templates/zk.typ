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
