var map= L.map("map").setView([43.8,18.3],13);
var outdoor=L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/outdoors-v10/tiles/256/{z}/{x}/{y}?" +
    "access_token=pk.eyJ1IjoidGhlYWJ1YmVrZXIiLCJhIjoiY2ppdWEzbHduMjA4MjNxdDl0ODUxd3Z1YiJ9.fi0_fhUNms_j4DfEngkNhQ").addTo(map);
//map.fitBounds(airports.getBounds());
//SVG pictures
var planes= new L.Icon({iconUrl:'data/plane.svg',
iconSize:[28,35]})

var airportFlag= new L.Icon({iconUrl:'data/flag.svg',
iconSize:[28,35]})
//setting up pop ups
function flightInformation (Feature,layer){
  layer.bindPopup("<h4 class='infoheader'>Flight Information</h4> <hr> <p class='infoheader'> ICA024: " + Feature.properties.icao24 +"<hr>+CALLSIGN:" + Feature.properties.callsign +"</p>");
  layer.setIcon(planes)
};

function AirportsInformation(Feature,layer){
    layer.bindPopup("<h4> Airports Information</h4> <hr> <p>Airport Name: "+ Feature.properties.name+"  Abbrev: "+Feature.properties.abbrev+"<hr><a href="+Feature.properties.wikipedia+">Click for detail</a></p>");
    layer.setIcon(airportFlag)
};
//adding geojson
var flights=L.geoJson(dataset,{
    onEachFeature:flightInformation,
    color: "blue"
}).addTo(map);

var airports=L.geoJson(airports,{
    onEachFeature:AirportsInformation,
}).addTo(map);
var basemap={
    "Base Map":outdoor
};
var overlayMaps = {
    "Airports": airports,
    "Live Flights": flights
  };
//layer control
L.control.layers(basemap, overlayMaps, {
    collapsed: false
  }).addTo(map);

  