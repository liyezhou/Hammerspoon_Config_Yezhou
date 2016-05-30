--Local Variables
local Hyper={"alt","cmd","ctrl"}
local Diper={"shift","alt","ctrl","cmd"}
local Viper={"alt","ctrl"}
local laptopScreen="Color LCD"
local desktopScreen="S23C350"
local shortAlertTime=0.8

--hs.location.start()
--hs.timer.doAfter(1, function()
--	lastLocation = hs.location.get()  
--	hs.location.stop()
--	hs.alert.show("Last: "..lastLocation.latitude)
--end)

--Location Service
--local function locationSwitched()
--	hs.location.start()
--	hs.timer.doAfter(1, function()
--		hs.alert.show("blah")
--		currentLocation = hs.location.get()  
--		if currentLocation~=nil then
--			hs.alert.show("Current: "..currentLocation.latitude)
--			distanceMoved=hs.location.distance(lastLocation, currentLocation)
--			hs.notify.new({title="Location Changed", informativeText=distanceMoved}):send()
--			lastLocation=currentLocation
--		end
--		hs.location.stop()
--	end)
--end	

--hs.location.register("switch location", locationSwitched, 0)

--Test Function
hs.hotkey.bind(Viper,"A",function()
	hs.alert.show("Blah") 
end)

--Turn screen to black or turn back to last saved brightness
hs.hotkey.bind(Diper,"B",function()
	if hs.brightness.get() == 0 then
		if lastBrightness ~= nil then
			hs.brightness.set(lastBrightness)
		else
			hs.brightness.set(math.floor(hs.brightness.ambient()/10))
		end
	else
		lastBrightness = hs.brightness.get()
		hs.brightness.set(0)
	end
end)

--Switch between application with right shift
hs.hotkey.bind({},80,function()
	hs.eventtap.event.newKeyEvent({"cmd"}, "tab", true):post()
	hs.eventtap.event.newKeyEvent({}, "tab", false):post()
	hs.timer.usleep(100000)
	hs.eventtap.event.newKeyEvent({}, "cmd", false):post()
end)

--Switch between windows WITHIN Application with right alt 
hs.hotkey.bind(Viper,80,function()
	if hs.application.frontmostApplication():allWindows()[2]==nil then
		--hs.alert.show("ctrl+tab")
		hs.eventtap.event.newKeyEvent({"ctrl"}, "tab", true):post()
		hs.eventtap.event.newKeyEvent({}, "tab", false):post()
		hs.timer.usleep(100000)
		hs.eventtap.event.newKeyEvent({}, "cmd", false):post()
	else
		--hs.alert.show("cmd+`")
		hs.eventtap.event.newKeyEvent({"cmd"}, "`", true):post()
		hs.eventtap.event.newKeyEvent({}, "`", false):post()
		hs.timer.usleep(100000)
		hs.eventtap.event.newKeyEvent({}, "cmd", false):post()
	end
end)

--Switch between windows WITHIN Application with right alt (Reverse Direction)
hs.hotkey.bind({"ctrl","shift","alt"},80,function()
	hs.eventtap.event.newKeyEvent({"ctrl", "shift"}, "tab", true):post()
	hs.eventtap.event.newKeyEvent({}, "tab", false):post()
	hs.timer.usleep(100000)
	hs.eventtap.event.newKeyEvent({}, "cmd", false):post()

end)
--Global Functions
function launchApp(theApp)
	if not hs.application.launchOrFocus(theApp)then
		hs.alert.show("Launch "..theApp.." Failed!")
	end
end

--Execute a function after a specified app mainWindow appears 
local function doAfterMainWindowAppear(theApp, theFunction, stackSize)
	if stackSize>50 then
		hs.alert.show("Script Failed")
		return 0
	end
	local cWin=hs.application.get(theApp)
	if cWin==nil then
		hs.timer.usleep(300000)
		doAfterMainWindowAppear(theApp, theFunction, stackSize + 1)
	else
		if cWin:mainWindow()==nil then
			hs.timer.usleep(300000)
			doAfterMainWindowAppear(theApp, theFunction, stackSize + 1)
		else
			theFunction()
			--hs.alert.show("Succeed after stack no. " .. stackSize)
		end
	end
end
--Get Mouse Pointed App

function getMouseApp()
	local cApp = hs.application.frontmostApplication()  
	local cWin = cApp:focusedWindow()
	local MousePosition = hs.mouse.getAbsolutePosition()	
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.MouseDown,MousePosition):post()
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.MouseUp,MousePosition):post()
	local qWin = hs.application.frontmostApplication():focusedWindow()  
	return qWin 
	--	cWin:focus()
