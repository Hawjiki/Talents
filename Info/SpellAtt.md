# Spell Attribute Bitmask Reference

Reference tables for spell attribute flags in World of Warcraft: Wrath of the Lich King 3.3.5a (build 12340). Flag names and notes are preserved from the supplied reference.

## Contents

- [Attributes](#attributes)
- [AttributesEx](#attributesex)
- [AttributesEx2](#attributesex2)
- [AttributesEx3](#attributesex3)
- [AttributesEx4](#attributesex4)
- [AttributesEx5](#attributesex5)
- [AttributesEx6](#attributesex6)
- [AttributesEx7](#attributesex7)

## Attributes

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `Attributes` | 0 | 1 | `0x00000001` | `SPELL_ATTR0_UNK0` | Unknown attribute 0\@Attr0 |
| `Attributes` | 1 | 2 | `0x00000002` | `SPELL_ATTR0_REQ_AMMO` | Treat as ranged attack — Use ammo, ranged attack range modifiers, ranged haste, etc. |
| `Attributes` | 2 | 4 | `0x00000004` | `SPELL_ATTR0_ON_NEXT_SWING` | On next melee (type 1) — Both "on next swing" attributes have identical handling in server & client |
| `Attributes` | 3 | 8 | `0x00000008` | `SPELL_ATTR0_IS_REPLENISHMENT` | Replenishment (client only) |
| `Attributes` | 4 | 16 | `0x00000010` | `SPELL_ATTR0_ABILITY` | Treat as ability — Cannot be reflected, not affected by cast speed modifiers, etc. |
| `Attributes` | 5 | 32 | `0x00000020` | `SPELL_ATTR0_TRADESPELL` | Trade skill recipe — Displayed in recipe list, not affected by cast speed modifiers |
| `Attributes` | 6 | 64 | `0x00000040` | `SPELL_ATTR0_PASSIVE` | Passive spell — Spell is automatically cast on self by core |
| `Attributes` | 7 | 128 | `0x00000080` | `SPELL_ATTR0_HIDDEN_CLIENTSIDE` | Hidden in UI (client only) — Not visible in spellbook or aura bar |
| `Attributes` | 8 | 256 | `0x00000100` | `SPELL_ATTR0_HIDE_IN_COMBAT_LOG` | Hidden in combat log (client only) — Spell will not appear in combat logs |
| `Attributes` | 9 | 512 | `0x00000200` | `SPELL_ATTR0_TARGET_MAINHAND_ITEM` | Auto-target mainhand item (client only) — Client will automatically select main-hand item as cast target |
| `Attributes` | 10 | 1024 | `0x00000400` | `SPELL_ATTR0_ON_NEXT_SWING_2` | On next melee (type 2) — Both "on next swing" attributes have identical handling in server & client |
| `Attributes` | 11 | 2048 | `0x00000800` | `SPELL_ATTR0_UNK11` | Unknown attribute 11\@Attr0 |
| `Attributes` | 12 | 4096 | `0x00001000` | `SPELL_ATTR0_DAYTIME_ONLY` | Only usable during daytime (unused) |
| `Attributes` | 13 | 8192 | `0x00002000` | `SPELL_ATTR0_NIGHT_ONLY` | Only usable during nighttime (unused) |
| `Attributes` | 14 | 16384 | `0x00004000` | `SPELL_ATTR0_INDOORS_ONLY` | Only usable indoors |
| `Attributes` | 15 | 32768 | `0x00008000` | `SPELL_ATTR0_OUTDOORS_ONLY` | Only usable outdoors |
| `Attributes` | 16 | 65536 | `0x00010000` | `SPELL_ATTR0_NOT_SHAPESHIFT` | Not usable while shapeshifted |
| `Attributes` | 17 | 131072 | `0x00020000` | `SPELL_ATTR0_ONLY_STEALTHED` | Only usable in stealth |
| `Attributes` | 18 | 262144 | `0x00040000` | `SPELL_ATTR0_DONT_AFFECT_SHEATH_STATE` | Don't shealthe weapons (client only) |
| `Attributes` | 19 | 524288 | `0x00080000` | `SPELL_ATTR0_LEVEL_DAMAGE_CALCULATION` | Scale with caster level — For non-player casts, scale impact and power cost with caster's level |
| `Attributes` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR0_STOP_ATTACK_TARGET` | Stop attacking after cast — After casting this, the current auto-attack will be interrupted |
| `Attributes` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR0_IMPOSSIBLE_DODGE_PARRY_BLOCK` | Prevent physical avoidance — Spell cannot be dodged, parried or blocked |
| `Attributes` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR0_CAST_TRACK_TARGET` | Automatically face target during cast (client only) |
| `Attributes` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR0_CASTABLE_WHILE_DEAD` | Can be cast while dead — Spells without this flag cannot be cast by dead units in non-triggered contexts |
| `Attributes` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR0_CASTABLE_WHILE_MOUNTED` | Can be cast while mounted |
| `Attributes` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR0_DISABLED_WHILE_ACTIVE` | Cooldown starts on expiry — Spell is unusable while already active, and cooldown does not begin until the effects have worn off |
| `Attributes` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR0_NEGATIVE_1` | Is negative spell — Forces the spell to be treated as a negative spell |
| `Attributes` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR0_CASTABLE_WHILE_SITTING` | Can be cast while sitting |
| `Attributes` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR0_CANT_USED_IN_COMBAT` | Cannot be used in combat |
| `Attributes` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR0_UNAFFECTED_BY_INVULNERABILITY` | Pierce invulnerability — Allows spell to pierce invulnerability, unless the invulnerability spell also has this attribute |
| `Attributes` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR0_HEARTBEAT_RESIST_CHECK` | Periodic resistance checks — Periodically re-rolls against resistance to potentially expire aura early |
| `Attributes` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR0_CANT_CANCEL` | Aura cannot be cancelled — Prevents the player from voluntarily canceling a positive aura |

## AttributesEx

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx` | 0 | 1 | `0x00000001` | `SPELL_ATTR1_DISMISS_PET` | Dismiss Pet on cast — Without this attribute, summoning spells will fail if caster already has a pet |
| `AttributesEx` | 1 | 2 | `0x00000002` | `SPELL_ATTR1_DRAIN_ALL_POWER` | Drain all power — Ignores listed power cost and drains entire pool instead |
| `AttributesEx` | 2 | 4 | `0x00000004` | `SPELL_ATTR1_CHANNELED_1` | Channeled (type 1) — Both "channeled" attributes have identical handling in server & client |
| `AttributesEx` | 3 | 8 | `0x00000008` | `SPELL_ATTR1_CANT_BE_REDIRECTED` | Ignore redirection effects — Spell will not be attracted by SPELL_MAGNET auras (Grounding Totem) |
| `AttributesEx` | 4 | 16 | `0x00000010` | `SPELL_ATTR1_UNK4` | Unknown attribute 4\@Attr1 |
| `AttributesEx` | 5 | 32 | `0x00000020` | `SPELL_ATTR1_NOT_BREAK_STEALTH` | Does not break stealth |
| `AttributesEx` | 6 | 64 | `0x00000040` | `SPELL_ATTR1_CHANNELED_2` | Channeled (type 2) — Both "channeled" attributes have identical handling in server & client |
| `AttributesEx` | 7 | 128 | `0x00000080` | `SPELL_ATTR1_CANT_BE_REFLECTED` | Ignore reflection effects — Spell will pierce through Spell Reflection and similar |
| `AttributesEx` | 8 | 256 | `0x00000100` | `SPELL_ATTR1_CANT_TARGET_IN_COMBAT` | Target cannot be in combat |
| `AttributesEx` | 9 | 512 | `0x00000200` | `SPELL_ATTR1_MELEE_COMBAT_START` | Starts auto-attack (client only) — Caster will begin auto-attacking the target on cast |
| `AttributesEx` | 10 | 1024 | `0x00000400` | `SPELL_ATTR1_NO_THREAT` | Does not generate threat — Also does not cause target to engage |
| `AttributesEx` | 11 | 2048 | `0x00000800` | `SPELL_ATTR1_DONT_REFRESH_DURATION_ON_RECAST` | Aura will not refresh its duration when recast |
| `AttributesEx` | 12 | 4096 | `0x00001000` | `SPELL_ATTR1_IS_PICKPOCKET` | Pickpocket (client only) |
| `AttributesEx` | 13 | 8192 | `0x00002000` | `SPELL_ATTR1_FARSIGHT` | Farsight aura (client only) |
| `AttributesEx` | 14 | 16384 | `0x00004000` | `SPELL_ATTR1_CHANNEL_TRACK_TARGET` | Track target while channeling — While channeling, adjust facing to face target |
| `AttributesEx` | 15 | 32768 | `0x00008000` | `SPELL_ATTR1_DISPEL_AURAS_ON_IMMUNITY` | Immunity cancels preapplied auras — For immunity spells, cancel all auras that this spell would make you immune to when the spell is applied |
| `AttributesEx` | 16 | 65536 | `0x00010000` | `SPELL_ATTR1_UNAFFECTED_BY_SCHOOL_IMMUNE` | Unaffected by school immunities — Will not pierce Divine Shield, Ice Block and other full invulnerabilities |
| `AttributesEx` | 17 | 131072 | `0x00020000` | `SPELL_ATTR1_UNAUTOCASTABLE_BY_PET` | Cannot be autocast by pet |
| `AttributesEx` | 18 | 262144 | `0x00040000` | `SPELL_ATTR1_PREVENTS_ANIM` | NYI, auras apply UNIT_FLAG_PREVENT_EMOTES_FROM_CHAT_TEXT |
| `AttributesEx` | 19 | 524288 | `0x00080000` | `SPELL_ATTR1_CANT_TARGET_SELF` | Cannot be self-cast |
| `AttributesEx` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR1_REQ_COMBO_POINTS1` | Requires combo points (type 1) |
| `AttributesEx` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR1_UNK21` | Unknown attribute 21\@Attr1 |
| `AttributesEx` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR1_REQ_COMBO_POINTS2` | Requires combo points (type 2) |
| `AttributesEx` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR1_UNK23` | Unknwon attribute 23\@Attr1 |
| `AttributesEx` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR1_IS_FISHING` | Fishing (client only) |
| `AttributesEx` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR1_UNK25` | Unknown attribute 25\@Attr1 |
| `AttributesEx` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR1_REQUIRE_ALL_TARGETS` | Require All Targets |
| `AttributesEx` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR1_UNK27` | Unknown attribute 27\@Attr1 — Melee spell? |
| `AttributesEx` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR1_DONT_DISPLAY_IN_AURA_BAR` | Hide in aura bar (client only) |
| `AttributesEx` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR1_CHANNEL_DISPLAY_SPELL_NAME` | Show spell name during channel (client only) |
| `AttributesEx` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR1_ENABLE_AT_DODGE` | Enable at dodge |
| `AttributesEx` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR1_UNK31` | Unknown attribute 31\@Attr1 |

## AttributesEx2

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx2` | 0 | 1 | `0x00000001` | `SPELL_ATTR2_CAN_TARGET_DEAD` | Can target dead players or corpses |
| `AttributesEx2` | 1 | 2 | `0x00000002` | `SPELL_ATTR2_UNK1` | Unknown attribute 1\@Attr2 |
| `AttributesEx2` | 2 | 4 | `0x00000004` | `SPELL_ATTR2_CAN_TARGET_NOT_IN_LOS` | Ignore Line of Sight |
| `AttributesEx2` | 3 | 8 | `0x00000008` | `SPELL_ATTR2_ALLOW_LOW_LEVEL_BUFF` | Allow Low Level Buff |
| `AttributesEx2` | 4 | 16 | `0x00000010` | `SPELL_ATTR2_DISPLAY_IN_STANCE_BAR` | Show in stance bar (client only) |
| `AttributesEx2` | 5 | 32 | `0x00000020` | `SPELL_ATTR2_AUTOREPEAT_FLAG` | Ranged auto-attack spell |
| `AttributesEx2` | 6 | 64 | `0x00000040` | `SPELL_ATTR2_CANT_TARGET_TAPPED` | Cannot target others' tapped units — Can only target untapped units, or those tapped by caster |
| `AttributesEx2` | 7 | 128 | `0x00000080` | `SPELL_ATTR2_UNK7` | Unknown attribute 7\@Attr2 |
| `AttributesEx2` | 8 | 256 | `0x00000100` | `SPELL_ATTR2_UNK8` | Unknown attribute 8\@Attr2 |
| `AttributesEx2` | 9 | 512 | `0x00000200` | `SPELL_ATTR2_UNK9` | Unknown attribute 9\@Attr2 |
| `AttributesEx2` | 10 | 1024 | `0x00000400` | `SPELL_ATTR2_UNK10` | Unknown attribute 10\@Attr2 — Related to taming? |
| `AttributesEx2` | 11 | 2048 | `0x00000800` | `SPELL_ATTR2_HEALTH_FUNNEL` | Health Funnel |
| `AttributesEx2` | 12 | 4096 | `0x00001000` | `SPELL_ATTR2_UNK12` | Unknown attribute 12\@Attr2 |
| `AttributesEx2` | 13 | 8192 | `0x00002000` | `SPELL_ATTR2_PRESERVE_ENCHANT_IN_ARENA` | Enchant persists when entering arena |
| `AttributesEx2` | 14 | 16384 | `0x00004000` | `SPELL_ATTR2_UNK14` | Unknown attribute 14\@Attr2 |
| `AttributesEx2` | 15 | 32768 | `0x00008000` | `SPELL_ATTR2_UNK15` | Unknown attribute 15\@Attr2 |
| `AttributesEx2` | 16 | 65536 | `0x00010000` | `SPELL_ATTR2_TAME_BEAST` | Tame Beast |
| `AttributesEx2` | 17 | 131072 | `0x00020000` | `SPELL_ATTR2_NOT_RESET_AUTO_ACTIONS` | Don't reset swing timer — Does not reset melee/ranged autoattack timer on cast |
| `AttributesEx2` | 18 | 262144 | `0x00040000` | `SPELL_ATTR2_REQ_DEAD_PET` | Requires dead pet |
| `AttributesEx2` | 19 | 524288 | `0x00080000` | `SPELL_ATTR2_NOT_NEED_SHAPESHIFT` | Also allow outside shapeshift — Even if Stances are nonzero, allow spell to be cast outside of shapeshift (though not in a different shapeshift) |
| `AttributesEx2` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR2_UNK20` | Unknown attribute 20\@Attr2 |
| `AttributesEx2` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR2_FAIL_ON_ALL_TARGETS_IMMUNE` | Fail on all targets immune — Causes BG flags to be dropped if combined with ATTR1_DISPEL_AURAS_ON_IMMUNITY |
| `AttributesEx2` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR2_UNK22` | Unknown attribute 22\@Attr2 |
| `AttributesEx2` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR2_IS_ARCANE_CONCENTRATION` | Arcane Concentration |
| `AttributesEx2` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR2_UNK24` | Unknown attribute 24\@Attr2 |
| `AttributesEx2` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR2_UNK25` | Unknown attribute 25\@Attr2 |
| `AttributesEx2` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR2_UNAFFECTED_BY_AURA_SCHOOL_IMMUNE` | Pierce aura application immunities — Allow aura to be applied despite target being immune to new aura applications |
| `AttributesEx2` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR2_UNK27` | Unknown attribute 27\@Attr2 |
| `AttributesEx2` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR2_UNK28` | Unknown attribute 28\@Attr2 |
| `AttributesEx2` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR2_CANT_CRIT` | Cannot critically strike |
| `AttributesEx2` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR2_ACTIVE_THREAT` | Active Threat |
| `AttributesEx2` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR2_FOOD_BUFF` | Food buff (client only) |

## AttributesEx3

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx3` | 0 | 1 | `0x00000001` | `SPELL_ATTR3_UNK0` | Unknown attribute 0\@Attr3 |
| `AttributesEx3` | 1 | 2 | `0x00000002` | `SPELL_ATTR3_IGNORE_PROC_SUBCLASS_MASK` | 1 Ignores subclass mask check when checking proc |
| `AttributesEx3` | 2 | 4 | `0x00000004` | `SPELL_ATTR3_UNK2` | Unknown attribute 2\@Attr3 |
| `AttributesEx3` | 3 | 8 | `0x00000008` | `SPELL_ATTR3_COMPLETELY_BLOCKED` | Completely Blocked |
| `AttributesEx3` | 4 | 16 | `0x00000010` | `SPELL_ATTR3_IGNORE_RESURRECTION_TIMER` | Ignore resurrection timer |
| `AttributesEx3` | 5 | 32 | `0x00000020` | `SPELL_ATTR3_UNK5` | Unknown attribute 5\@Attr3 |
| `AttributesEx3` | 6 | 64 | `0x00000040` | `SPELL_ATTR3_UNK6` | Unknown attribute 6\@Attr3 |
| `AttributesEx3` | 7 | 128 | `0x00000080` | `SPELL_ATTR3_STACK_FOR_DIFF_CASTERS` | Stack separately for each caster |
| `AttributesEx3` | 8 | 256 | `0x00000100` | `SPELL_ATTR3_ONLY_TARGET_PLAYERS` | Can only target players |
| `AttributesEx3` | 9 | 512 | `0x00000200` | `SPELL_ATTR3_NOT_A_PROC` | Not a Proc — Without this attribute, any triggered spell will be unable to trigger other auras' procs |
| `AttributesEx3` | 10 | 1024 | `0x00000400` | `SPELL_ATTR3_MAIN_HAND` | Require main hand weapon |
| `AttributesEx3` | 11 | 2048 | `0x00000800` | `SPELL_ATTR3_BATTLEGROUND` | Can only be cast in battleground |
| `AttributesEx3` | 12 | 4096 | `0x00001000` | `SPELL_ATTR3_ONLY_TARGET_GHOSTS` | Can only target ghost players |
| `AttributesEx3` | 13 | 8192 | `0x00002000` | `SPELL_ATTR3_DONT_DISPLAY_CHANNEL_BAR` | Do not display channel bar (client only) |
| `AttributesEx3` | 14 | 16384 | `0x00004000` | `SPELL_ATTR3_IS_HONORLESS_TARGET` | Honorless Target |
| `AttributesEx3` | 15 | 32768 | `0x00008000` | `SPELL_ATTR3_UNK15` | Unknown attribute 15\@Attr3 — Auto Shoot, Shoot, Throw - ranged normal attack attribute? |
| `AttributesEx3` | 16 | 65536 | `0x00010000` | `SPELL_ATTR3_CANT_TRIGGER_PROC` | Cannot trigger procs |
| `AttributesEx3` | 17 | 131072 | `0x00020000` | `SPELL_ATTR3_NO_INITIAL_AGGRO` | No initial aggro |
| `AttributesEx3` | 18 | 262144 | `0x00040000` | `SPELL_ATTR3_IGNORE_HIT_RESULT` | Ignore hit result — Spell cannot miss, or be dodged/parried/blocked |
| `AttributesEx3` | 19 | 524288 | `0x00080000` | `SPELL_ATTR3_DISABLE_PROC` | Cannot trigger spells during aura proc |
| `AttributesEx3` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR3_DEATH_PERSISTENT` | Persists through death |
| `AttributesEx3` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR3_UNK21` | Unknown attribute 21\@Attr3 |
| `AttributesEx3` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR3_REQ_WAND` | Requires equipped Wand |
| `AttributesEx3` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR3_UNK23` | Unknown attribute 23\@Attr3 |
| `AttributesEx3` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR3_REQ_OFFHAND` | Requires offhand weapon |
| `AttributesEx3` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR3_TREAT_AS_PERIODIC` | Treat as periodic effect |
| `AttributesEx3` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR3_CAN_PROC_FROM_PROCS` | Can Proc From Procs |
| `AttributesEx3` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR3_DRAIN_SOUL` | Drain Soul |
| `AttributesEx3` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR3_UNK28` | Unknown attribute 28\@Attr3 |
| `AttributesEx3` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR3_NO_DONE_BONUS` | Damage dealt is unaffected by modifiers |
| `AttributesEx3` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR3_DONT_DISPLAY_RANGE` | Do not show range in tooltip (client only) |
| `AttributesEx3` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR3_UNK31` | Unknown attribute 31\@Attr3 |

## AttributesEx4

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx4` | 0 | 1 | `0x00000001` | `SPELL_ATTR4_IGNORE_RESISTANCES` | Cannot be resisted |
| `AttributesEx4` | 1 | 2 | `0x00000002` | `SPELL_ATTR4_PROC_ONLY_ON_CASTER` | Only proc on self-cast |
| `AttributesEx4` | 2 | 4 | `0x00000004` | `SPELL_ATTR4_FADES_WHILE_LOGGED_OUT` | Buff expires while offline — Debuffs (except Resurrection Sickness) will automatically do this |
| `AttributesEx4` | 3 | 8 | `0x00000008` | `SPELL_ATTR4_UNK3` | Unknown attribute 3\@Attr4 |
| `AttributesEx4` | 4 | 16 | `0x00000010` | `SPELL_ATTR4_UNK4` | Treat as delayed spell |
| `AttributesEx4` | 5 | 32 | `0x00000020` | `SPELL_ATTR4_UNK5` | Unknown attribute 5\@Attr4 |
| `AttributesEx4` | 6 | 64 | `0x00000040` | `SPELL_ATTR4_NOT_STEALABLE` | Aura cannot be stolen |
| `AttributesEx4` | 7 | 128 | `0x00000080` | `SPELL_ATTR4_CAN_CAST_WHILE_CASTING` | Can be cast while casting — Ignores already in-progress cast and still casts |
| `AttributesEx4` | 8 | 256 | `0x00000100` | `SPELL_ATTR4_FIXED_DAMAGE` | Deals fixed damage |
| `AttributesEx4` | 9 | 512 | `0x00000200` | `SPELL_ATTR4_TRIGGER_ACTIVATE` | Spell is initially disabled (client only) |
| `AttributesEx4` | 10 | 1024 | `0x00000400` | `SPELL_ATTR4_SPELL_VS_EXTEND_COST` | Attack speed modifies cost — Adds 10 to power cost for each 1s of weapon speed |
| `AttributesEx4` | 11 | 2048 | `0x00000800` | `SPELL_ATTR4_UNK11` | Unknown attribute 11\@Attr4 |
| `AttributesEx4` | 12 | 4096 | `0x00001000` | `SPELL_ATTR4_UNK12` | Unknown attribute 12\@Attr4 |
| `AttributesEx4` | 13 | 8192 | `0x00002000` | `SPELL_ATTR4_UNK13` | Unknown attribute 13\@Attr4 |
| `AttributesEx4` | 14 | 16384 | `0x00004000` | `SPELL_ATTR4_DAMAGE_DOESNT_BREAK_AURAS` | Damage does not break auras |
| `AttributesEx4` | 15 | 32768 | `0x00008000` | `SPELL_ATTR4_UNK15` | Unknown attribute 15\@Attr4 |
| `AttributesEx4` | 16 | 65536 | `0x00010000` | `SPELL_ATTR4_NOT_USABLE_IN_ARENA` | Not usable in arena — Makes spell unusable despite CD <= 10min |
| `AttributesEx4` | 17 | 131072 | `0x00020000` | `SPELL_ATTR4_USABLE_IN_ARENA` | Usable in arena — Makes spell usable despite CD > 10min |
| `AttributesEx4` | 18 | 262144 | `0x00040000` | `SPELL_ATTR4_AREA_TARGET_CHAIN` | Chain area targets — [NYI] Hits area targets over time instead of all at once |
| `AttributesEx4` | 19 | 524288 | `0x00080000` | `SPELL_ATTR4_UNK19` | Unknown attribute 19\@Attr4 |
| `AttributesEx4` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR4_NOT_CHECK_SELFCAST_POWER` | Allow self-cast to override stronger aura (client only) |
| `AttributesEx4` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR4_DONT_REMOVE_IN_ARENA` | Keep when entering arena |
| `AttributesEx4` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR4_UNK22` | Unknown attribute 22\@Attr4 |
| `AttributesEx4` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR4_CANT_TRIGGER_ITEM_SPELLS` | Cannot trigger item spells |
| `AttributesEx4` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR4_UNK24` | Unknown attribute 24\@Attr4 — Shoot-type spell? |
| `AttributesEx4` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR4_IS_PET_SCALING` | Pet Scaling aura |
| `AttributesEx4` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR4_CAST_ONLY_IN_OUTLAND` | Only in Outland/Northrend |
| `AttributesEx4` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR4_FORCE_DISPLAY_CASTBAR` | Force Display Castbar |
| `AttributesEx4` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR4_UNK28` | Unknown attribute 28\@Attr4 |
| `AttributesEx4` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR4_UNK29` | Unknown attribute 29\@Attr4 |
| `AttributesEx4` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR4_UNK30` | Unknown attribute 30\@Attr4 |
| `AttributesEx4` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR4_UNK31` | Unknown attribute 31\@Attr4 |

## AttributesEx5

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx5` | 0 | 1 | `0x00000001` | `SPELL_ATTR5_CAN_CHANNEL_WHEN_MOVING` | Can be channeled while moving |
| `AttributesEx5` | 1 | 2 | `0x00000002` | `SPELL_ATTR5_NO_REAGENT_WHILE_PREP` | No reagents during arena preparation |
| `AttributesEx5` | 2 | 4 | `0x00000004` | `SPELL_ATTR5_REMOVE_ON_ARENA_ENTER` | Remove when entering arena — Force this aura to be removed on entering arena, regardless of other properties |
| `AttributesEx5` | 3 | 8 | `0x00000008` | `SPELL_ATTR5_USABLE_WHILE_STUNNED` | Usable while stunned |
| `AttributesEx5` | 4 | 16 | `0x00000010` | `SPELL_ATTR5_UNK4` | Unknown attribute 4\@Attr5 |
| `AttributesEx5` | 5 | 32 | `0x00000020` | `SPELL_ATTR5_SINGLE_TARGET_SPELL` | Single-target aura — Remove previous application to another unit if applied |
| `AttributesEx5` | 6 | 64 | `0x00000040` | `SPELL_ATTR5_UNK6` | Unknown attribute 6\@Attr5 |
| `AttributesEx5` | 7 | 128 | `0x00000080` | `SPELL_ATTR5_UNK7` | Unknown attribute 7\@Attr5 |
| `AttributesEx5` | 8 | 256 | `0x00000100` | `SPELL_ATTR5_CANT_TARGET_PLAYER_CONTROLLED` | Cannot target player controlled units but can target players |
| `AttributesEx5` | 9 | 512 | `0x00000200` | `SPELL_ATTR5_START_PERIODIC_AT_APPLY` | Immediately do periodic tick on apply |
| `AttributesEx5` | 10 | 1024 | `0x00000400` | `SPELL_ATTR5_HIDE_DURATION` | Do not send aura duration to client |
| `AttributesEx5` | 11 | 2048 | `0x00000800` | `SPELL_ATTR5_ALLOW_TARGET_OF_TARGET_AS_TARGET` | Auto-target target of target (client only) |
| `AttributesEx5` | 12 | 4096 | `0x00001000` | `SPELL_ATTR5_UNK12` | Unknown attribute 12\@Attr5 — Cleave related? |
| `AttributesEx5` | 13 | 8192 | `0x00002000` | `SPELL_ATTR5_HASTE_AFFECT_DURATION` | Duration scales with Haste Rating |
| `AttributesEx5` | 14 | 16384 | `0x00004000` | `SPELL_ATTR5_NOT_USABLE_WHILE_CHARMED` | Charmed units cannot cast this spell |
| `AttributesEx5` | 15 | 32768 | `0x00008000` | `SPELL_ATTR5_UNK15` | Unknown attribute 15\@Attr5 — Related to multi-target spells? |
| `AttributesEx5` | 16 | 65536 | `0x00010000` | `SPELL_ATTR5_UNK16` | Unknown attribute 16\@Attr5 |
| `AttributesEx5` | 17 | 131072 | `0x00020000` | `SPELL_ATTR5_USABLE_WHILE_FEARED` | Usable while feared |
| `AttributesEx5` | 18 | 262144 | `0x00040000` | `SPELL_ATTR5_USABLE_WHILE_CONFUSED` | Usable while confused |
| `AttributesEx5` | 19 | 524288 | `0x00080000` | `SPELL_ATTR5_DONT_TURN_DURING_CAST` | Do not auto-turn while casting |
| `AttributesEx5` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR5_UNK20` | Unknown attribute 20\@Attr5 |
| `AttributesEx5` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR5_UNK21` | Unknown attribute 21\@Attr5 |
| `AttributesEx5` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR5_UNK22` | Unknown attribute 22\@Attr5 |
| `AttributesEx5` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR5_UNK23` | Unknown attribute 23\@Attr5 |
| `AttributesEx5` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR5_UNK24` | Unknown attribute 24\@Attr5 |
| `AttributesEx5` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR5_UNK25` | Unknown attribute 25\@Attr5 |
| `AttributesEx5` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR5_SKIP_CHECKCAST_LOS_CHECK` | Ignore line of sight checks |
| `AttributesEx5` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR5_DONT_SHOW_AURA_IF_SELF_CAST` | Don't show aura if self-cast (client only) |
| `AttributesEx5` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR5_DONT_SHOW_AURA_IF_NOT_SELF_CAST` | Don't show aura unless self-cast (client only) |
| `AttributesEx5` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR5_UNK29` | Unknown attribute 29\@Attr5 |
| `AttributesEx5` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR5_UNK30` | Unknown attribute 30\@Attr5 |
| `AttributesEx5` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR5_UNK31` | Unknown attribute 31\@Attr5 — Forces nearby enemies to attack caster? |

## AttributesEx6

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx6` | 0 | 1 | `0x00000001` | `SPELL_ATTR6_DONT_DISPLAY_COOLDOWN` | Don't display cooldown (client only) |
| `AttributesEx6` | 1 | 2 | `0x00000002` | `SPELL_ATTR6_ONLY_IN_ARENA` | Only usable in arena |
| `AttributesEx6` | 2 | 4 | `0x00000004` | `SPELL_ATTR6_IGNORE_CASTER_AURAS` | Ignore all preventing caster auras |
| `AttributesEx6` | 3 | 8 | `0x00000008` | `SPELL_ATTR6_ASSIST_IGNORE_IMMUNE_FLAG` | Ignore immunity flags when assisting |
| `AttributesEx6` | 4 | 16 | `0x00000010` | `SPELL_ATTR6_UNK4` | Unknown attribute 4\@Attr6 |
| `AttributesEx6` | 5 | 32 | `0x00000020` | `SPELL_ATTR6_DONT_CONSUME_PROC_CHARGES` | Don't consume proc charges |
| `AttributesEx6` | 6 | 64 | `0x00000040` | `SPELL_ATTR6_USE_SPELL_CAST_EVENT` | Generate spell_cast event instead of aura_start (client only) |
| `AttributesEx6` | 7 | 128 | `0x00000080` | `SPELL_ATTR6_UNK7` | Unknown attribute 7\@Attr6 |
| `AttributesEx6` | 8 | 256 | `0x00000100` | `SPELL_ATTR6_CANT_TARGET_CROWD_CONTROLLED` | Do not implicitly target in CC — Implicit targeting (chaining and area targeting) will not impact crowd controlled targets |
| `AttributesEx6` | 9 | 512 | `0x00000200` | `SPELL_ATTR6_UNK9` | Unknown attribute 9\@Attr6 |
| `AttributesEx6` | 10 | 1024 | `0x00000400` | `SPELL_ATTR6_CAN_TARGET_POSSESSED_FRIENDS` | Can target possessed friends — [NYI] |
| `AttributesEx6` | 11 | 2048 | `0x00000800` | `SPELL_ATTR6_NOT_IN_RAID_INSTANCE` | Unusable in raid instances |
| `AttributesEx6` | 12 | 4096 | `0x00001000` | `SPELL_ATTR6_CASTABLE_WHILE_ON_VEHICLE` | Castable while caster is on vehicle |
| `AttributesEx6` | 13 | 8192 | `0x00002000` | `SPELL_ATTR6_CAN_TARGET_INVISIBLE` | Can target invisible units |
| `AttributesEx6` | 14 | 16384 | `0x00004000` | `SPELL_ATTR6_UNK14` | Unknown attribute 14\@Attr6 |
| `AttributesEx6` | 15 | 32768 | `0x00008000` | `SPELL_ATTR6_UNK15` | Unknown attribute 15\@Attr6 |
| `AttributesEx6` | 16 | 65536 | `0x00010000` | `SPELL_ATTR6_UNK16` | Unknown attribute 16\@Attr6 |
| `AttributesEx6` | 17 | 131072 | `0x00020000` | `SPELL_ATTR6_UNK17` | Unknown attribute 17\@Attr6 — Mount related? |
| `AttributesEx6` | 18 | 262144 | `0x00040000` | `SPELL_ATTR6_CAST_BY_CHARMER` | Spell is cast by charmer — Client will prevent casting if not possessed, charmer will be caster for all intents and purposes |
| `AttributesEx6` | 19 | 524288 | `0x00080000` | `SPELL_ATTR6_UNK19` | Unknown attribute 19\@Attr6 |
| `AttributesEx6` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR6_ONLY_VISIBLE_TO_CASTER` | Only visible to caster (client only) |
| `AttributesEx6` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR6_CLIENT_UI_TARGET_EFFECTS` | Client UI target effects (client only) |
| `AttributesEx6` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR6_UNK22` | Unknown attribute 22\@Attr6 |
| `AttributesEx6` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR6_UNK23` | Unknown attribute 23\@Attr6 |
| `AttributesEx6` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR6_CAN_TARGET_UNTARGETABLE` | Can target untargetable units |
| `AttributesEx6` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR6_NOT_RESET_SWING_IF_INSTANT` | Do not reset swing timer if cast time is instant |
| `AttributesEx6` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR6_UNK26` | Unknown attribute 26\@Attr6 — Player castable buff? |
| `AttributesEx6` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR6_LIMIT_PCT_HEALING_MODS` | Limit applicable %healing modifiers — This prevents certain healing modifiers from applying - see implementation if you really care about details |
| `AttributesEx6` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR6_UNK28` | Unknown attribute 28\@Attr6 — Death grip? |
| `AttributesEx6` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR6_LIMIT_PCT_DAMAGE_MODS` | Limit applicable %damage modifiers — This prevents certain damage modifiers from applying - see implementation if you really care about details |
| `AttributesEx6` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR6_UNK30` | Unknown attribute 30\@Attr6 |
| `AttributesEx6` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR6_IGNORE_CATEGORY_COOLDOWN_MODS` | Ignore cooldown modifiers for category cooldown |

## AttributesEx7

| Attributes Field | Bit | Decimal Value | Hex Value | Core Flag | Meaning / Source Notes |
| --- | ---: | ---: | --- | --- | --- |
| `AttributesEx7` | 0 | 1 | `0x00000001` | `SPELL_ATTR7_UNK0` | Unknown attribute 0\@Attr7 |
| `AttributesEx7` | 1 | 2 | `0x00000002` | `SPELL_ATTR7_IGNORE_DURATION_MODS` | Ignore duration modifiers |
| `AttributesEx7` | 2 | 4 | `0x00000004` | `SPELL_ATTR7_DISABLE_AURA_WHILE_DEAD` | Disable Aura While Dead |
| `AttributesEx7` | 3 | 8 | `0x00000008` | `SPELL_ATTR7_IS_CHEAT_SPELL` | Is cheat spell — Cannot cast if caster doesn't have UnitFlag2 & UNIT_FLAG2_ALLOW_CHEAT_SPELLS |
| `AttributesEx7` | 4 | 16 | `0x00000010` | `SPELL_ATTR7_UNK4` | Unknown attribute 4\@Attr7 — Soulstone related? |
| `AttributesEx7` | 5 | 32 | `0x00000020` | `SPELL_ATTR7_SUMMON_PLAYER_TOTEM` | Summons player-owned totem |
| `AttributesEx7` | 6 | 64 | `0x00000040` | `SPELL_ATTR7_NO_PUSHBACK_ON_DAMAGE` | Damage dealt by this does not cause spell pushback |
| `AttributesEx7` | 7 | 128 | `0x00000080` | `SPELL_ATTR7_UNK7` | Unknown attribute 7\@Attr7 |
| `AttributesEx7` | 8 | 256 | `0x00000100` | `SPELL_ATTR7_HORDE_ONLY` | Horde only |
| `AttributesEx7` | 9 | 512 | `0x00000200` | `SPELL_ATTR7_ALLIANCE_ONLY` | Alliance only |
| `AttributesEx7` | 10 | 1024 | `0x00000400` | `SPELL_ATTR7_DISPEL_CHARGES` | Dispel/Spellsteal remove individual charges |
| `AttributesEx7` | 11 | 2048 | `0x00000800` | `SPELL_ATTR7_INTERRUPT_ONLY_NONPLAYER` | Only interrupt non-player casting |
| `AttributesEx7` | 12 | 4096 | `0x00001000` | `SPELL_ATTR7_UNK12` | Unknown attribute 12\@Attr7 |
| `AttributesEx7` | 13 | 8192 | `0x00002000` | `SPELL_ATTR7_UNK13` | Unknown attribute 13\@Attr7 |
| `AttributesEx7` | 14 | 16384 | `0x00004000` | `SPELL_ATTR7_UNK14` | Unknown attribute 14\@Attr7 |
| `AttributesEx7` | 15 | 32768 | `0x00008000` | `SPELL_ATTR7_UNK15` | Unknown attribute 15\@Attr7 — Exorcism - guaranteed crit vs families? |
| `AttributesEx7` | 16 | 65536 | `0x00010000` | `SPELL_ATTR7_CAN_RESTORE_SECONDARY_POWER` | Can restore secondary power — Only spells with this attribute can replenish a non-active power type |
| `AttributesEx7` | 17 | 131072 | `0x00020000` | `SPELL_ATTR7_UNK17` | Unknown attribute 17\@Attr7 |
| `AttributesEx7` | 18 | 262144 | `0x00040000` | `SPELL_ATTR7_HAS_CHARGE_EFFECT` | Has charge effect |
| `AttributesEx7` | 19 | 524288 | `0x00080000` | `SPELL_ATTR7_ZONE_TELEPORT` | Is zone teleport |
| `AttributesEx7` | 20 | 1048576 | `0x00100000` | `SPELL_ATTR7_UNK20` | Unknown attribute 20\@Attr7 — Invulnerability related? |
| `AttributesEx7` | 21 | 2097152 | `0x00200000` | `SPELL_ATTR7_UNK21` | Unknown attribute 21\@Attr7 |
| `AttributesEx7` | 22 | 4194304 | `0x00400000` | `SPELL_ATTR7_IGNORE_COLD_WEATHER_FLYING` | Ignore cold weather flying restriction — Set for loaner mounts, allows them to be used despite lacking required flight skill |
| `AttributesEx7` | 23 | 8388608 | `0x00800000` | `SPELL_ATTR7_CANT_DODGE` | Spell cannot be dodged |
| `AttributesEx7` | 24 | 16777216 | `0x01000000` | `SPELL_ATTR7_CANT_PARRY` | Spell cannot be parried |
| `AttributesEx7` | 25 | 33554432 | `0x02000000` | `SPELL_ATTR7_CANT_MISS` | Spell cannot be missed |
| `AttributesEx7` | 26 | 67108864 | `0x04000000` | `SPELL_ATTR7_UNK26` | Unknown attribute 26\@Attr7 |
| `AttributesEx7` | 27 | 134217728 | `0x08000000` | `SPELL_ATTR7_BYPASS_NO_RESURRECT_AURA` | Bypasses the prevent resurrection aura |
| `AttributesEx7` | 28 | 268435456 | `0x10000000` | `SPELL_ATTR7_CONSOLIDATED_RAID_BUFF` | Consolidate in raid buff frame (client only) |
| `AttributesEx7` | 29 | 536870912 | `0x20000000` | `SPELL_ATTR7_UNK29` | Unknown attribute 29\@Attr7 |
| `AttributesEx7` | 30 | 1073741824 | `0x40000000` | `SPELL_ATTR7_UNK30` | Unknown attribute 30\@Attr7 |
| `AttributesEx7` | 31 | 2147483648 | `0x80000000` | `SPELL_ATTR7_CLIENT_INDICATOR` | Client indicator (client only) |
