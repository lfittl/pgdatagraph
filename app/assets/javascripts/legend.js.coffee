class PG.Legend

  defaults:
    className: "legend"

  constructor: (container, @graphs, options) ->
    @container = $(container)
    @options = $.extend @defaults, options
    @element = $("<div></div>").addClass(@options.className)
    @container.append @element

    @legend = new Rickshaw.Graph.Legend
      graph: @graphs[0]
      element: @element.get(0)

    instance = @
    @graphSeries = {}
    for line, i in @legend.lines
      $label = $(line.element).find("span").first()
      $label.attr "rel", line.series.name
      @graphSeries[line.series.name] =
        series   : _.map @graphs, (graph) -> graph.series[graph.series.length - 1 - i]
        disabled : no
      $label.on "click", ->
        instance.toggle $(this)

  toggle: ($label) ->
    $line = $label.parent(".line")
    name = $label.attr("rel")
    graphSeries = @graphSeries[name]

    if graphSeries.disabled
      graphSeries.disabled = no
      series.disabled = no for series in graphSeries.series
      $label.removeClass "#{@options.className}__label_disabled"
      $line.removeClass "disabled"
    else
      return if _.every(_.pluck(_.without(@graphSeries, graphSeries), "disabled"))
      graphSeries.disabled = yes
      series.disabled = yes for series in graphSeries.series
      $label.addClass "#{@options.className}__label_disabled"
      $line.addClass "disabled"
    @updateGraphs()

  updateGraphs: ->
    graph.update() for graph in @graphs
