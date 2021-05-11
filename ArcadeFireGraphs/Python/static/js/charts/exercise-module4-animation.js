
async function drawBars (){

  // 1. Access data

  const data = await d3.csv("http://0.0.0.0:5001/static/data/MMA_fighters.csv")


    // 2. Create dimensions

  const width = 500

  const dimensions = {
      width,
      height : width * 0.6,
      margins : {
          top : 30,
          right : 10,
          bottom : 50,
          left : 50
      }
  }

  dimensions.boundedWidth = dimensions.width
      - dimensions.margins.left
      - dimensions.margins.right
  
  dimensions.boundedHeight = dimensions.height
      - dimensions.margins.top
      - dimensions.margins.bottom


  // 3. Draw Canvas

  const wrapper = d3.select("#wrapper")
    .append("svg")
      .attr("width", dimensions.width)
      .attr("height", dimensions.height)
  
  const bounds = wrapper.append("g")
    .style("transform",`translate(${
        dimensions.margins.left
    }px, ${
        dimensions.margins.top
    }px)`)

    // init static elements
  bounds.append("g")
    .attr("class", "bins")
  bounds.append("line")
    .attr("class", "mean")
  bounds.append("g")
    .attr("class", "x-axis")
    .style("transform", `translateY(${dimensions.boundedHeight}px)`)
  .append("text")
    .attr("class", "x-axis-label")

  const drawHistogram = metric => {

    const xAccesor = d => d[metric]
    const yAccessor = d => d.length
    

    // 4. Create scales

    const xScale = d3.scaleLinear()
      .domain(d3.extent(data, xAccesor))
      .range([0,dimensions.boundedWidth])
      .nice()
    
    const binGenerator = d3.bin() 
      .domain(xScale.domain())
      .value(xAccesor)
      .thresholds(11)
    
    const bins = binGenerator(data)

    const yScale = d3.scaleLinear()
      .domain([0,d3.max(bins,yAccessor)])
      .range([dimensions.boundedHeight,0])


    console.log(bins)
    console.log(yScale.domain())
    console.log(xScale.domain())
        

    // 5. Draw data

    const barPadding = 1.5 

    const updateTransition = d3.transition()
      .duration(700)
      .delay(500)
      .ease(d3.easeBounceOut)
    
    const exitTransition = d3.transition()
      .duration(700)
      .ease(d3.easeBounceOut)

    //const binsGroup = bounds.append("g")

    let binGroups = bounds.select(".bins")
        .selectAll(".bin")
        .data(bins)

    const oldBinGroups = binGroups.exit()

    oldBinGroups.selectAll("rect")
      .style("fill","red")
      .transition(exitTransition)
        .attr("y", dimensions.boundedHeight)
        .attr("height",0)

    oldBinGroups
      .transition(exitTransition)
        .remove()
    
    const newBinGroups = binGroups.enter().append("g")
      .attr("class","bin")

    newBinGroups.append("rect")
      .attr("x", d=> xScale(d.x0) + barPadding)
      .attr("y", dimensions.boundedHeight)
      .attr("width", d => d3.max([
        0,
        xScale(d.x1) - xScale(d.x0) - barPadding
      ]))
      .attr("height",0)
      .style("fill","yellowgreen")

    // update binGroups to include new points

    binGroups = newBinGroups.merge(binGroups)
      
    const barRects = binGroups.select("rect")
      .transition(updateTransition)
      .attr("x", d => xScale(d.x0) + barPadding / 2)
      .attr("y", d => yScale(yAccessor(d)))
      .attr("width", d => d3.max([
        0,
        xScale(d.x1) - xScale(d.x0) - barPadding 
      ]))
      .attr("height", d => dimensions.boundedHeight 
          - yScale(yAccessor(d)))
      .attr("fill","cornflowerblue")

    // 6. Draw Peripherals

    const axisGenerator = d3.axisBottom()
      .scale(xScale)
    
    const xAxis = bounds.select(".x-axis")
      .call(axisGenerator)
     // .style("transform", `translateY(${dimensions.boundedHeight}px)`)

      const xAxisLabel = xAxis.select(".x-axis-label")
      //.transition(updateTransition)
      .attr("x", dimensions.boundedWidth / 2)
      .attr("y", dimensions.margins.bottom - 10)
      .attr("fill", "black")
      .style("font-size", "1.4em")
      .text(metric)
      .style("text-transform", "capitalize") 
   

    }

    const metrics = [
      "Height",
      "Weight",
      "Wins",
      "Losses",
      "Draws",
      "Win_Percentage"
    ]
  
    let selectedMetricIndex = 0
    drawHistogram(metrics[selectedMetricIndex])

    const button = d3.select("body")
      .append("button")
        .text("Change metric")

    button.node().addEventListener("click", onClick)
    function onClick() {
      selectedMetricIndex = (selectedMetricIndex + 1) % metrics.length
      drawHistogram(metrics[selectedMetricIndex])
  }
}

drawBars()