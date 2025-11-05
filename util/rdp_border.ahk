#NoEnv
#SingleInstance, Force
try Menu, Tray, Icon, flat_rdp_icon_orange_bright.ico
SetBatchLines, -1
SetTitleMatchMode, 2

; ==== Settings ====
borderColor := "ff8243"   ; orange (hex, no 0x)
borderThickness := 6
borderInset := 2          ; move borders inward
checkIntervalMs := 150

; ==== Create 4 border GUIs (click-through, always on top) ====
for _, side in ["Top","Left","Bottom","Right"] {
    Gui, %side%:New, +AlwaysOnTop -Caption +ToolWindow +E0x20 +OwnDialogs
    Gui, %side%:Color, %borderColor%
    Gui, %side%:Show, Hide, rdpBorder%side%
}

SetTimer, UpdateBorder, %checkIntervalMs%
OnExit, Cleanup
return

UpdateBorder:
    WinGet, aid, ID, A
    if (!aid) {
        Gosub, HideBorders
        return
    }

    ; ==== RDP window detection by title (with dash) ====
    WinGet, proc, ProcessName, ahk_id %aid%
    WinGetTitle, title, ahk_id %aid%
    hasDash := InStr(title, " - Remote Desktop Connection")    ; note the dash
    isRDP := (proc = "mstsc.exe") && hasDash
    if (!isRDP) {
        Gosub, HideBorders
        return
    }

    ; ==== Compute positions ====
    WinGetPos, X, Y, W, H, ahk_id %aid%
    t := borderThickness
    i := borderInset

    ; Top: inset horizontally so it lines up with left/right; Y stays flush
    topX := X + i
    topY := Y
    topW := W - (2 * i)
    topH := t

    ; Bottom: inset on both sides
    bottomX := X + i
    bottomY := Y + H - t - i
    bottomW := W - (2 * i)
    bottomH := t

    ; Left/Right: start at Y+i and end at top of bottom border
    leftX := X + i
    leftY := Y + i
    leftW := t
    leftH := H - t - (2 * i)

    rightX := X + W - t - i
    rightY := Y + i
    rightW := t
    rightH := H - t - (2 * i)

    ; ==== Draw borders ====
    Gui, Top:Show,    x%topX%    y%topY%    w%topW%    h%topH%    NA
    Gui, Left:Show,   x%leftX%   y%leftY%   w%leftW%   h%leftH%   NA
    Gui, Bottom:Show, x%bottomX% y%bottomY% w%bottomW% h%bottomH% NA
    Gui, Right:Show,  x%rightX%  y%rightY%  w%rightW%  h%rightH%  NA
return

HideBorders:
    for _, side in ["Top","Left","Bottom","Right"]
        Gui, %side%:Hide
return

Cleanup:
    Gosub, HideBorders
    ExitApp
