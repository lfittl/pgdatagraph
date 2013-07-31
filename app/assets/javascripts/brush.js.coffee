Rickshaw.namespace "Rickshaw.Graph.Brush"

Rickshaw.Graph.Brush = Rickshaw.Class.create

  initialize: (args) ->
    element = @element = args.element
    graph = @graph = args.graph

    @build()
    graph.onUpdate => @update()

  build: ->
    element = @element
    graph = @graph
    min = graph.dataDomain()[0]
    max = graph.dataDomain()[1]
    maxPx = element.parent().width()
    values = [min..max]

    update = (event, ui) ->
      left = ui.position.left
      width = element.width()
      percentPx = 100 / maxPx
      startIndex = parseInt((left * percentPx / 100) * values.length - 1, 10)
      endIndex = parseInt(((left + width) * percentPx / 100) * values.length - 1, 10)

    $ ->
      $(element).draggable
        axis: "x"
        containment: $(element).parent()
        stop: update

      $(element).resizable
        containment: $(element).parent()
        handles: "e, w"
        stop: update


    # $( function() {
    #   $(element).slider( {
    #     range: true,
    #     min: graph.dataDomain()[0],
    #     max: graph.dataDomain()[1],
    #     values: [
    #       graph.dataDomain()[0],
    #       graph.dataDomain()[1]
    #     ],
    #     slide: function( event, ui ) {

    #       graph.window.xMin = ui.values[0];
    #       graph.window.xMax = ui.values[1];
    #       graph.update();

    #       # if we're at an extreme, stick there
    #       if (graph.dataDomain()[0] == ui.values[0]) {
    #         graph.window.xMin = undefined;
    #       }
    #       if (graph.dataDomain()[1] == ui.values[1]) {
    #         graph.window.xMax = undefined;
    #       }
    #     }
    #   } );
    # } );

    # element[0].style.width = graph.width + 'px';

  update: ->
    # var element = this.element;
    # var graph = this.graph;

    # var values = $(element).slider('option', 'values');

    # $(element).slider('option', 'min', graph.dataDomain()[0]);
    # $(element).slider('option', 'max', graph.dataDomain()[1]);

    # if (graph.window.xMin == null) {
    #   values[0] = graph.dataDomain()[0];
    # }
    # if (graph.window.xMax == null) {
    #   values[1] = graph.dataDomain()[1];
    # }

    # $(element).slider('option', 'values', values);

