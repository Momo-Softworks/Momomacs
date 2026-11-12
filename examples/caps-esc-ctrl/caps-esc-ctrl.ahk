#Requires AutoHotkey v2.0
#SingleInstance Force
; Caps Lock: tap = Esc, hold = Ctrl.
; A tap is a press and release within 300 ms with no other key in between.
; Holding it while pressing another key works like Ctrl.
; Shift+Caps Lock is not special: real Caps Lock is always off.

SetCapsLockState "AlwaysOff"

*CapsLock:: {
    Send "{Blind}{LCtrl down}"
    start := A_TickCount
    KeyWait "CapsLock"
    Send "{Blind}{LCtrl up}"
    ; A_PriorKey ignores keys sent by this script, so it is still
    ; "CapsLock" here only if no other key was pressed during the hold.
    if (A_PriorKey = "CapsLock" && A_TickCount - start < 300)
        Send "{Esc}"
}
