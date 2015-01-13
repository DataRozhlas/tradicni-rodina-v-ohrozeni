class ig.SingleLine
  (@parentElement, @country, @metric) ->
    width = 1000
    height = 240
    @margin = top: 60 right: 60 bottom: 60 left: 25
    if @country.id == "Greece"
      height = 140
      @margin.top = 10
    @width = width - @margin.right - @margin.left
    @height = height - @margin.top - @margin.bottom
    @svg = @parentElement.append \svg
      ..attr \width width
      ..attr \height height
    @drawing = @svg.append \g
      ..attr \transform "translate(#{@margin.left}, #{@margin.top})"
    dataline = @country.years
      .filter -> 1985 < it.year
      .map ~> {year: it.year, value: it[@metric].value}
    @xScale = d3.scale.linear!
      ..domain d3.extent dataline.map (.year)
      ..range [0, @width]
    @yScale = d3.scale.linear!
      ..domain d3.extent dataline.map (.value)
      ..range [@height, 0]
    line = d3.svg.line!
      ..x ~> @xScale it.year
      ..y ~> @yScale it.value
      ..interpolate \cardinal
    @drawing.append \path
      ..attr \d line dataline
    @svg.append \text
      ..text ig.utils.formatNumber dataline.0.value, 1
      ..attr \x 0
      ..attr \y @margin.top + 4 + @yScale dataline.0.value
    @svg.append \text
      ..text ig.utils.formatNumber dataline.[*-1].value, 1
      ..attr \x @margin.left + 7 + @xScale dataline.[*-1].year
      ..attr \y @margin.top + 4 + @yScale dataline.[*-1].value
    if @country.id == "Czech Republic"
      @drawCzech!
    else
      @drawGreece!

  drawGreece: ->
    @parentElement.append \h3
      ..html "Sňatků na 1000 obyvatel v Řecku mezi roky 1985 a 2012"
    for i in [28 to 48 by 4]
      @drawGreekLineAt @country.years[i], @country.years[i].year

  drawCzech: ->
    @drawLineAt @country.years[30], "1990: Konec novomanželských půjček"
    @drawLineAt @country.years[46], "2006: Uzákoněno registrované partnerství"
    @svg.append \ellipse
      ..attr \cx @margin.left + @xScale @country.years[47].year
      ..attr \cy 7 + @margin.top + @yScale @country.years[47][@metric].value
      ..attr \rx (@xScale @country.years[47].year) - (@xScale @country.years[45].year)
      ..attr \ry 30
    @svg.append \text
      ..text "2005 – 2008: Společné zdanění manželů"
      ..attr \text-anchor \middle
      ..attr \x @margin.left + @xScale @country.years[47].year
      ..attr \y (7 + @margin.top + @yScale @country.years[47][@metric].value) - 50
    @parentElement.append \h3
      ..html "Sňatků na 1000 obyvatel v České republice mezi roky 1985 a 2012"

  drawLineAt: (year, text) ->
    x = @margin.left + @xScale year.year
    y = @margin.top + @yScale year[@metric].value
    textY = y - 30
    textD = 5
    if text == "2006: Uzákoněno registrované partnerství"
      y += 10
      textY += 85
    @svg.append \line
      ..attr \x1 x
      ..attr \x2 x
      ..attr \y1 textY
      ..attr \y2 y - 5
    @svg.append \text
      ..text text
      ..attr \x x + 5
      ..attr \y textY + textD
      ..attr \text-anchor \start

  drawGreekLineAt: (year, text) ->
    x = @margin.left + @xScale year.year
    y = @margin.top + @yScale year[@metric].value
    textY = @margin.top + @height + 20
    textD = 5
    y += 10
    @svg.append \line
      ..attr \x1 x
      ..attr \x2 x
      ..attr \y1 textY
      ..attr \y2 y - 5
    @svg.append \text
      ..text text
      ..attr \x x + 5
      ..attr \y textY + textD
      ..attr \text-anchor \start
