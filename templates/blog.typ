#import "shared.typ": *
#import "blog-preview.typ": color_scheme, colored, conf, preview, concealed, preview-concealer

// The default template for blog posts.
// When the typst-concealer plugin is active, use conf (which bypasses the full
// page template) so math blocks render at auto size rather than A4.
#let main = if preview == "true" or (concealed == "true" and preview-concealer == "true") {
  conf.with()
} else {
  shared-template.with(kind: "post", lang: "en")
}

// shortcut for English blog posts
#let main-en = main
// shortcut for Chinese blog posts
#let main-zh = main.with(lang: "zh", region: "cn")
