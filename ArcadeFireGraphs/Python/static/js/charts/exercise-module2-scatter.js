
async function drawScatter (){

    // 1. Access data

    const data = await d3.csv("http://0.0.0.0:5001/static/data/MMA_fighters.csv")

    const xAccesor = d => d.Height
    const yAccesor = d => d.Weight
    const colorAccesor = d => d.Wins


    // 2. Create dimensions

    const width = d3.min([
        window.innerWidth * 0.9 ,
        window.innerHeight * 0.9
    ])

    const dimensions = {
        width,
        height : width,
        margins : {
            top : 10,
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

    // 4. Create scales

    const xScale = d3.scaleLinear()
      .domain(d3.extent(data, xAccesor))
      .range([0,dimensions.boundedWidth])
      .nice()
    
    const yScale = d3.scaleLinear()
        .domain(d3.extent(data, yAccesor))
        .range([dimensions.boundedHeight,0])
        .nice()
    
    const colorScale = d3.scaleLinear()
        .domain(d3.extent(data, colorAccesor))
        .range(["#C64191","#028090"])
        

    // 5. Draw data

    const dots = bounds.selectAll("circle")
      .data(data)
      .enter().append("circle")
        .attr("cx", d => xScale(xAccesor(d)))
        .attr("cy", d => yScale(yAccesor(d)))
        .attr("fill", d => colorScale(colorAccesor(d)))
        .attr("r",3)

    // 6. Draw peripherals

    const xAxisGenerator = d3.axisBottom()
      .scale(xScale)

    const xAxis = bounds.append("g")
      .call(xAxisGenerator)
        .style("transform",`translateY(${
            dimensions.boundedHeight
        }px)`)
    
    const xAxisLabel = xAxis.append("text")
      .attr("x", dimensions.boundedWidth / 2)
      .attr("y", dimensions.margins.bottom - 10)
      .attr("fill", "black")
      .style("font-size", "1.3em")
      .html("Height")


    
    const yAxisGenerator = d3.axisLeft()
      .scale(yScale)

    const yAxis = bounds.append("g")
      .call(yAxisGenerator)

    const yAxisLabel = yAxis.append("text")
      .attr("x", -dimensions.boundedHeight  / 2)
      .attr("y", -dimensions.margins.left + 10 )
      .attr("fill", "black")
      .style("font-size", "1.4em")
      .html("Weight")
      .style("transform","rotate(-90deg)")
      .style("text-anchor","middle")

    
      


}

drawScatter()