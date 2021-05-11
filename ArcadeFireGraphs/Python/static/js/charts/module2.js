
async function drawScatter(){

    // 1. Access data
    const data = await d3.json("/my_weather_data")

    const xAccessor = d => d.humidity
    const yAccessor = d => d.dewPoint

    const colorAccesor = d => d.cloudCover

    console.log(xAccessor(data[3]))

    // 2. Create dimensions

    // Para el scatter, prefiero que el canvas sea un cuadrado y no un rectangulo como en el timeline
    // Para eso voy a escoger el menor valor entre el alto y el ancho d el aventana

    const width = d3.min([
        window.innerWidth*0.9,
        window.innerHeight*0.9
    ])

    const dimensions = {
        width,
        height : width,
        margins: {
            top: 10,
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
    
    // 3. Draw canvas

    const wrapper = d3.select("#wrapper")
        .append("svg")
            .attr("width", dimensions.width)
            .attr("height", dimensions.height)

    const bounds = wrapper.append("g")
        .style("transform", `translate(${
            dimensions.margins.left
        }px, ${
            dimensions.margins.top
        }px)`)
    
    // 4. Create scales

    const xScale = d3.scaleLinear()
        .domain(d3.extent(data,xAccessor))
        .range([0,dimensions.boundedWidth])
        .nice()
    
    const yScale = d3.scaleLinear()
    .domain(d3.extent(data,yAccessor))
    .range([dimensions.boundedHeight,0])
    .nice()

    console.log(d3.extent(data,yAccessor))
    console.log(yScale.domain())

    const colorScale = d3.scaleLinear()
        .domain(d3.extent(data,colorAccesor))
        .range(["skyblue","darkslategray"])

    // 5. Draw data

    const dots = bounds.selectAll("circle")
        .data(data)
        .enter().append("circle")
            .attr("cx", d => xScale(xAccessor(d)))
            .attr("cy", d => yScale(yAccessor(d)))
            .attr("r",4)
            .attr("fill", d => colorScale(colorAccesor(d)))
    
    // 6. Draw peripherals

    const xAxisGenerator = d3.axisBottom()
        .scale(xScale)
    
    const xAxis = bounds.append("g")
        .call(xAxisGenerator)
            .style("transform",`translateY(${
                dimensions.boundedHeight
            }px)`)

    const xAxisLabel = xAxis.append("text")
        .attr("x",dimensions.boundedWidth / 2)
        .attr("y",dimensions.margins.bottom - 10)
        .attr("fill", "black")
        .style("font-size","1.4em")
        .html("Dew Point (ºF) ")
    
    const yAxisGenerator = d3.axisLeft()
        .scale(yScale)
        .ticks(4)  // le indico a D3 los ticks que quiero pero D3 podría reajustar internamente
        //.tickValues()  // también puedo usar este método

    const yAxis = bounds.append("g")
        .call(yAxisGenerator)
    
    const yAxisLabel = yAxis.append("text")
        .attr("x",-dimensions.boundedHeight / 2)
        .attr("y",-dimensions.margins.left + 10)
        .attr("fill", "black")
        .style("font-size","1.4em")
        .html("Relative Humidity")
        .style("transform","rotate(-90deg)") // con esto roto el label
        .style("text-anchor","middle")      // esto me ayuda a centrar bien el label


            

}

drawScatter()