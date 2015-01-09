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

class ig.Comparator
  startYear: 1990
  endYear: 2012
  (@baseElement, data) ->
    width = 1000
    height = 600

    @svg = @baseElement.append \svg
      ..attr \class \comparator
      ..attr \width width
      ..attr \height height
    margin = top: 0 right: 20 bottom: 0 left: 60
    @width = width - margin.right - margin.left
    @height = height - margin.top - margin.bottom
    @drawing = @svg.append \g
      ..attr \transform "translate(#{margin.left}, #{margin.top})"
    @zeroLine = @drawing.append \line
      ..attr \class \zero-line
      ..attr \x1 -20
      ..attr \x2 @width + 10
      ..attr \y1 10
      ..attr \y2 10
    @pathsG = @drawing.append \g
      ..attr \class \paths

    @xScale = d3.scale.linear!
      ..domain [@startYear, @endYear]
      ..range [0, @width]

    @yScale = d3.scale.linear!
      ..range [height, 0]
    @data = data.filter -> sensibleCountries[it.name]

    @display "marriage-rate"

  display: (metric, drawChangeFromFirstCivil) ->
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
        year.comparatorRate = year[metric].value
        if drawChangeFromFirstCivil
          year.comparatorRate /= (country.firstYears.civil || country.firstYears.marriage)[metric].value
        values.push year.comparatorRate
    # console.log d3.extent values
    @yScale.domain d3.extent values
    # @yScale.domain [0.42028985507246375, 1.5357142857142856]

    line = d3.svg.line!
      ..x ~> @xScale it.year
      ..y ~> @yScale it.comparatorRate
      ..interpolate \basis
    zeryY = if drawChangeFromFirstCivil
      @yScale 1
    else
      @height + 20
    @zeroLine
      .attr \y1 zeryY
      .attr \y2 zeryY

    @pathsG.selectAll \g.country .data data
      ..enter!
        ..append \g
          ..attr \class -> "country" + if it.name == "Slovakia" then " slovakia" else ""
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
          ..append \circle
            ..attr \r 4
          ..attr \data-tooltip ~> "#{it.name}"
      ..selectAll \path
        ..attr \d line
      ..selectAll \circle
        ..attr \cx ~> @xScale it.comparatorYears[*-1].year
        ..attr \cy ~> @yScale it.comparatorYears[*-1].comparatorRate
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





