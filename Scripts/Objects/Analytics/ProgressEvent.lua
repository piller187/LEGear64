--[[-----------------------------------------------------------------------------------

Visit www.gameanalytics.com to create an account and enable analytics for your game

Event types documentation:
http://restapidocs.gameanalytics.com/#event-types

-----------------------------------------------------------------------------------]]

Script.status=0--choice "Status" "Start, Complete, Fail"
Script.levelname="defaultlevel"--string "Level name"

function Script:Send()--in
	local statuses = {"Start", "Complete", "Fail"}
	Analytics:SendProgressionEvent(statuses[self.status+1],levelname)
end
