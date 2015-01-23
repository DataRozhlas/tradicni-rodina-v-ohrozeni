metrics =
  * id: "divorce-rate"
    title: "rozvodovost"
    amount: "hodnoty rozvodovosti"
    more: "více rozvodů"
  * id: "marriage-rate"
    title: "sňatečnost"
    amount: "hodnoty sňatečnosti"
    more: "více svateb"
  * id: "fertility-rate"
    title: "porodnost"
    amount: "hodnoty porodnosti"
    more: "více porodů"
  * id: "births-outside-marriage"
    title: "mimomanželské děti"
    amount: "podílu mimomanželských dětí"
    more: "více mimomanželských dětí"
  * id: "family-incomplete"
    title: "neúplné rodiny"
    amount: "podílu neúplných rodil"
    more: "více neúplných rodin"
  * id: "pregnancies-teen-rate"
    title: "těhotenství náctiletých"
    amount: "hodnoty těhotenství náctiletých"
    more: "více těhotenství náctiletých"
  * id: "abortions-rate"
    title: "potratovost"
    amount: "podílu potratů"
    more: "více potratů"

class ig.GodCorrelator extends ig.Correlator
  (@parentElement, data) ->
    @data = data.filter -> it.god and it.years[0]
    @supplemental = @parentElement.append \div
      ..attr \class \supplemental

    @correlatorContainer = @parentElement.append \div
      ..attr \class \correlator-container
    @drawSelector!
    super @correlatorContainer
    @labelX = -> "#{ig.utils.formatNumber it.x * 100} %"

    @labelPoint = -> it.name
    @drawSupplementalLabels!
    @draw metrics.0

  draw: (metric) ->
    @labelY = if metric.id in <[births-outside-marriage family-incomplete abortions-rate]>
      -> "#{ig.utils.formatNumber it.y, 1} %"
    else
      -> "#{ig.utils.formatNumber it.y, 1}"
    data = @data.map (country) ->
      x = country.god# + country.lifeForce
      {name, id} = country
      if country.years[*-1][metric.id]
        y = that.value
      else
        for year in country.years
          if yar[metric.id]
            y = that.value
      {x, y, name, id}
    data .= filter -> (it.y || it.y == 0) and (it.x || it.x == 0)
    @correlate data
    @svg.selectAll \circle
      .attr \class ->
        if it.id == "Czech Republic"
          "czech"
        else if it.id == "Slovakia"
          "slovakia"
        else
          ""

    corrCoef = jStat.corrcoeff do
      data.map (.x)
      data.map (.y)
    variance = (corrCoef ** 2) * 100
    influence = switch
    | variance < 15 => "vůbec neovlivňuje"
    | variance < 20 => "prakticky neovlivňuje"
    | variance < 50 => "téměř neovlivňuje"
    | variance < 60 => "mírně ovlivňuje"
    | otherwise => "silně ovlivňuje"
    @supplemental.html "
      <p>Víra v Boha<br><b>#influence</b><br>#{metric.title}</p>
      <p>Ovlivňuje příbližně <b>#{Math.round variance}&nbsp;%</b> #{metric.amount}</p>
      <p>Běžně uznávaná<br>hranice závislosti<br>je <b>50 %</b> <br></p>
      "
    @selectorLinks
      ..classed \active -> it is metric
    @ySupplementalLabel.html metric.more + " ›"

  drawSelector: ->
    selector = @parentElement.append \div
      ..attr \class \selector
      ..append \div
        ..attr \class \title
        ..html "Zobrazit jinou metriku:"
      ..append \div
        ..attr \class \list
        ..selectAll \a .data metrics .enter!append \a
          ..html -> it.title
          ..attr \href \#
          ..on \click ~>
            d3.event.preventDefault!
            @draw it
    @selectorLinks = selector.selectAll \a

  drawSupplementalLabels: ->
    @xSupplementalLabel = @parentElement.append \div
      .attr \class \supplemental-x
      .html "více věřících ›"
    @ySupplementalLabel = @parentElement.append \div
      .attr \class \supplemental-y
      .html "vyšší porodnost ›"
