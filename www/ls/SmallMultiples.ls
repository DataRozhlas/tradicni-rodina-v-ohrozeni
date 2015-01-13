firstCountries =
  "Czech Republic"
  "Slovakia"
  "Poland"
  "Great Britain"
  "Netherlands"
  "Spain"

class ig.SmallMultiples
  lineHeight: 120
  textWidth: 200
  graphWidth: 149
  startYear: 1982
  endYear: 2012
  (@parentElement, @countries) ->
    metrics = <[divorce-rate marriage-rate fertility-rate pregnancies-teen-rate abortions-rate]>
    @svg = @parentElement.append \svg
      ..attr \width 1000
    toDisplay = @countries.filter -> -1 != firstCountries.indexOf it.id
    toDisplay.sort (a, b) -> (firstCountries.indexOf a.id) - (firstCountries.indexOf b.id)

    line = d3.svg.line!
      ..x (.x)
      ..y (.y)

    countriesYears = toDisplay.map ~>
      it.years.filter ~> it.year > @startYear
    xScale = d3.scale.linear!
      ..domain [@startYear, @endYear]
      ..range [0, @graphWidth]
    yScales = metrics.map (metric) ~>
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

    @svg.attr \height toDisplay.length * (@lineHeight + 10)
    @countryG = @svg.selectAll \g.country .data toDisplay, (.id)
      ..enter!append \g
        ..attr \class \country
        ..append \text
          ..text ~> it.name
          ..attr \x 20
          ..attr \y 20
        ..selectAll \g.graph .data metrics .enter!append \g
          ..attr \class \graph
          ..attr \transform (d, i) ~> "translate(#{@textWidth + i * (@graphWidth + 10)}, 0)"
          ..append \rect
            ..attr \x 0
            ..attr \y 0
            ..attr \width @graphWidth
            ..attr \height @lineHeight
          ..append \path
      ..attr \transform (d, i) ~> "translate(0, #{i * (@lineHeight + 10)})"
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
