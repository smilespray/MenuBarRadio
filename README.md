# MenuBarRadio
The simplest menu bar radio app for Mac OS X.

##One Feature
- Internet radio while you work.

##Many Unfeatures
- No volume control
- No EQ
- No Recording
- No bloated UI
- No artwork retrieval
- No lyrics retrieval
- No music store integration
- No social media integration
- No registration
- No spam

###Version 1 TODO List###

####DONE####
- DONE Ditch app window with play, stop and volume controls
- DONE Temporary menu bar icon
- DONE Set up bare-bones menu bar menu
- DONE Hook up play, stop & quit
- DONE Set LSUIElement in Info.plist
- DONE Remember last playback state (starts playing on launch if it played on quit)

####TODO####
- Change stations
- Simple list of stations (name and URL)
    - Data structure for retaining stations
    - UI: Dialog for entering name and URL
    - Retain station list across launches
    - Dynamically populating the menu with stations
    - Default list of stations for first-ever run
- Playlist (PLS, M3U) parsing
- UI: Checkmark next to currently playing station
- UI: Proper menu bar icon
- UI: Menu bar icon must reflect buffering and playback status
- UI: Proper application icon
- UI: Preferences dialog
- Remember last station played
- Launch app on login

###Version 2 plans###
- Simple station browser (based on Shoutcast or better third-party source)
	- Browse by region
	- Browse by genre
- ID3 tag support (show as tooltip when mousing over menu bar icon)
