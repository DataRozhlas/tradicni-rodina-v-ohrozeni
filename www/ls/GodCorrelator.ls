class ig.GodCorrelator extends ig.Correlator
  (@parentElement, data) ->
    @data = data.filter -> it.god and it.years[0]
    @correlatorContainer = @parentElement.append \div
      ..attr \class \correlator-container
    super @correlatorContainer
    @labelX = -> "#{ig.utils.formatNumber it.x * 100} %"
    @labelY = -> "#{ig.utils.formatNumber it.y, 1}"
    @labelPoint = -> it.name
    @draw 'divorce-rate'

  draw: (metric) ->
    data = @data.map (country) ->
      x = country.god# + country.lifeForce
      {name, id} = country
      if country.years[*-1][metric]
        y = that.value
      else
        for year in country.years
          if yar[metric]
            y = that.value
      {x, y, name, id}
    data .= filter -> it.y isnt null and it.x isnt null
    @correlate data
    @svg.selectAll \circle
      .attr \class ->
        if it.id == "Czech Republic"
          "czech"
        else if it.id == "Slovakia"
          "slovakia"
        else
          ""
