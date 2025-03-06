#----------------------------------------------------
# Godot Simple XML Tools by RYN for Godot Version 1.5
#----------------------------------------------------
extends Node

#------------------------------------------------------------
# Callable Functions
#------------------------------------------------------------
func get_key_exists(key: String, xml_data: String) -> bool:
	var key_start: int = xml_data.findn("<" + key + ">", 0)
	var key_end: int = xml_data.findn("</" + key + ">", 0)
	
	if key_start == key_end or key_end < key_start:
		return false
	return true


func get_int_key(key: String, xml_data: String) -> int:
	var keyData: String = get_key(key, xml_data)
	if not keyData.is_empty() and keyData.is_valid_int():
		return keyData.to_int()
	else:
		return -1


func get_float_key(key: String, xml_data: String) -> float:
	var keyData: String = get_key(key, xml_data)
	if not keyData.is_empty() and keyData.is_valid_float():
		return keyData.to_float()
	else:
		return -1


func get_bool_key(key: String, xml_data: String) -> bool:
	var keyData: String = get_key(key, xml_data)
	if not keyData.is_empty() and keyData == "true":
		return true
	else:
		return false


func get_key(key: String, xml_data: String) -> String:
	if not get_key_exists(key, xml_data):
		return ""
	
	var xml_split: PackedStringArray = xml_data.split("<"+key+">", true)
	
	if xml_split.size() > 1:
		xml_split = xml_split[1].split("</"+key+">", true)
		if xml_split.size() > 1:
			return xml_split[0]
		else:
			return ""
	else:
		return ""


func delete_key(key: String, xml_data: String) -> String:
	if not get_key_exists(key, xml_data):
		return xml_data
	
	var header: String
	var xml_split: PackedStringArray = xml_data.split("<"+key+">", true)
	
	if xml_split.size() > 1:
		header = xml_split[0]
		xml_split = xml_split[1].split("</"+key+">", true)
		if xml_split.size() > 1:
			return header + xml_split[1]
		else:
			return xml_data
	else:
		return xml_data


func get_key_list(xml_data: String) -> PackedStringArray:
	xml_data = xml_data.strip_escapes()
	var keyList: PackedStringArray = []
	var splitList: PackedStringArray = xml_data.split("</",false)
	for i: int in splitList.size():
		if not splitList[i].begins_with("<"):
			if splitList[i].contains(">"):
				var keyName: String = splitList[i].split(">",false)[0]
				if keyList.find(keyName) == -1:
					keyList.append(splitList[i].split(">",false)[0])
		
	return keyList


func add_key(key: String, key_data: String, xml_data: String) -> String:
	if get_key_exists(key, xml_data):
		return update_key(key, key_data, xml_data)

	return xml_data + "<"+key+">" + key_data + "</"+key+">"


func update_key(key: String, key_data: String, xml_data: String) -> String:
	if not get_key_exists(key, xml_data):
		return add_key(key, key_data, xml_data)

	var header: String
	var footer: String
	var xml_split: PackedStringArray = xml_data.split("<"+key+">", true)

	if xml_split.size() <= 2:
		header = xml_split[0]
		xml_split = xml_split[1].split("</"+key+">", true)
		if xml_split.size() == 2:
			footer =  xml_split[1]
			return header + "<"+key+">" + key_data + "</"+key+">" + footer 
		else:
			return xml_data
	else:
		return xml_data
