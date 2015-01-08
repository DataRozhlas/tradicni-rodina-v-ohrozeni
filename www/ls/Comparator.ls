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
    width = width - margin.right - margin.left
    height = height - margin.top - margin.bottom

    @drawing = @svg.append \g
      ..attr \transform "translate(#{margin.left}, #{margin.top})"
    @pathsG = @drawing.append \g
      ..attr \class \paths

    @xScale = d3.scale.linear!
      ..domain [@startYear, @endYear]
      ..range [0, width]

    @yScale = d3.scale.linear!
      ..range [height, 0]

    @data = data.map ({country, years}) ~>
      years .= filter ~> it.year >= @startYear
      {country, years}
    @data .= filter -> sensibleCountries[it.country.name]
    @zeroLine = @drawing.append \line
      ..attr \class \zero-line
      ..attr \x1 -20
      ..attr \x2 width + 10
      ..attr \y1 10
      ..attr \y2 10

    @display "fertility-rate"

  display: (metric) ->
    values = []
    displayable = for {country, years} in @data
      years .= filter -> it[metric].value isnt null
      for year in years
        year.comparatorRate = year[metric].value# / years[0][metric].value
        values.push year.comparatorRate
      if country.name == "Cyprus"
        console.log years.map (.comparatorRate)
      {country, years}
    # console.log d3.extent values
    @yScale.domain d3.extent values
    # @yScale.domain [0.42028985507246375, 1.5357142857142856]

    line = d3.svg.line!
      ..x ~> @xScale it.year
      ..y ~> @yScale it.comparatorRate
      ..interpolate \basis

    @zeroLine
      .attr \y1 @yScale 1
      .attr \y2 @yScale 1

    @pathsG.selectAll \g.country .data displayable
      ..enter!
        ..append \g
          ..attr \class -> "country" + if it.country.name == "Slovakia" then " slovakia" else ""
          ..append \path
            ..attr \class \none
            ..datum ({country, years}) ~>
              years.filter -> it.year <= (Math.min country.dates.civil, country.dates.marriage)
          ..append \path
            ..attr \class \civil
            ..datum ({country, years}) ~>
              years.filter -> country.dates.civil <= it.year <= country.dates.marriage
          ..append \path
            ..attr \class \marriage
            ..datum ({country, years}) ~>
              years.filter -> country.dates.marriage <= it.year
          ..append \circle
            ..attr \r 4
      ..selectAll \path
        ..attr \d line
        ..attr \data-tooltip (d, i, ii) ~> "#{@data[ii].country.name}"
      ..selectAll \circle
        ..attr \cx ~> @xScale it.years[*-1].year
        ..attr \cy ~> @yScale it.years[*-1].comparatorRate
        ..attr \class ~>
            year = it.years[*-1].year
            if year > it.country.dates.marriage
              "marriage"
            else if year > it.country.dates.civil
              "civil"
            else if it.country.name == "Slovakia"
              "slovakia"
            else
              ""





