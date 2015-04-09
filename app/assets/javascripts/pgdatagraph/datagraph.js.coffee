class PG.DataGraph

  @defaults:
    className: "datagraph"
    overview: yes
    legend: yes
    datePickers: [
      { label: "last 30 days",  duration: 30 },
      { label: "last 2 weeks",  duration: 14 },
      { label: "last 24 hours", duration: 1 }
    ]
    defaultDuration: 1
    series: {}
    dateFormat: "M d, yy"
    timezone: "Etc/UTC"
    renderer: "line"
    stack: false
    detailSmoothing: 10
    overviewSmoothing: 10
    yAxisTickFormat: (y) -> y
    hoverDetailYFormat: (y) -> y.toFixed(2)
    hoverDetailLabelFormat: (series, x, y, formattedX, formattedY, d) ->
      "#{series.name}:&nbsp;#{formattedY}"
    dataSelectionChanged: $.noop
    hoverDetailClicked: $.noop
    secondaryAxis: null

  constructor: (element, @url, options) ->
    @element = $(element)
    defaults = $.extend yes, {}, @constructor.defaults
    @options = $.extend yes, defaults, options
    @graphs  = []
    @palette = new PG.Palette()
    @seriesColors = {}

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
          if i is @options.datePickers.length - 1
            $datePicker.addClass("#{@options.className}__datepicker_last")
          if datePicker.duration == @options.defaultDuration
            @selectDatePicker $datePicker

    instance = @
    @datePickers.on "click", ".#{@options.className}__datepicker", (event) ->
      instance.selectDatePicker $(this)

    if @options.overview
      @overview = $("<div class='#{@options.className}__overview'></div>")
      @element.append @overview

    $(@detail).on "click", @hoverDetailClicked

  calculateSeriesData: (seriesData, name, scale, opts = {}) ->
    if @seriesColors[name]?
      color = @seriesColors[name]
    else
      if @options.series[name]?.color?
        color = @palette.colors[@options.series[name].color]
      else
        color = @palette.color()
      @seriesColors[name] = color

    renderer = opts.renderer or @options.series[name]?.renderer or @options.renderer
    seriesName = @options.series[name]?.name or name
    @seriesDataNames[seriesName] = name

    if renderer is "area"
      stroke = no
    else
      stroke = color.stroke

    s = {
      data: seriesData
      name: seriesName
      renderer: renderer
      stroke: stroke
      color: color.fill
      scale: scale
      className: opts.className
      yFormatter: opts.yFormatter
    }

    if @options.series[name]?.disabled
      s.disabled = yes

    s

  getSeries: (data) ->
    @seriesDataNames = {}
    series = []

    initialOrder = _.keys(data)

    if @options.series
      seriesOrder = _.keys(@options.series)
      for name in seriesOrder
        initialOrder = _.without initialOrder, name
      initialOrder = seriesOrder.concat(initialOrder)

    @seriesOrder = initialOrder unless @seriesOrder? && @seriesOrder.slice(0).sort() == initialOrder.slice(0).sort()

    primaryMax = _.max(data[@seriesOrder[0]], (s) -> s[1])[1]
    @primaryScale = d3.scale.linear().domain([0, primaryMax]).nice()

    if @options.secondaryAxis?
      secondaryMax = _.max(data[@seriesOrder[0]], (s) -> s[2])[2]
      @secondaryScale = d3.scale.linear().domain([0, secondaryMax]).nice()

    for name in @seriesOrder
      primaryData = _.map data[name], (s) -> { x: s[0], y: s[1] }
      series.push(@calculateSeriesData(primaryData, name, @primaryScale)) if primaryData.length > 0

      if @options.secondaryAxis?
        secondaryData = _.map data[name], (s) -> { x: s[0], y: s[2] }
        secondaryOpts = { className: @options.secondaryAxis.className, yFormatter: @options.secondaryAxis.hoverDetail, renderer: 'better_bar' }
        series.push(@calculateSeriesData(secondaryData, @options.secondaryAxis.name, @secondaryScale, secondaryOpts)) if secondaryData.length > 0 && secondaryData[0].y?

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
      interpolation: "linear"
      padding:
        top: 0.1
      dotSize: 2
      stack: @options.stack

    @setupXAxis(@detail)
    @setupYAxis(@detail)

    xAxis = new Rickshaw.Graph.Axis.Time
      element: @detail.find('.x-axis-container').get(0)
      graph: @detailGraph
      ticksTreatment: "glow"
      timeFixture: new Rickshaw.Fixtures.TimeWithTimezone(@options.timezone)

    new Rickshaw.Graph.Axis.Y.Scaled
      element: @detail.find('.primary-y-axis-container').get(0)
      graph: @detailGraph
      tickFormat: @options.yAxisTickFormat
      ticksTreatment: "glow"
      pixelsPerTick: @options.pixelsPerTick or 25
      orientation: 'right'
      scale: @primaryScale

    if @options.secondaryAxis?
      new Rickshaw.Graph.Axis.Y.Scaled
        element: @detail.find('.secondary-y-axis-container').get(0)
        graph: @detailGraph
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT
        ticksTreatment: "glow"
        pixelsPerTick: @options.pixelsPerTick or 25
        orientation: 'left'
        scale: @secondaryScale
        grid: false

    detail = new Rickshaw.Graph.HoverDetail
      graph: @detailGraph
      yFormatter: @options.hoverDetailYFormat
      xFormatter: (x) => moment(x * 1000).tz(@options.timezone).format("llll zz")
      formatter: @options.hoverDetailLabelFormat
      onRender: (detail) =>
        point = detail.points.filter((p) -> p.active).shift()
        @currentDetail =
          x: detail.domainX
          series: point.series

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
      interpolation: "linear"
      padding:
        top: 0.1
      unstack: @options.unstack
      ticksTreatment: "glow"

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: @overviewGraph
      timeFixture: new Rickshaw.Fixtures.TimeWithTimezone(@options.timezone)

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

  setupXAxis: ($container) ->
    $xAxisContainer = $("<div class='x-axis-container'></div>")
    $container.find("svg").after $xAxisContainer

  setupYAxis: ($container) ->
    $container.find("svg").after $("<div class='primary-y-axis-container'></div>")
    $container.find("svg").after $("<div class='secondary-y-axis-container'></div>")

  getActiveSeriesNames: ->
    _.compact _.map @graphs[0].series, (s) =>
      @seriesDataNames[s.name] unless s.disabled

  overviewRangeChanged: (start, end) =>
    @element.addClass "#{@options.className}_loading-details"
    @rangeStart = start
    @rangeEnd = end
    @options.dataSelectionChanged(start, end, @getActiveSeriesNames(), @seriesColors)
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
        @options.dataSelectionChanged(@rangeStart, @rangeEnd, @getActiveSeriesNames(), @seriesColors)
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

    start = moment().subtract('days', parseInt($datePicker.attr("rel")))
    end   = moment()
    @calendarFrom.datepicker "setDate", start.toDate()
    @calendarTo.datepicker "setDate", end.toDate()

    # No need to convert these to requested timezone as intervals relative to now() are timezone-independent
    @updateTimeframe(start.unix(), end.unix())

  calendarDateSelected: =>
    @element.find(".#{@options.className}__datepicker_active").removeClass("#{@options.className}__datepicker_active")
    @calendar.addClass "#{@options.className}__calendar_active"

    # Only take the date from the datepicker
    start = @calendarFrom.datepicker('getDate')
    end   = @calendarTo.datepicker('getDate')
    start = moment.tz({year: start.getFullYear(), month: start.getMonth(), day: start.getDate()}, @options.timezone)
    end   = moment.tz({year: end.getFullYear(),   month: end.getMonth(),   day: end.getDate()},   @options.timezone)

    # End date ends on the end of the day
    end.add("d", 1)

    @updateTimeframe(start.unix(), end.unix())

  hoverDetailClicked: =>
    @options.hoverDetailClicked @seriesDataNames[@currentDetail.series.name], parseInt(@currentDetail.x, 10)

  updateTimeframe: (start, end) =>
    @element.addClass "#{@options.className}_loading"
    $.ajax
      dataType: "jsonp"
      url: "#{@url}"
      data: {start: start, end: end}
      type: "get"
      success: (data, status, xhr) =>
        @element.removeClass "#{@options.className}_loading"
        series = @getSeries(data)
        @graphs = []
        @renderDetailGraph(series)
        @renderOverviewGraph(series)
        @updateSeries()
        @updateLegend() if @options.legend
        @options.dataSelectionChanged @rangeStart, @rangeEnd, @getActiveSeriesNames(), @seriesColors
