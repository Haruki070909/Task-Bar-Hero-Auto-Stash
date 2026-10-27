; ===================================================================================
; Project   : TBH Auto-Stasher (Haruki Edition)
; Version   : 2.0.0 (Production Release)
; Author    : Haruki (Discord: haruki_kino)
; Community : https://discord.gg/gardenofdream
; ===================================================================================
;@Ahk2Exe-SetName TBH Auto-Stasher (Haruki Edition)
;@Ahk2Exe-SetDescription Smart Inventory & Stash Manager for Taskbar Hero
;@Ahk2Exe-SetCopyright Created by Haruki (discord.gg/gardenofdream)
;@Ahk2Exe-SetVersion 2.0.0.0

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
DllCall("SetProcessDPIAware")

global ConfigFile := A_ScriptDir . "\config.ini"

IniRead, HasMatDLC,       %ConfigFile%, DLC, HasMatDLC, 1
IniRead, HasExtraSlots,   %ConfigFile%, DLC, HasExtraSlots, 1
IniRead, EdtTimer,        %ConfigFile%, Runtime, ScanInterval, 3
IniRead, UseWebhook,      %ConfigFile%, Webhook, UseWebhook, 1
IniRead, WebhookURL,      %ConfigFile%, Webhook, WebhookURL, %A_Space%

IniRead, SavedReady,      %ConfigFile%, Calibration, Ready, 0
IniRead, Off_StashAllX,   %ConfigFile%, Calibration, Off_StashAllX, 0
IniRead, Off_StashAllY,   %ConfigFile%, Calibration, Off_StashAllY, 0
IniRead, Off_MatTabX,     %ConfigFile%, Calibration, Off_MatTabX, 0
IniRead, Off_MatTabY,     %ConfigFile%, Calibration, Off_MatTabY, 0
IniRead, Off_Tab1X,       %ConfigFile%, Calibration, Off_Tab1X, 0
IniRead, Off_Tab1Y,       %ConfigFile%, Calibration, Off_Tab1Y, 0
IniRead, Off_TabLastX,    %ConfigFile%, Calibration, Off_TabLastX, 0
IniRead, Off_StashLastX,  %ConfigFile%, Calibration, Off_StashLastX, 0
IniRead, Off_StashLastY,  %ConfigFile%, Calibration, Off_StashLastY, 0
IniRead, Off_InvCheckX,   %ConfigFile%, Calibration, Off_InvCheckX, 0
IniRead, Off_InvCheckY,   %ConfigFile%, Calibration, Off_InvCheckY, 0
IniRead, EmptyStashColor, %ConfigFile%, Calibration, EmptyStashColor, 0x181818
IniRead, EmptyInvColor,   %ConfigFile%, Calibration, EmptyInvColor, 0x181818
IniRead, SavedWinTitle,   %ConfigFile%, Calibration, GameWinTitle, %A_Space%

global AvatarFile := ""
if FileExist(A_ScriptDir . "\avatar.png")
    AvatarFile := A_ScriptDir . "\avatar.png"
else if FileExist(A_ScriptDir . "\avatar.ico")
    AvatarFile := A_ScriptDir . "\avatar.ico"

Menu, Tray, Tip, TBH Auto-Stasher v2.0 - Haruki Edition
if (AvatarFile != "") {
    Menu, Tray, Icon, %AvatarFile%
}

global IsRunning := false
global CurrentTab := 1
global MaxTabs := (HasExtraSlots = 1) ? 5 : 2
global WinID := ""
global Ready := (SavedReady = 1) ? true : false
global DDLTab := 1
global StashCount := 0
global TotalElapsedSec := 0
global FormattedTime := "00:00:00"

if (Ready and SavedWinTitle != "") {
    WinGet, FoundID, ID, %SavedWinTitle%
    if (FoundID != "")
        WinID := FoundID
}

Gui, +AlwaysOnTop -Caption +Border +HwndAppHwnd
Gui, Color, 11111B, 1E1E2E

Gui, Add, Progress, x0 y0 w300 h38 Background181825 Disabled
if (AvatarFile != "") {
    Gui, Add, Picture, x8 y5 w28 h28 BackgroundTrans gDragWindow, %AvatarFile%
    Gui, Font, s10 c89DCEB Bold, Segoe UI
    Gui, Add, Text, x42 y9 w200 h24 BackgroundTrans gDragWindow, TBH AUTO-STASHER v2.0
} else {
    Gui, Font, s10 c89DCEB Bold, Segoe UI
    Gui, Add, Text, x12 y9 w220 h24 BackgroundTrans gDragWindow, ⚡ TBH AUTO-STASHER v2.0
}

