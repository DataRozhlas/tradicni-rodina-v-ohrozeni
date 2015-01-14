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


  scrollTween = (offset) ->
    ->
      interpolate = d3.interpolateNumber do
        window.pageYOffset || document.documentElement.scrollTop
        offset
      (progress) -> window.scrollTo 0, interpolate progress
  return if not $?
  $ 'body' .prepend "<div class='hero'><div class='overlay'></div></div>"
  $hero = $ '.hero'
  $hero.append "<span class='copy'>Image &copy; <a href='http://www.freeimages.com/profile/knorthern' target='_blank'>Kate Northern, freeimages.com</a></span>"
  $hero.append "<a href='#' class='scroll-btn'>Pokračovat</a>"
  $ '.hero a.scroll-btn' .bind 'click touchstart' (evt) ->
    evt.preventDefault!
    offset = $ ig.containers.comparator .offset!top
    offset -= 140
    d3.transition!
      .duration 800
      .tween "scroll" scrollTween offset
  filling = $ ".ig.filling"
    ..css \height $hero.height!
  $ window .bind \resize -> filling.css \height $hero.height!

if d3?
  init!
else
  $ window .bind \load ->
    if d3?
      init!
