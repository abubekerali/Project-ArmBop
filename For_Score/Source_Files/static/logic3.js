// Store API endpoints inside subject queryUrl


var InitialTime = new Date().toISOString().split('T')[0];
var date = new Date()
date.setDate(date.getDate() - 1);
var FinalTime = date.toISOString().split('T')[0];




// Perform a GET request to the query URL
d3.json("/locations", function(data) {
  // Once we get a response, send the data.features object to the createFeatures function
  createFeatures(data.features);
});

//Documentation on L.Circle can be found at https://leafletjs.com/reference-1.3.0.html#circle

function createFeatures(flightData) {       

    // Create a GeoJSON layer containing the features array on the flightData object
    // Run the onEachFeature function once for each piece of data in the array
    var flights = L.geoJson(flightData, {
      onEachFeature: function (feature, layer){
        layer.bindPopup("<h3>" + feature.properties.callsign +
        "</h3><hr><p>" + "ICAO24: "+ feature.properties.icao24 + "</p>");
      },
      pointToLayer: function (feature, latlng) {
        return new L.circle(latlng,
          {radius: 5000,
            fillColor: '#f03',
            fillOpacity: 0.5,
            stroke: true,
            color: "red",
            weight: 1
        })
      }
    });
  
    // Sending our flight layer to the createMap function
    createMap(flights)
  }
  

  
  

function createMap(flights) {

  // Define streetmap and darkmap layers
  var outdoormap = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/outdoors-v10/tiles/256/{z}/{x}/{y}?" +
  "access_token=pk.eyJ1IjoicGl0YXJ5cyIsImEiOiJjamljYjBmZTMwMWY2M3BucjNzeXI0cG05In0.GV-ALNLB9sg1XeIzr_iiIw");

  var darkmap = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/dark-v9/tiles/256/{z}/{x}/{y}?" +
    "access_token=pk.eyJ1IjoicGl0YXJ5cyIsImEiOiJjamljYjBmZTMwMWY2M3BucjNzeXI0cG05In0.GV-ALNLB9sg1XeIzr_iiIw");

  var satellitemap = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256/{z}/{x}/{y}?" +
  "access_token=pk.eyJ1IjoicGl0YXJ5cyIsImEiOiJjamljYjBmZTMwMWY2M3BucjNzeXI0cG05In0.GV-ALNLB9sg1XeIzr_iiIw");

  // Define a baseMaps object to hold our base layers
  var baseMaps = {
    "Outdoor Map": outdoormap,
    "Dark Map": darkmap,
    "Satellite Map": satellitemap
  };

  // Create overlay object to hold our overlay layer
  var overlayMaps = {
    Flights: flights
  };

  // Create our map, giving it the streetmap and flight layers to display on load
  var myMap = L.map("map", {
    center: [
      37.09, -95.71
    ],
    zoom: 2,
    layers: [outdoormap, flights]
  });

  // Create a layer control
  // Pass in our baseMaps and overlayMaps
  // Add the layer control to the map
  L.control.layers(baseMaps, overlayMaps, {
    collapsed: false
  }).addTo(myMap);

  
L.marker([51.5, -0.09]).addTo(myMap);
  
}
