---@type Mq
local mq = require('mq')
require 'ImGui'

local Open, ShowUI = true, true

local gui = {
    item_name = '',
    item_preference = 'Keep',
    item_scope = 'all',
    simulate_name = '',
    check_name = '',
    tribute_mode = 'me',
    selected_config_index = 1,
    config_name = '',
    config_setting = '',
    config_value = '',
    status_message = 'Ready',
}

local CONFIG_TYPES = {
    'category',
    'character',
    'command',
    'condition',
    'helper',
    'preference',
    'rule',
    'setting',
    'subcommand',
}

local ITEM_PREFERENCES = {
    'Keep',
    'Sell',
    'Bank',
    'Guild',
    'Tribute',
    'Buy',
    'Ignore',
    'Destroy',
}

local ITEM_SCOPES = { 'all', 'me' }
local TRIBUTE_MODES = { 'me', 'guild' }

local CONFIG_ACTIONS = {
    category = {
        title = 'Categories',
        list_label = 'List categories',
        name_label = 'Category name',
        name_help = 'Used by Add and Remove. List ignores the name field.',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'add', label = 'Add' },
            { key = 'remove', label = 'Remove' },
        },
    },
    character = {
        title = 'Character settings',
        list_label = nil,
        name_label = 'Character name (optional for Edit)',
        name_help = 'Edit can show the current character file if the name is blank. Set uses Character setting and New value below.',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'edit', label = 'Edit' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    command = {
        title = 'Commands',
        list_label = 'List commands',
        name_label = 'Command name',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'create', label = 'Create' },
            { key = 'delete', label = 'Delete' },
            { key = 'edit', label = 'Edit' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    condition = {
        title = 'Conditions',
        list_label = 'List conditions',
        name_label = 'Condition name',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'create', label = 'Create' },
            { key = 'delete', label = 'Delete' },
            { key = 'edit', label = 'Edit' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    helper = {
        title = 'Helpers',
        list_label = 'List helpers',
        name_label = 'Helper name',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'create', label = 'Create' },
            { key = 'delete', label = 'Delete' },
            { key = 'edit', label = 'Edit' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    preference = {
        title = 'Preferences',
        list_label = 'List preferences',
        name_label = 'Preference name',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'add', label = 'Add' },
            { key = 'remove', label = 'Remove' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    rule = {
        title = 'Rules',
        list_label = 'List rules',
        name_label = 'Rule name',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'add', label = 'Add' },
            { key = 'remove', label = 'Remove' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    setting = {
        title = 'Global settings',
        list_label = nil,
        name_label = 'Unused',
        name_help = 'Edit opens the global settings file. Set uses Setting and Value below.',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'edit', label = 'Edit' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
    subcommand = {
        title = 'Subcommands',
        list_label = 'List subcommands',
        name_label = 'Subcommand name',
        buttons = {
            { key = 'help', label = 'Help' },
            { key = 'list', label = 'List' },
            { key = 'create', label = 'Create' },
            { key = 'delete', label = 'Delete' },
            { key = 'edit', label = 'Edit' },
            { key = 'set', label = 'Set' },
        },
        use_setting_value = true,
    },
}

local function trim(value)
    if type(value) ~= 'string' then
        return ''
    end
    return value:match('^%s*(.-)%s*$') or ''
end

local function quote_if_needed(value)
    value = trim(value)
    if value == '' then
        return value
    end
    return ('"%s"'):format(value)
end

local function run_command(command)
    gui.status_message = ('Last command: /yalm %s'):format(command)
    mq.cmdf('/yalm %s', command)
end

local function combo_from_list(label, current_value, values)
    local current_index = 1
    for i, value in ipairs(values) do
        if value == current_value then
            current_index = i
            break
        end
    end

    local preview = values[current_index] or values[1]
    if ImGui.BeginCombo(label, preview) then
        for i, value in ipairs(values) do
            local is_selected = i == current_index
            if ImGui.Selectable(value, is_selected) then
                current_value = value
                current_index = i
            end
            if is_selected then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end

    return current_value
end

local function combo_index(label, current_index, values)
    local preview = values[current_index] or values[1]
    if ImGui.BeginCombo(label, preview) then
        for i, value in ipairs(values) do
            local is_selected = i == current_index
            if ImGui.Selectable(value, is_selected) then
                current_index = i
            end
            if is_selected then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end
    return current_index
end

local function help_marker(text)
    ImGui.TextDisabled('(?)')
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
        ImGui.TextUnformatted(text)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

local function config_name_tooltip(config_type)
    if config_type == 'category' then
        return [[Category name.

Used by:
- Add
- Remove

Examples:
Class
Tradeskill
Quest

Commands built by this GUI:
category add "Class"
category remove "Tradeskill"]]
    elseif config_type == 'character' then
        return [[Character name to edit.

Examples:
Airale
Boxcleric

Blank name is allowed for Edit and will use the current character.

Commands built by this GUI:
character edit
character edit "Airale"]]
    elseif config_type == 'command' then
        return [[Command module name.

Examples:
SellStuff
DoBank
CleanupLoot

Commands built by this GUI:
command create "SellStuff"
command edit "SellStuff"
command delete "SellStuff"]]
    elseif config_type == 'condition' then
        return [[Condition module name.

Examples:
Scrolls
CanEquip
NeedUpgrade

Commands built by this GUI:
condition create "Scrolls"
condition edit "Scrolls"
condition delete "Scrolls"]]
    elseif config_type == 'helper' then
        return [[Helper module name.

Examples:
GetClassList
BestTarget
MissingSpellOwner

Commands built by this GUI:
helper create "GetClassList"
helper edit "GetClassList"
helper delete "GetClassList"]]
    elseif config_type == 'preference' then
        return [[Preference name.

Examples:
Keep
Sell
Bank
Tribute

Commands built by this GUI:
preference add "Keep"
preference remove "Sell"
preference set <setting> <value>]]
    elseif config_type == 'rule' then
        return [[Rule name.

Examples:
Spells
Tradeskills
ArmorUpgrades

Commands built by this GUI:
rule add "Spells"
rule remove "ArmorUpgrades"
rule set <setting> <value>]]
    elseif config_type == 'setting' then
        return [[Global settings do not use the name field.

Use Edit or Set instead.

Example:
setting edit
setting set frequency 3]]
    elseif config_type == 'subcommand' then
        return [[Subcommand module name.

Examples:
Add
Edit
Delete

Commands built by this GUI:
subcommand create "Add"
subcommand edit "Edit"
subcommand delete "Delete"]]
    end

    return [[Enter the name used by the selected configuration type.]]
end

local function config_setting_tooltip(config_type)
    if config_type == 'character' then
        return [[Character setting name to change.

Known examples:
frequency
save_slots
always_loot
unmatched_item_rule

Example:
Character setting = frequency
New value = 3]]
    elseif config_type == 'command' then
        return [[Field name inside the selected command entry.

Examples:
loaded
filename
enabled

The exact valid fields depend on how YALM stores that type.

Command built by this GUI:
command set <setting> <value>]]
    elseif config_type == 'condition' then
        return [[Field name inside the selected condition entry.

Examples:
loaded
filename
enabled

The exact valid fields depend on the condition data structure.

Command built by this GUI:
condition set <setting> <value>]]
    elseif config_type == 'helper' then
        return [[Field name inside the selected helper entry.

Examples:
loaded
filename
enabled

The exact valid fields depend on the helper data structure.

Command built by this GUI:
helper set <setting> <value>]]
    elseif config_type == 'preference' then
        return [[Preference field name to change.

Common examples in YALM preference objects:
setting
quantity
list

Example:
Preference name = Keep
Setting = quantity
Value = 10]]
    elseif config_type == 'rule' then
        return [[Rule field name to change.

Common examples:
category
conditions
items
name

Example:
Rule name = Spells
Setting = category
Value = Scrolls]]
    elseif config_type == 'setting' then
        return [[Global setting name to change.

Known examples visible in the GUI:
frequency
save_slots
always_loot
unmatched_item_rule

Example:
setting set frequency 3]]
    elseif config_type == 'subcommand' then
        return [[Field name inside the selected subcommand entry.

Examples:
loaded
filename
enabled

The exact valid fields depend on the subcommand data structure.

Command built by this GUI:
subcommand set <setting> <value>]]
    end

    return [[Enter the field name to change for the selected type.]]
end

local function config_value_tooltip(config_type)
    if config_type == 'character' then
        return [[New value for the selected character setting.

Examples:
frequency = 3
save_slots = true
always_loot = false
unmatched_item_rule = Keep

Use:
- numbers for numeric settings
- true/false for boolean settings
- text for rule names or preferences]]
    elseif config_type == 'command' then
        return [[New value for the selected command field.

Examples:
true
false
mycommand.lua
1

The exact valid value depends on the selected field.]]
    elseif config_type == 'condition' then
        return [[New value for the selected condition field.

Examples:
true
false
Scrolls.lua
1

The exact valid value depends on the selected field.]]
    elseif config_type == 'helper' then
        return [[New value for the selected helper field.

Examples:
true
false
GetClassList.lua
1

The exact valid value depends on the selected field.]]
    elseif config_type == 'preference' then
        return [[New value for the selected preference field.

Examples:
setting = Keep
quantity = 10
list = Scrolls

Use text, numbers, or booleans depending on the field.]]
    elseif config_type == 'rule' then
        return [[New value for the selected rule field.

Examples:
category = Scrolls
name = Spells
conditions = Scrolls

The exact valid value depends on the field you are changing.]]
    elseif config_type == 'setting' then
        return [[New value for the selected global setting.

Examples:
frequency = 3
save_slots = true
always_loot = false
unmatched_item_rule = Keep]]
    elseif config_type == 'subcommand' then
        return [[New value for the selected subcommand field.

Examples:
true
false
Edit.lua
1

The exact valid value depends on the selected field.]]
    end

    return [[Enter the new value for the selected field.]]
end

local function draw_status(state, global_settings)
    if not ImGui.CollapsingHeader('Status', ImGuiTreeNodeFlags.DefaultOpen) then
        return
    end

    ImGui.Text(('Version: %s'):format(state.version or 'unknown'))
    ImGui.Text(('Terminate flag: %s'):format(tostring(state.terminate)))
    ImGui.Text(('Command running: %s'):format(state.command_running or 'none'))

    if global_settings and global_settings.settings then
        ImGui.Separator()
        ImGui.Text('Runtime settings')
        ImGui.BulletText(('frequency: %s'):format(tostring(global_settings.settings.frequency)))
        ImGui.BulletText(('save_slots: %s'):format(tostring(global_settings.settings.save_slots)))
        ImGui.BulletText(('always_loot: %s'):format(tostring(global_settings.settings.always_loot)))
        ImGui.BulletText(('unmatched_item_rule: %s'):format(tostring(global_settings.settings.unmatched_item_rule)))
    end

    ImGui.Separator()
    ImGui.TextWrapped(gui.status_message)
end

local function draw_general_commands()
    if not ImGui.CollapsingHeader('General', ImGuiTreeNodeFlags.DefaultOpen) then
        return
    end

    if ImGui.Button('Help##general') then
        run_command('help')
    end
    ImGui.SameLine()
    if ImGui.Button('Reload##general') then
        run_command('reload')
    end
end

local function draw_item_tools()
    if not ImGui.CollapsingHeader('Item tools', ImGuiTreeNodeFlags.DefaultOpen) then
        return
    end

    ImGui.SeparatorText('Set item preference')
    gui.item_name, _ = ImGui.InputText('Item name##setitem', gui.item_name)
    gui.item_preference = combo_from_list('Preference##setitem', gui.item_preference, ITEM_PREFERENCES)
    gui.item_scope = combo_from_list('Scope##setitem', gui.item_scope, ITEM_SCOPES)

    if ImGui.Button('Run setitem##item') then
        local item_name = trim(gui.item_name)
        if item_name ~= '' then
            run_command(('setitem %s %s %s'):format(quote_if_needed(item_name), gui.item_preference, gui.item_scope))
        else
            gui.status_message = 'Set item skipped: enter an item name first.'
        end
    end

    ImGui.SeparatorText('Check preferences')
    ImGui.TextWrapped('Use Check inventory for everything in bags. Use Check named item for one database item.')
    gui.check_name, _ = ImGui.InputText('Named item##check', gui.check_name)

    if ImGui.Button('Check named item##check') then
        local item_name = trim(gui.check_name)
        if item_name ~= '' then
            run_command(('check %s'):format(quote_if_needed(item_name)))
        else
            gui.status_message = 'Check skipped: enter an item name first.'
        end
    end
    ImGui.SameLine()
    if ImGui.Button('Check inventory##check') then
        run_command('check')
    end

    ImGui.SeparatorText('Simulate looting')
    gui.simulate_name, _ = ImGui.InputText('Item name##simulate', gui.simulate_name)
    if ImGui.Button('Simulate named item##simulate') then
        local item_name = trim(gui.simulate_name)
        if item_name ~= '' then
            run_command(('simulate %s'):format(quote_if_needed(item_name)))
        else
            gui.status_message = 'Simulate skipped: enter an item name first.'
        end
    end
end

local function draw_npc_tools()
    if not ImGui.CollapsingHeader('NPC tools', ImGuiTreeNodeFlags.DefaultOpen) then
        return
    end

    if ImGui.Button('Buy##npc') then
        run_command('buy')
    end
    ImGui.SameLine()
    if ImGui.Button('Sell##npc') then
        run_command('sell')
    end
    ImGui.SameLine()
    if ImGui.Button('Bank##npc') then
        run_command('bank')
    end

    if ImGui.Button('Guild bank##npc') then
        run_command('guild')
    end

    gui.tribute_mode = combo_from_list('Tribute mode##npc', gui.tribute_mode, TRIBUTE_MODES)
    if ImGui.Button('Tribute##npc') then
        run_command(('tribute %s'):format(gui.tribute_mode))
    end
end

local function validate_config_action(config_type, action_key)
    local name = trim(gui.config_name)
    local setting = trim(gui.config_setting)
    local value = trim(gui.config_value)

    if action_key == 'help' then
        return true, ('%s help'):format(config_type)
    end

    if action_key == 'list' then
        return true, ('%s list'):format(config_type)
    end

    if action_key == 'edit' then
        if config_type == 'character' then
            if name ~= '' then
                return true, ('%s edit %s'):format(config_type, quote_if_needed(name))
            end
            return true, ('%s edit'):format(config_type)
        end
        if config_type == 'setting' then
            return true, ('%s edit'):format(config_type)
        end
        if name == '' then
            return false, 'Edit skipped: enter a name first.'
        end
        return true, ('%s edit %s'):format(config_type, quote_if_needed(name))
    end

    if action_key == 'set' then
        if setting == '' then
            return false, 'Set skipped: enter a setting first.'
        end
        if value == '' then
            return false, 'Set skipped: enter a value first.'
        end
        return true, ('%s set %s %s'):format(config_type, setting, quote_if_needed(value))
    end

    if action_key == 'add' or action_key == 'remove' or action_key == 'create' or action_key == 'delete' then
        if name == '' then
            return false, ('%s skipped: enter a name first.'):format(action_key:gsub('^%l', string.upper))
        end
        return true, ('%s %s %s'):format(config_type, action_key, quote_if_needed(name))
    end

    return false, 'Unsupported action.'
end

local function draw_action_button(config_type, action)
    if ImGui.Button(('%s##%s_%s'):format(action.label, config_type, action.key)) then
        local ok, result = validate_config_action(config_type, action.key)
        if ok then
            run_command(result)
        else
            gui.status_message = result
        end
    end
end

local function draw_config_tools()
    if not ImGui.CollapsingHeader('Configuration tools', ImGuiTreeNodeFlags.DefaultOpen) then
        return
    end

    gui.selected_config_index = combo_index('Type##config', gui.selected_config_index, CONFIG_TYPES)
    local config_type = CONFIG_TYPES[gui.selected_config_index]
    local meta = CONFIG_ACTIONS[config_type]

    ImGui.SeparatorText(meta.title)

    if meta.list_label then
        ImGui.TextWrapped(meta.list_label)
    end

    gui.config_name, _ = ImGui.InputText((meta.name_label or 'Name') .. '##config_name', gui.config_name)
    ImGui.SameLine()
    help_marker(config_name_tooltip(config_type))

    if meta.name_help and trim(meta.name_help) ~= '' then
        ImGui.TextWrapped(meta.name_help)
    end

    if meta.use_setting_value then
        local setting_label = 'Setting##config_setting'
        local value_label = 'Value##config_value'

        if config_type == 'character' then
            setting_label = 'Character setting##config_setting'
            value_label = 'New value##config_value'
        end

        gui.config_setting, _ = ImGui.InputText(setting_label, gui.config_setting)
        ImGui.SameLine()
        help_marker(config_setting_tooltip(config_type))

        gui.config_value, _ = ImGui.InputText(value_label, gui.config_value)
        ImGui.SameLine()
        help_marker(config_value_tooltip(config_type))
    end

    local buttons = meta.buttons or {}
    for i, action in ipairs(buttons) do
        draw_action_button(config_type, action)
        if i < #buttons then
            ImGui.SameLine()
        end
    end

    ImGui.Separator()
    if config_type == 'category' then
        ImGui.TextWrapped('Category uses add and remove, not create and delete.')
    elseif config_type == 'character' then
        ImGui.TextWrapped('Character settings let you edit a character config file or set a specific character setting and value.')
    elseif config_type == 'command' then
        ImGui.TextWrapped('Commands support Help, List, Create, Delete, Edit, and Set.')
    elseif config_type == 'condition' then
        ImGui.TextWrapped('Conditions support Help, List, Create, Delete, Edit, and Set.')
    elseif config_type == 'helper' then
        ImGui.TextWrapped('Helpers support Help, List, Create, Delete, Edit, and Set.')
    elseif config_type == 'preference' then
        ImGui.TextWrapped('Preferences support Help, List, Add, Remove, and Set.')
    elseif config_type == 'rule' then
        ImGui.TextWrapped('Rules support Help, List, Add, Remove, and Set.')
    elseif config_type == 'setting' then
        ImGui.TextWrapped('Global settings support Help, Edit, and Set. They do not use the name field.')
    elseif config_type == 'subcommand' then
        ImGui.TextWrapped('Subcommands support Help, List, Create, Delete, Edit, and Set.')
    else
        ImGui.TextWrapped('Use Help to see the exact syntax that YALM supports for the selected type.')
    end
end

local function render(state, global_settings)
    if Open then
        Open, ShowUI = ImGui.Begin('YALM GUI by CANNONBALLDEX', Open)
        if ShowUI then
            draw_general_commands()
            draw_item_tools()
            draw_npc_tools()
            draw_config_tools()
            draw_status(state, global_settings)
        end
        ImGui.End()
    end
end

function gui.init(state_ref, settings_ref)
    mq.bind('/yalmgui', function(...)
        local args = { ... }
        local action = args[1]

        if action == 'show' then
            Open = true
        elseif action == 'hide' then
            Open = false
        else
            Open = not Open
        end
    end)

    mq.imgui.init('yalm_gui', function()
        render(state_ref, settings_ref())
    end)
end

return gui