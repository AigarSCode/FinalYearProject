extends StaticBody3D

var asteroid:Node3D
var activeTab:String = "AsteroidInformationTab"
@onready var tabList = [$AsteroidInformationTab, $CloseApproachDataTab, $OrbitalElementTab]

var buttonSelected = preload("res://materials/ButtonSelected.tres")
var buttonUnselected = preload("res://materials/ButtonUnselected.tres")

# Ready function assigns all information for all tabs
func _ready() -> void:
	asteroid = get_parent()
	
	# Set Asteroid Name and ID
	$LabelAsteroidName.text += asteroid.asteroidName
	$LabelAsteroidID.text += asteroid.asteroidNeoWsID
	
	populateInfoTab()
	populateApproachTab()
	populateElementTab()


# Populate the Information Tab using Parent data
func populateInfoTab() -> void:
	tabList[0].get_node("LabelHazardous").text += "Yes" if asteroid.is_potentially_hazardous else "No"
	tabList[0].get_node("LabelSentry").text += "Yes" if asteroid.is_sentry_object else "No"
	
	var diameterText = str(asteroid.estimated_diameterKm_min) + " to " + str(asteroid.estimated_diameterKm_max)
	tabList[0].get_node("LabelDiameterKm").text += diameterText
	diameterText = str(asteroid.estimated_diameterMi_min) + " to " + str(asteroid.estimated_diameterMi_max)
	tabList[0].get_node("LabelDiameterMi").text += diameterText
	
	tabList[0].get_node("LabelEarliestObs").text += asteroid.earliestObs
	tabList[0].get_node("LabelLatestObs").text += asteroid.latestObs
	tabList[0].get_node("LabelSource").text += asteroid.source
	tabList[0].get_node("LabelProducer").text += asteroid.producer


# Populate the Close Approach Tab using Parent data
func populateApproachTab() -> void:
	tabList[1].get_node("LabelOrbitingBody").text += asteroid.orbitingBody
	tabList[1].get_node("LabelDateFull").text += asteroid.dateFull
	tabList[1].get_node("LabelRelativeVelKm").text += asteroid.relativeVelKm
	tabList[1].get_node("LabelRelativeVelMi").text += asteroid.relativeVelMi
	tabList[1].get_node("LabelMissDistKm").text += asteroid.missDistKm
	tabList[1].get_node("LabelMissDistMi").text += asteroid.missDistMi
	tabList[1].get_node("LabelMissDistAu").text += asteroid.missDistAU


# Populate the Orbital Element Tab using Parent data
func populateElementTab() -> void:
	var keyList = asteroid.element_data_dictionary.keys()
	
	# Set Premade orbital element strings
	for i in range(1, 12):
		var elementLabel = tabList[2].get_node("LabelElement" + str(i))
		elementLabel.text = asteroid.element_data_dictionary[keyList[i - 1]]


# Change Tabs when a Tab Button is pressed (Function called from XRControllers)
func switchTab(tabButton) -> void:
	if tabButton == "TabButton1":
		activeTab = "AsteroidInformationTab"
	elif tabButton == "TabButton2":
		activeTab = "CloseApproachDataTab"
	elif tabButton == "TabButton3":
		activeTab = "OrbitalElementTab"
	
	changeTabVisibility()


# Make other tabs invisible when one is in use
func changeTabVisibility() -> void:
	for tab in tabList:
		if tab.name == activeTab:
			tab.visible = true
		else:
			tab.visible = false
	
	# Change Button Material for selected and unselected states
	$TabButton1.get_node("MeshInstance3D").material_override = buttonSelected if activeTab == "AsteroidInformationTab" else buttonUnselected
	$TabButton2.get_node("MeshInstance3D").material_override = buttonSelected if activeTab == "CloseApproachDataTab" else buttonUnselected
	$TabButton3.get_node("MeshInstance3D").material_override = buttonSelected if activeTab == "OrbitalElementTab" else buttonUnselected
