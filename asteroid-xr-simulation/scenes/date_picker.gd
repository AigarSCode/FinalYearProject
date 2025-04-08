extends StaticBody3D

@onready var user = get_node("/root/Node3D/XROrigin3D/XRCamera3D")

var months:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
var daysInMonth:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var day:int = 1
var month:int = 0
var year:int = 2025

var dateString:String


func _ready() -> void:
	pass


# Always face the user
func _process(delta: float) -> void:
	if user != null:
		# Issue encountered, Users height was not taken into account. Now height is offset to face the user
		var user_camera_pos = user.global_position
		user_camera_pos.y = global_position.y
		look_at(user_camera_pos, Vector3.UP)
		rotate_y(deg_to_rad(180))


# Increment for day, month and year. (Function called from XRControllers)
func incrementDates(option) -> void:
	if option == "day":
		day += 1
		if month == 1 and year % 4 == 0:
			if day > 29:
				day = 1
		else:
			if day > daysInMonth[month]:
				day = 1
	
	if option == "month":
		month += 1
		if month >= months.size():
			month = 0
		if day > daysInMonth[month]:
			day = 1
	
	if option == "year":
		year += 1
		if year > 2050:
			year = 1970
	
	updateDateUI()


# Decrement for day, month and year. (Function called from XRControllers)
func decrementDates(option) -> void:
	if option == "day":
		day -= 1
		if month == 1 and year % 4 == 0:
			if day < 1:
				day = 29
		else:
			if day < 1:
				day = daysInMonth[month]
	
	if option == "month":
		month -= 1
		if month < 0:
			month = months.size() - 1
		if month == 1 and year % 4 == 0:
			if day > 29:
				day = 29
		if day > daysInMonth[month]:
			day = daysInMonth[month]
	
	if option == "year":
		year -= 1
		if year < 1970:
			year = 2050
		
		if month == 1 and year % 4 == 0:
			if day > 29:
				day = 29
		elif day > daysInMonth[month]:
			day = daysInMonth[month]
	
	updateDateUI()


# Update UI with Date changes
func updateDateUI() -> void:
	$LabelDaySelect.text = str(day)
	$LabelMonthSelect.text = str(months[month])
	$LabelYearSelect.text = str(year)
	
	# Update Date String and add leading zeros
	dateString = str(year) + "-" + str(month+1).pad_zeros(2) + "-" + str(day).pad_zeros(2)
