async function drawBars() {

    // 1. Access Data

    const data = await d3.json("/my_weather_data")

    const drawHistogram = metric => {
    
        // en vez de usar dos accessors, como en la otras gráficas, solo usaremos uno para el valor dentro del dataset
        const xAccessor = d => d[metric]

        // para el yAccessor, quiero el conteo por bin, es decir, algo que no está dentro del dataset original
        const yAccessor = d => d.length

        // 2. Create Chart Dimensions

        const width = 600
        let dimensions = {
            width,
            height : width * 0.6,
            margins : {
                top: 30,
                right: 10,
                bottom: 50,
                left: 50
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

        
        // 4. Create Scales

        const xScale = d3.scaleLinear()
        .domain(d3.extent(data, xAccessor))
        .range([0,dimensions.boundedWidth])
        .nice()

        const binGenerator = d3.bin()
        .domain(xScale.domain())
        .value(xAccessor)
        .thresholds(12)

        const bins = binGenerator(data)

        const yScale = d3.scaleLinear()
        .domain([0, d3.max(bins,yAccessor)])
        .range([dimensions.boundedHeight, 0])

        console.log(bins)
        console.log(yScale.domain())
        console.log(xScale.domain())

        // 5. Draw Data

        const binsGroup = bounds.append("g")

        const binGroups = binsGroup.selectAll("g")
            .data(bins)
            .join("g")

        const barPadding = 1

        const barRects = binGroups.append("rect")
        .attr("x", d => xScale(d.x0) +  barPadding / 2)
        .attr("y" , d => yScale(yAccessor(d)))
        .attr("width", d => d3.max([
            0,
            xScale(d  .x1) - xScale(d.x0) - barPadding
        ]))
        .attr("height", d => dimensions.boundedHeight 
            - yScale(yAccessor(d)))
        .attr("fill","cornflowerblue")

        // labels

        const barText = binGroups.filter(yAccessor)
        .append("text")
                .attr("x", d => xScale(d.x0) + (xScale(d.x1) - xScale(d.x0)) / 2)
            .attr("y", d => yScale(yAccessor(d)) - 5)
            .text(yAccessor)
            .style("text-anchor", "middle")
            .attr("fill", "darkgrey")
            .style("font-size", "12px")
            .style("font-family", "sans-serif")
        
        // 6. Draw Peripherals

        const mean = d3.mean (data, xAccessor)
        
        const meanLine = bounds.append("line")
        .attr("x1", xScale(mean))
        .attr("x2", xScale(mean))
        .attr("y1", -15)
        .attr("y2", dimensions.boundedHeight)
        .attr("stroke" , "maroon")
        .attr("stroke-dasharray" , "2px 4px")

    
        
        const meanLabel = bounds.append("text")
        .attr("x",xScale(mean))
        .attr("y", -20)
        .text("mean")
        .attr("fill" , "maroon")
        .style("font-size", "12px")
        .style("font-family", "sans-serif")
        .style("text-anchor", "middle")
        
        const axisGenerator = d3.axisBottom()
        .scale(xScale)
        
        const xAxis = bounds.append("g")
        .call(axisGenerator)
        .style("transform", `translateY(${dimensions.boundedHeight}px)`)

        const xAxisLabel = xAxis.append("text")
        .attr("x", dimensions.boundedWidth / 2)
        .attr("y", dimensions.margins.bottom - 10)
        .attr("fill", "black")
        .style("font-size", "1.4em")
        .text(metric)
        .style("text-transform", "capitalize")
    
    }

    const metrics = [
        "windSpeed",
        "moonPhase",
        "dewPoint",
        "humidity",
        "uvIndex",
        "windBearing",
        "temperatureMin",
        "temperatureMax",
        "visibility",
        "cloudCover",
      ]
    
      metrics.forEach(drawHistogram)


}

drawBars()