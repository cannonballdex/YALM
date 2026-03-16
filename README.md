Yet Another Loot Manager (YALM)

YOU WILL NEED THE items.db file at https://drive.google.com/file/d/1F4MpdCi5euOsS0DJfNJBWqz3tOYdNURf/view?usp=drive_link
Place the items.db file inside your YALM folder.

Yet Another Loot Manager (YALM) is an automated loot management system for MacroQuest.
It controls how characters loot items using the Advanced Loot (AdvLoot) system in EverQuest.

YALM allows you to:

Automatically decide who should loot items

Create configurable loot rules

Manage categories and preferences

Use conditions and helpers for advanced logic

Support groups, raids, and DanNet-connected characters

Query a local SQLite item database

The project is modular and extensible, allowing users to create custom commands, conditions, and helpers.

Features

Automated Advanced Loot handling

Group and raid loot distribution

Character-specific loot rules

Category and preference management

Modular configuration system

SQLite item database lookup

DanNet support for remote character queries

Extensible helper and condition system

GUI support via ImGui

Requirements

Before using YALM you must have:

Required

MacroQuest

Lua plugin enabled

Advanced Loot enabled in EverQuest

SQLite3 Lua module

LuaFileSystem

These dependencies are automatically installed if you use MacroQuest's PackageMan.

Optional

DanNet plugin (for querying group members remotely)

Installation

Navigate to your MacroQuest lua directory:

MacroQuest/lua/

Copy the yalm folder into that directory:

MacroQuest/lua/yalm/

Ensure the following files exist:

lua/
 └── yalm/
     ├── config/
     ├── core/
     ├── definitions/
     ├── lib/
     ├── templates/
     ├── gui.lua
     ├── init.lua
     ├── items.db
     └── README.md

Start the script in MacroQuest:

/lua run yalm
How It Works

YALM runs continuously while you are in-game.

The main loop:

Loads configuration files

Registers commands and conditions

Monitors the Advanced Loot window

Evaluates each item

Determines who should loot it

Loot decisions use:

character settings

rules

conditions

helpers

inventory checks

database item information

Basic Commands

All commands use the /yalm prefix.

Show help
/yalm help

Displays available commands and configuration options.

Reload YALM
/yalm reload

Reloads the script and configuration.

Configuration System

Configuration files are stored inside:

yalm/config/

Configuration is divided into several categories:

Type	Description
commands	Custom commands
conditions	Logic used when evaluating items
helpers	Utility functions used by rules
rules	Loot decision rules
categories	Item grouping
preferences	Player loot preferences
Creating Custom Modules

YALM uses template files to generate new modules.

Templates are stored in:

yalm/templates/

You can create:

commands

conditions

helpers

Create a New Module

Example:

/yalm create command mycommand

This creates:

config/commands/mycommand.lua

based on the template:

templates/Command.lua
Command Template

Example command module:

---@type Mq
local mq = require("mq")

local function action(global_settings, char_settings, args)
    -- your logic here
end

return { action_func = action }
Condition Template

Conditions evaluate whether an item matches criteria.

Example:

---@type Mq
local mq = require("mq")

local function condition(item)
    return true
end

return { condition_func = condition }

Conditions return:

true  -> condition passes
false -> condition fails
Helper Template

Helpers return data used by rules.

Example:

---@type Mq
local mq = require("mq")

local function helper(item)
    return true
end

return { helper_func = helper }
Item Database

YALM includes a SQLite database:

items.db

This database stores EverQuest item data.

Example usage:

Database.QueryDatabaseForItemId(item_id)

This allows rules and conditions to access item metadata.

Core Components
Looting Engine

Located in:

core/looting.lua

Handles:

solo looting

group master looting

personal loot

Inventory Checks
core/inventory.lua

Determines:

if a character already has the item

if inventory space is available

if a class can use the item

Evaluation System
core/evaluate.lua

Responsible for determining:

Can this character loot this item?

It evaluates:

rules

inventory

preferences

group membership

Loader System
core/loader.lua

Dynamically loads configuration modules such as:

commands

helpers

conditions

This allows modules to be edited without restarting MacroQuest.

GUI

YALM includes an ImGui interface.

The GUI module is located here:

gui.lua

It displays configuration and runtime status.

Logging System

Logging is handled by:

lib/Write.lua

Example output:

[YALM] :: Item assigned to player

Log levels include:

trace

debug

info

warn

error

fatal

