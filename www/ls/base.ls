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
  if ig.containers.correlator
    container = d3.select that
    new ig.GodCorrelator container, data

  scrollTween = (offset) ->
    ->
      interpolate = d3.interpolateNumber do
        window.pageYOffset || document.documentElement.scrollTop
        offset
      (progress) -> window.scrollTo 0, interpolate progress
  return if not $?
  $(".author").after("""<div class='sources'>
    <p>Data o <a target="_blank" href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_find&lang=en">porodnosti</a>, <a target="_blank" href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_find&lang=en">mimomanželských dětech</a>, <a target="_blank" href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_fordager&lang=en">těhotenství náctiletých</a>, <a target="_blank" href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_fabort&lang=en">potratech</a>, <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_ndivind&lang=en" target="_blank">rozvodovosti</a>, <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_nind&lang=en" target="_blank">manželstvích</a>, <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=ilc_lvps20&lang=en" target="_blank">neúplných rodinách</a> a <a href="http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=migr_pop1ctz&lang=en" target="_blank">složení populace</a>: <a href="http://ec.europa.eu/eurostat" target="_blank">Eurostat.</a></p>
    <p>Data o náboženství: <a href="http://ec.europa.eu/public_opinion/archives/ebs/ebs_341_en.pdf" target="_blank">Eurobarometer</a>, strana 381.</p>
    </div>
    """)
  $ 'body' .prepend "<div class='hero'><div class='overlay'></div></div>"
  $hero = $ '.hero'
  $hero.append "<span class='copy'>Image &copy; <a href='http://www.freeimages.com/profile/knorthern' target='_blank'>Kate Northern, freeimages.com</a></span>"
  $hero.append "<a href='#' class='scroll-btn'>Pokračovat</a>"
  $ '.hero a.scroll-btn' .bind 'click touchstart' (evt) ->
    evt.preventDefault!
    filling = $ ".ig.filling"
    offset = filling.offset!top + filling.height!
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
