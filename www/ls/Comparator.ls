sensibleCountries =
  "Belgium" : 1
  "Bulgaria" : 1
  "Czech Republic" : 1
  "Denmark" : 1
  "Estonia" : 1
  "Greece" : 1
  "Spain" : 1
  "Croatia" : 1
  "Italy" : 1
  "Latvia" : 1
  "Lithuania" : 1
  "Hungary" : 1
  "Netherlands" : 1
  "Austria" : 1
  "Poland" : 1
  "Portugal" : 1
  "Romania" : 1
  "Slovenia" : 1
  "Slovakia" : 1
  "Finland" : 1
  "Sweden" : 1
  "United Kingdom" : 1
  # "Iceland" : 1
  "Norway" : 1
  "Switzerland" : 1
  # "Albania" : 1
  "Germany (including former GDR)" : 1
  "Ireland" : 1
  "France (metropolitan)" : 1
  # "Cyprus" : 1
  "Luxembourg" : 1
  "Malta" : 1
  # "Liechtenstein" : 1
  # "Bosnia and Herzegovina" : 1
class Metric
  (@id, @name, @unit = '') ->
metricsHuman =
  "marriage-rate"           : new Metric "marriage-rate" "Sňatečnost" "Sňatků na 1000 obyvatel"
  "abortions-rate"          : new Metric "abortions-rate" "Potraty" "Potratů na 100 těhotenství"
  "births-outside-marriage" : new Metric "births-outside-marriage" "Děti narozené mimo manželství" "% dětí se narodilo mimo manželství"
  "fertility-rate"          : new Metric "fertility-rate" "Porodnost" "Narozených dětí na 1000 obyvatel"
  "pregnancies-teen-rate"   : new Metric "pregnancies-teen-rate" "Těhotenství náctiletých", "Těhotenství dívek mezi 10 a 19 lety na 100 000 dívek v populaci"
  "divorce-rate"            : new Metric "divorce-rate" "Rozvodovost" "Rozvodů na 1000 obyvatel"
  "family-incomplete"       : new Metric "family-incomplete" "Neúplné rodiny" "% dětí vyrůstajících bez obou rodičů"
  "abortions-total"         : new Metric "abortions-total" "Potraty"
  "abortions-teen"          : new Metric "abortions-teen" "Potraty náctiletých"
  "age-at-first-child"      : new Metric "age-at-first-child" "Věk matky při narození prvního dítěte"
  "pregnancies-total"       : new Metric "pregnancies-total" "Těhotenství"
  "hiv-rate"                : new Metric "hiv-rate" "Úmrtí na HIV"

