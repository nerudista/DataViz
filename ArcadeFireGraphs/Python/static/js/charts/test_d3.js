async function drawValenceBars(){

    // 1. Access data

    const data = await d3.csv("/static/assets/arcade_fire_data.csv")

    const drawChart = album => {

        var dataset = data.filter( track => track.album_name === album )
        
        //console.log(data)
        console.log(dataset)

        
        const xAccessor = d => d.track_name
        const yAccessor = d => d.valence
        const colorAccesor = d => d.album_name

        console.log(xAccessor(dataset[5]))
        console.log(yAccessor(dataset[5]))
        //console.log(colorAccesor(dataset[5]))


        // 2. Create charts dimensions

        const width = window.innerWidth * 0.6

        const dimensions = {
            width,
            height : 300,
            margins : {
                top : 10,
                right : 10,
                bottom : 50,
                right : 50
            }
        }

        dimensions.boundedWidth = dimensions.width
            - dimensions.margins.left
            - dimensions.margins.right
        
        dimensions.boundedHeight = dimensions.height
            - dimensions.margins.top
            - dimensions.margins.bottom

        // 3. Draw Canvas

        const wrapper = d3.select("#wrapper-valence-disc")
            .append("svg")
                .attr("width",dimensions.width)
                .attr("height",dimensions.height)
        
        const bounds = wrapper.append("g")
            .attr("class", "bounds")
            .style("transform",`translate(${
                dimensions.margins.left
            }px, ${
                dimensions.margins.top
            }px)`)

        // 4. Create Scales

        const yScale = d3.scaleLinear()
            .domain([0, d3.max(dataset, d => d.valence)]).nice()
            .range([dimensions.height - dimensions.margins.bottom, dimensions.margins.top])
    

        
        const xScale = d3.scaleBand()
            .domain(d3.range(dataset.length))
            //.range([dimensions.boundedHeight, 0])
            .range([0,dimensions.width])
            .padding(0.5)
        
        const colorScale = d3.scaleOrdinal()
            .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"])
        
        //const unique = [...new Set(dataset.map(item => item.album_name))];
        //console.log(unique)


        console.log(dataset.length)
        console.log(xAccessor(dataset[5]))
        console.log(xScale.bandwidth())
        console.log(colorScale.domain())
        
        // 5. Draw data 

        const barPadding = 1.5

    /*     const barsGroup = bounds.append("g")
            .selectAll("rects")
            .data(dataset)
            .join("rect")
            .attr("x", d => xScale(20))
            .attr("y", (d,i) => yScale(i))
            .attr("width", d => 10)
            .attr("height", yScale.bandwidth())
            .attr("fill","steelblue") */
        
        bounds.append("g")
        .selectAll("rect")
        .data(dataset)
        .enter()
        .append("rect")
            //.attr("x", xScale(xAccessor)) 
            .attr("x", (d, i) => xScale(i))  //ok            
            //.attr("y", d => yScale(yAccessor)) // ok
            .attr("y", d => yScale(d.valence)) // ok
            //.attr("width", d => xScale(xAccessor))
            //.attr("height", yScale.bandwidth())
            .attr("height", d => yScale(0) - yScale(d.valence))
            .attr("width", xScale.bandwidth())      
            //.attr("fill", "steelblue")
            .attr("fill", d => colorScale(colorAccesor))
    }
    
    const albums = [
        "Everything Now",
        "Reflektor",
        "The Suburbs",
        "Neon Bible",
        "Funeral"
        ]

    albums.forEach(drawChart)

}

drawValenceBars()