File Structure
yalm
│
├── config
│   ├── commands
│   ├── conditions
│   ├── helpers
│   ├── rules
│   └── subcommands
│
├── core
│   ├── evaluate.lua
│   ├── inventory.lua
│   ├── looting.lua
│   └── loader.lua
│
├── definitions
│   ├── Classes.lua
│   ├── Item.lua
│   ├── ItemTypes.lua
│   └── InventorySlots.lua
│
├── lib
│   ├── database.lua
│   ├── dannet.lua
│   ├── utils.lua
│   └── Write.lua
│
├── templates
│   ├── Command.lua
│   ├── Condition.lua
│   └── Helper.lua
│
├── gui.lua
├── init.lua
├── items.db
└── README.md
Troubleshooting
Script exits immediately

Check that Advanced Loot is enabled:

Alt + O → Loot → Use Advanced Looting
SQLite errors

Make sure MacroQuest installed the package:

lsqlite3

If not, reinstall dependencies with PackageMan.

Commands not working

Reload YALM:

/yalm reload
Contributing

Contributions are welcome.

Recommended guidelines:

Follow the existing module structure

Keep helpers small and reusable

Avoid hardcoding item IDs when possible

Document new rules or conditions

USER MANUAL

YALM User Guide — Configuring Loot Rules

This guide explains how to configure loot rules in Yet Another Loot Manager (YALM).

Loot rules determine who receives items when they appear in the Advanced Loot window.

YALM evaluates each item and decides:

Should I loot this item?
Who should loot it?
Should it be ignored?

Rules allow you to fully automate this process.

How Loot Decisions Work

When an item appears in the Advanced Loot window, YALM evaluates it using the following steps:

Check if the item matches a rule

Evaluate any conditions

Use helpers to gather extra information

Check character preferences

Check inventory and equipment

Assign the item to a player

The system can work with:

solo characters

groups

raids

DanNet-connected characters

Where Rules Are Stored

Loot rules are stored in:

yalm/config/rules/

Each file in this directory defines one rule.

Example:

config/rules/loot-spells.lua
config/rules/loot-tradeskills.lua
config/rules/loot-upgrades.lua

You can create as many rules as you want.

Basic Rule Structure

A simple rule looks like this:

return {
    name = "loot-spells",

    item = {
        name = "Spell:"
    },

    action = "loot"
}

Explanation:

Field	Meaning
name	name of the rule
item	how to match items
action	what to do when matched
Rule Evaluation Order

Rules are evaluated in order.

The first rule that matches the item will be used.

Example:

1. upgrade gear
2. spells
3. tradeskill items
4. vendor trash

Once a rule matches, evaluation stops.

Matching Items

Rules match items using fields inside the item section.

Example:

item = {
    name = "Spell:"
}

This matches any item whose name contains:

Spell:

Example items:

Spell: Ice Comet
Spell: Complete Heal
Spell: Torpor
Matching Exact Items

You can match an exact item name.

Example:

item = {
    name = "Golden Efreeti Boots"
}

Only that specific item will match.

Matching Multiple Items

You can match multiple items using a list.

Example:

item = {
    name = {
        "Golden Efreeti Boots",
        "Cloak of Flames",
        "Fungi Tunic"
    }
}
Matching Item Types

You can match by item type.

Example:

item = {
    type = "Spell"
}

Possible types include:

Spell
Armor
Weapon
Container
Food
Drink
Augmentation
Tradeskill
Using Categories

Categories group items together.

Example categories might include:

spells
tradeskills
gear
vendor-trash
collectibles

Example rule:

item = {
    category = "tradeskills"
}

Categories are defined in:

config/categories/
Actions

Rules must specify an action.

Common actions include:

Action	Meaning
loot	loot the item
ignore	ignore the item
leave	leave the item in the loot window

Example:

action = "loot"
Assigning Items to a Specific Character

You can force a specific character to receive an item.

Example:

action = {
    type = "assign",
    character = "Clericbot"
}

Now the item will always go to Clericbot.

Group Upgrade Rules

One of the most common uses is automatically looting gear upgrades.

Example:

return {
    name = "gear-upgrades",

    item = {
        type = "Armor"
    },

    condition = "upgrade",

    action = "loot"
}

The condition checks:

Is this item better than what the character is wearing?

If yes, the item is looted.

Using Conditions

Conditions allow more advanced logic.

Example:

condition = "can-equip"

This checks:

Can this character equip this item?

If the character cannot equip it, the rule fails.

