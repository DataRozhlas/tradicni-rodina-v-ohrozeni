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
  "abortions-total"         : new Metric "abortions-total" "Potraty"
  "abortions-teen"          : new Metric "abortions-teen" "Potraty náctiletých"
  "births-outside-marriage" : new Metric "births-outside-marriage" "Narozené děti mimo manželství"
  "fertility-rate"          : new Metric "fertility-rate" "Porodnost"
  "age-at-first-child"      : new Metric "age-at-first-child" "Věk matky při narození prvního dítěte"
  "pregnancies-total"       : new Metric "pregnancies-total" "Těhotenství"
  "pregnancies-teen"        : new Metric "pregnancies-teen" "Těhotenství náctiletých"
  "divorce-rate"            : new Metric "divorce-rate" "Rozvodovost"
  "marriage-rate"           : new Metric "marriage-rate" "Sňatečnost" "sňatků na 1000 obyvatel"
  "hiv-rate"                : new Metric "hiv-rate" "Úmrtí na HIV"

class ig.Comparator
  startYear: 1990
  endYear: 2012
  terminatorRadius: 4
  (@baseElement, data) ->
    @fullWidth  = width = 1000
    @fullHeight = height = 600
    @container = @baseElement.append \div
      ..attr \class \comparator
    @svg = @container.append \svg
      ..attr \class \comparator
      ..attr \width width
      ..attr \height height
    @voronoiSvg = @container.append \svg
      ..attr \class \voronoi
      ..attr \width width
      ..attr \height height
    @margin = top: 10 right: 20 bottom: 10 left: 60
    @width = width - @margin.right - @margin.left
    @height = height - @margin.top - @margin.bottom
    @drawing = @svg.append \g
      ..attr \transform "translate(#{@margin.left}, #{@margin.top})"
    @zeroLine = @drawing.append \line
      ..attr \class \zero-line
      ..attr \x1 -20
      ..attr \x2 @width + 10
      ..attr \y1 10
      ..attr \y2 10
    @pathsG = @drawing.append \g
      ..attr \class \paths
    @terminatorsG = @drawing.append \g
      ..attr \class \terminators

    @xScale = d3.scale.linear!
      ..domain [@startYear, @endYear]
      ..range [0, @width]

    @yScale = d3.scale.linear!
      ..range [@height, 0]
    @data = data.filter -> sensibleCountries[it.name]

    @voronoi = d3.geom.voronoi!
      ..x ~> @margin.left + it.comparatorOffset * (@terminatorRadius + 0.5) + @xScale it.year
      ..y ~> @margin.top + @yScale it.comparatorRate
      ..clipExtent [[0,0], [width, height]]
    @graphTip = new ig.GraphTip @
    @display "marriage-rate"

  display: (metric, drawChangeFromFirstCivil) ->
    @currentMetric = metricsHuman[metric]
    values = []
    data = if drawChangeFromFirstCivil
      @data.filter ~>
        (it.firstYears.civil || it.firstYears.marriage) && ((it.firstYears.civil || it.firstYears.marriage)[metric].value)
    else
      @data.slice!
    for {years}:country in data
      country.comparatorYears = country.years.filter ~>
        it.year >= @startYear and it[metric].value isnt null
      for year in country.comparatorYears
        year.comparatorOffset = 0
        year.comparatorRate = year[metric].value
        if drawChangeFromFirstCivil
          year.comparatorRate /= (country.firstYears.civil || country.firstYears.marriage)[metric].value
        values.push year
      country.comparatorLastYear = country.comparatorYears[*-1]

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
        offset = 0
        while data[currentIndex - 1] and 2 * @terminatorRadius > Math.abs data[currentIndex].comparatorLastY - data[currentIndex - 1].comparatorLastY
          if not data[currentIndex - 1].comparatorLastYear.comparatorOffset
            data[currentIndex - 1].comparatorLastYear.comparatorOffset = -1
          --currentIndex
          ++offset
        country.comparatorLastYear.comparatorOffset = if offset == 1
          1
        else
          dir = if offset % 2 then 1 else -1
          o = Math.ceil (offset + 1) / 2
          (o + 1) * dir

    line = d3.svg.line!
      ..x ~> it.comparatorOffset * (@terminatorRadius + 0.5) + @xScale it.year
      ..y ~> @yScale it.comparatorRate
      ..interpolate \basis
    zeryY = if drawChangeFromFirstCivil
      @yScale 1
    else
      @height + 20
    @zeroLine
      .attr \y1 zeryY
      .attr \y2 zeryY

    @paths = @pathsG.selectAll \g.country .data data
      ..enter!
        ..append \g
          ..attr \class -> "country" + if it.isSlovakia then " slovakia" else ""
          ..append \path
            ..attr \class \none
            ..datum ({comparatorYears}:country) ~>
              comparatorYears.filter -> it.year <= (Math.min country.dates.civil, country.dates.marriage)
          ..append \path
            ..attr \class \civil
            ..datum ({comparatorYears}:country) ~>
              comparatorYears.filter -> country.dates.civil <= it.year <= country.dates.marriage
          ..append \path
            ..attr \class \marriage
            ..datum ({comparatorYears}:country) ~>
              comparatorYears.filter -> country.dates.marriage <= it.year
          ..attr \data-tooltip ~> "#{it.name}"
      ..selectAll \path
        ..attr \d line

    @terminators = @terminatorsG.selectAll \circle .data data
      ..enter!
        ..append \circle
          ..attr \r @terminatorRadius
          ..attr \class ~>
              year = it.comparatorYears[*-1].year
              if year > it.dates.marriage
                "marriage"
              else if year > it.dates.civil
                "civil"
              else if it.name == "Slovakia"
                "slovakia"
              else
                ""
      ..attr \cx ~>
        it.comparatorLastYear.comparatorOffset * (@terminatorRadius + 0.5) + @xScale it.comparatorLastYear.year
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
      <b>#{ig.utils.formatNumber point[@currentMetric.id].value, 2}</b> #{@currentMetric.unit}<br></p>"
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

polygon = ->
  "M#{it.join "L"}Z"