end


--Make current App fill the screen, the left half, right half
function setCurrentAppToRect(theKey,x,y,w,h)
	hs.hotkey.bind(Diper,theKey,function()
		local cApp = hs.application.frontmostApplication()  
		local mouseScreen = hs.mouse.getCurrentScreen()
		--cApp:focusedWindow():moveToScreen(mouseScreen)
		cApp:focusedWindow():moveToUnit(hs.geometry.rect(x,y,w,h))
		hs.alert.show("Reposing "..cApp:title(), shortAlertTime)
	end)
end

setCurrentAppToRect("F",0,0,1,1)
setCurrentAppToRect("D",0,0,0.5,1) -- left
setCurrentAppToRect("G",0.5,0,0.5,1) -- right
setCurrentAppToRect("E",0,0,0.61,1) -- left
setCurrentAppToRect("R",0.61,0,0.39,1) -- right

--Move current App to the screen pointed by the mouse
hs.hotkey.bind(Diper,"S",function()
	local cApp = hs.application.frontmostApplication()  
	local mouseScreen = hs.mouse.getCurrentScreen()
	cApp:focusedWindow():moveToScreen(mouseScreen)
end)
--Using the set noteApp to do notetaking
function noteTakingMode(theKey,noteApp,perc)
	hs.hotkey.bind(Viper, theKey, function() 
		local cApp = hs.application.frontmostApplication()  
		local app1 = cApp:bundleID()
		local app2 = noteApp 
		launchApp(app2)
		local function applyLayout()
			hs.timer.usleep(10000)
			if noteApp=="TextEdit" then
				local menuStr = {"File", "New"}
				hs.application.get("TextEdit"):selectMenuItem(menuStr)
			end
			hs.timer.usleep(10000)
			if noteApp=="/usr/local/Cellar/macvim/7.4-77/MacVim.app" then
				app2 = "MacVim"
			end
			local windowlayout={
				{app1, nil, laptopScreen, hs.geometry.rect(0,0,perc,1), nil, nil},
				{app2, nil, laptopScreen, hs.geometry.rect(perc,0,1-perc,1),nil, nil},
			}
			hs.layout.apply(windowlayout)
		end
		doAfterMainWindowAppear(noteApp, applyLayout, 1)
	end)
end

noteTakingMode("N", "Notes",0.6)
noteTakingMode("T", "TextEdit",0.75)
noteTakingMode("A", "/Applications/Microsoft OneNote.app",0.55)
noteTakingMode(",", "MacVim",0.7)
noteTakingMode("C", "Calendar",0.55)

--copy truly only text
hs.hotkey.bind(Diper,"C",function()
	hs.timer.usleep(250000)
	hs.eventtap.keyStroke({"cmd"}, "c")	
	--hs.alert.show("Copied "..(hs.pasteboard.getContents()))
	hs.timer.usleep(100000)
	local pasteContent = hs.pasteboard.getContents()
	hs.pasteboard.setContents(pasteContent.."")
end)

hs.hotkey.bind(Diper,"V",function()
	local pasteContent = hs.pasteboard.getContents()
	hs.pasteboard.setContents(pasteContent.."")
	--hs.alert.show("Pasting "..(hs.pasteboard.getContents()))
	hs.timer.usleep(250000)
	hs.eventtap.keyStroke({"cmd"}, "v")
end)
--copy truly unformatted text
--hs.hotkey.bind(Diper,"C",function()
--	local oriMousePosition = hs.mouse.getAbsolutePosition()
--	hs.application.frontmostApplication():selectMenuItem({"Edit","Copy"})
--	hs.application.launchOrFocus("TextEdit")
--	local cApp = hs.application.get("TextEdit")
--	cApp:selectMenuItem({"File", "New"})
--	cApp:selectMenuItem({"Edit", "Paste"})
--	cApp:selectMenuItem({"Edit", "Select All"})
--	cApp:selectMenuItem({"Edit", "Copy"})
--	cApp:selectMenuItem({"File", "Close"})
--	local cWin = cApp:focusedWindow()
--	cWin:moveToScreen(hs.screen.allScreens()[1])
--	--cWin:setTopLeft(hs.geometry.point(0,0))
--	local cX = cWin:frame().x
--	local cY = cWin:frame().y
--	--hs.eventtap.leftClick(hs.geometry.point(cX+150,cY+195))
--	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown,hs.geometry.point(cX+150,cY+295)):post()
--	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp,hs.geometry.point(cX+150,cY+295)):post()
--	hs.mouse.setAbsolutePosition(oriMousePosition)
--end)

