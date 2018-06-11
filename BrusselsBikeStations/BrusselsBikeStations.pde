/*
  This sketch shows all the bike stations in Brussels and available bikes and stands 
 at each station.
 */

//import unfolding Maps library
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.events.EventDispatcher;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.providers.OpenStreetMap;

AbstractMapProvider p1 = new OpenStreetMap.OpenStreetMapProvider();
UnfoldingMap map;
DebugDisplay debugDisplay;

String bikeBrussel = "villoStationsAvailability.csv";

ArrayList<Station> bikeStations = new ArrayList<Station>();
int maxAvailableBikes = 0;

void setup() {
  size(800, 600, P2D);
  smooth();

  // Create an interactive map of Brussels
  map = new UnfoldingMap(this, "Brussels Bike Stations", p1);
  Location BrusselsLocation = new Location(50.8503f, 4.3517f);
  map.zoomAndPanTo(12, BrusselsLocation);
  map.setZoomRange(12, 18);
  EventDispatcher eventDispatcher = MapUtils.createDefaultEventDispatcher(this, map);

  // Create debug display 
  debugDisplay = new DebugDisplay(this, map, eventDispatcher, 10, 10);

  // load CSV data
  loadBikeData();
}

void draw() {
  // Draw the map and make it a bit darker
  map.draw();
  debugDisplay.draw();
  fill(0, 50);
  noStroke();
  rect(0, 0, width, height);
  
  // Iterate over all the bike stations
  for (Station bikeStation : bikeStations) {
    // Convert geographic locations to screen positions
    ScreenPosition pos = map.getScreenPosition(bikeStation.location);
    // Map number of available bikes to radius of circle
    maxAvailableBikes = max(maxAvailableBikes, bikeStation.availableBikes);
    float r = map(bikeStation.availableBikes, 0, maxAvailableBikes, 1, 50);
    // Draw circles of different sizes according to the number of available bikes  
    fill(200, 100, 0, 150);
    ellipse(pos.x, pos.y, r, r);

    // Displaying bike station names when mouse pointer moves over bike stations
    if (dist(pos.x, pos.y, mouseX, mouseY) < 15) {
      fill(0);
      textSize(14);
      text(bikeStation.name, pos.x - textWidth(bikeStation.name)/2, pos.y);
    }

    // Display bike station information table when clicking the station position.
    if (bikeStation.showLabel) {
      fill(20);
      textSize(12);
      rect(10, 470, textWidth("Address: " + bikeStation.address)+20, 120);
      fill(255);
      text("Station Name: " + bikeStation.name, 20, 490);
      text("Address: " + bikeStation.address, 20, 510);
      text("Status: " + bikeStation.status, 20, 530);   
      text("Bikes Available: " + bikeStation.availableBikes, 20, 550); 
      text("Stands Available: " + bikeStation.availableStands, 20, 570);
    }
  }
}

void mouseClicked() {
  // Display bike station information. 
  for (Station bikeStation : bikeStations) {
    bikeStation.showLabel = false;
    ScreenPosition pos = map.getScreenPosition(bikeStation.location);
    if (dist(pos.x, pos.y, mouseX, mouseY) < 15) {
      bikeStation.showLabel = true;
    }
  }
}

// a function to load and read bike stations csv file
void loadBikeData() {  
  // Load CSV data
  Table bikeDataCSV = loadTable(bikeBrussel, "header, csv");
  for (TableRow bikeStationRow : bikeDataCSV.rows ()) {
    // Create an empty object to store data
    Station bikeStation = new Station();

    // Read data from CSV file
    bikeStation.name = bikeStationRow.getString("name");
    bikeStation.address = bikeStationRow.getString("address");
    bikeStation.status = bikeStationRow.getString("status");
    bikeStation.availableBikes = bikeStationRow.getInt("available_bikes");
    bikeStation.availableStands = bikeStationRow.getInt("available_bike_stands");
    float lat = bikeStationRow.getFloat("latitude");
    float lng = bikeStationRow.getFloat("longitude");
    bikeStation.location = new Location(lat, lng);

    // Add to list of all bike stations
    bikeStations.add(bikeStation);
  }
}



