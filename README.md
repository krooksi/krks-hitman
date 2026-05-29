# KROOKS HITMAN

NPC-only Hitman Contracts script for QBCore servers.

## Dependencies

* qb-core
* ox_lib
* ox_target
* ox_inventory
* oxmysql

## Install

1. Put the `krks-hitman` folder into your `resources` folder.
2. Add this to your `server.cfg`:

```cfg
ensure krks-hitman
```

Recommended ensure order:

```cfg
ensure oxmysql
ensure ox_lib
ensure qb-core
ensure ox_target
ensure ox_inventory
ensure krks-hitman
```

## Usage

* Through the NPC: go to the `Config.NPC.coords` location and talk to the contact.
* Through command: `/hitman`

## Important

This script is made for NPC targets, not contracts for killing real players.
This prevents the server from turning into a griefing server.

## Items for ox_inventory

If you use `encrypted_contract` for the high risk contract in `Config.Contracts`, add this to your ox_inventory items file:

```lua
['encrypted_contract'] = {
    label = 'Encrypted Contract',
    weight = 100,
    stack = true,
    close = true,
    description = 'Encrypted illegal work contract'
},
```

If `Config.PaymentItem = 'black_money'`, you must have this item in ox_inventory. If you do not have it, add:

```lua
['black_money'] = {
    label = 'Black Money',
    weight = 0,
    stack = true,
    close = true,
    description = 'Unwashed money'
},
```

Or change this in the config:

```lua
Config.PaymentItem = 'cash'
```

Then the script will give QBCore cash money.

## Dispatch

The default dispatch sends an ox_lib notify to on-duty police officers.
If you have your own dispatch, change this in the config:

```lua
Config.Dispatch.useCustomEvent = true
Config.Dispatch.customClientEvent = 'your_dispatch:event'
```

Then you can connect your own dispatch using the `PoliceDispatch` function in `client/main.lua`.

## Discord logs

In the config:

```lua
Config.Discord.enabled = true
Config.Discord.webhook = 'YOUR_WEBHOOK'
```

Logs:

* contract started
* contract completed
* contract failed
* disconnect with an active contract

## Gang whitelist

If you want only certain gangs to be able to use it:

```lua
Config.UseGangWhitelist = true
Config.AllowedGangs = {
    cartel = true,
    crips = true,
}
```

The gang name must be the QBCore gang name, not the label.

## Config locations

NPC location:

```lua
Config.NPC.coords = vector4(705.82, -966.91, 30.41, 177.0)
```

Contract target spawn locations:

```lua
Config.Contracts[1].coords = {
    vector4(x, y, z, heading),
}
```

## Possible issues

### Menus do not open

Make sure `ox_lib` is ensured before this script.

### Target does not appear

Make sure `ox_target` is working and that this script is ensured after ox_target in the ensure order.

### Payment is not received

If you use the black_money item, make sure that item exists in your ox_inventory items.
If you do not want to use an item, set `Config.PaymentItem = 'cash'`.

### High risk contract does not start

You are missing the `encrypted_contract` item, or it does not exist in your ox_inventory items.