Gui, Font, s10 cA6ADC8 Bold, Segoe UI
Gui, Add, Text, x246 y7 w22 h24 Center BackgroundTrans gMinimizeApp, ─
Gui, Font, s10 cF38BA8 Bold, Segoe UI
Gui, Add, Text, x272 y7 w22 h24 Center BackgroundTrans gGuiClose, ✕

Gui, Add, Progress, x12 y46 w276 h56 Background1E1E2E Disabled
if (Ready) {
    Gui, Font, s9 cA6E3A1 Bold, Segoe UI
    Gui, Add, Text, x18 y51 w264 h32 Center BackgroundTrans vStatusText, Status: Ready! (Saved Config Loaded)`nPress [F2] to Start or [F1] to Recalibrate
    Gui, Font, s8 cA6ADC8 Norm, Segoe UI
    Gui, Add, Text, x18 y82 w264 Center BackgroundTrans vSensorText, Sensor: Ready (Empty Color %EmptyInvColor%)
} else {
    Gui, Font, s9 cF38BA8 Bold, Segoe UI
    Gui, Add, Text, x18 y51 w264 h32 Center BackgroundTrans vStatusText, Status: Not Calibrated`nPress [F1] to start setup
    Gui, Font, s8 cA6ADC8 Norm, Segoe UI
    Gui, Add, Text, x18 y82 w264 Center BackgroundTrans vSensorText, Sensor: Waiting for setup...
}

Gui, Add, Progress, x12 y108 w276 h36 Background181825 Disabled
Gui, Font, s9 cA6E3A1 Bold, Segoe UI
Gui, Add, Text, x20 y117 w125 BackgroundTrans vRunTimeText, ⏱ Time: 00:00:00
Gui, Font, s9 cF9E2AF Bold, Segoe UI
Gui, Add, Text, x150 y117 w95 BackgroundTrans vStashCountText, 📦 Stashed: 0
Gui, Font, s8 c89B4FA Norm, Segoe UI
Gui, Add, Text, x248 y118 w35 Center BackgroundTrans gResetStats, [Reset]

Gui, Font, s8 c89B4FA Bold, Segoe UI
Gui, Add, GroupBox, x12 y150 w276 h64, DLC CONFIGURATION (SELECT BEFORE F1)
Gui, Font, s8 cCDD6F4 Norm, Segoe UI
Gui, Add, CheckBox, x24 y169 vHasMatDLC Checked%HasMatDLC% gUpdateDLC, Material Stash DLC (Mat Tab first)
Gui, Add, CheckBox, x24 y190 vHasExtraSlots Checked%HasExtraSlots% gUpdateDLC, +3 Stash Slots DLC (5 Tabs total)

Gui, Font, s8 c89B4FA Bold, Segoe UI
Gui, Add, GroupBox, x12 y220 w276 h64, RUNTIME SETTINGS
Gui, Font, s8 cCDD6F4 Norm, Segoe UI
Gui, Add, Text, x24 y239 BackgroundTrans, Active Stash Tab:
TabList := (HasExtraSlots = 1) ? "1|2|3|4|5" : "1|2"
Gui, Add, DropDownList, x160 y235 w60 vDDLTab gUpdateTab Choose1, %TabList%
Gui, Add, Text, x24 y262 BackgroundTrans, Scan Interval (sec):
Gui, Add, Edit, x160 y258 w60 h20 cFFFFFF Number vEdtTimer gSaveRuntimeConfig, %EdtTimer%

Gui, Font, s8 cCBA6F7 Bold, Segoe UI
Gui, Add, GroupBox, x12 y290 w276 h72, DISCORD WEBHOOK (AUTO SCREENSHOT)
Gui, Font, s8 cCDD6F4 Norm, Segoe UI
Gui, Add, CheckBox, x24 y309 vUseWebhook Checked%UseWebhook% gSaveWebhookConfig, Enable Screenshot to Discord
Gui, Font, s8 c89DCEB Bold, Segoe UI
Gui, Add, Text, x235 y309 w45 Center BackgroundTrans gTestWebhook, [Test]
Gui, Font, s8 cFFFFFF Norm, Segoe UI
Gui, Add, Edit, x24 y331 w252 h22 cFFFFFF vWebhookURL gSaveWebhookConfig, %WebhookURL%