Common Conditions
Condition	Purpose
can-equip	character can equip item
upgrade	item is an upgrade
inventory-space	inventory has room
not-owned	character does not already have item

Example:

condition = {
    "can-equip",
    "upgrade"
}

Both conditions must pass.

Using Helpers

Helpers provide extra data used by rules.

Example helpers might check:

group class distribution
raid membership
inventory duplicates
item rarity

Example rule using a helper:

helper = "group-needs-item"

This helper might check if another group member needs the item.

Tradeskill Example Rule

Example rule for looting tradeskill items.

return {
    name = "loot-tradeskills",

    item = {
        category = "tradeskills"
    },

    action = {
        type = "assign",
        character = "Tradeskillbot"
    }
}

All tradeskill items go to Tradeskillbot.

Vendor Trash Rule

Automatically loot vendor items.

return {
    name = "vendor-trash",

    item = {
        value = ">5"
    },

    action = "loot"
}

Meaning:

Loot items worth more than 5 platinum.
Ignoring Items

Example rule to ignore junk items.

return {
    name = "ignore-trash",

    item = {
        name = {
            "Bat Wing",
            "Spiderling Eye"
        }
    },

    action = "ignore"
}
Example Complete Setup

Example rule set:

rules/
 ├─ upgrades.lua
 ├─ spells.lua
 ├─ tradeskills.lua
 ├─ vendor.lua
 └─ ignore.lua

Evaluation order:

1 upgrades
2 spells
3 tradeskills
4 vendor trash
5 ignore
Reloading Rules

After editing rules, reload YALM:

/yalm reload

This loads all rule changes without restarting MacroQuest.

Testing Rules

To test rules:

Kill a mob

Open the Advanced Loot window

Watch YALM logs

Example log output:

[YALM] Evaluating item: Golden Efreeti Boots
[YALM] Rule matched: gear-upgrades
[YALM] Assigned to: Warriorbot
Best Practices

Recommended practices:

Keep rules simple

Avoid large complicated rules.

Break them into smaller rules.

Use categories

Categories reduce repetition.

Example:

category = "spells"

instead of listing every spell.

Test with a small group

Verify rules with 1–2 characters before using them in raids.

Order matters

Put important rules first.

Example:

upgrades
spells
tradeskills
vendor trash
Troubleshooting
Item not looted

Check:

Did a rule match the item?

Look in logs.

Wrong character received item

Check:

assignment rules
upgrade conditions
group helpers
Rule not triggering

Verify:

item name
category
condition spelling
Next Steps

Advanced users can extend YALM by creating:

custom helpers

custom conditions

custom commands

See:

templates/

for starting examples.

YALM Advanced Rule Writing Guide

This guide explains how to create advanced loot rules in Yet Another Loot Manager (YALM).

Advanced rules allow you to:

dynamically assign loot

detect upgrades

route items to specific characters

balance loot across a group

prioritize gear improvements

create intelligent vendor trash logic

prevent duplicate items

These rules rely on:

conditions

helpers

item properties

rule priority

How Rule Evaluation Works Internally

Every time an item appears in the Advanced Loot window, YALM performs this sequence:

1. load item data
2. evaluate rules in order
3. run rule conditions
4. run helper functions
5. determine best character
6. assign loot

The first rule that returns a valid action wins.

Because of this, rule order is extremely important.

Example order:

1 upgrades
2 missing spells
3 tradeskills
4 collectibles
5 vendor trash
Advanced Rule Structure

A full rule can include several fields:

return {
    name = "gear-upgrade",

    item = {
        type = "Armor",
        requiredlevel = ">50"
    },

    condition = {
        "can-equip",
        "upgrade"
    },

    helper = "best-upgrade-target",

    action = {
        type = "assign"
    }
}

Fields available:

Field	Purpose
name	rule identifier
item	item filters
condition	logic tests
helper	helper functions
action	final loot decision
Advanced Item Filtering

Rules can filter items by multiple properties.

Example:

item = {
    type = "Armor",
    reclevel = ">60",
    value = ">100"
}

Meaning:

Armor
recommended level above 60
value greater than 100 platinum
Comparison Operators

Filters support comparisons.

Operator	Meaning
>	greater than
<	less than
>=	greater or equal
<=	less or equal
=	exact match

Example:

value = ">200"

Matches items worth more than 200pp.

Matching Multiple Conditions

You can match multiple properties at once.

Example:

item = {
    type = "Weapon",
    damage = ">20",
    delay = "<30"
}

Meaning:

weapon
damage above 20
delay faster than 30
Using Item Methods

