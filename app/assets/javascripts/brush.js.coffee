class PG.Brush

  defaults:
    className: ""

  constructor: (container, @graph, options) ->
    @container = $(container)
    @options = $.extend @defaults, options

    @element = $("<div class='brush'></div>").addClass(@options.className)
    @container.append @element

    @min          = @graph.dataDomain()[0]
    @max          = @graph.dataDomain()[1]
    @domainValues = [@min..@max]
    @percentPx    = 100 / @container.width()

    @element.draggable
      axis: "x"
      containment: @container
      stop: @getRange

    @element.resizable
      containment: @container
      handles: "e, w"
      stop: @getRange

  getRange: (event, ui) =>
    left        = ui.position.left
    width       = @element.width()
    startIndex  = parseInt((left * @percentPx / 100) * @domainValues.length - 1, 10)
    endIndex    = parseInt(((left + width) * @percentPx / 100) * @domainValues.length - 1, 10)
    startIndex  = 0 if !startIndex? or startIndex < 0
    endIndex    = @domainValues.length - 1 if !endIndex? or endIndex < 0

    console.log "PG.Brush#getRange: ", [@domainValues[startIndex], @domainValues[endIndex]]
    return [@domainValues[startIndex], @domainValues[endIndex]]


