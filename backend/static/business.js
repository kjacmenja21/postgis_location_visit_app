// Handle marker saving
document.getElementById("saveButton").onclick = function () {
  var name = document.getElementById("markerName").value;
  var description = document.getElementById("markerDescription").value;
  var date = document.getElementById("markerDate").value;
  var coord_type = document.getElementById("markerType").value;

  if (name && description) {
    // Save marker to the backend
    fetch("/api/add_marker", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: getUsername(),
        password: getPassword(),
        name: name,
        description: description,
        lat: tempMarker.getLatLng().lat,
        lon: tempMarker.getLatLng().lng,
        coord_type: coord_type,
        visit_date: date || null, // Pass date if provided
      }),
    })
      .then((response) => {
        if (response.ok) {
          tempMarker
            .bindPopup(`<b>${name}</b><br>${description}<br>${date}`)
            .openPopup();
          alert("Marker added successfully!");
        } else {
          alert("Failed to add marker.");
          tempMarker.remove();
          tempMarker = null;
        }
      })
      .then(() => refreshMarkers(map))
      .catch((error) => console.error("Error adding marker:", error));
  } else {
    alert("Please fill in all fields.");
    tempMarker.remove();
  }
};

// Handle marker deletion
document.getElementById("deleteButton").onclick = function () {
  var name = document.getElementById("deleteName").value;
  if (name) {
    fetch("/api/remove_marker", {
      method: "DELETE", // Correct HTTP method for deletion
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: getUsername(),
        password: getPassword(),
        name: name, // Pass the marker name to delete
      }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Failed to delete marker: " + response.statusText);
        }
        return response.json();
      })
      .then((data) => {
        // Display success message or handle response
        alert(data.message || "Marker deleted successfully!");
      })
      .then(() => refreshMarkers(map))
      .catch((error) => {
        // Handle errors
        console.error("Error:", error);
        alert("Error deleting marker: " + error.message);
      });
  } else {
    alert("Please enter a marker name to delete.");
  }
};

// Reset map functionality
document.getElementById("resetButton").onclick = function () {
  map.setView([45.815, 15.981], 10); // Reset to initial position
  clearDrawnPolygons();
  clearHeatmap();
  refreshMarkers(map);
};

function clearDrawnPolygons() {
  if (window.drawnPolygons) {
    window.drawnPolygons.forEach((polygon) => map.removeLayer(polygon));
  }
  window.drawnPolygons = [];
}

function getDistance(distanceElementName) {
  let distance = document.getElementById(distanceElementName).value.trim();
  // Check if the distance ends with 'km', if so, convert to meters
  if (distance.toLowerCase().endsWith("km")) {
    // Remove 'km' and multiply by 1000 to convert to meters
    distance = parseFloat(distance.slice(0, -2)) * 1000;
  } else if (distance.toLowerCase().endsWith("m")) {
    distance = parseFloat(distance.slice(0, -1));
  } else {
    // If it doesn't end with 'km', treat it as meters
    distance = parseFloat(distance);
  }
  // Ensure distance is a valid number
  if (isNaN(distance) || distance <= 0) {
    return 1000;
  }
  return distance;
}

document.getElementById("drawPolygonsButton").onclick = async function () {
  let distance = getDistance("polygonDistance");
  // Use the coordinates of a "red marker" (you'll need to define this marker in your map logic)
  const redMarker = tempMarker; // Reference to your red marker (e.g., L.marker instance)

  if (redMarker == null) {
    alert("Click on the map to draw the polygon from!");
    return;
  }
  const lat = redMarker.getLatLng().lat;
  const lon = redMarker.getLatLng().lng;

  const body = JSON.stringify({
    username: getUsername(),
    password: getPassword(),
    lat: lat,
    lon: lon,
    distance: distance,
  });
  console.log(lat, lon, body);

  // Fetch polygons from the API
  fetch(`/api/nearby_polygons`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: body,
  })
    .then(async (response) => {
      clearDrawnPolygons();
      const data = await response.json();
      console.log(data);

      data.features.forEach((feature) => {
        if (feature.polygon) {
          const polygon = L.geoJSON(feature.polygon).addTo(map);
          window.drawnPolygons.push(polygon);
        }
      });

      alert("Polygons and points drawn successfully!");
      //alert(response.statusText);
    })
    .catch((error) => {
      console.error("Error fetching or drawing polygons:", error);
      alert("Failed to draw polygons. Check the console for details.");
    });
};

// Event listener for the heatmap button
document.getElementById("heatmapButton").addEventListener("click", function () {
  // Get the value from the input field
  let distance = getDistance("heatmapDistance");

  // Fetch the heatmap data from the API
  fetch(`/api/heatmap_data?distance=${distance}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      distance: distance,
      username: getUsername(),
      password: getPassword(),
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      // Clear any existing heatmap layers before adding a new one
      clearHeatmap();

      // Create an array of points for the heatmap (format: [lat, lon, intensity])
      var heatmapData = data.features.map((point) => [
        point.geometry.coordinates[1], // Latitude
        point.geometry.coordinates[0], // Longitude
        point.properties.intensity,
      ]);

      // Add the heatmap layer to the map
      window.heatmapLayer = L.heatLayer(heatmapData, {
        radius: 25,
        blur: 15,
      }).addTo(map);
    })
    .catch((error) => console.error("Error fetching heatmap data:", error));
});

// Get user location and center map with a "person" marker
if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition(function (position) {
    var userLat = position.coords.latitude;
    var userLon = position.coords.longitude;

    // Center the map on the user's location
    map.setView([userLat, userLon], 13);

    // Create a custom "person" marker icon
    var personIcon = L.divIcon({
      className: "user-marker",
      html: "P", // The 'P' represents a person
      iconSize: [30, 30],
      iconAnchor: [15, 15],
    });

    // Add the person marker at the user's location
    L.marker([userLat, userLon], { icon: personIcon })
      .addTo(map)
      .bindPopup("<b>You are here!</b>");
  });
}
function clearHeatmap() {
  if (window.heatmapLayer) {
    map.removeLayer(window.heatmapLayer);
  }
}
