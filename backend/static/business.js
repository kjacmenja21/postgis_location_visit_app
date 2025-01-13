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
  clearPolyline();
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

document.getElementById("planButton").addEventListener("click", function () {
  const startDate = new Date(document.getElementById("startDate").value);
  const endDate = new Date(document.getElementById("endDate").value);
  const planType = document.getElementById("planType").value;
  console.log(startDate, endDate, planType);

  const body = JSON.stringify({
    username: getUsername(),
    password: getPassword(),
    coord_type: planType,
    start_date: getDateFormat(startDate),
    end_date: getDateFormat(endDate),
  });

  console.log(body);

  fetch(`/api/travel_plan`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: body,
  }).then(async (response) => {
    const data = await response.json();
    console.log(data);

    drawTravelPlan(data, map);
  });
});

function getDateFormat(date) {
  return date.toISOString().split("T")[0];
}

function drawTravelPlan(data, map) {
  if (window.polyline) {
    window.polyline.removeFrom(map); // Remove the existing polyline from the map
    window.polyline = null; // Set the reference to null
  }
  // Parse the data
  const travelPlan = data; // The data is directly an array of objects
  const coord_type = travelPlan.type;

  // Extract coordinates from the data array and ensure they are valid
  const coordinates = travelPlan.data[0][0].coordinates
    .map((item) => {
      if (item.lon !== undefined && item.lat !== undefined) {
        return [item.lon, item.lat];
      } else {
        console.error("Invalid coordinate found:", item);
        return null; // Skip invalid coordinates
      }
    })
    .filter((coord) => coord !== null); // Remove any null coordinates

  // Check if there are any valid coordinates left
  if (coordinates.length === 0) {
    console.error("No valid coordinates to display.");
    return; // Exit the function if no valid coordinates
  }

  // Create a polyline from the coordinates
  const polyline = L.polyline(coordinates, {
    color: coord_type === "wishlist" ? "yellow" : "blue", // Set color based on type
    weight: 4, // Thickness of the line
    opacity: 0.8, // Line opacity
    className: "bordered-polyline",
  }).arrowheads({ size: "20px" });

  // Add the polyline to the map
  polyline.addTo(map);

  window.polyline = polyline;
  // Add a popup showing details about the travel plan
  polyline.bindPopup(`
      <strong>Travel Plan</strong><br>
      <b>Type:</b> ${coord_type}<br>
  `);

  // <b>Start Date:</b> ${start_date}<br>
  // <b>End Date:</b> ${end_date}
  // Adjust the map view to fit the polyline bounds
  map.fitBounds(polyline.getBounds());
}

function clearPolyline() {
  if (window.polyline) {
    window.polyline.remove();
    window.polyline = null;
  }
}
// Function to animate the map to the next point when the button is clicked
function flyToPoints(buttonId) {
  // Ensure that window.polyline exists and contains coordinates
  if (!window.polyline || !window.polyline.getLatLngs()) {
    console.error("No polyline found or polyline has no coordinates.");
    return;
  }
  // Extract the coordinates from the polyline
  const coordinates = window.polyline.getLatLngs();

  // Retrieve the button using the provided ID
  const button = document.getElementById(buttonId);

  // Track the current index of the destination
  let currentIndex = parseInt(button.getAttribute("data-current-index") || "0");
  const totalDestinations = coordinates.length;

  // Check if there are still destinations to visit
  if (currentIndex < totalDestinations) {
    // Fly to the current point with animation
    map.flyTo(coordinates[currentIndex], 10, {
      // Adjust the zoom level (10) as necessary
      animate: true,
      duration: 2, // Duration of the flyTo animation (in seconds)
    });

    // Update the button text to reflect the current and total destinations
    button.textContent = `Destination ${
      currentIndex + 1
    } / ${totalDestinations}`;

    // Increment the index for the next click
    button.setAttribute("data-current-index", currentIndex + 1);
  } else {
    // If all points have been visited, reset the button
    button.textContent = "Fly Through Points";
    button.setAttribute("data-current-index", "0");
    console.log("All destinations reached.");
  }
}

// Add event listener for the button click
document.getElementById("flyButton").addEventListener("click", function () {
  flyToPoints("flyButton");
});
