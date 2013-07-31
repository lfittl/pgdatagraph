class window.DataGraph

  defaults:
    className : "datagraph"
    overview  : yes
    legend    : yes
    filters   : yes
    renderer  : "line"

  constructor: (element, @series, options) ->
    @element  = $(element)
    @options  = $.extend @defaults, options
    @detail   = $("<div class='#{@options.className}__detail'></div>")
    @element.append @detail
    @renderDetailGraph()

    if @options.filters
      @filters  = $("<div class='#{@options.className}__filters'></div>")
      @element.append @filters

    if @options.overview
      @overview = $("<div class='#{@options.className}__overview'></div>")
      @element.append @overview
      @renderOverviewGraph()

  renderDetailGraph: (series) ->
    series = @series unless series?
    @detailGraph = new Rickshaw.Graph
      element: @detail.get(0)
      renderer: @options.renderer
      stroke: yes
      preserve: yes
      series: series
    @detailGraph.render()

  renderOverviewGraph: (series) ->
    series = @series unless series?
    @overviewGraph = new Rickshaw.Graph
      element: @overview.get(0)
      renderer: @options.renderer
      stroke: yes
      preserve: yes
      series: series

    @renderBrush()
    @overviewGraph.render()

  renderBrush: ->
    if @brush? and @brush.length > 0
      @brush.remove()

    @brush = $("<div class='#{@options.className}__brush'></div>")
    @overview.append @brush

    @min          = @overviewGraph.dataDomain()[0]
    @max          = @overviewGraph.dataDomain()[1]
    @domainValues = [@min..@max]
    @percentPx    = 100 / @brush.parent().width()

    @brush.draggable
      axis: "x"
      containment: @overview
      stop: @getRange

    @brush.resizable
      containment: @overview
      handles: "e, w"
      stop: @getRange

  getRange: (event, ui) =>
    left = ui.position.left
    width = @brush.width()
    startIndex = parseInt((left * @percentPx / 100) * @domainValues.length - 1, 10)
    endIndex = parseInt(((left + width) * @percentPx / 100) * @domainValues.length - 1, 10)
    console.log [@domainValues[startIndex], @domainValues[endIndex]]
    return [@domainValues[startIndex], @domainValues[endIndex]]
