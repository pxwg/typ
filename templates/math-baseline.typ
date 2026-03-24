#let math-bot-label = label("_math_bot_")
#let math-ref-bot-label = label("_math_ref_bot_")

#let y-shifts = state("y-shifts", ())
#let inline-math-count = counter("inline-math-count")

#let shift-inline-math(body) = context {
  let formula-cnt = inline-math-count.get().first()
  inline-math-count.step()
  let begin-loc = here()
  // The wrapper ensures that the viewbox of rendered SVG math matches its bounding box.
  let wrapper = text.with(top-edge: "bounds", bottom-edge: "bounds")
  // For debugging: draw red box around the wrapper
  // let wrapper = it => box(wrapper(it), stroke: red)
  html.elem(
    "span",
    html.frame(wrapper(
      // Add invisible elements below the math body to measure its bottom position.
      math.attach(math.limits(body.body), b: pad([#none#math-bot-label], -1em))
        + sym.wj
        + math.attach(math.limits([#none]), b: pad(
          [#none#math-ref-bot-label],
          -1em,
        )),
    )),
    attrs: (
      // Rendered SVG defines its width & height in "em" units,
      // so we also convert y-shift relative to text size in "em" units.
      style: "vertical-align: -"
        + str(calc.round(
          y-shifts.final().at(formula-cnt, default: 0pt) / text.size,
          digits: 2,
        ))
        + "em;",
      class: "typst-inline-math",
    ),
  )
}

/// Themed variant of shift-inline-math: renders dark and light SVGs in one call
/// so the counter increments only once, then wraps them in the standard
/// `code-image themed` container that the site's CSS already handles.
/// Measurement labels are placed only in the dark frame; both frames contain
/// identical math (only fill differs) so their geometry is the same.
#let shift-inline-math-themed(body, dark-fill, light-fill) = context {
  let formula-cnt = inline-math-count.get().first()
  inline-math-count.step()
  let wrapper = text.with(top-edge: "bounds", bottom-edge: "bounds")
  html.elem(
    "span",
    {
      // Dark version — carries the measurement labels.
      html.elem(
        "span",
        {
          set text(fill: dark-fill)
          html.frame(wrapper(
            math.attach(math.limits(body.body), b: pad([#none#math-bot-label], -1em)) +
            sym.wj +
            math.attach(math.limits([#none]), b: pad([#none#math-ref-bot-label], -1em)),
          ))
        },
        attrs: (class: "dark typst-inline-math"),
      )
      // Light version — same structure but no labels (geometry is identical).
      html.elem(
        "span",
        {
          set text(fill: light-fill)
          html.frame(wrapper(
            math.attach(math.limits(body.body), b: pad([#none], -1em)) +
            sym.wj +
            math.attach(math.limits([#none]), b: pad([#none], -1em)),
          ))
        },
        attrs: (class: "light typst-inline-math"),
      )
    },
    attrs: (
      class: "code-image themed typst-inline-math-wrapper",
      style: "vertical-align: -"
        + str(calc.round(
          y-shifts.final().at(formula-cnt, default: 0pt) / text.size,
          digits: 2,
        ))
        + "em;",
    ),
  )
}

#let html-export-template(doc) = context {
  if target() != "html" {
    return doc
  }
  show math.equation.where(block: false): it => {
    // The target() function can be used to apply html.frame selectively only
    // when the export target is HTML.
    // When html.frame is applied to a figure, the target() for all the elements
    // inside will be set to "paged" instead.
    // https://github.com/typst/typst/issues/721#issuecomment-3064895139
    if target() == "html" {
      shift-inline-math(it)
    } else {
      it
    }
  }
  show math.equation.where(block: true): it => {
    html.elem(
      "div",
      html.frame(it),
      attrs: (class: "typst-display-math"),
    )
  }
  // Wrap code blocks in a div for styling
  show raw.where(block: true): it => {
    html.elem(
      "div",
      it,
      attrs: (class: "typst-code-block"),
    )
  }
  doc
  // After the whole document, calculate the y-shift for every inline math.
  // This reduces the number of `query` calls, improving performance.
  context {
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
