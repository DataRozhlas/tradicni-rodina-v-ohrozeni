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
  new Tooltip!watchElements!


if d3?
  init!
else
  $ window .bind \load ->
    if d3?
      init!
