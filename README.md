# Matcha — Menu Binding (Temporary)

Create custom menu tabs, widgets, and keybinds from Lua scripts.

```lua
UI.AddTab("My Script", function(tab)
    local sec = tab:Section("Settings", "Left")
    sec:Toggle("enabled", "Enabled")
    sec:Keybind("enabled_kb", 0x46, "hold")
    sec:SliderInt("range", "Range", 1, 5000, 2000)
end)
```

---

## UI

| | |
|---|---|
| `UI.AddTab(name, fn)` | Create a tab. `fn(tab)` runs every frame. |
| `UI.RemoveTab(name)` | Remove a tab. |
| `UI.GetValue(id)` | Read a widget value from anywhere. |
| `UI.SetValue(id, val)` | Write a widget value from anywhere. |

```lua
while true do
    if UI.GetValue("aim_on") then
        local fov = UI.GetValue("aim_fov")
    end
    wait()
end
```

---

## Sections

Created from the `tab` object. Two columns: `"Left"` and `"Right"`.
Optional pages turn a section into a tabbed card.

```lua
tab:Section(name, side)                            -> Section
tab:Section(name, side, {"Page 1", "Page 2"})      -> Section (tabbed)
tab:Section(name, side, pages, max_height)          -> Section (scrollable)
```

```lua
local sec = tab:Section("Aimbot", "Left", {"Main", "Advanced"}, 400)
if sec.page == 0 then
    -- Main page
elseif sec.page == 1 then
    -- Advanced page
end
```

Sections close automatically when a new one starts.

---

## Widgets

Every widget returns an **object** you can store and call methods on.

```lua
local toggle = sec:Toggle("aim_on", "Enabled")
toggle.value            -- current value
toggle:GetValue()       -- same, always fresh
toggle:SetValue(true)   -- change it
```

All widgets accept an **optional callback as the last argument**.

---

### Toggle

```lua
sec:Toggle(id, label [, default] [, callback]) -> Widget
```

```lua
sec:Toggle("aim_on", "Aimbot", function(state)
    print("Aimbot: " .. tostring(state))
end)

sec:Toggle("team_check", "Team Check", true)
```

---

### Keybind

Place after a Toggle. Left-click to rebind, right-click to pick mode.

```lua
sec:Keybind(id [, key [, type]]) -> KeybindWidget
```

| Arg | Description |
|---|---|
| `key` | VK code. `0` = unbound. |
| `type` | `"toggle"` `"hold"` `"always"` `"click"` |

```lua
sec:Toggle("aim_on", "Aimbot")
local kb = sec:Keybind("aim_kb", 0x46, "hold")  -- F, hold
-- local kb = sec:Keybind("aim_kb", Enum.KeyCode.F, "hold")  -- F, hold

kb:AddToHotkey("Aimbot", "aim_on")  -- show in hotkey list when aim_on is ON
```

**KeybindWidget methods:**

| | |
|---|---|
| `.value` / `:IsEnabled()` | Is the keybind active right now |
| `:GetKey()` | VK code / Enum.KeyCode |
| `:SetKey(vk)` | Rebind |
| `:GetKeyName()` | `"f"`, `"lmb"`, `"none"` |
| `:GetType()` | `"toggle"`, `"hold"`, `"always"`, `"click"` |
| `:SetType(str)` | Change mode |
| `:AddToHotkey(label, toggle_id)` | Show in hotkey overlay when toggle is ON |
| `:RemoveFromHotkey()` | Hide from overlay |

**VK codes:** `0x01` LMB · `0x02` RMB · `0x04` MMB · `0x05` X1 · `0x06` X2 · `0x41`–`0x5A` A–Z

**Enum keycodes:** `Enum.KeyCode.MouseButton1` LMB · `Enum.KeyCode.MouseButton2` RMB · `Enum.KeyCode.MouseButton3` MMB · `Enum.KeyCode.MouseButton4` X1 · `Enum.KeyCode.MouseButton5` X2 · `Enum.KeyCode.A`–`Enum.KeyCode.Z` A–Z

