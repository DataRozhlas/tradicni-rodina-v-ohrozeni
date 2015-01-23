class ig.Correlator
  (@parentElement) ->
    {clientWidth:@fullWidth, offsetHeight:@fullHeight} = @parentElement.node!
    @leftLabelWidth = 60
    @bottomLabelHeight = 20
    @margin = top: 5 left: @leftLabelWidth + 25, right: 25 bottom: 20 + @bottomLabelHeight
    @svg = @parentElement.append \svg
      ..attr \width @fullWidth
      ..attr \height @fullHeight
    @width = @fullWidth - @margin.left - @margin.right
    @height = @fullHeight - @margin.top - @margin.bottom
    @drawing = @svg.append \g
      ..attr \transform "translate(#{@margin.left},#{@margin.top})"
    @pointsG = @drawing.append \g
      ..attr \class \points
    @xAxisG = @svg.append \g
      ..attr \class "axis axis-x"
      ..attr \transform "translate(#{@margin.left},#{@margin.top + @height + 15})"
    @yAxisG = @svg.append \g
      ..attr \class "axis axis-y"
      ..attr \transform "translate(#{@leftLabelWidth}, #{@margin.top})"
    @xScale = d3.scale.linear!
      ..range [0, @width]
    @yScale = d3.scale.linear!
      ..range [@height, 0]
    @graphTip = new ig.GraphTip @
    @initVoronoi!

  correlate: (data) ->
    @currentData = data
    @xScale.domain d3.extent data.map (.x)
    @yScale.domain d3.extent data.map (.y)
    @drawCircles data
    @drawAxes data
    @drawVoronoi data

  drawCircles: (data) ->
    @pointElements = @pointsG.selectAll \g.point .data data, (.id)
      ..enter!append \g
        ..attr \class \point
        ..attr \transform ~> "translate(#{@xScale it.x},#{@yScale it.y})"
        ..append \line
          ..attr \class \x
        ..append \line
          ..attr \class \y
        ..append \circle
          ..attr \r 3
      ..exit!remove!
      ..transition!
        ..duration 800
        ..attr \transform ~> "translate(#{@xScale it.x},#{@yScale it.y})"
      ..select \line.x
        ..attr \y2 ~> 15 + (@height - @yScale it.y)
      ..select \line.y
        ..attr \x1 ~> "#{-20 + -1 * @xScale it.x}"

  drawAxes: (data) ->
    @drawXAxis data
    @drawYAxis data

  drawXAxis: (data) ->
    extent = d3.extent data.map (.x)
    @xAxisElements = @xAxisG.selectAll \g .data data, (.id)
      ..enter!append \g
        ..attr \transform ~> "translate(#{@xScale it.x}, 0)"
        ..append \line
          ..attr \y1 0
          ..attr \y2 5
          ..attr \x1 0
          ..attr \x2 0
        ..append \text
          ..attr \text-anchor \middle
          ..attr \y 20
      ..exit!remove!
      ..attr \class ->
        switch it.x
        | extent.0 => "min"
        | extent.1 => "max"
        | otherwise => ""
      ..transition!
        ..duration 800
        ..attr \transform ~> "translate(#{@xScale it.x}, 0)"
        ..select \text
          ..text @labelX

  drawYAxis: (data) ->
    data = data.slice!sort (a, b) -> a.y - b.y
    extent = d3.extent data.map (.y)
    @yAxisElements = @yAxisG.selectAll \g .data data, (.id)
      ..enter!append \g
        ..attr \transform ~> "translate(0, #{@yScale it.y})"
        ..append \line
          ..attr \y1 0
          ..attr \y2 0
          ..attr \x1 0
          ..attr \x2 5
        ..append \text
          ..attr \text-anchor \end
          ..attr \y 5
          ..attr \x -5
      ..exit!remove!
      ..attr \class ->
        switch it.y
        | extent.0 => "min"
        | extent.1 => "max"
        | otherwise => ""
      ..transition!
        ..duration 800
        ..attr \transform ~> "translate(0, #{@yScale it.y})"
        ..select \text
          ..text @labelY

  initVoronoi: ->
    @voronoiPointGenerator = d3.geom.voronoi!
      ..x ~> @xScale it.x
      ..y ~> @yScale it.y
      ..clipExtent [[-5, -5], [@width + 5, @height + 5]]
    @voronoiXGenerator = d3.geom.voronoi!
      ..x ~> @xScale it.x
      ..y 0
      ..clipExtent [[-5, 0], [@width + 5, @margin.bottom]]
    @voronoiYGenerator = d3.geom.voronoi!
      ..clipExtent [[0, -5], [@margin.left - 5, @height + 5]]
      ..x 0
      ..y ~> @yScale it.y

    @voronoiSvg = @parentElement.append \svg
      ..attr \class \voronoi
      ..attr \width @fullWidth
      ..attr \height @fullHeight
    @voronoiPointsG = @voronoiSvg.append \g
      ..attr \transform "translate(#{@margin.left},#{@margin.top})"
    @voronoiXG = @voronoiSvg.append \g
      ..attr \transform "translate(#{@margin.left},#{@margin.top + @height + 5})"
    @voronoiYG = @voronoiSvg.append \g
      ..attr \transform "translate(0,#{@margin.top})"

  drawVoronoi: (data) ->
    points = @voronoiPointGenerator data
      .filter -> it
    @voronoiSvg.selectAll \path .remove!
    @voronoiPointsG.selectAll \path .data points .enter!append \path
      ..attr \d polygon
      ..on \mouseover ~> @highlightPoint it.point
      ..on \mouseout @~downlight
    xPoints = @voronoiXGenerator data
      .filter -> it
    @voronoiXG.selectAll \path .data xPoints .enter!append \path
      ..attr \d polygon
      ..on \mouseover ~> @highlightX it.point.x
      ..on \mouseout @~downlight
    yPoints = @voronoiYGenerator data
      .filter -> it
    @voronoiYG.selectAll \path .data yPoints .enter!append \path
      ..attr \d polygon
      ..on \mouseover ~> @highlightY it.point.y
      ..on \mouseout @~downlight

  highlightPoint: (point) ->
    @svg.classed \hasActive yes
    @pointElements.classed \active -> it is point
    @xAxisElements.classed \active -> it.x is point.x
    @yAxisElements.classed \active -> it.y is point.y
    @graphTip.display do
      @xScale point.x
      @yScale point.y
      @labelPoint point

  highlightX: (x) ->
    @svg.classed \hasActive yes
    points = @currentData.filter -> it.x is x
    @pointElements.classed \active -> it in points
    @xAxisElements.classed \active -> it.x is x
    @yAxisElements.classed \active -> it in points

  highlightY: (y) ->
    @svg.classed \hasActive yes
    points = @currentData.filter -> it.y is y
    @pointElements.classed \active -> it in points
    @xAxisElements.classed \active -> it in points
    @yAxisElements.classed \active -> it.y is y

  downlight: ->
    @svg
      ..classed \hasActive no
      ..selectAll \.active .classed \active no
    @graphTip.hide!

  labelX: -> it.x
  labelY: -> it.y
  labelPoint: -> it.id



polygon = ->
  "M#{it.join "L"}Z"
