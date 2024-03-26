<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Set"%>
<!DOCTYPE html>
<html>
<head>
    <title>Carte des Stations</title>
    <link rel='stylesheet' href='https://unpkg.com/leaflet@1.7.1/dist/leaflet.css' />
    <link rel='stylesheet' href='https://unpkg.com/leaflet.markercluster/dist/MarkerCluster.css' />
    <link rel='stylesheet' href='https://unpkg.com/leaflet.markercluster/dist/MarkerCluster.Default.css' />
    <link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css'>
</head>
<body>
<div class='container mt-4'>
    <h1>Stations-service à proximité</h1>
    <input type='number' id='distance' class='form-control' placeholder='Entrez la distance en km'>
    <button id='findStations' class='btn btn-primary mt-2'>Trouver des stations</button>
    <select id='services' class='form-control mt-2'>
        <option value=''>Tous les services</option>
        <% Set<String> allServices = (Set<String>) request.getAttribute("allServices");
           if(allServices != null) {
               for(String service : allServices) {
        %>
        <option value='<%= service.replace("'", "\\'") %>'><%= service %></option>
        <% 
               }
           } 
        %>
    </select>
    <div id='map' style='height: 400px;' class='mt-3'></div>
</div>

<script src='https://unpkg.com/leaflet@1.7.1/dist/leaflet.js'></script>
<script src='https://unpkg.com/leaflet.markercluster/dist/leaflet.markercluster.js'></script>
<script src='https://code.jquery.com/jquery-3.3.1.slim.min.js'></script>
<script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js'></script>
<script src='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js'></script>
<script>
    var stations = <%= request.getAttribute("stationsJson") %>;
    var userLocation;

    var map = L.map('map').setView([46.2276, 2.2137], 6);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    if ('geolocation' in navigator) {
        navigator.geolocation.getCurrentPosition(function(position) {
            userLocation = [position.coords.latitude, position.coords.longitude];
            L.marker(userLocation).addTo(map).bindPopup('Vous êtes ici').openPopup();
            map.setView(userLocation, 13);
        });
    }

    function findAndDisplayStations(distance, serviceFilter) {
        map.eachLayer(function(layer) {
            if (!(layer instanceof L.TileLayer)) {
                map.removeLayer(layer);
            }
        });
        var markers = L.markerClusterGroup();
        stations.forEach(function(station) {
            if (!serviceFilter || station.services.includes(serviceFilter)) {
                var marker = L.marker([station.latitude, station.longitude]).bindPopup(buildPopupContent(station));
                if (!userLocation || map.distance(userLocation, [station.latitude, station.longitude]) <= distance * 1000) {
                    markers.addLayer(marker);
                }
            }
        });
        map.addLayer(markers);
    }

    function buildPopupContent(station) {
        var content = '<b>' + station.ville + '</b><br>' + station.adresse + '<br><br><b>Opening Hours:</b><br>';
        for (var day in station.openingHours) {
            content += day + ': ' + station.openingHours[day] + '<br>';
        }
        if (station.services && station.services.length > 0) {
            content += '<br><b>Services:</b><br>' + station.services.join(', ') + '<br>';
        }
        content += '<br><b>Fuel Prices:</b><br>';
        for (var fuel in station.fuelPrices) {
            content += fuel + ': ' + station.fuelPrices[fuel] + '€<br>';
        }
        return content;
    }

		$('#findStations').click(function() {
	    var distance = $('#distance').val() || 5; // Default distance is 5km
	    var selectedService = $('#services').val();
	    findAndDisplayStations(distance, selectedService);
	});
	
	$('#services').change(function() {
	    var distance = $('#distance').val() || 5; // Default distance is 5km
	    var selectedService = $(this).val();
	    findAndDisplayStations(distance, selectedService);
	});
	</script>
</body>
</html>