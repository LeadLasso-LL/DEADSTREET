class_name BattleCombatPressureCatalog
extends RefCounted

# Provisional local combat-pressure tuning. Not final morale balance.
# Spatial only: no LOS, cover, weapon threat, or recent-casualty memory.

const PRESSURE_RADIUS := 20.0
const FRIENDLY_SUPPORT_RADIUS := 15.0
const ISOLATION_RADIUS := 12.0

const CASUALTY_WEIGHT := 0.25
const WOUNDED_WEIGHT := 0.15
const HOSTILE_PROXIMITY_WEIGHT := 0.25
const ISOLATION_WEIGHT := 0.15
const MULTI_DIRECTION_WEIGHT := 0.20
const FRIENDLY_SUPPORT_MITIGATION := 0.20

const CASUALTY_COUNT_NORMALIZE := 2.0
const WOUNDED_COUNT_NORMALIZE := 3.0
const HOSTILE_PROXIMITY_NORMALIZE := 2.0
const FRIENDLY_SUPPORT_COUNT_NORMALIZE := 3.0

# Provisional v1 behavior threshold. Not final morale balance.
# High local pressure suppresses healthy autonomous aggressive approach only.
const HIGH_PRESSURE_AGGRESSION_THRESHOLD := 0.70
