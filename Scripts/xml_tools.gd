#----------------------------------------------------
# Godot Simple XML Tools by RYN for Godot Version 1.0
#----------------------------------------------------
extends Node


#Checks for the existance of a given XML key
func get_xml_key_exists(key: String, xml_data: String) -> bool:
	
	#Get the starting and ending position of the key data
	var key_start: int = xml_data.findn("<" + key + ">", 0)
	var key_end: int = xml_data.findn("</" + key + ">", 0)
	
	#Make sure the key start and end are valid
	if key_start == key_end || key_end < key_start:
		return false
		
	return true


#Returns the data portion of a given XML key
func get_xml_key_data(key: String, xml_data: String) -> String:
	
	var xml_split: Array = xml_data.split("<"+key+">", true)
	
	if xml_split.size() > 1:
	
		xml_split = xml_split[1].split("</"+key+">", true)
	
		if xml_split.size() > 1:
			return xml_split[0]
		else:
			return ""
	
	else:
		return ""


#Deletes a given XML key
func delete_xml_key(key: String, xml_data: String) -> String:
	
	var header: String
		
	var xml_split: Array = xml_data.split("<"+key+">", true)
	
	if xml_split.size() > 1:
	
		header = xml_split[0]
	
		xml_split = xml_split[1].split("</"+key+">", true)
	
		if xml_split.size() > 1:
			return header + xml_split[1]
		else:
			return xml_data
	else:
		return xml_data


#Add a new XML key
func add_new_xml_key(key: String, key_data: String, xml_data: String) -> String:

	if get_xml_key_exists(key, xml_data) == true:
		# call update_xml_key
		return update_xml_key(key, key_data, xml_data)
	else:
		return xml_data + "<"+key+">" + key_data + "</"+key+">"


#Update an existing XML key
func update_xml_key(key: String, key_data: String, xml_data: String) -> String:
	
	if get_xml_key_exists(key, xml_data) == false:
		# call update_xml_key
		return add_new_xml_key(key, key_data, xml_data)
	else:
		
		var header: String
		var footer: String
		var xml_split: Array = xml_data.split("<"+key+">", true)
	
		if xml_split.size() > 1:
	
			header = xml_split[0]
	
			xml_split = xml_split[1].split("</"+key+">", true)
	
			if xml_split.size() > 1:

				footer =  xml_split[1]
				return header + "<"+key+">" + key_data + "</"+key+">" + footer 
			
			else:
				return xml_data

		else:
			return xml_data