Gui, Font, s9 Bold, Segoe UI
Gui, Add, Button, x12 y370 w134 h34 gStartCalibration, 1. Calibrate (F1)
Gui, Add, Button, x154 y370 w134 h34 vBtnToggle gToggleAuto, 2. Start Auto (F2)
Gui, Add, Button, x12 y410 w276 h28 gForceStashNow, ▶ Test Stash Now (F3)

Gui, Add, Progress, x0 y446 w300 h64 Background181825 Disabled
Gui, Add, Progress, x12 y446 w276 h1 Background313244 Disabled

Gui, Font, s8 cF9E2AF Bold, Segoe UI
Gui, Add, Text, x12 y452 w276 Center BackgroundTrans, ✨ Created by : Haruki ✨
Gui, Font, s8 cCDD6F4 Norm, Segoe UI
Gui, Add, Text, x12 y469 w276 Center BackgroundTrans gCopyDiscord, 💬 Discord : haruki_kino (Click to copy)
Gui, Font, s8 c89DCEB Underline, Segoe UI
Gui, Add, Text, x12 y486 w276 Center BackgroundTrans gOpenDiscordGroup, 🌐 Group : https://discord.gg/gardenofdream

Gui, Show, w300 h510, TBH Auto-Stasher - Haruki
return

DragWindow:
    PostMessage, 0xA1, 2,,, A
return

MinimizeApp:
    Gui, Minimize
return

CopyDiscord:
    Clipboard := "haruki_kino"
    ToolTip, Copied Discord ID: haruki_kino
    SetTimer, ClearTip, -1500
return

OpenDiscordGroup:
    Run, https://discord.gg/gardenofdream
return

ClearTip:
    ToolTip
return

SaveRuntimeConfig:
    Gui, Submit, NoHide
    if (EdtTimer < 1 or EdtTimer = "")
        EdtTimer := 1
    IniWrite, %EdtTimer%, %ConfigFile%, Runtime, ScanInterval
return

SaveWebhookConfig:
    Gui, Submit, NoHide
    IniWrite, %WebhookURL%, %ConfigFile%, Webhook, WebhookURL
    IniWrite, %UseWebhook%, %ConfigFile%, Webhook, UseWebhook
return

TestWebhook:
    Gui, Submit, NoHide
    if (WebhookURL = "") {
        MsgBox, 48, Webhook Missing, Please paste your Discord Webhook URL into the box first!
        return
    }
    ToolTip, Sending test screenshot to Discord...
    SetTimer, ClearTip, -2500
    SendDiscordScreenshot("🔔 **[TEST] TBH Auto-Stasher v2.0 Connected!**\n✨ Created by **Haruki** (`discord.gg/gardenofdream`)")
return

SendDiscordScreenshot(CustomMsg) {
    GuiControlGet, UseWebhook,, UseWebhook
    GuiControlGet, WebhookURL,, WebhookURL
    if (!UseWebhook or WebhookURL = "")
        return

    capX := 0, capY := 0, capW := A_ScreenWidth, capH := A_ScreenHeight
    if (EnsureGameWindow()) {
        WinGetPos, wx, wy, ww, wh, ahk_id %WinID%
        if (ww > 50 and wh > 50) {
            capX := wx, capY := wy, capW := ww, capH := wh
        }
    }

    PsScript := A_Temp . "\tbh_discord_sender.ps1"
    ImgFile  := A_Temp . "\tbh_stash_capture.png"
    FileDelete, %PsScript%

    PsCode =
    (LTrim
        $ErrorActionPreference = 'SilentlyContinue'
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Net.Http
        $bmp = New-Object System.Drawing.Bitmap(%capW%, %capH%)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.CopyFromScreen(%capX%, %capY%, 0, 0, $bmp.Size)
        $bmp.Save('%ImgFile%', [System.Drawing.Imaging.ImageFormat]::Png)
        $g.Dispose()
        $bmp.Dispose()

        $url = '%WebhookURL%'
        $client = New-Object System.Net.Http.HttpClient
        $content = New-Object System.Net.Http.MultipartFormDataContent

        $msg = "%CustomMsg%" -replace '\\n', "`n"
        $payload = @{ username = 'TBH Auto-Stasher | Haruki'; content = $msg } | ConvertTo-Json -Compress
        $jsonPart = New-Object System.Net.Http.StringContent($payload, [System.Text.Encoding]::UTF8, 'application/json')
        $content.Add($jsonPart, 'payload_json')

        $fileStream = [System.IO.File]::OpenRead('%ImgFile%')
        $filePart = New-Object System.Net.Http.StreamContent($fileStream)
        $filePart.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('image/png')
        $content.Add($filePart, 'file', 'stash_report.png')

        $null = $client.PostAsync($url, $content).Result
        $fileStream.Close()
        $client.Dispose()
    )
    FileAppend, %PsCode%, %PsScript%, UTF-8
    Run, powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PsScript%",, Hide
}

