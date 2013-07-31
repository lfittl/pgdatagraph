class PG.DataGraph

  defaults:
    className : "datagraph"
    overview  : yes
    legend    : yes
    filters   : yes
    renderer  : "line"

  constructor: (element, @series, options) ->
    @element = $(element)
    @options = $.extend @defaults, options
    @graphs  = []

    @detail = $("<div class='#{@options.className}__detail'></div>")
    @element.append @detail
    @renderDetailGraph()

    if @options.filters
      @filters = $("<div class='#{@options.className}__filters'></div>")
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
    @graphs.push @detailGraph

  renderOverviewGraph: (series) ->
    series = @series unless series?
    @overviewGraph = new Rickshaw.Graph
      element: @overview.get(0)
      renderer: @options.renderer
      stroke: yes
      preserve: yes
      series: series

    @brush = new PG.Brush @overview, @overviewGraph,
      className: "#{@options.className}__brush"

    @overviewGraph.render()
    @graphs.push @overviewGraph
