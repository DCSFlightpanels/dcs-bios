BIOS.protocol.beginModule("CommonData", 0x400)
BIOS.protocol.setExportModuleAircrafts(BIOS.ALL_PLAYABLE_AIRCRAFT)

local defineString = BIOS.util.defineString
local defineIntegerFromGetter = BIOS.util.defineIntegerFromGetter

local latDeg, latSec, latFractionalSec
local lonDeg, lonSec, lonFractionalSec
local altFt
local hdgDeg
local hdgDegFrac
local iasDisp
moduleBeingDefined.exportHooks[#moduleBeingDefined.exportHooks+1] = function()
	-- skip  this data if ownship export is disabled
	if not LoIsOwnshipExportAllowed() then return end
	
	playerName = LoGetPilotName()
		if playerName == nil then playerName = "XXX" end
	
	iasDisp = LoGetIndicatedAirSpeed()
		if iasDisp == nil then iasDisp = "0000" end
	iasEU = string.format("%4d", math.floor(0.5 + iasDisp * 3.6))           -- km/h
	iasUS = string.format("%4d", math.floor(0.5 + iasDisp * 1.94384449))	-- knots
	
	local selfData = LoGetSelfData()
	if selfData == nil then return end
		if selfData.LatLongAlt == nil then return end
	altFt = selfData.LatLongAlt.Alt / 0.3048
	local lat = selfData.LatLongAlt.Lat
		if lat < 0 then lat = 0 - lat 
						latDir = "S"
		else lat = lat 
			 latDir = "N" end		
	local lon = selfData.LatLongAlt.Long
		if lon < 0 then lon = 0 - lon 
						lonDir	= "W"
		else lon = lon 
		     lonDir = "E" end 

	latDeg = math.floor(lat)
	lat1 = (lat - latDeg) * 60 -- convert to seconds
	latSec = math.floor(lat1)
	latFractionalSec = lat1 - latSec

	lonDeg = math.floor(lon)
	lon1 = (lon - lonDeg) * 60 -- convert to seconds
	lonSec = math.floor(lon1)
	lonFractionalSec = lon1 - lonSec
	
	if selfData.Heading ~= nil then
		local hdgDegValue = selfData.Heading / (2 * math.pi) * 360
		hdgDeg = math.floor(hdgDegValue)
		hdgDegFrac = hdgDegValue - hdgDeg
	end
end

local function getVersion()
	return "0.7.35"
end
defineString("DCS_BIOS", getVersion, 6,  "Metadata" , "DCS Bios Version")

defineString("PILOTNAME", function() return playerName end, 24, "Metadata", "Pilot Name")


defineString("LAT_Z_DIR", function() return latDir end, 1, "Position", "Latitude Direction")
defineIntegerFromGetter("LAT_DEG", function() return latDeg end, 90, "Position", "Latitude Degrees")
defineIntegerFromGetter("LAT_SEC", function() return latSec end, 59, "Position", "Latitude Seconds")
defineIntegerFromGetter("LAT_SEC_FRAC", function()
	if not LoIsOwnshipExportAllowed() then return nil end
	return math.floor(latFractionalSec*65535)
end, 65535, "Position", "Latitude Fractional Seconds (divide by 65535)")

defineString("IAS_EU", function() return iasEU end, 4, "Speed", "Indicated Airspeed KM H")
defineString("IAS_US", function() return iasUS end, 4, "Speed", "Indicated Airspeed KNT")
defineIntegerFromGetter("IAS_EU_INT", function()
	if not LoIsOwnshipExportAllowed() then return nil end
	return iasDisp * 3.6
end, 65535, "Speed", "Indicated Airspeed KM H (Int)")
defineIntegerFromGetter("IAS_US_INT", function()
	if not LoIsOwnshipExportAllowed() then return nil end
	return iasDisp * 1.94384449
end, 65535, "Speed", "Indicated Airspeed KNT (Int)")


defineString("LON_Z_DIR", function() return lonDir end, 1, "Position", "Longitude Direction")
defineIntegerFromGetter("LON_DEG", function() return lonDeg end, 180, "Position", "Longitude Degrees")
defineIntegerFromGetter("LON_SEC", function() return lonSec end, 59, "Position", "Longitude Seconds")
defineIntegerFromGetter("LON_SEC_FRAC", function()
	if not LoIsOwnshipExportAllowed() then return nil end
	return math.floor(lonFractionalSec*65535)
end, 65535, "Position", "Longitude Fractional Seconds (divide by 65535)")

defineIntegerFromGetter("ALT_MSL_FT", function()
	if not LoIsOwnshipExportAllowed() then return nil end
	return math.floor(altFt)
end, 65535, "Altitude", "Altitude MSL (ft)")

defineIntegerFromGetter("HDG_DEG", function() return hdgDeg end, 360, "Heading", "Heading (Degrees)")
defineIntegerFromGetter("HDG_DEG_FRAC", function()
	if not LoIsOwnshipExportAllowed() then return nil end
	return hdgDegFrac * 127
end, 127, "Heading", "Heading (Fractional Degrees, divide by 127)")

BIOS.protocol.endModule()