EnsureGameWindow() {
    if (WinID != "" and WinExist("ahk_id " WinID))
        return true
    if (SavedWinTitle != "") {
        WinGet, FoundID, ID, %SavedWinTitle%
        if (FoundID != "") {
            WinID := FoundID
            return true
        }
    }
    return false
}

ResetStats:
    TotalElapsedSec := 0
    StashCount := 0
    FormattedTime := "00:00:00"
    GuiControl,, RunTimeText, ⏱ Time: 00:00:00
    GuiControl,, StashCountText, 📦 Stashed: 0
return

UpdateClock:
    TotalElapsedSec++
    hrs := Floor(TotalElapsedSec / 3600)
    mins := Floor(Mod(TotalElapsedSec, 3600) / 60)
    secs := Mod(TotalElapsedSec, 60)
    FormattedTime := Format("{:02}:{:02}:{:02}", hrs, mins, secs)
    GuiControl,, RunTimeText, ⏱ Time: %FormattedTime%
return

UpdateDLC:
    Gui, Submit, NoHide
    MaxTabs := (HasExtraSlots = 1) ? 5 : 2
    GuiControl,, DDLTab, % (HasExtraSlots = 1) ? "|1|2|3|4|5" : "|1|2"
    CurrentTab := 1
    GuiControl, Choose, DDLTab, 1
    Ready := false
    IniWrite, %HasMatDLC%, %ConfigFile%, DLC, HasMatDLC
    IniWrite, %HasExtraSlots%, %ConfigFile%, DLC, HasExtraSlots
    IniWrite, 0, %ConfigFile%, Calibration, Ready
    GuiControl, +cF38BA8, StatusText
    GuiControl,, StatusText, Status: DLC Updated!`nPress [F1] to Calibrate
return

UpdateTab:
    Gui, Submit, NoHide
    CurrentTab := DDLTab
return

F1::
StartCalibration:
    SetTimer, CheckAndStash, Off
    SetTimer, UpdateClock, Off
    IsRunning := false
    GuiControl,, BtnToggle, 2. Start Auto (F2)

    GuiControlGet, HasMatDLC,, HasMatDLC
    GuiControlGet, HasExtraSlots,, HasExtraSlots
    MaxTabs := (HasExtraSlots = 1) ? 5 : 2

    KeyWait, F1

    WaitForConfirm("STEP 1: Hover over [Stash All] button`n-> Press [ ` ] or [F1] to save")
    MouseGetPos, pX, pY, WinID
    WinGetTitle, SavedWinTitle, ahk_id %WinID%
    WinGetPos, WinX, WinY, , , ahk_id %WinID%
    Off_StashAllX := pX - WinX
    Off_StashAllY := pY - WinY

    if (HasMatDLC = 1) {
        WaitForConfirm("STEP 2 (DLC): Hover over [Material Tab]`n-> Press [ ` ] or [F1] to save")
        MouseGetPos, pX, pY
        Off_MatTabX := pX - WinX
        Off_MatTabY := pY - WinY
    }

    WaitForConfirm("STEP 3: Hover over Stash [Tab 1]`n-> Press [ ` ] or [F1] to save")
    MouseGetPos, pX, pY
    Off_Tab1X := pX - WinX
    Off_Tab1Y := pY - WinY

    WaitForConfirm("STEP 4: Hover over Stash [Tab " . MaxTabs . "]`n-> Press [ ` ] or [F1] to save")
    MouseGetPos, pX, pY
    Off_TabLastX := pX - WinX

    WaitForConfirm("STEP 5: Hover over LAST EMPTY SLOT in Stash`n(Bottom-Right) -> Press [ ` ] or [F1]")
    MouseGetPos, pX, pY
    Off_StashLastX := pX - WinX
    Off_StashLastY := pY - WinY
    MouseMove, pX - 150, pY, 0
    Sleep, 40
    PixelGetColor, EmptyStashColor, %pX%, %pY%, RGB
    MouseMove, %pX%, %pY%, 0

    WaitForConfirm("STEP 6: Hover over EMPTY TRIGGER SLOT in Inv`n-> Press [ ` ] or [F1] to finish!")
    MouseGetPos, pX, pY
    Off_InvCheckX := pX - WinX
    Off_InvCheckY := pY - WinY
    MouseMove, pX - 150, pY, 0
    Sleep, 40
    PixelGetColor, EmptyInvColor, %pX%, %pY%, RGB
    MouseMove, %pX%, %pY%, 0

    IniWrite, 1,                 %ConfigFile%, Calibration, Ready
    IniWrite, %SavedWinTitle%,   %ConfigFile%, Calibration, GameWinTitle
    IniWrite, %Off_StashAllX%,   %ConfigFile%, Calibration, Off_StashAllX
    IniWrite, %Off_StashAllY%,   %ConfigFile%, Calibration, Off_StashAllY
    IniWrite, %Off_MatTabX%,     %ConfigFile%, Calibration, Off_MatTabX
    IniWrite, %Off_MatTabY%,     %ConfigFile%, Calibration, Off_MatTabY
    IniWrite, %Off_Tab1X%,       %ConfigFile%, Calibration, Off_Tab1X
    IniWrite, %Off_Tab1Y%,       %ConfigFile%, Calibration, Off_Tab1Y
    IniWrite, %Off_TabLastX%,    %ConfigFile%, Calibration, Off_TabLastX
    IniWrite, %Off_StashLastX%,  %ConfigFile%, Calibration, Off_StashLastX
    IniWrite, %Off_StashLastY%,  %ConfigFile%, Calibration, Off_StashLastY
    IniWrite, %Off_InvCheckX%,   %ConfigFile%, Calibration, Off_InvCheckX
    IniWrite, %Off_InvCheckY%,   %ConfigFile%, Calibration, Off_InvCheckY
    IniWrite, %EmptyStashColor%, %ConfigFile%, Calibration, EmptyStashColor
    IniWrite, %EmptyInvColor%,   %ConfigFile%, Calibration, EmptyInvColor

    ToolTip
    Ready := true
    CurrentTab := 1
    GuiControl, Choose, DDLTab, 1
    GuiControl, +cA6E3A1, StatusText
    GuiControl,, StatusText, Status: Ready & Saved! (Tabs: %MaxTabs%)`nPress [F2] to Start Auto
    GuiControl,, SensorText, Sensor: Ready (Empty Color %EmptyInvColor%)
return

WaitForConfirm(msg) {
    GuiControl, +cF9E2AF, StatusText
    GuiControl,, StatusText, %msg%
    Loop {
        ToolTip, %msg%
        Sleep, 25
        if (GetKeyState("``", "P") or GetKeyState("F1", "P")) {
            KeyWait, ``
            KeyWait, F1
            SoundBeep, 750, 80
            Sleep, 200
            break
        }
    }
}

F2::
ToggleAuto:
    Gui, Submit, NoHide
    if (!Ready) {
        MsgBox, 48, Calibration Required, Please press [F1] to calibrate coordinates first!
        return
    }
    if (!EnsureGameWindow()) {
        MsgBox, 48, Game Window Not Found, Could not find the game window! Please make sure the game is running or press [F1] to recalibrate.
        return
    }
    IsRunning := !IsRunning
    if (IsRunning) {
        if (EdtTimer < 1 or EdtTimer = "")
            EdtTimer := 3
        GuiControl,, BtnToggle, Stop Auto (F2)
        GuiControl, +cA6E3A1, StatusText
        GuiControl,, StatusText, Status: Monitoring Inventory...`n(Current Stash Tab: %CurrentTab%/%MaxTabs%)
        SetTimer, UpdateClock, 1000
        TimerMS := EdtTimer * 1000
        SetTimer, CheckAndStash, %TimerMS%
        Gosub, CheckAndStash
    } else {
        GuiControl,, BtnToggle, 2. Start Auto (F2)
        GuiControl, +cF9E2AF, StatusText
        GuiControl,, StatusText, Status: Paused`nPress [F2] to Resume
        SetTimer, UpdateClock, Off
        SetTimer, CheckAndStash, Off
    }
return

CheckAndStash:
    if (!EnsureGameWindow())
        return

    WinGetPos, WinX, WinY, , , ahk_id %WinID%
    InvSlotX := WinX + Off_InvCheckX
    InvSlotY := WinY + Off_InvCheckY

    if (IsGridOccupied(InvSlotX, InvSlotY, EmptyInvColor)) {
        GuiControl,, SensorText, Sensor: ITEM DETECTED! Stashing...
        Gosub, ExecuteStash
    } else {
        GuiControl,, SensorText, Sensor: Inv Slot Empty (Monitoring)
    }
return

F3::
ForceStashNow:
    Gui, Submit, NoHide
    if (!Ready) {
        MsgBox, 48, Error, Please press F1 to calibrate first!
        return
    }
    Gosub, ExecuteStash
return

ExecuteStash:
    GuiControlGet, HasMatDLC,, HasMatDLC
    GuiControlGet, HasExtraSlots,, HasExtraSlots
    MaxTabs := (HasExtraSlots = 1) ? 5 : 2

    if (!EnsureGameWindow())
        return

    WinGetPos, WinX, WinY, , , ahk_id %WinID%
    MouseGetPos, OrigX, OrigY

    StashAllX := WinX + Off_StashAllX
    StashAllY := WinY + Off_StashAllY
    StashLastX := WinX + Off_StashLastX
    StashLastY := WinY + Off_StashLastY
    InvSlotX := WinX + Off_InvCheckX
    InvSlotY := WinY + Off_InvCheckY

    TabStep := (MaxTabs > 1) ? ((Off_TabLastX - Off_Tab1X) / (MaxTabs - 1.0)) : 0

    StashCount++
    GuiControl,, StashCountText, 📦 Stashed: %StashCount%

    if (HasMatDLC = 1) {
        MatTabX := WinX + Off_MatTabX
        MatTabY := WinY + Off_MatTabY
        Click, %MatTabX%, %MatTabY%
        Sleep, 250
        Click, %StashAllX%, %StashAllY%
        Sleep, 350
    }

    Loop, %MaxTabs% {
        CurTabX := Round(WinX + Off_Tab1X + ((CurrentTab - 1) * TabStep))
        CurTabY := WinY + Off_Tab1Y
        Click, %CurTabX%, %CurTabY%
        Sleep, 300

        Click, %StashAllX%, %StashAllY%
        Sleep, 350

        MouseMove, StashLastX - 150, StashLastY, 0
        Sleep, 40

        if (IsGridOccupied(StashLastX, StashLastY, EmptyStashColor)) {
            if (CurrentTab < MaxTabs) {
                CurrentTab++
                GuiControl, Choose, DDLTab, %CurrentTab%
                GuiControl,, StatusText, Status: Stash %CurrentTab% Active (Prev Full)
                if (!IsGridOccupied(InvSlotX, InvSlotY, EmptyInvColor)) {
                    break
                }
            } else {
                MouseMove, %OrigX%, %OrigY%, 0
                SendDiscordScreenshot("🚨 **ALERT: ALL " . MaxTabs . " STASH TABS ARE FULL!**\n📦 Total Stashed: **#" . StashCount . "** | ⏱ Run Time: **" . FormattedTime . "**\n🛑 Macro has automatically stopped.")
                SetTimer, CheckAndStash, Off
                SetTimer, UpdateClock, Off
                IsRunning := false
                GuiControl,, BtnToggle, 2. Start Auto (F2)
                GuiControl, +cF38BA8, StatusText
                GuiControl,, StatusText, STOPPED: All %MaxTabs% Stashes Full!
                GuiControl,, SensorText, Sensor: All Stash Tabs Full!
                MsgBox, 48, Stash Full, All %MaxTabs% Stash tabs are full! Macro has stopped.
                return
            }
        } else {
            break
        }
    }

    MouseMove, %OrigX%, %OrigY%, 0
    SendDiscordScreenshot("📦 **Inventory Full -> Auto-Stashed! (#" . StashCount . ")**\n🗂 Active Stash Tab: **" . CurrentTab . "/" . MaxTabs . "** | ⏱ Run Time: **" . FormattedTime . "**")
return

IsGridOccupied(centerX, centerY, baseColor) {
    baseR := (baseColor >> 16) & 0xFF
    baseG := (baseColor >> 8) & 0xFF
    baseB := baseColor & 0xFF

    offsets := [-6, 0, 6]
    for i, dx in offsets {
        for j, dy in offsets {
            px := centerX + dx
            py := centerY + dy
            PixelGetColor, col, %px%, %py%, RGB
            R := (col >> 16) & 0xFF
            G := (col >> 8) & 0xFF
            B := col & 0xFF
            diff := Abs(R - baseR) + Abs(G - baseG) + Abs(B - baseB)
            if (diff > 40 or R > 65 or G > 65 or B > 65) {
                return true
            }
        }
    }
    return false
}

GuiClose:
ExitApp