class ig.Comparator
  startYear: 1982
  endYear: 2012
  terminatorRadius: 4
  (@parentElement, data) ->
    @fullWidth  = width = 1000
    @fullHeight = height = 600
    @parentElement.append \div
      ..attr \class \shade
    @createHeader!
    @drawChangeFromFirstCivil = no
    @svg = @parentElement.append \svg
      ..attr \class \comparator
      ..attr \width width
      ..attr \height height
    @voronoiSvg = @parentElement.append \svg
      ..attr \class \voronoi
      ..attr \width width
      ..attr \height height
    @margin = top: 10 right: 50 bottom: 10 left: 0
    @width = width - @margin.right - @margin.left
    @height = height - @margin.top - @margin.bottom
    @drawing = @svg.append \g
      ..attr \transform "translate(#{@margin.left}, #{@margin.top})"
    @zeroLine = @drawing.append \line
      ..attr \class \zero-line
      ..attr \x1 -20
      ..attr \x2 @width + 10
      ..attr \y1 height + 20
      ..attr \y2 height + 20
    @pathsG = @drawing.append \g
      ..attr \class \paths
    @terminatorsG = @drawing.append \g
      ..attr \class \terminators

    @xScale = d3.scale.linear!
      ..domain [@startYear, @endYear]
      ..range [0, @width]

    @yScale = d3.scale.linear!
      ..range [@height, 0]
    @data = data.filter -> sensibleCountries[it.id]

    @voronoi = d3.geom.voronoi!
      ..x ~> @margin.left + it.comparatorOffset * (2 * @terminatorRadius + 1.5) + @xScale it.year
      ..y ~> @margin.top + @yScale it.comparatorRate
      ..clipExtent [[0,0], [width, height]]
    @graphTip = new ig.ComparatorTip @
    @display "marriage-rate"

  toggleDrawChangeFromFirstCivil: ->
    @drawChangeFromFirstCivil = !@drawChangeFromFirstCivil
    @display @currentMetric.id

  display: (metric) ->
    @currentMetric = metricsHuman[metric]
    @updateHeader @currentMetric
    values = []
    data = if @drawChangeFromFirstCivil
      @data.filter ~>
        (it.firstYears.civil || it.firstYears.marriage) && ((it.firstYears.civil || it.firstYears.marriage)[metric].value)
    else
      @data.slice!
    for {years}:country in data
      country.comparatorYears = country.years.filter ~>
        it.year >= @startYear and it[metric].value isnt null and not isNaN it[metric].value and isFinite it[metric].value
      for year in country.comparatorYears
        year.comparatorOffset = 0
        year.comparatorRate = year[metric].value
        if @drawChangeFromFirstCivil
          year.comparatorRate /= (country.firstYears.civil || country.firstYears.marriage)[metric].value
        values.push year
      country.comparatorLastYear = country.comparatorYears[*-1]
    data .= filter (.comparatorYears.length > 1)
    @yScale.domain d3.extent values.map (.comparatorRate)
    for country in data
      country.comparatorLastY = @yScale country.comparatorLastYear.comparatorRate
    data.sort (a, b) ->
      | a.comparatorLastY - b.comparatorLastY => that
      | a.isSlovakia => 1
      | b.isSlovakia => -1
      | otherwise => 0
    for country, index in data
      continue unless index
      lastCountry = data[index - 1]
      if 2 * @terminatorRadius > Math.abs country.comparatorLastY - lastCountry.comparatorLastY
        currentIndex = index
        offsets = while data[currentIndex - 1] and 2 * @terminatorRadius > Math.abs country.comparatorLastY - data[currentIndex - 1].comparatorLastY
          --currentIndex
          if data[currentIndex].comparatorLastYear.year != country.comparatorLastYear.year
            continue
          data[currentIndex].comparatorLastYear.comparatorOffset
        offsets.sort (a, b) -> a - b
        offset = 0
        while offsets[offset] == offset
          offset++
        country.comparatorLastYear.comparatorOffset = offset

    line = d3.svg.line!
      ..x ~> it.comparatorOffset * (2 * @terminatorRadius + 1.5) + @xScale it.year
      ..y ~> @yScale it.comparatorRate
      ..interpolate \cardinal
    zeryY = if @drawChangeFromFirstCivil
      @yScale 1
    else
      @height + 20
    @zeroLine
      .transition!
      .duration 800
      .attr \y1 zeryY
      .attr \y2 zeryY

    @paths = @pathsG.selectAll \g.country .data data, (.id)
      ..enter!
        ..append \g
          ..attr \class ->
              suff =
                | it.isSlovakia => " slovakia"
                | it.isCzech => " czech"
                | _ => ""
              "country" + suff
          ..append \path
            ..attr \class \none
            ..attr \data-type \none
          ..append \path
            ..attr \class \civil
            ..attr \data-type \civil
          ..append \path
            ..attr \class \marriage
            ..attr \data-type \marriage
          ..attr \opacity 0
          ..transition!
            ..duration 800
            ..attr \opacity 1
      ..exit!
        ..transition!
          ..duration 800
          ..attr \opacity 0
          ..remove!
      ..selectAll \path
        ..transition!
          ..duration 800
          ..attr \d ({comparatorYears}:country) ->
            type = @getAttribute \data-type
            years = switch type
              | \none
                comparatorYears.filter -> it.year <= (Math.min country.dates.civil, country.dates.marriage)
              | \civil
                comparatorYears.filter -> country.dates.civil <= it.year <= country.dates.marriage
              | otherwise
                comparatorYears.filter -> country.dates.marriage <= it.year
            line years

    @terminators = @terminatorsG.selectAll \circle .data data, (.id)
      ..enter!
        ..append \circle
          ..attr \r @terminatorRadius
          ..attr \class ~>
              year = it.comparatorYears[*-1].year
              if year > it.dates.marriage
                "marriage"
              else if it.isCzech
                "czech"
              else if year > it.dates.civil
                "civil"
              else if it.isSlovakia
                "slovakia"
              else
                ""
          ..attr \opacity 0
      ..exit!
        ..transition 800
        ..attr \opacity 0
        ..remove!
      ..transition!
        ..duration 800
        ..attr \opacity 1
        ..attr \cx ~>
          it.comparatorLastYear.comparatorOffset * (2 * @terminatorRadius + 1.5) + @xScale it.comparatorLastYear.year
        ..attr \cy ~> @yScale it.comparatorLastYear.comparatorRate

    @drawVoronoi values
    # @displayGraphTip data.4.years[*-1]

  drawVoronoi: (values) ->
    voronoi = @voronoi values
      .filter -> it
    @voronoiSvg.selectAll \path .remove!
    @voronoiSvg.selectAll \path .data voronoi .enter!append \path
      ..attr \d polygon
      ..on \mouseover ~>
        @displayGraphTip it.point
        @highlightCountry it.point.country
      ..on \mouseout ~>
        @graphTip.hide!
        @downlightCountry it.point.country

  displayGraphTip: (point) ->
    text = "<h3>#{point.country.name}</h3>"
    text += "<p><span class='metric'>#{@currentMetric.name}</span> v roce #{point.year}: <br>
      <b>#{ig.utils.formatNumber point[@currentMetric.id].value, 2}</b> <span class='unit'>#{@currentMetric.unit}</span><br></p>"
    rights = if point.country.firstYears.marriage?year < point.year
      "V tomto roce zde již bylo legální manželství stejnopohlavních párů"
    else if point.country.firstYears.civil?year < point.year
      "V tomto roce zde již byl institut registrovaného partnerství"
    else
      "V tomto roce zde nebyla žádná forma stejnopohlavních svazků"
    text += "<p class='rights'>#{rights}</p>"
    @graphTip.display point, text

  highlightCountry: (country) ->
    @paths
      .classed \active no
      .filter -> it is country
      .classed \active yes

  downlightCountry: ->
    @paths.classed \active no

  updateHeader: (metric) ->
    @header
      ..select "span.metric" .html metric.name
      ..select "span.unit" .html metric.unit
      ..selectAll ".link a"
        .classed \active no
        .filter -> it is metric.id
        .classed \active yes
      ..select \a.changeFromFirstCivil
        ..html if @drawChangeFromFirstCivil then "Zobrazit jako vývoj hodnot" else "Zobrazit jako změnu od zavedení registrovaného partnerství"

  createHeader: ->
    @header = @parentElement.append \div
      ..attr \class \header
      ..append \h2
        ..html "<span class='metric'></span> v Evropě mezi roky 1990 a 2012"
      ..append \span
        ..attr \class "subheader subheader1"
        ..html "<b><span class='unit'></span> v Evropě mezi roky 1990 a 2012.</b><br>Zobrazit "
        ..selectAll \span.link .data <[divorce-rate marriage-rate fertility-rate births-outside-marriage family-incomplete pregnancies-teen-rate abortions-rate]> .enter!append \span
          ..attr \class \link
          ..append \a
            ..attr \href \#
            ..html -> metricsHuman[it].name
            ..on \click ~>
              d3.event.preventDefault!
              @display it
          ..append \span
            ..attr \class \divider
            ..html ", "
      ..append \span
        ..attr \class "subheader subheader2"
        ..append \a
          ..attr \class "changeFromFirstCivil"
          ..attr \href \#
          ..on \click ~>
            d3.event.preventDefault!
            @toggleDrawChangeFromFirstCivil!
      ..append \ul
        ..append \li
          ..append \span
          ..append \span .html "Stejnopohlavní manželství"
        ..append \li
          ..append \span
          ..append \span .html "Registrované partnerství"
        ..append \li
          ..append \span
          ..append \span .html "Žádná forma stejnopohlavních svazků"

polygon = ->
  "M#{it.join "L"}Z"

