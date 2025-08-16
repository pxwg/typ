#import "shared.typ": *
#import "blog-preview.typ": color_scheme, colored, conf, preview

// The default template for blog posts.
#let main = if preview == "true" { conf.with() } else {
  shared-template.with(kind: "post", lang: "en")
}

// shortcut for English blog posts
#let main-en = main
// shortcut for Chinese blog posts
#let main-zh = main.with(lang: "zh", region: "cn")
