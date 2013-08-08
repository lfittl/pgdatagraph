# Graph looks weird with series that have extreme drops to x: 0

class PG.DataGraph

  defaults:
    className: "datagraph"
    overview: yes
    legend: yes
    datePickers: [
      { label: "last 30 days",  duration: "-1m" },
      { label: "last 2 weeks",  duration: "-2w" },
      { label: "last 24 hours", duration: "-1d" }
    ]
    dateFormat: "M d, yy"
    palette: {
      "default": {
        color: "rgba(192,132,255,0.5)"
        stroke: "rgba(0,0,0,0.15)"
      }
      "table_size": {
        color: "rgba(241,196,15,0.5)"
        stroke: "rgba(241,196,15,1.0)"
      }
      "unclassified": {
        color: "rgba(39,174,96,0.5)"
        stroke: "rgba(39,174,96,1.0)"
      }
      "OLTP": {
        color: "rgba(192,57,43,0.5)"
        stroke: "rgba(192,57,43,1.0)"
      }
    }
    series: {
      renderer: "line"
    }
    detailSmoothing: 10
    overviewSmoothing: 10
    yAxisTickFormat: (y) -> y
    hoverDetailYFormat: (y) -> y.toFixed(2)
    hoverDetailLabelFormat: (series, x, y, formattedX, formattedY, d) ->
      "#{series.name}:&nbsp;#{formattedY}"
    dataSelectionChanged: $.noop

  constructor: (element, @url, options) ->
    @element = $(element)
    @options = $.extend yes, @defaults, options
    @graphs  = []

    @renderLoaders()

    if @options.legend
      @legendContainer = $("<div class='#{@options.className}__legend'></div>")
      @element.append @legendContainer

    @detail = $("<div class='#{@options.className}__detail'></div>")
    @element.append @detail

    if @options.datePickers
      @datePickers = $("<div class='#{@options.className}__datepickers'></div>")
      @element.append @datePickers
      @calendar = $("<div class='#{@options.className}__calendar'></div>")
      @calendarFrom = $("<input class='#{@options.className}__calendar-from'>")
      @calendarTo = $("<input class='#{@options.className}__calendar-to'>")
      @calendar.append @calendarFrom
      @calendar.append $("<span class='#{@options.className}__calendar-dash'>–</span>")
      @calendar.append @calendarTo
      @calendarFrom.datepicker
        onSelect: @calendarDateSelected
        dateFormat: @options.dateFormat
        showAnim: ""
      @calendarTo.datepicker
        onSelect: @calendarDateSelected
        dateFormat: @options.dateFormat
        showAnim: ""
      @datePickers.append @calendar
      if @options.datePickers.length
        for datePicker, i in @options.datePickers
          $datePicker = $("<div class='#{@options.className}__datepicker' rel='#{datePicker.duration}'>#{datePicker.label}</div>")
          @datePickers.append $datePicker
          if i is 0
            $datePicker.addClass("#{@options.className}__datepicker_first")
            @selectDatePicker $datePicker
          if i is @options.datePickers.length - 1
            $datePicker.addClass("#{@options.className}__datepicker_last")

    instance = @
    @datePickers.on "click", ".#{@options.className}__datepicker", (event) ->
      instance.selectDatePicker $(this)

    if @options.overview
      @overview = $("<div class='#{@options.className}__overview'></div>")
      @element.append @overview

  getSeries: (data) ->
    @seriesDataNames = {}
    series = []
    _(data).each (seriesData, name) =>
      seriesData = _.map seriesData, (s) -> { x: s[0], y: s[1] }
      palette = @options.palette[name] or @options.palette.default
      stroke = if renderer is "area" then no else palette.stroke
      renderer = @options.series[name]?.renderer or @options.series.renderer
      seriesName = @options.series[name]?.name or name
      @seriesDataNames[seriesName] = name
      series.push {
        data: seriesData
        name: seriesName
        renderer: renderer
        stroke: stroke
        color: palette.color
      }
    series

  renderLoaders: ->
    @loader = $("<div class='#{@options.className}__loader'><span class='#{@options.className}__loader-label'>Loading graph data…</span></div>")
    @detailLoader = $("<div class='#{@options.className}__detail-loader'><span class='#{@options.className}__loader-label'>Loading details…</span></div>")
    @element.addClass "#{@options.className}_loading"
    @element.append @loader
    @element.append @detailLoader

  renderDetailGraph: (series) ->
    if @detailGraph?
      @detail.html("")
      @detailGraph = null
    @detailGraph = new Rickshaw.Graph
      element: @detail.get(0)
      preserve: yes
      series: series
      renderer: "multi"
      dotSize: 2

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: @detailGraph
    xAxis.render()

    yAxis = new Rickshaw.Graph.Axis.Y
      graph: @detailGraph
      tickFormat: @options.yAxisTickFormat
    yAxis.render()

    detail = new Rickshaw.Graph.HoverDetail
      graph: @detailGraph
      yFormatter: @options.hoverDetailYFormat
      formatter: @options.hoverDetailLabelFormat

    smoother = new Rickshaw.Graph.Smoother
      graph: @detailGraph

    smoother.setScale @options.detailSmoothing

    @graphs.push @detailGraph
    @detailGraph.render()

  renderOverviewGraph: (series) ->
    if @overviewGraph?
      @overview.html("")
      @overviewGraph = null
    @overviewGraph = new Rickshaw.Graph
      element: @overview.get(0)
      preserve: yes
      series: series
      renderer: "multi"

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: @overviewGraph
    xAxis.render()

    smoother = new Rickshaw.Graph.Smoother
      graph: @overviewGraph

    smoother.setScale @options.overviewSmoothing

    @overviewGraph.render()
    @graphs.push @overviewGraph

    @brush = new PG.Brush @overview, @overviewGraph,
      className: "#{@options.className}__brush"
      rangeChanged: @overviewRangeChanged
    @rangeStart = @brush.min
    @rangeEnd = @brush.max

  getActiveSeriesNames: ->
    _.compact _.map @graphs[0].series, (s) =>
      @seriesDataNames[s.name] unless s.disabled

  overviewRangeChanged: (start, end) =>
    @element.addClass "#{@options.className}_loading-details"
    @rangeStart = start
    @rangeEnd = end
    @options.dataSelectionChanged(start, end, @getActiveSeriesNames())
    $.ajax
      dataType: "jsonp"
      url: "#{@url}"
      data: {
        start: start
        end: end
      }
      type: "get"
      success: (data, status, xhr) =>
        series = @getSeries(data)
        @graphs = [@overviewGraph]
        @renderDetailGraph(series)
        @updateLegend() if @options.legend
        @updateSeries()
        @element.removeClass "#{@options.className}_loading-details"

  updateLegend: (yo) =>
    @legendContainer.html("")
    @legend = new PG.Legend @legendContainer, @graphs, {
      onToggle: (seriesStates) =>
        @seriesStates = seriesStates
        @options.dataSelectionChanged(@rangeStart, @rangeEnd, @getActiveSeriesNames())
    }

  updateSeries: =>
    if @options.overview and @overviewGraph and @seriesStates?
      for series in @detailGraph.series
        series.disabled = !@seriesStates[series.name]
      for series in @overviewGraph.series
        series.disabled = !@seriesStates[series.name]
      @detailGraph.update()
      @overviewGraph.update()

  selectDatePicker: ($datePicker) ->
    @calendar.removeClass "#{@options.className}__calendar_active"
    activeClassName = "#{@options.className}__datepicker_active"
    @element.find(".#{activeClassName}").removeClass(activeClassName)
    $datePicker.addClass activeClassName
    @calendarFrom.datepicker "setDate", $datePicker.attr("rel")
    @calendarTo.datepicker "setDate", new Date()
    @updateTimeframe()

  calendarDateSelected: =>
    @element.find(".#{@options.className}__datepicker_active").removeClass("#{@options.className}__datepicker_active")
    @calendar.addClass "#{@options.className}__calendar_active"
    @updateTimeframe()

  updateTimeframe: =>
    @element.addClass "#{@options.className}_loading"
    $.ajax
      dataType: "jsonp"
      url: "#{@url}"
      data: {
        start: @calendarFrom.datepicker('getDate').getTime() / 1000
        end: @calendarTo.datepicker('getDate').getTime() / 1000
      }
      type: "get"
      success: (data, status, xhr) =>
        @element.removeClass "#{@options.className}_loading"
        series = @getSeries(data)
        @graphs = []
        @renderDetailGraph(series)
        @renderOverviewGraph(series)
        @updateSeries()
        @updateLegend() if @options.legend

