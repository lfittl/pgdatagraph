class PG.Palette

  colors:
    red:
      stroke: "#b64639"
      fill: "#dc6355"
    orange:
      stroke: "#b27a01"
      fill: "#e3b514"
    yellowGreen:
      stroke: "#9bac0c"
      fill: "#c3d52a"
    lime:
      stroke: "#60a121"
      fill: "#8cd347"
    mediumSeaGreen:
      stroke: "#1a9853"
      fill: "#47d386"
    turquoise:
      stroke: "#188a91"
      fill: "#47cbd3"
    dodgerBlue:
      stroke: "#1675ab"
      fill: "#39a9e9"
    violet:
      stroke: "#5d5bbb"
      fill: "#8f8dee"
    orchid:
      stroke: "#5d5bbb"
      fill: "#8f8dee"
    violetRed:
      stroke: "#b42b58"
      fill: "#ed789e"

  random: ->
    unused = _(@colors).map (colors, name) =>
      name unless @colors[name].used
    randomKey = unused[Math.floor(Math.random() * unused.length)]
    @colors[randomKey].used = yes
    @colors[randomKey]