---

### SliderInt

```lua
sec:SliderInt(id, label, min, max [, default] [, callback]) -> Widget
```

```lua
sec:SliderInt("fov", "FOV Size", 10, 800, 180, function(val)
    print("FOV: " .. val)
end)
```

---

### SliderFloat

```lua
sec:SliderFloat(id, label, min, max [, default [, fmt]] [, callback]) -> Widget
```

```lua
sec:SliderFloat("smooth", "Smoothing", 0.1, 20.0, 6.0, "%.1f", function(val)
    print("Smooth: " .. val)
end)
```

---

### Combo

Returns a **ComboWidget** with item management. Callback gives `(index, text)`.

```lua
sec:Combo(id, label, items [, default] [, callback]) -> ComboWidget
```

```lua
local c = sec:Combo("hitbox", "Target", {"Head", "Torso", "Nearest"}, 0, function(idx, text)
    print("Target: " .. text)
end)

c:Add("Arms")              -- add option
c:Remove("Nearest")         -- remove option
c:Clear()                   -- remove all
c:GetItems()                -- {"Head", "Torso", "Arms"}
c:GetText()                 -- current selection string
c:SetValue(1)               -- select "Torso"
```

---

### Button

```lua
sec:Button(label [, callback])
sec:Button(label, width, height [, callback])
```

```lua
sec:Button("Reset All", function()
    UI.SetValue("aim_on", false)
    UI.SetValue("fov", 180)
end)
```

---

### ColorPicker

**Must follow a Toggle.** Callback gives `(Color3, alpha)`.

```lua
sec:ColorPicker(id [, r, g, b, a] [, callback]) -> Widget
```

```lua
sec:Toggle("box_on", "Box ESP")
sec:ColorPicker("box_col", 1, 0, 0, 1, function(color, alpha)
    print(color.R, color.G, color.B, alpha)
end)
```

---

### ColorPicker2

Dual picker. **Must follow a Toggle.** Callback gives `(Color3, a, Color3, a)`.

```lua
sec:ColorPicker2(id1, {r,g,b,a}, id2, {r,g,b,a} [, callback])
```

```lua
sec:Toggle("vis_check", "Visible Check")
sec:ColorPicker2("vis_col", {0,1,0,1}, "invis_col", {1,0,0,1}, function(c1, a1, c2, a2)
    print("Visible: " .. c1.R .. " Invisible: " .. c2.R)
end)
```

---

### InputText

Callback fires **when the field loses focus** (Enter / Escape / click away).

```lua
sec:InputText(id, label [, default] [, callback]) -> Widget
```

```lua
sec:InputText("webhook", "Webhook URL", "", function(text)
    print("Saved: " .. text)
end)
```

---

### Text · Tip · Spacing

```lua
sec:Text("Label text")
sec:Tip("Tooltip on the right side of previous widget")
sec:Spacing()
```

---

## Types

| Widget | Value type |
|---|---|
| Toggle | `bool` |
| SliderInt | `int` |
| SliderFloat | `float` |
| Combo | `int` (0-based) |
| InputText | `string` |
| ColorPicker | `r, g, b, a` |
| Keybind | `bool` |

---

## Callbacks

| Widget | Args | When |
|---|---|---|
| Toggle | `state` | Toggled |
| SliderInt | `value` | Dragging |
| SliderFloat | `value` | Dragging |
| Combo | `index, text` | Changed |
| Button | — | Clicked |
| ColorPicker | `Color3, alpha` | Changed |
| ColorPicker2 | `Color3, a, Color3, a` | Changed |
| InputText | `text` | Lost focus |

---

## Hotkey Overlay

Register a keybind to appear in the on-screen hotkey list.
It only shows when the linked toggle is **ON**.

```lua
sec:Toggle("esp_on", "ESP")
local kb = sec:Keybind("esp_kb", 0x02, "hold")
kb:AddToHotkey("ESP", "esp_on")

-- later:
kb:RemoveFromHotkey()
```

