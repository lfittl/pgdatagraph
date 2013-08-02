class PG.Brush

  defaults:
    className: ""

  constructor: (container, @graph, options) ->
    @options    = $.extend @defaults, options
    @container  = $(container)
    @element    = $("<div class='brush'></div>").addClass(@options.className)
    @coverLeft  = $("<div class='brush-cover brush-cover_left'></div>")
    @coverRight = $("<div class='brush-cover brush-cover_right'></div>")

    @container.append @element
    @container.append @coverLeft
    @container.append @coverRight

    @min            = @graph.dataDomain()[0]
    @max            = @graph.dataDomain()[1]
    @domainValues   = [@min..@max]
    @containerWidth = @container.width()
    @percentPx      = 100 / @containerWidth

    @element.draggable
      axis: "x"
      containment: @container
      stop: @getRange
      drag: @updateCover

    @element.resizable
      containment: @container
      handles: "e, w"
      stop: @getRange
      resize: @updateCover

    @resizeHandleWidth = @element.find(".ui-resizable-handle").width() - 1

  getRange: (event, ui) =>
    left        = ui.position.left
    width       = @element.width()
    startIndex  = parseInt((left * @percentPx / 100) * @domainValues.length - 1, 10)
    endIndex    = parseInt(((left + width) * @percentPx / 100) * @domainValues.length - 1, 10)
    startIndex  = 0 if !startIndex? or startIndex < 0
    endIndex    = @domainValues.length - 1 if !endIndex? or endIndex < 0

    console.log "PG.Brush#getRange: ", [@domainValues[startIndex], @domainValues[endIndex]]
    return [@domainValues[startIndex], @domainValues[endIndex]]

  updateCover: (event, ui) =>
    @coverLeft.css
      left: 0
      width: ui.position.left - @resizeHandleWidth
    @coverRight.css
      right: 0
      width: @containerWidth - ui.position.left - @element.width() - @resizeHandleWidth


