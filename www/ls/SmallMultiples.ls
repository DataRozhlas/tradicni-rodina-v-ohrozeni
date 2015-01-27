firstCountries =
  "Czech Republic"
  "Slovakia"
  "Poland"
  "Great Britain"
  "Denmark"
  "Norway"

class Metric
  (@id, @name, @unit = '') ->
metricsHuman =
  "abortions-rate"          : new Metric "abortions-rate" "Potraty" "Počet potratů na 100 těhotenství"
  "births-outside-marriage" : new Metric "births-outside-marriage" "Děti narozené mimo manželství" "Procento dětí narozených mimo manželství"
  "fertility-rate"          : new Metric "fertility-rate" "Porodnost" "Narozených dětí na 1000 obyvatel"
  "pregnancies-teen-rate"   : new Metric "pregnancies-teen-rate" "Těhotenství náctiletých", "Těhotenství dívek mezi 10 a 19 lety na 100 000 dívek v populaci"
  "divorce-rate"            : new Metric "divorce-rate" "Rozvodovost" "Rozvodů na 1000 obyvatel"
  "marriage-rate"           : new Metric "marriage-rate" "Sňatečnost" "Sňatků na 1000 obyvatel"
class ig.SmallMultiples
  lineHeight: 75
  textWidth: 200
  graphWidth: 123
  startYear: 1982
  endYear: 2012
  (@parentElement, countries) ->
    @countries = countries
      .filter (.name)
      .sort (a, b) ->
        | a.searchable > b.searchable => 1
        | a.searchable < b.searchable => -1
        | otherwise => 0
    @metrics = <[fertility-rate births-outside-marriage pregnancies-teen-rate abortions-rate marriage-rate divorce-rate]>
    @parentElement.append \div
      ..attr \class \header
      ..selectAll \div .data @metrics .enter!append \div
        ..html -> metricsHuman[it].name
    @svg = @parentElement.append \svg
      ..attr \width 1000
    @parentElement.append \div
      ..attr \class \header
      ..selectAll \div .data @metrics .enter!append \div
        ..append \span .attr \class \name
          ..html -> metricsHuman[it].name
        ..append \span .attr \class \unit
          ..html -> metricsHuman[it].unit
    countrySelector = @parentElement.append \div
      ..attr \class \country-selector
      ..append \div
        ..attr \class \header
        ..html "Vyberte země k porovnání:"
      ..append \div
        ..attr \class \countries
        ..selectAll \a .data @countries .enter!append \a
          ..attr \class \country
          ..attr \href \#
          ..html -> it.name
          ..on \click ~>
            d3.event.preventDefault!
            index = firstCountries.indexOf it.id
            if index == -1
              firstCountries.push it.id
            else
              firstCountries.splice index, 1
            @redraw!
    @countriesElements = countrySelector.selectAll "a.country"
    @elementOffset = ig.utils.offset @parentElement.node!
    @redraw!

  redraw: ->
    metrics = @metrics
    @displayedCountries = displayedCountries = @countries.filter -> -1 != firstCountries.indexOf it.id
    displayedCountries.sort (a, b) -> (firstCountries.indexOf a.id) - (firstCountries.indexOf b.id)
    @countriesElements.classed \active -> -1 != firstCountries.indexOf it.id

    line = d3.svg.line!
      ..x (.x)
      ..y (.y)

    countriesYears = displayedCountries.map ~>
      it.years.filter ~> it.year > @startYear
    @xScale = xScale = d3.scale.linear!
      ..domain [@startYear, @endYear]
      ..range [0, @graphWidth]
    @yScales = yScales = metrics.map (metric) ~>
      minimum = Infinity
      maximum = -Infinity
      for countryYears in countriesYears
        for year in countryYears
          value = year[metric].value
          if value != null and isFinite value
            maximum = value if value > maximum
            minimum = value if value < minimum
      d3.scale.linear!
        ..domain [minimum, maximum]
        ..range [@lineHeight, 0]
    getLineX = (metric, metricIndex, countryIndex) ->
      country = displayedCountries[countryIndex]
      switch @getAttribute \class
        |\civil
          if country.firstYears.civil then xScale that.year else -9999
        |\marriage
          if country.firstYears.marriage then xScale that.year else -9999
        |\marriage-ban
          if country.firstYears.marriageBan then xScale that.year else -9999

    @svg
      .attr \height displayedCountries.length * (@lineHeight + 10) + 30
      .on \mousemove @~onMouseMove
    @countryG = @svg.selectAll \g.country .data displayedCountries, (.id)
      ..enter!append \g
        ..attr \class \country
        ..append \text
          ..text ~> it.name
          ..attr \x 0
          ..attr \y 20
        ..append \text
          ..attr \class "first-year civil"
          ..text ~>
            if it.firstYears.civil?year
              "Reg. partnerství: #that"
            else
              void
          ..attr \x 0
          ..attr \y 40
        ..append \text
          ..attr \class "first-year marriage"
          ..text ~>
            if it.firstYears.marriage?year
              "Manželství: #that"
            else
              void
          ..attr \x 0
          ..attr \y ~> if it.firstYears.civil then 60 else 40
        ..append \text
          ..attr \class "first-year marriage-ban"
          ..text ~>
            if it.firstYears.marriageBan?year
              "Úst. omezení manželství: #that"
            else
              void
          ..attr \x 0
          ..attr \y ~> if it.firstYears.civil then 60 else 40
        ..selectAll \g.graph .data metrics .enter!append \g
          ..attr \class \graph
          ..attr \transform (d, i) ~> "translate(#{@textWidth + i * (@graphWidth + 10)}, 0)"
          ..append \rect
            ..attr \x 0
            ..attr \y 0
            ..attr \width @graphWidth
            ..attr \height @lineHeight
          ..append \line .attr \class \civil
          ..append \line .attr \class \marriage
          ..append \line .attr \class \marriage-ban
          ..append \path
        ..append \g .attr \class \mouse-line
          ..attr \transform "translate(-1000,0)"
          ..append \line
            ..attr \x1 0
            ..attr \x2 0
            ..attr \y1 0
            ..attr \y2 @lineHeight
          ..append \text
            ..attr \class \year
            ..attr \text-anchor \middle
            ..attr \y (d, i) ~> if i then @lineHeight + 17 else -7
          ..append \rect
            ..attr \x -30
            ..attr \y 0
            ..attr \width 60
            ..attr \height 20
          ..append \text
            ..attr \text-anchor \middle
            ..attr \class \value
      ..exit!remove!
      ..attr \transform (d, i) ~> "translate(0, #{20 + i * (@lineHeight + 10)})"
      ..selectAll "g.graph path"
        ..attr \d (metric, metricIndex, countryIndex) ~>
          coords = countriesYears[countryIndex]
            .map ~>
              value = it[metric].value
              if value != null and not isNaN value and isFinite value
                x: xScale it.year
                y: yScales[metricIndex] value
              else
                null
            .filter -> it isnt null
          line coords
      ..classed \last (d, i) ~> i + 1 == @displayedCountries.length
      ..selectAll "g.graph line"
        ..attr \y1 0
        ..attr \y2 @lineHeight
        ..attr \x1 getLineX
        ..attr \x2 getLineX
    @mouseLineG = @svg.selectAll \g.mouse-line
    @mouseLineValue = @mouseLineG.select \text.value
    @mouseLineYear = @mouseLineG.select \text.year
    @mouseLineLine = @mouseLineG.select \line
    @mouseLineRect = @mouseLineG.select \rect

  onMouseMove: ->
    x = d3.event.layerX
    x -= @textWidth
    metricIndex = Math.floor x / (@graphWidth + 10)
    metric = @metrics[metricIndex]
    return @hideTip! if not metric
    return @hideTip! if x < 0
    x %= (@graphWidth + 10)
    year = Math.round @xScale.invert x
    return @hideTip! if year > @endYear
    projX = @textWidth + metricIndex * (@graphWidth + 10) + @xScale year

    @mouseLineG.attr \transform "translate(#{projX},0)"
    highlightedYears = @displayedCountries.map (country) ->
      highlightedYear = null
      for countryYear in country.years
        if countryYear.year == year # ok, naming convention could've been better
          highlightedYear = countryYear
      highlightedYear
    @mouseLineLine.attr \y1 (d, i) ~> @yScales[metricIndex] highlightedYears[i][metric].value
    @mouseLineValue.attr \y (d, i) ~> -10 + @yScales[metricIndex] highlightedYears[i][metric].value
    @mouseLineRect.attr \y (d, i) ~> -25 + @yScales[metricIndex] highlightedYears[i][metric].value
    @mouseLineValue.text (d, i) ~>
      if highlightedYears[i][metric].value != null
        ig.utils.formatNumber highlightedYears[i][metric].value, 2
      else
        'N/A'
    @mouseLineYear.text year

  hideTip: ->
    @mouseLineG.attr \transform "translate(-1000, 0)"
