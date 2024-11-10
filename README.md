# TOD Timers

Adds a UI element to 
- run timers to determine / check repop times
- track Time of Death of NMs and repop timers for Placeholders

## Timers

To start a new timer: 
/tod timer - starts a new timer at the time the command entered
/tod timer {time} - starts a new timer starting at the specified time
 - {time} can be entered as 
 - mm:ss (uses current day and hh)
 - hh:mm:ss (uses current day)

To stop timer(s):
/tod stop - stops all running timers
/tod stop # - stops timer with specified ID (1, 2, 3 etc.)

To clear timer(s):
/tod clear - clears all timers (also clears all NM / PH timers)
/tod clear # - clears timer with specified ID (1, 2, 3 etc.)

## NMs and Placeholders

On death of NM, Time of Death added to UI (includes indication of minimum respawn)
On death of Placeholder, count down to next PH pop added to UI

On installation the addon has example NM only

To add NM:
/tod add {code} {name} {min NM respawn} {PH respawn} {NM ID} {PH1 ID} ({PH2 ID} .. {PHn ID})
- {code} - a unique code given to each NM
- {name} - Full NM Name
- {min MN respawn} - the minimum time for NM respawn (in s)
- {PH respawn} - the respawn time of Placeholder (in s)
- {NM ID} - ID of NM
- {PH# ID} - ID of Placeholder(s)
- IDs can be entered as numbers (in decimal) but it is easier to take the hex ID (e.g. from HXUI) and enter 0x... e.g. for a mob with ID with ID 500 (shown as [1F4] in HXUI), enter 500 or 0x1f4

Note: the NM is added for the zone that the player is currently in (i.e. you should be in the correct zone to add an NM)

To delete an NM:
 /tod del {code}

## Manual NM / Placeholder times

If a Time of Death is not directly witnessed it can be added:
 /tod nm {code} {time} - adds NM time of death at the specified time
 /tod ph {code} {time} - adds Placeholder time of death at the specified time

## Other Commands

/tod list
- Lists stored NM information
/tod ui
- Toggles UI visibility (timers keep running when UI hidden)
/tod help
- Prints addon help to chatlog
