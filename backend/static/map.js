const redIcon = new L.Icon({
  iconUrl:
    "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png",
  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

let allMarkers = []; // Store all markers for filtering
let currentPolygon = null;
// Initialize the map centered on a specific location
var map = L.map("map").setView([45.815, 15.981], 10); // Centered on Zagreb

map.doubleClickZoom.disable();

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

    if (currentPolygon) {
      map.removeLayer(currentPolygon);
    }

    currentPolygon = L.polygon(
      [
        [bbox.getSouthWest().lat, bbox.getSouthWest().lng],
        [bbox.getSouthWest().lat, bbox.getNorthEast().lng],
        [bbox.getNorthEast().lat, bbox.getNorthEast().lng],
        [bbox.getNorthEast().lat, bbox.getSouthWest().lng],
      ],
      {
        // Set the transparency of the fill and stroke
        fillOpacity: 0.1, // Set fill opacity (0 is fully transparent, 1 is fully opaque)
        opacity: 0.2, // Set stroke opacity (0 is fully transparent, 1 is fully opaque)
      }
    );

    currentPolygon.addTo(map);
    // Fit the map to the bounds of the new polygon
    map.fitBounds(currentPolygon.getBounds());
  })
  .addTo(map);

// Allow adding markers only on click-and-drag
let isDragging = false;
let tempMarker = null;

map.on("dblclick", (e) => {
  const { lat, lng } = e.latlng;
  if (!tempMarker) {
    tempMarker = L.marker([lat, lng], { draggable: true, icon: redIcon }).addTo(
      map
    );
  }
  tempMarker.setLatLng([lat, lng]);
});

map.on("mousedown", (e) => {
  isDragging = true;
});

map.on("mouseup", (e) => {
  if (isDragging) {
    isDragging = false;
  }
});

// Function to refresh markers
function refreshMarkers(map) {
  let username = document.getElementById("username").value.trim();
  let password = document.getElementById("password").value.trim();

  // Check if username and password are provided
  if (!username || !password) {
    console.error("Username and password are required.");
    alert("Please enter both username and password.");
    return;
  }

  fetch("/api/lokacije", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ username, password }), // Send credentials in the body
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then((data) => {
      // Create a Set of current marker coordinates for comparison
      const currentCoords = new Set(
        allMarkers.map(
          (m) => `${m.marker.getLatLng().lat},${m.marker.getLatLng().lng}`
        )
      );

      // Add new markers and update allMarkers list
      const newMarkers = data
        .map((loc) => {
          const coordsKey = `${loc.lat},${loc.lon}`;

          // If the marker is not already on the map, create it
          if (!currentCoords.has(coordsKey)) {
            const marker = L.marker([loc.lat, loc.lon])
              .addTo(map)
              .bindPopup(
                `<b>${loc.naziv}</b><br>${loc.opis}<br>${
                  loc.datum_posjeta || "No date"
                }`
              );
            return { marker, date: loc.datum_posjeta };
          }
          return null;
        })
        .filter(Boolean); // Filter out nulls

      // Remove markers that are no longer in the data
      allMarkers.forEach(({ marker }) => {
        const markerCoordsKey = `${marker.getLatLng().lat},${
          marker.getLatLng().lng
        }`;
        if (!data.some((loc) => `${loc.lat},${loc.lon}` === markerCoordsKey)) {
          map.removeLayer(marker); // Remove marker from the map
        }
      });

      // Update the allMarkers array
      allMarkers = [
        ...allMarkers.filter(({ marker }) =>
          data.some(
            (loc) =>
              `${loc.lat},${loc.lon}` ===
              `${marker.getLatLng().lat},${marker.getLatLng().lng}`
          )
        ),
        ...newMarkers,
      ];
    })
    .catch((error) => console.error("Error refreshing markers:", error));
}

refreshMarkers(map);
