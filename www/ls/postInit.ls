style = document.createElement 'style'
    ..innerHTML = ig.data.style
font = document.createElement \link
  ..href = '//fonts.googleapis.com/css?family=Roboto:300,400,400italic,700&subset=latin,latin-ext'
  ..rel = 'stylesheet'
  ..type = 'text/css'
document.getElementsByTagName 'head' .0
  ..appendChild style
  ..appendChild font
