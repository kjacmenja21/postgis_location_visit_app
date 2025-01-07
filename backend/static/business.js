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
        naziv: name,
        opis: description,
        lat: tempMarker.getLatLng().lat,
        lon: tempMarker.getLatLng().lng,
        datum_posjeta: date || null, // Pass date if provided
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
        naziv: name, // Pass the marker name to delete
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
};

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
