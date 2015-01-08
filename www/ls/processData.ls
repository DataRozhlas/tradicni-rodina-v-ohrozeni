class Country
  (@name, @dates) ->

ig.processData = ->
  dates = processDates!
  lines = ig.data.stats.split "\n"
    ..shift!
  allYears = [1960 to 2012]
  allMetrics =
    "abortions-total"
    "abortions-teen"
    "births-outside-marriage"
    "fertility-rate"
    "age-at-first-child"
    "pregnancies-total"
    "pregnancies-teen"
    "divorce-rate"
    "marriage-rate"
    "hiv-rate"

  countries = for line in lines
    [countryName, ...years] = line.split "\t"
    id = countryName
    country = new Country countryName, dates[countryName]
    years .= map (d, i) ->
      year = allYears[i]
      yearData = {year}
      for cell, index in  d.split "|"
        metric = allMetrics[index]
        [value, footnotes] = cell.split "&"
        value = if value.length
          parseFloat value
        else
          null
        yearData[metric] = {value, footnotes}
      yearData
    {country, id, years}
  countries

processDates = ->
  lines = ig.data.dates.split "\n"
    ..shift!
    ..pop!
  countryDates = {}
  for line in lines
    [country, ...dates] = line.split "\t"
    dates .= map ->
      if it.length
        parseInt do
          it.split "-" .0
          10
      else
        9999
    [civil, marriage, adoption, marriageBan] = dates
    countryDates[country] = {civil, marriage, adoption, marriageBan}
  countryDates


