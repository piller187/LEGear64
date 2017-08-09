--[[-----------------------------------------------------------------------------------

Visit www.gameanalytics.com to create an account and enable analytics for your game

Event types documentation:
http://restapidocs.gameanalytics.com/#event-types

-----------------------------------------------------------------------------------]]

Script.eventid="defaultevent"--string "Event ID"
Script.value=1--float "Value"

function Script:Send()--in
	Analytics:SendGenericEvent(self.eventid,self.value)
end
