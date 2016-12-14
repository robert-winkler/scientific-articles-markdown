var data = [
    {
        type: "hybrid OA",
        cost: 3000
    }, {
        type: "fully OA",
        cost: 1800
    }, {
        type: "PeerJ",
        cost: 1095
    }, {
        type: "community-sponsored",
        cost: 50
    }
];

// Replace current picture with SVG
var imgOrig = document.querySelector("#pub-costs");
var imgEl = document.createElement("div");
imgEl.setAttribute("id", "pub-costs");
imgOrig.parentNode.replaceChild(imgEl, imgOrig);

var img = d3.select("#pub-costs"),
    imgWidth = 400,
    imgHeight = 400;
var margin = {top: 25, right: 25, bottom: 50, left: 80},
    width = imgWidth - margin.left - margin.right,
    height = imgHeight - margin.top - margin.bottom;

var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
    y = d3.scaleLinear().rangeRound([height, 0]);

var svg = img.append("svg")
        .attr("width", imgWidth + "px")
        .attr("height", imgHeight + "px");
var g = svg.append("g")
        .attr("transform", "translate("+ margin.left + "," + margin.top + ")");

x.domain(data.map(function(d) { return d.type; }));
y.domain([0, d3.max(data, function(d) { return d.cost; })]);

g.append("g")
    .attr("class", "axis axis--x")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x))
    .attr("dy", "5em");

g.append("g")
    .attr("class", "axis axis--y")
    .call(d3.axisLeft(y).ticks(3))
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("dy", "1em")
    .attr("text-anchor", "end");

svg.append("g")
    .attr("class", "label--y")
    .append("text")
    .attr("x", -(imgHeight - margin.bottom))
    .attr("y", 0)
    .attr("transform", "rotate(-90)")
    .attr("dy", "1.2em")
    .text("Article Processing Charges (APC) in USD");

g.selectAll(".bar")
    .data(data)
    .enter().append("rect")
    .attr("class", "bar")
    .attr("fill", "#aa4400")
    .attr("x", function(d) { return x(d.type); })
    .attr("y", function(d) { return y(d.cost); })
    .attr("width", x.bandwidth())
    .attr("height", function(d) { return height - y(d.cost); });

function wrap(text, width) {
  text.each(function() {
    var text = d3.select(this),
        words = text.text().split(/(\s+|-)/).reverse(),
        word,
        line = [],
        lineNumber = 0,
        lineHeight = 1.1, // ems
        y = text.attr("y"),
        dy = parseFloat(text.attr("dy")),
        tspan = text.text(null).append("tspan").attr("x", 0).attr("y", y).attr("dy", dy + "em");
    while (word = words.pop()) {
      line.push(word);
      tspan.text(line.join(" "));
      if (tspan.node().getComputedTextLength() > width) {
        line.pop();
        tspan.text(line.join(" "));
        line = [word];
        tspan = text.append("tspan").attr("x", 0).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
      }
    }
  });
}

svg.selectAll(".axis--x .tick text")
  .call(wrap, 100);
