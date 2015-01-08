inited = no
init = ->
  return if inited
  inited := yes
  data = ig.processData!
  container = d3.select ig.containers.base
  comparator = new ig.Comparator container, data
  new Tooltip!watchElements!

if d3?
  init!
else
  $ window .bind \load ->
    if d3?
      init!