---

## Examples

### Aimbot + ESP

```lua
UI.AddTab("Script", function(tab)
    local aim = tab:Section("Aimbot", "Left", {"Targeting", "Silent"})

    if aim.page == 0 then
        aim:Toggle("aim_on", "Enabled")
        local kb = aim:Keybind("aim_kb", 0x02, "hold")
        kb:AddToHotkey("Aimbot", "aim_on")

        aim:Toggle("aim_tc", "Team Check", true)
        aim:Tip("Ignores teammates")
        aim:Combo("aim_bone", "Hitbox", {"Head", "Torso", "Nearest"}, 0)
        aim:SliderInt("aim_fov", "FOV", 10, 800, 180)
        aim:SliderFloat("aim_smooth", "Smoothing", 0.0, 20.0, 6.0, "%.1f")

    elseif aim.page == 1 then
        aim:Toggle("aim_silent", "Silent Aim")
        local skb = aim:Keybind("aim_skb", 0x04, "hold")
        skb:AddToHotkey("Silent Aim", "aim_silent")
        aim:SliderInt("aim_hc", "Hitchance", 1, 100, 85)
    end

    local gun = tab:Section("Weapon", "Left")
    gun:Toggle("gun_norecoil", "No Recoil")
    gun:Toggle("gun_nospread", "No Spread")
    gun:Toggle("gun_infammo", "Infinite Ammo")

    local esp = tab:Section("ESP", "Right")
    esp:Toggle("esp_on", "Enabled")
    local ekb = esp:Keybind("esp_kb")
    ekb:AddToHotkey("ESP", "esp_on")

    esp:Toggle("esp_box", "Box")
    esp:ColorPicker("esp_boxcol", 1, 0, 0, 1)
    esp:Toggle("esp_vis", "Visible Check")
    esp:ColorPicker2("vis_col", {0,1,0,1}, "invis_col", {1,0,0,1})
    esp:Toggle("esp_name", "Name")
    esp:Toggle("esp_hp", "Health Bar")
    esp:SliderInt("esp_dist", "Distance", 100, 20000, 8000)

    local misc = tab:Section("Misc", "Right")
    misc:InputText("webhook", "Webhook", "", function(text)
        print("Webhook: " .. text)
    end)
    misc:Button("Reset", function()
        UI.SetValue("aim_on", false)
        UI.SetValue("aim_smooth", 6.0)
        UI.SetValue("esp_on", false)
        UI.SetValue("esp_dist", 8000)
    end)
end)
```

### Widget Objects

```lua
UI.AddTab("Demo", function(tab)
    local sec = tab:Section("Objects", "Left")

    local t = sec:Toggle("demo_t", "Toggle")
	local k = sec:Keybind("demo_k", 0x46, "toggle")
    local s = sec:SliderInt("demo_s", "Slider", 0, 100, 50)
    local c = sec:Combo("demo_c", "Combo", {"A", "B", "C"})
    local i = sec:InputText("demo_i", "Input", "hello")

    local actions = tab:Section("Actions", "Right")

    actions:Button("Read All", function()
        print("toggle: " .. tostring(t.value))
        print("slider: " .. s:GetValue())
        print("combo: " .. c:GetText() .. " [" .. c.value .. "]")
        print("input: " .. i.value)
        print("key: " .. k:GetKeyName() .. " [" .. k:GetType() .. "]")
        print("active: " .. tostring(k:IsEnabled()))
    end)

    actions:Button("Write All", function()
        t:SetValue(true)
        s:SetValue(75)
        c:SetValue(2)
        i:SetValue("world")
        k:SetKey(0x47)
        k:SetType("hold")
    end)

    actions:Button("Combo Items", function()
        c:Add("D")
        c:Remove("A")
        local items = c:GetItems()
        for idx, name in ipairs(items) do
            print(idx .. ": " .. name)
        end
    end)
end)
```