--Screen Layout Presets
--hs.hotkey.bind(Hyper,"2",function()
--	local app1 = "Microsoft OneNote"
--	local app2 = "Notes"
--	launchApp(app1)
--	launchApp(app2)
--	local function applyLayout()
--		local windowlayout={
--			{app1, nil, laptopScreen, hs.geometry.rect(0,0,0.6,1), nil, nil},
--			{app2, nil, laptopScreen, hs.geometry.rect(0.6,0,0.4,1),nil, nil},
--		}
--		hs.layout.apply(windowlayout)
--	end
--	hs.timer.doAfter(0.5, applyLayout)
--end)
--Launch App Helper function

function launchAndSwitchScreen(theApp)
	if not hs.application.launchOrFocus(theApp) then
		hs.alert.show("Launch "..theApp.." Failed!")
	else
		hs.alert.show("Launching "..theApp, shortAlertTime)
		local cApp = hs.application.get(theApp)  
		if cApp~=nil then
			local function moveAppToWindow()
				local appScreen = cApp:focusedWindow():screen()
				local mouseScreen = hs.mouse.getCurrentScreen()
				if appScreen ~= mouseScreen then
					cApp:mainWindow():moveToScreen(mouseScreen)
				end
			end
			doAfterMainWindowAppear(theApp,moveAppToWindow,1)
			--if cApp:focusedWindow() then
			--	moveAppToWindow()
			--else
			--	hs.timer.doAfter(3.0, moveAppToWindow)
			--end
		end
	end
end

--Binding Applications to Ctrl+Cmd+Alt+theKey 
function bindHyperToApplication(theKey, theApp)
	hs.hotkey.bind(Hyper,theKey,function()
		launchAndSwitchScreen(theApp)
	end)
end

bindHyperToApplication("A","/Applications/Microsoft OneNote.app")
-- airdrop bindHyperToApplication("B","Microsoft OneNote")
bindHyperToApplication("C","Fantastical 2")
--bindHyperToApplication("C","Calendar")
-- bindHyperToApplication("D","Dictionary")
bindHyperToApplication("E","Eudic")
bindHyperToApplication("F","Finder")
bindHyperToApplication("G","Omnifocus")
-- nothing bindHyperToApplication("H","Dictionary")
bindHyperToApplication("I","ITunes")
-- little Snitch bindHyperToApplication("J","Dictionary")
bindHyperToApplication("K","Keynote")
bindHyperToApplication("L","/Applications/Adobe Illustrator CC 2015/Adobe Illustrator.app")
bindHyperToApplication("M","Mathematica")
bindHyperToApplication("N","Notes")
bindHyperToApplication("O","OmniFocus")
bindHyperToApplication("P","/Applications/Adobe Photoshop CC 2015/Adobe Photoshop CC 2015.app")
bindHyperToApplication("Q","QQ")
bindHyperToApplication("R","Parallels Desktop")
bindHyperToApplication("S","Safari")
bindHyperToApplication("T","TextEdit")
-- nothing bindHyperToApplication("U","Dictionary")
bindHyperToApplication("V","Preview")
-- special keynote or word bindHyperToApplication("W","/Applications/Microsoft Word.app")
bindHyperToApplication("X","Xcode-beta")
-- nothing bindHyperToApplication("Y","Dictionary")
bindHyperToApplication("Z","WeChat")


bindHyperToApplication(",","MacVim")
bindHyperToApplication(".","Terminal")

--Launch Word if Word is open, but Keynote is not 
hs.hotkey.bind(Hyper,"W",function()
	local theApp="Pages"	
	if hs.application.get("Microsoft Word")~=nil and hs.application.get("Pages")==nil or hs.application.frontmostApplication():title()=="Pages" then
		theApp="/Applications/Microsoft Word.app"	
	end
	launchAndSwitchScreen(theApp)
end)

