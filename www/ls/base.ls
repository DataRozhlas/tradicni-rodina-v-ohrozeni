inited = no
init = ->
  return if inited
  inited := yes
  ig.fit!
  data = ig.processData!
  if ig.containers.comparator
    container = d3.select ig.containers.comparator
    comparator = new ig.Comparator container, data
  if ig.containers.czech
    container = d3.select that
    singleLineCz = new ig.SingleLine container, data[2], 'marriage-rate'
  if ig.containers.greece
    container = d3.select that
    singleLineGreece = new ig.SingleLine container, data[5], 'marriage-rate'
  if ig.containers.multiples
    container = d3.select that
    new ig.SmallMultiples container, data
  new Tooltip!watchElements!


if d3?
  init!
else
  $ window .bind \load ->
    if d3?
      init!
