#import "./typst-physics/physica.typ": *

// Compatibility overrides for newer Typst symbol names.
#let expectationvalue(..sink) = {
  let args = sink.pos()
  let expr = args.at(0)
  let func = args.at(1, default: none)

  if func == none {
    $lr(chevron.l expr chevron.r)$
  } else {
    $lr(chevron.l func#h(0pt)mid(|)#h(0pt)expr#h(0pt)mid(|)#h(0pt)func chevron.r)$
  }
}
#let expval = expectationvalue

#let innerproduct(u, v) = {
  $lr(chevron.l #u, #v chevron.r)$
}
#let iprod = innerproduct

#let bra(f) = $lr(chevron.l #f|)$
#let ket(f) = $lr(|#f chevron.r)$

#let braket(..sink) = {
  let args = sink.pos()
  let bra = args.at(0)
  let ket = args.at(-1, default: bra)

  if args.len() <= 2 {
    $ lr(chevron.l bra#h(0pt)mid(|)#h(0pt)ket chevron.r) $
  } else {
    let middle = args.at(1)
    $ lr(chevron.l bra#h(0pt)mid(|)#h(0pt)middle#h(0pt)mid(|)#h(0pt)ket chevron.r) $
  }
}

#let outerproduct(..sink) = {
  let args = sink.pos()
  let ket = args.at(0)
  let bra = args.at(1, default: ket)

  $ lr(|ket#h(0pt)mid(chevron.r#h(0pt)chevron.l)#h(0pt)bra|) $
}

#let matrixelement(n, M, m) = {
  $ lr(chevron.l #n#h(0pt)mid(|)#h(0pt)#M#h(0pt)mid(|)#h(0pt)#m chevron.r) $
}
#let mel = matrixelement
