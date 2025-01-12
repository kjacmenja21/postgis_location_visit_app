// Handle marker saving
document.getElementById("saveButton").onclick = function () {
  var name = document.getElementById("markerName").value;
  var description = document.getElementById("markerDescription").value;
  var date = document.getElementById("markerDate").value;

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
        coord_type: "wishlist",
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
  if (window.drawnPolygons) {
    window.drawnPolygons.forEach((polygon) => map.removeLayer(polygon));
  }
  refreshMarkers(map);
};

function getPolygonDistance() {
  let distance = document.getElementById("polygonDistance").value.trim();
  // Check if the distance ends with 'km', if so, convert to meters
  if (distance.toLowerCase().endsWith("km")) {
    // Remove 'km' and multiply by 1000 to convert to meters
    distance = parseFloat(distance.slice(0, -2)) * 1000;
  } else {
    // If it doesn't end with 'km', treat it as meters
    distance = parseFloat(distance);
  }
  // Ensure distance is a valid number
  if (isNaN(distance) || distance <= 0) {
    alert("Please enter a valid distance greater than 0.");
    return;
  }
}

document.getElementById("drawPolygonsButton").onclick = async function () {
  let distance = getPolygonDistance();
  // Use the coordinates of a "red marker" (you'll need to define this marker in your map logic)
  const redMarker = tempMarker; // Reference to your red marker (e.g., L.marker instance)
  const lat = redMarker.getLatLng().lat;
  const lon = redMarker.getLatLng().lng;

  // Fetch polygons from the API
  fetch(`/api/nearby_polygons`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      username: getUsername(),
      password: getPassword(),
      lat,
      lon,
      distance,
    }),
  })
    .then((response) => {
      alert("YIPPIE");
    })
    .catch((error) => {
      alert("Darn");
    });
};

// .then(response => {
//   if (window.drawnPolygons) {
//     window.drawnPolygons.forEach((polygon) => map.removeLayer(polygon));
//   }
//   window.drawnPolygons = [];

//   const data = await response.json();

//   data.features.forEach((feature) => {
//     // Draw the convex hull polygon (if present)
//     if (feature.polygon) {
//       const polygon = L.geoJSON(feature.polygon).addTo(map);
//       window.drawnPolygons.push(polygon);
//     }
//     alert("Polygons and points drawn successfully!");
//   });
// })
// .catch (error => {
// console.error("Error fetching or drawing polygons:", error);
// alert("Failed to draw polygons. Check the console for details.");
// });

// Event listener for the heatmap button
document.getElementById("heatmapButton").addEventListener("click", function () {
  // Get the value from the input field
  let distance = document.getElementById("heatmapDistance").value.trim();
  // Check if the distance ends with 'km', if so, convert to meters
  if (distance.toLowerCase().endsWith("km")) {
    // Remove 'km' and multiply by 1000 to convert to meters
    distance = parseFloat(distance.slice(0, -2)) * 1000;
  } else {
    // If it doesn't end with 'km', treat it as meters
    distance = parseFloat(distance);
  }
  if (!distance || isNaN(distance) || distance <= 0) {
    alert("Please enter a valid distance.");
    return;
  }

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
      if (window.heatmapLayer) {
        map.removeLayer(window.heatmapLayer);
      }

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
