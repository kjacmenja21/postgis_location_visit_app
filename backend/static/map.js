// Initialize the map centered on a specific location
var map = L.map("map").setView([45.815, 15.981], 10); // Centered on Zagreb

// Add OpenStreetMap layer
L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution:
    'Map data © <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors',
}).addTo(map);

// Add Geocoder control for searching
var geocoder = L.Control.geocoder({
  defaultMarkGeocode: false,
  collapsed: true,
  placeholder: "Search for a location...",
})
  .on("markgeocode", function (e) {
    var bbox = e.geocode.bbox;
    var poly = L.polygon([
      [bbox.getSouthWest().lat, bbox.getSouthWest().lng],
      [bbox.getSouthWest().lat, bbox.getNorthEast().lng],
      [bbox.getNorthEast().lat, bbox.getNorthEast().lng],
      [bbox.getNorthEast().lat, bbox.getSouthWest().lng],
    ]).addTo(map);
    map.fitBounds(poly.getBounds());
  })
  .addTo(map);

// Fetch existing locations and display them
fetch("/api/lokacije")
  .then((response) => response.json())
  .then((data) => {
    data.forEach((loc) => {
      L.marker([loc.lat, loc.lon])
        .addTo(map)
        .bindPopup(`<b>${loc.naziv}</b><br>${loc.opis}`);
    });
  })
  .catch((error) => console.error("Error loading locations:", error));

// Allow adding markers only on click-and-drag
let isDragging = false;
let tempMarker = null;

map.on("mousedown", (e) => {
  isDragging = true;
  tempMarker = L.marker(e.latlng, { draggable: true }).addTo(map);
});

map.on("mouseup", (e) => {
  if (isDragging) {
    isDragging = false;

    // Automatically populate the form with the clicked location
    document.getElementById("markerName").value = "";
    document.getElementById("markerDescription").value = "";

    // Handle marker saving
    document.getElementById("saveButton").onclick = function () {
      var name = document.getElementById("markerName").value;
      var description = document.getElementById("markerDescription").value;

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
          }),
        })
          .then((response) => {
            if (response.ok) {
              tempMarker
                .bindPopup(`<b>${name}</b><br>${description}`)
                .openPopup();
              alert("Marker added successfully!");
            } else {
              alert("Failed to add marker.");
              tempMarker.remove();
            }
          })
          .catch((error) => console.error("Error adding marker:", error));
      } else {
        alert("Please fill in both fields.");
        tempMarker.remove();
      }
    };
  }
});

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
