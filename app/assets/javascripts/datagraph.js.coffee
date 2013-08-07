class PG.DataGraph

  defaults:
    className   : "datagraph"
    overview    : yes
    legend      : yes
    datePickers : [
      { label: "last 30 days",  duration: "-1m" },
      { label: "last 2 weeks",  duration: "-2w" },
      { label: "last 24 hours", duration: "-1d" }
    ]
    dateFormat  : "dd.mm.yy"
    renderer    : "line"

  constructor: (element, @series, options) ->
    @element = $(element)
    @options = $.extend @defaults, options
    @graphs  = []

    if @options.legend
      @legendContainer = $("<div class='#{@options.className}__legend'></div>")
      @element.append @legendContainer

    @detail = $("<div class='#{@options.className}__detail'></div>")
    @element.append @detail
    @renderDetailGraph()

    if @options.datePickers
      @datePickers = $("<div class='#{@options.className}__datepickers'></div>")
      @element.append @datePickers
      $calendar = $("<div class='#{@options.className}__calendar'></div>")
      @calendarFrom = $("<input class='#{@options.className}__calendar-from'>")
      @calendarTo = $("<input class='#{@options.className}__calendar-to'>")
      $calendar.append @calendarFrom
      $calendar.append $("<span class='#{@options.className}__calendar-dash'>–</span>")
      $calendar.append @calendarTo
      @calendarFrom.datepicker
        onSelect: @calendarDateSelected
        dateFormat: @options.dateFormat
      @calendarTo.datepicker
        onSelect: @calendarDateSelected
        dateFormat: @options.dateFormat
      @datePickers.append $calendar
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
      @renderOverviewGraph()

    if @options.legend
      @legend = new PG.Legend @legendContainer, @graphs

  renderDetailGraph: (series) ->
    series = @series unless series?
    @detailGraph = new Rickshaw.Graph
      element: @detail.get(0)
      renderer: @options.renderer
      stroke: yes
      preserve: yes
      series: series

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: @detailGraph
    xAxis.render()

    yAxis = new Rickshaw.Graph.Axis.Y
      graph: @detailGraph
    yAxis.render()

    @graphs.push @detailGraph
    @detailGraph.render()

  renderOverviewGraph: (series) ->
    series = @series unless series?
    @overviewGraph = new Rickshaw.Graph
      element: @overview.get(0)
      renderer: @options.renderer
      stroke: yes
      preserve: yes
      series: series

    xAxis = new Rickshaw.Graph.Axis.Time
      graph: @overviewGraph
    xAxis.render()

    @brush = new PG.Brush @overview, @overviewGraph,
      className: "#{@options.className}__brush"

    @overviewGraph.render()
    @graphs.push @overviewGraph

  selectDatePicker: ($datePicker) ->
    activeClassName = "#{@options.className}__datepicker_active"
    @element.find(".#{activeClassName}").removeClass(activeClassName)
    $datePicker.addClass activeClassName
    @calendarFrom.datepicker "setDate", $datePicker.attr("rel")
    @calendarTo.datepicker "setDate", new Date()
