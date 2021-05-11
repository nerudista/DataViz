
async function drawBars (){

    // 1. Access data

    const data = await d3.csv("http://0.0.0.0:5001/static/data/MMA_fighters.csv")

    const drawHistogram = metric => {
      
      const xAccesor = d => d[metric]

      const yAccessor = d => d.length


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

      const binsGroup = bounds.append("g")

      const binGroups = binsGroup.selectAll("g")
          .data(bins)
          .join("g")
      
      const barPadding = 1.5 

      const barRects = binGroups.append("rect")
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
        "Height",
        "Weight",
        "Wins",
        "Losses",
        "Draws",
        "Win_Percentage"
      ]
    
      metrics.forEach(drawHistogram)

    
      


}

drawBars()