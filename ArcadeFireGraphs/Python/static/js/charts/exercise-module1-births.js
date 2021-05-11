async function drawLineChart(){

    // 1.- Access data

    const dataset = await d3.csv("https://raw.githubusercontent.com/jbrownlee/Datasets/master/daily-total-female-births.csv")
    
    // Create accessors

    const yAccessor = d => d.Births

    // For x axis, I need to parse the date 
    // date comes as: "1959-01-01"
    const dateParser = d3.timeParse("%Y-%m-%d")
    const xAccessor = d => dateParser(d.Date)

    console.log(xAccessor(dataset[50]))
    console.log(yAccessor(dataset[50]))
    
    // 2.- Create chart dimensions

    let dimensions = {
        width : window.innerWidth * 0.9,
        height : 500,
        margin: {
            top:20,
            bottom:60,
            left:60,
            right:20
        }
    }

    dimensions.boundedWidth = dimensions.width
      - dimensions.margin.left
      - dimensions.margin.right
    
    dimensions.boundedHeight = dimensions.height
      - dimensions.margin.top
      - dimensions.margin.bottom
    

    // 3.- Create the canvas

    const wrapper = d3.select("#wrapper")
        .append("svg")  // this must be svg, if I use "g", nothing is rendered
            .attr("width", dimensions.width)
            .attr("height", dimensions.height)
    
    const bounds = wrapper.append("g")
        .style("transform",`translate(${
            dimensions.margin.left
        }px, ${
            dimensions.margin.top
        }px)`)
    
    // 4.- Create scales

    const yScale = d3.scaleLinear()
        .domain(d3.extent(dataset,yAccessor)) // input data
        .range([dimensions.boundedHeight,0])  // output pixels

    const xScale = d3.scaleTime()
        .domain(d3.extent(dataset,xAccessor))
        .range([0,dimensions.boundedWidth])
    
    console.log(xScale.ticks(3))
    
    // 5. Draw data

    const lineGenerator = d3.line()
    .x(d => xScale(xAccessor(d)))
    .y(d => yScale(yAccessor(d)))

    const line = bounds.append("path")
      .attr("d", lineGenerator(dataset))
      .attr("fill", "none")
      .attr("stroke", "#AB2346")
      .attr("stroke-width", 1.2)
    
    // 6.- Draw peripherials

    const yAxisGenerator = d3.axisLeft()
        .scale(yScale)
    
    const yAxis = bounds.append("g")
        .call(yAxisGenerator)
    
    const xAxisGenerator = d3.axisBottom()
        .scale(xScale)
    
    const xAxis = bounds.append("g")
        .call(xAxisGenerator)
            .style("transform",`translateY(${
                dimensions.boundedHeight
            }px)`)

}

drawLineChart()