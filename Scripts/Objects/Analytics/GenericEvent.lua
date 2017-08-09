--[[-----------------------------------------------------------------------------------

Visit www.gameanalytics.com to create an account and enable analytics for your game

Event types documentation:
http://restapidocs.gameanalytics.com/#event-types

-----------------------------------------------------------------------------------]]

Script.eventid="defaultevent"--string "Event ID"

function Script:Send()--in
	Analytics:SendGenericEvent(self.eventid)
end
