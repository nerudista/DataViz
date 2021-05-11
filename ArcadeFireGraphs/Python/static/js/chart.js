 // Assign the specification to a local variable vlSpec.
 var vlSpec = {
    "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
    "height":550,
    "config": {
        "view": {
            "strokeWidth": 0,
            "step": 13
        },
        "axis": {
            "domain": false
        }
    },
    "data": {
        "url": "/static/assets/historia_reinventa.csv"
    },
    "mark": { "type":"rect"},
    "encoding": {
        "column": {
            "field": "Fecha",
            "timeUnit": "year",
            "type": "ordinal",
            "title":false
        },
        "x": {
            "field": "Fecha",
            "timeUnit": "day",
            "type": "ordinal",
            "title": "Day",
            "scale": {"padding":0.1},
            "axis":{
                "title": null,
         "labels": false,
         "ticks": false
         }
        },
        "y": {
            "field": "Fecha",
            "timeUnit": "week",
            "type": "ordinal",
            "title": "Month",
            "scale":{"padding":0.1},
            "axis":{
                "title": null,
         "labels": false,
         "ticks": false
         }
        },
        "color": {
            "field": "Tipo",
            "type": "nominal",
            "legend": {
                "title": null,
                "direction":"horizontal",
                "orient": "none",
                "legendX" : 300,
                "legendY" : -60
            },
            "scale": {"range": ["#E9C5B6", "#3B4756", "#d6dcd9","#8B161A"],
            "opacity": 0.8,
            }
        },
        "tooltip": [{"field": "Hito", "type": "nominal"},
                     {"field":"Fecha", "timeUnit": "yearmonthdate", "title":"Fecha"}
                    ],
        "href": {"field": "URL", "type": "nominal"}
    }
  }
  ;

  // Embed the visualization in the container with id `vis`
  vegaEmbed('#vis', vlSpec);