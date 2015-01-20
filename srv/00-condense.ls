require! {
  fs
  csv: 'csv-parse'
  async
}

keyJoin = '&'
valueJoin = '|'
dir = "#__dirname/../data/eurostat"
countries = {}
file_to_metric =
  'demo_fabort_1_Data.csv'   : 'abortions'
  'demo_find_1_Data.csv'     : 'fertility'
  'demo_fordager_1_Data.csv' : 'pregnancies'
  'demo_ndivind_1_Data.csv'  : 'divorce'
  'demo_nind_1_Data.csv'     : 'marriage'
  'hlth_cd_asdr_1_Data.csv'  : 'hiv'
  'ilc_lvps20_1_Data.csv'    : 'family'
(err, files) <~ fs.readdir dir
# files.length = 1
fields = {}
years = {}
spaceRegex = new RegExp "[ ,]" 'g'

(err, data) <~ fs.readFile "#__dirname/../data/migr_pop1ctz_1_Data.csv"
(err, output) <~ csv data, {}
output.shift!
countries_teens = {}
for [year, country,  _, age, _, value] in output
  value = if value == ":"
     null
  else
    parseFloat value.replace spaceRegex, ''
  countries_teens[country] ?= {pedo: 0, nopedo: 0}
  if value
    if age == 'From 15 to 19 years'
      countries_teens[country].nopedo = value
    else
      countries_teens[country].pedo = value

<~ async.eachSeries files, (file, cb) ->
  (err, data) <~ fs.readFile "#dir/#file"
  (err, output) <~ csv data, {}
  output.shift!
  for [year, country, ...bullshit, field, value, flags] in output
    out = if value == ":"
       ''
    else
      parseFloat value.replace spaceRegex, ''

    outField = file_to_metric[file] + '-' + field
    fields[outField] = 1
    years[year] = 1
    countries[country] ?= {}
    countries[country][outField] ?= {}
    countries[country][outField][year] = [out, flags]
  cb!

# console.log fields
# console.log years
outFields =
  'abortions-Total'
  'abortions-Teen' # !!
  'fertility-Proportion of live births outside marriage'
  'fertility-Total fertility rate'
  'fertility-Mean age of women at birth of first child'
  'pregnancies-Total' #
  'pregnancies-Teen' # !!
  'divorce-Crude divorce rate'
  'marriage-Crude marriage rate'
  'hiv-Human immunodeficiency virus [HIV] disease'
  'family-incomplete'

lines = for country of countries
  cells = for year in [1960 to 2012]
    values = for field in outFields
      value = if field == "abortions-Teen"
        o =
          (countries[country]['abortions-Less than 15 years']?[year].0 || '') + (countries[country]['abortions-From 15 to 19 years']?[year].0 || '')
          countries[country]['abortions-Less than 15 years']?[year].1
      else if field == 'pregnancies-Teen'
        o =
          (countries[country]['pregnancies-From 10 to 14 years']?[year].0 || '') + (countries[country]['pregnancies-From 15 to 19 years']?[year].0 || '')
          countries[country]['pregnancies-From 10 to 14 years']?[year].1
      else if field == "family-incomplete"
        o =
          (countries[country]['family-Child not living with parents']?[year]?0 || '') + (countries[country]['family-Child living with a single parent']?[year]?0 || '')
          countries[country]['family-Child not living with parents']?[year]?1
      else
        (countries[country]?[field]?[year]) || ['']

      if value.1
        value.join keyJoin
      else
        value.0
    values.join valueJoin
  cells.unshift if countries_teens[country] then that.pedo + that.nopedo else 0
  cells.unshift country
  cells.join "\t"
lines.unshift (['country' 'teen-females'] ++ [1960 to 2012]).join "\t"
csv = lines.join "\n"
fs.writeFile "#__dirname/../data/stats.tsv", csv