Your rules can reference any method from Item.lua.

Examples:

Item:Damage()
Item:Delay()
Item:HP()
Item:HeroicSTR()
Item:WornSlot()
Item:Tradeskills()
Item:Type()
Item:Value()

These allow extremely flexible rule logic.

Example: Gear Upgrade Rule

A rule that distributes gear upgrades automatically.

return {

    name = "gear-upgrade",

    item = {
        type = "Armor"
    },

    condition = {
        "can-equip",
        "upgrade"
    },

    helper = "best-upgrade-target",

    action = {
        type = "assign"
    }

}

What happens:

1 item is armor
2 group members who can equip it are checked
3 upgrade value calculated
4 best upgrade target receives item
Example: Class-Specific Loot

Send certain items to specific classes.

Example: give healing gear to clerics.

return {

    name = "cleric-healing",

    item = {
        healamt = ">50"
    },

    condition = "class:CLR",

    action = {
        type = "assign",
        class = "CLR"
    }

}
Example: Spell Distribution

Automatically distribute spells.

return {

    name = "spell-distribution",

    item = {
        type = "Spell"
    },

    helper = "character-missing-spell",

    action = {
        type = "assign"
    }

}

Logic:

Find group member missing spell
Assign item to that player
Example: Prevent Duplicate Loot

Stop characters from looting duplicate items.

return {

    name = "no-duplicates",

    condition = "not-owned",

    action = "loot"

}

Meaning:

only loot item if character does not already have it
Advanced Helper Usage

Helpers provide advanced decision logic.

Helpers can:

scan group inventory
check spell books
calculate gear upgrades
determine best class for item

Example:

helper = "group-needs-item"

The helper returns the best target.

Weighted Upgrade System

Some users implement upgrade scoring.

Example:

stat score
AC value
heroic stats
focus effects

Upgrade score example:

score = HP + AC + heroic stats

Rule:

helper = "highest-upgrade-score"

This assigns the item to the character who gains the most value.

Raid Loot Logic

Raid groups require special rules.

Example:

return {

    name = "raid-upgrades",

    item = {
        reclevel = ">100"
    },

    helper = "raid-best-upgrade",

    action = {
        type = "assign"
    }

}

The helper scans all raid members.

Smart Vendor Looting

Example rule for vendor trash:

return {

    name = "vendor-loot",

    item = {
        value = ">20"
    },

    condition = "inventory-space",

    action = "loot"
}

Meaning:

loot vendor items worth more than 20pp
only if inventory space exists
Intelligent Tradeskill Routing

Send tradeskill items to a crafting character.

return {

    name = "tradeskill-routing",

    item = {
        tradeskills = true
    },

    action = {
        type = "assign",
        character = "Crafter"
    }

}
Collectible Handling

Example:

return {

    name = "collectibles",

    item = {
        collectible = true
    },

    helper = "missing-collectible",

    action = {
        type = "assign"
    }

}

Meaning:

find player missing collectible
assign item
Rule Priority Strategy

Best rule ordering:

1 upgrade gear
2 missing spells
3 missing collectibles
4 tradeskills
5 vendor trash
6 ignore junk

This prevents valuable items from being caught by lower rules.

Debugging Advanced Rules

Enable debug logging.

Example output:

[YALM] evaluating item: Cloak of Flames
[YALM] rule matched: gear-upgrade
[YALM] helper returned: Warriorbot
[YALM] assigning item
Performance Considerations

Advanced rules run often.

Avoid:

large loops
heavy database queries
complex string matching

Better approach:

use categories
cache item properties
use helpers
Common Power-User Tricks
Hybrid upgrade rules

Check both armor and weapons:

type = {"Armor","Weapon"}
Auto-distribute stack items

Example:

bone chips
spider silk
pelts
Detect augment upgrades

Example rule:

augtype
heroic stats
focus effects
Prioritize tank gear

Example:

AC > HP
Recommended Advanced Rule Set

A strong endgame rule set usually includes:

gear-upgrades.lua
spell-distribution.lua
collectibles.lua
tradeskills.lua
vendor.lua
ignore.lua
When to Create Helpers

Create helpers when rules require:

group comparisons
upgrade scoring
inventory scanning
spell detection
class balancing

Helpers keep rules simple and readable.

Final Advice

Good rule systems are:

simple
ordered
predictable
easy to debug

Avoid overly complicated logic inside a single rule.

Credits

Original Author
fuddles

GUI Implementation
Cannonballdex
