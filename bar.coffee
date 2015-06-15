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

d3.text "int.txt", (e, original_data) ->
  throw e if e
  original_data = original_data.split("\n").map (e) -> e.split("\t")
  charts.each (i) ->
    data = original_data.map (e) -> +e[i] + 1
    x = d3.scale.log().base(2)
      .domain d3.extent(data)
      .range [0, width]
    data = d3.layout.histogram().bins(x.ticks(10))(data).map (e) -> {x: e.x, y: e.y, dx: e.dx}
    y = d3.scale.linear()
      .domain [0, d3.max(data, (e) -> e.y)]
      .range [height, 0]
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
