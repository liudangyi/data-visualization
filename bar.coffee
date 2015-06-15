padding = 20
height = 300
width = 500
outer_height = height + padding * 3
outer_width = width + padding * 2
columns = [1, 2, 3, 4] # TSV columns

charts = d3.select ".container"
  .style "width", "#{outer_width * 2}px"
  .append "svg"
  .attr "width", outer_width * 2
  .attr "height", outer_height * 2
  .selectAll "g"
  .data columns
.enter().append "g"
  .attr "transform", (d, i) -> "translate(#{i % 2 * outer_width + padding},#{i // 2 * outer_height + padding})"

d3.text "int.txt", (e, original_data) ->
  throw e if e
  original_data = original_data.split("\n").map (e) -> e.split("\t")
  charts.each (i) ->
    data = original_data.map (e) -> +e[i]
    x = d3.scale.linear()
      .domain d3.extent(data)
      .range [0, width]
    data = d3.layout.histogram().bins(x.ticks(10))(data).map (e) -> {x: e.x, y: e.y, dx: e.dx}
    y = d3.scale.linear()
      .domain [0, d3.max(data, (e) -> e.y)]
      .range [height, 0]
    xAxis = d3.svg.axis()
      .scale x
      .orient "bottom"
    d3.select this
      .selectAll "g"
      .data data
    .enter().append "g"
      .attr "transform", (d) -> "translate(#{x(d.x)},#{y(d.y)})"
      .append "rect"
      .attr "x", 1
      .attr "width", (d) -> x(d.x + d.dx) - x(d.x) - 2
      .attr "height", (d) -> height - y(d.y)
    d3.select this
      .append "g"
      .attr "class", "x axis"
      .attr "transform", "translate(0,#{height})"
      .call xAxis