--Go to Airdrop
hs.hotkey.bind(Hyper,"B",function()
	theApp="Finder"
	if not hs.application.launchOrFocus(theApp) then
		hs.alert.show("Launch "..theApp.." Failed!")
	else
		local cApp = hs.application.get(theApp)  
		if cApp~=nil then
			local function moveAppToWindow()
				local appScreen = cApp:focusedWindow():screen()
				local mouseScreen = hs.mouse.getCurrentScreen()
				if appScreen ~= mouseScreen then
					cApp:mainWindow():moveToScreen(mouseScreen)
				end
				hs.eventtap.keyStroke({"cmd"}, "N")
				hs.eventtap.keyStroke({"cmd", "alt", "shift"}, "R")
			end
			doAfterMainWindowAppear(theApp,moveAppToWindow,1)
		end
	end

end)
-- then bind to a hotkey
--hs.hotkey.bind(Hyper,'G','Expose',function()expose:toggleShow()end)
--hs.hotkey.bind(Diper,'G','App Expose',function()expose_app:toggleShow()end)

-- Diper X for googling
hs.hotkey.bind(Diper, 'X', function()
	local oriStr = hs.pasteboard.getContents()	
	hs.eventtap.keyStroke({"cmd"}, "c")
	hs.timer.usleep(100000)
	if hs.pasteboard.getContents() == oriStr then
		hs.alert.show("Opening Google", shortAlertTime)
		hs.execute("open -a Safari http://google.com.sg/")
	else
		hs.alert.show("Searching Google for "..hs.pasteboard.getContents(), shortAlertTime)
		hs.execute("open -a Safari \"http://google.com/search?q="..hs.pasteboard.getContents().."\"")
	end
end)

--Launch Whatsapp
hs.hotkey.bind(Diper, 'W', function()
	launchAndSwitchScreen("WhatsApp")	
	--hs.alert.show("Opening Whatsapp", shortAlertTime)
	--hs.execute("open -a Safari https://web.whatsapp.com ")
	--hs.timer.usleep(300000)
	--local cX = 728
	--local cY = 329
	--hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown,hs.geometry.point(cX,cY)):post()
	--hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp,hs.geometry.point(cX,cY)):post()
end)

--Launch Inbox 
hs.hotkey.bind(Diper, 'I', function()
	hs.alert.show("Opening Inbox", shortAlertTime)
	hs.execute("open -a Safari https://inbox.google.com ")
end)

--Check Large amount of online accounts 
hs.hotkey.bind(Diper, 'L', function()
	hs.alert.show("Opening Common Websites", shortAlertTime)
	hs.execute("open -a Safari https://ivle.nus.edu.sg/v1/Module/Student/Default.aspx?CourseID=DFAB18BE-0F98-4D9B-A6B8-947A918B3A1B ")
	hs.execute("open -a Safari https://drive.google.com/drive/u/0/# ")
	hs.execute("open -a Safari https://outlook.office.com/owa/?realm=u.nus.edu#path=/mail ")
	hs.execute("open -a Safari https://rvhs8.asknlearn.com/Lms/default.aspx?ReturnUrl=%2flms%2f ")
	hs.execute("open -a Safari https://lms.asknlearn.com/RVHS/logon_new.aspx?ReturnUrl=/RVHS/web/startpage/Index.aspx ")
	hs.execute("open -a Safari https://inbox.google.com ")
end)

--Check Large amount of online accounts 
hs.hotkey.bind(Diper, 'U', function()
	hs.alert.show("Opening Google Drive", shortAlertTime)
	hs.execute("open -a Safari https://drive.google.com/drive/u/0/# ")
end)

-- Hyper D for dictionary 
hs.hotkey.bind(Hyper, 'D', function()
	local oriStr = hs.pasteboard.getContents()	
	hs.eventtap.keyStroke({"cmd"}, "c")
	hs.timer.usleep(50000)
	if hs.pasteboard.getContents() == oriStr then
		launchApp("Dictionary")
	else
		hs.execute("open dict://\""..(hs.pasteboard.getContents()).."\"")
	end
end)

--Hyper G for Hints
--hs.hotkey.bind(Hyper, "G", function()
--	hs.hints.style = "vimperator"
--	hs.hints.showTitleThresh = 4
--	hs.hints.windowHints()
--end)

-- Automatic Reload Config File after saving
function reloadConfig(files)
	doReload = false
	for _,file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded", shortAlertTime)

--setting up exposé
-- set up your instance(s)
--local expose = hs.expose.new(nil,{showThumbnails=false}) -- default windowfilter, no thumbnails
--local expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application
--local expose_space = hs.expose.new(nil,{includeOtherSpaces=false}) -- only windows in the current Mission Control Space
--local expose_browsers = hs.expose.new{'Safari','Google Chrome'} -- specialized expose using a custom windowfilter
-- for your dozens of browser windows :)


