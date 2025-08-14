; =============================================================
;          智能中英文输入法切换脚本 (v1.3 - 最终版：带总开关)
; =============================================================

; --- 0. 自动以管理员权限运行 ---
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#SingleInstance Force

; --- 1. 用户自定义设置 ---
global chineseImeId := "0x08040804"  ; 中文(简体, 中国)
global englishImeId := "0x04090409"  ; 英语(美国)
global idleTimeout := 5000           ; 闲置超时时间 (毫秒)

; --- 2. 脚本初始化与总开关 ---
global isScriptActive := true        ; 脚本总开关，true为开启
global isTempChineseMode := false
switchToEnglish()
SetTimer, CheckForIdle, 1000
return

; --- 3. 定义快捷键 ---

; 总开关快捷键：Ctrl + Win + Space
^#Space::
    isScriptActive := !isScriptActive ; 反转开关状态 (true -> false, false -> true)
    if (isScriptActive)
    {
        switchToEnglish() ; 重新开启时，强制切回英文
        ToolTip, 脚本功能已开启
    }
    else
    {
        ToolTip, 脚本功能已暂停
    }
    SetTimer, RemoveToolTip, 2000
return

; 临时中文切换快捷键：Win + Space
#Space::
    if (!isScriptActive) ; 如果脚本被暂停了，则不执行任何操作
        return

    isTempChineseMode := true
    switchToChinese()
    ToolTip, 中文输入已开启
    SetTimer, RemoveToolTip, 2000
return

; --- 4. 核心逻辑：检查闲置并切换 ---
CheckForIdle:
    if (!isScriptActive) ; 如果脚本被暂停了，则不执行任何检查
        return

    if (isTempChineseMode and A_TimeIdlePhysical > idleTimeout)
    {
        switchToEnglish()
        isTempChineseMode := false
        ToolTip, 已自动切回英文输入法。
        SetTimer, RemoveToolTip, 2000
    }
return

; --- 5. 辅助函数 ---
RemoveToolTip:
    ToolTip
return

switchToIme(imeId)
{
    active_window := WinActive("A")
    PostMessage, 0x50, 0, %imeId%,, ahk_id %active_window%
}

switchToEnglish()
{
    if (isScriptActive) ; 只有在脚本开启状态下才执行切换
        switchToIme(englishImeId)
}

switchToChinese()
{
    if (isScriptActive)
        switchToIme(chineseImeId)
}