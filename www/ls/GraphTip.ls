class ig.GraphTip
  (@graph) ->
    @element = @graph.container.append \div
      ..attr \class "graph-tip"
    @content = @element.append \div
      ..attr \class \content
    @arrow = @element.append \div
      ..attr \class \arrow

  display: (point, content) ->
    @element.classed \active yes
    @content.html content
    width = @element.node!offsetWidth
    height = @element.node!offsetHeight
    xPosition = @graph.margin.left + point.comparatorOffset * (@graph.terminatorRadius + 0.5) + @graph.xScale point.year
    yPosition = @graph.margin.top + @graph.yScale point.comparatorRate
    left = xPosition - width / 2
    offset = 0
    if left < 0
      offset = left
      left = 0
    if left + width > @graph.fullWidth
      offset = left + width - @graph.fullWidth
      left = @graph.fullWidth - width
    top = yPosition - height
    @element
      ..style \left left + "px"
      ..style \top top + "px"
    @arrow.style \left offset + "px"

  hide: ->
    @element.classed \active no
