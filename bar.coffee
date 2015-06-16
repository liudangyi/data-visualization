# 这里是绘图的一些显示属性
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
  # 先用 columns 的数据创建四个子图
  .selectAll "g"
  .data columns
.enter().append "g"
  .attr "transform", (d, i) -> "translate(#{i % 2 * outer_width + padding.left},#{i // 2 * outer_height + padding.top})"

# 数据我们存在 original_data 里，形式如 [[xxx, 1, 2, 3, 4], [xxx, 2, 2, 3, 4], ... ]
original_data = null
scale_x = []
scale_y = []

# 这个函数是用于显示筛选过的条状图的，基本和下面画最初始的条状图的代码一样
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

# 这个是主要部分，先读数据
d3.text "int.txt", (e, _data) ->
  throw e if e
  # 将字符串变成（数组的）数组
  original_data = _data.split("\n").map (e) -> e.split("\t").map (e) -> +e + 1 # 转换成数字并加一，因为要取对数……
  # 对于每个子图
  charts.each (i) ->
    # 取出第 i 列
    data = original_data.map (e) -> e[i]
    # 这里定义了一个对数变换，x 是一个函数，从 [data.min, data.max] 映射到 [0, width]
    x = d3.scale.log().base(2)
      .domain d3.extent(data)
      .range [0, width]
    # 保存下来留着 filter_data 函数用
    scale_x[i] = x
    # 这里用了 d3.layout 的一个内置函数，直接将一维数据集按照 x.ticks(10) 分割并统计频数
    # 返回的结果是 { e | 在 data 中，[e.x, e.x + e.dx) 的数据有 e.y 个 }
    data = d3.layout.histogram().bins(x.ticks(10))(data).map (e) -> {x: e.x, y: e.y, dx: e.dx}
    # 这是一个线性变换，从 [0, 频数（e.y）的最大值] 到 [height, 0]
    # 请注意这是一个斜率为负的函数！！
    y = d3.scale.linear()
      .domain [0, d3.max(data, (e) -> e.y)]
      .range [height, 0]
    # 保存下来留着 filter_data 函数用
    scale_y[i] = y
    # 这是两个画坐标轴的函数
    xAxis = d3.svg.axis()
      .scale x
      .orient "bottom"
    yAxis = d3.svg.axis()
      .scale y
      .orient "left"
    # 真正开始动手画了！
    d3.select this
    # 用 data 的内容创建 n 个正方形
      .selectAll "rect"
      .data data
    .enter().append "rect"
      # 对于每个正方形
      # *左上角* 相对于原点的坐标是 [x(d.x) + 1, y(d.y)]，+1 是为了好看，不然太密集
      .attr "x", (d) -> x(d.x) + 1
      .attr "y", (d) -> y(d.y)
      # 自己的宽度是 x(d.x + d.dx) - x(d.x) - 2
      .attr "width", (d) -> x(d.x + d.dx) - x(d.x) - 2
      # 高度是 height - y(d.y)  <---- 注意，y(d.y) 是一个斜率为负的函数！！
      .attr "height", (d) -> height - y(d.y)
    # 绑定交互，可以不管
    d3.select this
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
    # 画坐标轴 - x 轴
    d3.select this
    .append "g"
      .attr "class", "x axis"
      .attr "transform", "translate(0,#{height})"
      .call xAxis
    # 画坐标轴 - y 轴
    d3.select this
    .append "g"
      .attr "class", "y axis"
      .call yAxis
    # 画 y 轴上的 label
    .append "text"
      .attr "transform", "rotate(-90)"
      .attr "y", 6
      .attr "dy", ".71em"
      .attr "class", "label"
      .text "Count"
  # 这个是保证鼠标移动生成的直方图能覆盖鼠标点击的直方图的 hack
  filter_data "click", 1, [0, 0] # create rect first
