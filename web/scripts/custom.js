var map = undefined;
var mapControl = undefined;
var geojson = undefined;
var testGeojson = undefined;

$( document ).ready(function() {
	console.log('custom.js loaded')


	map = $("#GeneralMap").ntmap("instance").options.mapId 
	console.log(map);	
	
	mapControl = $("#GeneralMap").ntmap("instance").options.controller;
	
	var OpenStreetMap_Mapnik = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
		maxZoom: 19,
		attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
	});	
	
	mapControl.addBaseLayer(OpenStreetMap_Mapnik,'OpenStreetMap');
	
	var zoom_bar = new L.Control.ZoomBar({position: 'topleft'}).addTo(map);
	
	addSomeGeoJson();

});

function addSomeGeoJson() {
    var apiRequest = new XMLHttpRequest;
    apiRequest.open("GET", "scripts/geoJsonFiles/test.geojson", true);
    apiRequest.onload = function () {
        if (apiRequest.readyState == 4 && apiRequest.status == 200) {
			testGeojson = L.geoJson(JSON.parse(apiRequest.response), {
				onEachFeature: function(feature, layer) {
					layer.bindPopup(feature.properties.description);
				}
			});
			mapControl.addOverlay(testGeojson,'Test GeoJson');
        }
    }
    apiRequest.send();    
}


