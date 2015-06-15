padding = { left: 40, top: 20, right: 0, bottom: 20 }
height = 300
width = 500
outer_height = height + padding.top + padding.bottom
outer_width = width + padding.left + padding.right
columns = [1, 2, 3, 4] # TSV columns

charts = d3.select ".container"
  .style "width", "#{outer_width * 2}px"
.append "svg"
  .attr "width", outer_width * 2
  .attr "height", outer_height * 2
  .selectAll "g"
  .data columns
.enter().append "g"
  .attr "transform", (d, i) -> "translate(#{i % 2 * outer_width + padding.left},#{i // 2 * outer_height + padding.top})"

original_data = null
scale_x = []
scale_y = []

filter_data = (class_name, index, range) ->
  filtered = original_data.filter (e) -> range[0] <= e[index] < range[1]
  charts.each (i) ->
    x = scale_x[i]
    y = scale_y[i]
    data = filtered.map (e) -> e[i]
    data = d3.layout.histogram().bins(x.ticks(10))(data).map (e) -> {x: e.x, y: e.y, dx: e.dx}
    d3.select this
      .selectAll "rect.#{class_name}"
      .data data
    .enter().append "rect"
      .attr "class", "#{class_name}"
      .attr "x", (d) -> x(d.x) + 1
      .attr "width", (d) -> x(d.x + d.dx) - x(d.x) - 2
    d3.select this
      .selectAll "rect.#{class_name}"
      .attr "y", (d) -> y(d.y)
      .attr "height", (d) -> height - y(d.y)

d3.text "int.txt", (e, _data) ->
  throw e if e
  original_data = _data.split("\n").map (e) -> e.split("\t").map (e) -> +e + 1
  charts.each (i) ->
    data = original_data.map (e) -> e[i]
    x = d3.scale.log().base(2)
      .domain d3.extent(data)
      .range [0, width]
    scale_x[i] = x
    data = d3.layout.histogram().bins(x.ticks(10))(data).map (e) -> {x: e.x, y: e.y, dx: e.dx}
    y = d3.scale.linear()
      .domain [0, d3.max(data, (e) -> e.y)]
      .range [height, 0]
    scale_y[i] = y
    xAxis = d3.svg.axis()
      .scale x
      .orient "bottom"
    yAxis = d3.svg.axis()
      .scale y
      .orient "left"
    d3.select this
      .selectAll "rect"
      .data data
    .enter().append "rect"
      .attr "x", (d) -> x(d.x) + 1
      .attr "y", (d) -> y(d.y)
      .attr "width", (d) -> x(d.x + d.dx) - x(d.x) - 2
      .attr "height", (d) -> height - y(d.y)
    d3.select this
      # .on "mouseleave", -> 
      #   filter_data "hover", 1, [0, 0]
      .on "click", (d) ->
        if d3.event.target.__data__
          d = d3.event.target.__data__
          filter_data "click", i, [d.x, d.x + d.dx]
        else
          filter_data "click", i, [0, 0]
      .on "mouseover", (d) ->
        if d3.event.target.__data__
          d = d3.event.target.__data__
          filter_data "hover", i, [d.x, d.x + d.dx]
    d3.select this
    .append "g"
      .attr "class", "x axis"
      .attr "transform", "translate(0,#{height})"
      .call xAxis
    d3.select this
    .append "g"
      .attr "class", "y axis"
      .call yAxis
    .append "text"
      .attr "transform", "rotate(-90)"
      .attr("y", 6)
      .attr("dy", ".71em")
      .attr "class", "label"
      .text "Count"
  filter_data "click", 1, [0, 0] # create rect first
