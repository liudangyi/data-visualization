// Generated by CoffeeScript 1.9.3
(function() {
  var charts, columns, height, outer_height, outer_width, padding, width;

  padding = 20;

  height = 300;

  width = 500;

  outer_height = height + padding * 3;

  outer_width = width + padding * 2;

  columns = [1, 2, 3, 4];

  charts = d3.select(".container").style("width", (outer_width * 2) + "px").append("svg").attr("width", outer_width * 2).attr("height", outer_height * 2).selectAll("g").data(columns).enter().append("g").attr("transform", function(d, i) {
    return "translate(" + (i % 2 * outer_width + padding) + "," + (Math.floor(i / 2) * outer_height + padding) + ")";
  });

  d3.text("int.txt", function(e, original_data) {
    if (e) {
      throw e;
    }
    original_data = original_data.split("\n").map(function(e) {
      return e.split("\t");
    });
    return charts.each(function(i) {
      var data, x, xAxis, y;
      data = original_data.map(function(e) {
        return +e[i];
      });
      x = d3.scale.linear().domain(d3.extent(data)).range([0, width]);
      data = d3.layout.histogram().bins(x.ticks(10))(data).map(function(e) {
        return {
          x: e.x,
          y: e.y,
          dx: e.dx
        };
      });
      y = d3.scale.linear().domain([
        0, d3.max(data, function(e) {
          return e.y;
        })
      ]).range([height, 0]);
      xAxis = d3.svg.axis().scale(x).orient("bottom");
      d3.select(this).selectAll("g").data(data).enter().append("g").attr("transform", function(d) {
        return "translate(" + (x(d.x)) + "," + (y(d.y)) + ")";
      }).append("rect").attr("x", 1).attr("width", function(d) {
        return x(d.x + d.dx) - x(d.x) - 2;
      }).attr("height", function(d) {
        return height - y(d.y);
      });
      return d3.select(this).append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis);
    });
  });

}).call(this);