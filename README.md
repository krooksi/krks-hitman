# island_hitman

NPC-only Hitman Contracts script Island RP / QBCore serverile.

## Dependencies

- qb-core
- ox_lib
- ox_target
- ox_inventory
- oxmysql

## Install

1. Pane kaust `island_hitman` oma `resources` kausta.
2. Lisa `server.cfg` sisse:

```cfg
ensure island_hitman
```

Soovitatud ensure order:

```cfg
ensure oxmysql
ensure ox_lib
ensure qb-core
ensure ox_target
ensure ox_inventory
ensure island_hitman
```

## Kasutamine

- NPC kaudu: mine Config.NPC.coords asukohta ja räägi kontaktiga.
- Commandiga: `/hitman`

## Tähtis

See script on tehtud NPC sihtmärkide jaoks, mitte päris mängijate tapmise contractideks.
Nii ei muutu server griefimiseks.

## Itemid ox_inventory jaoks

Kui kasutad Config.Contracts high risk contractil `encrypted_contract`, lisa ox_inventory itemite faili:

```lua
['encrypted_contract'] = {
    label = 'Encrypted Contract',
    weight = 100,
    stack = true,
    close = true,
    description = 'Krüpteeritud illegaalne tööleping'
},
```

Kui `Config.PaymentItem = 'black_money'`, peab sul ox_inventorys olema selline item olemas. Kui ei ole, lisa:

```lua
['black_money'] = {
    label = 'Must raha',
    weight = 0,
    stack = true,
    close = true,
    description = 'Pesemata raha'
},
```

Või muuda configis:

```lua
Config.PaymentItem = 'cash'
```

Siis annab script QBCore cash raha.

## Dispatch

Default dispatch saadab ox_lib notify on-duty politseinikele.
Kui sul on enda dispatch, muuda configis:

```lua
Config.Dispatch.useCustomEvent = true
Config.Dispatch.customClientEvent = 'sinu_dispatch:event'
```

Siis saad client/main.lua `PoliceDispatch` funktsiooni järgi oma dispatchi külge panna.

## Discord logs

Configis:

```lua
Config.Discord.enabled = true
Config.Discord.webhook = 'SINU_WEBHOOK'
```

Logib:

- contract alustamine
- contract lõpetamine
- contract failimine
- disconnect aktiivse contractiga

## Gang whitelist

Kui tahad, et ainult kindlad gangid saavad kasutada:

```lua
Config.UseGangWhitelist = true
Config.AllowedGangs = {
    cartel = true,
    crips = true,
}
```

Gang nimi peab olema QBCore gang name, mitte label.

## Config asukohad

NPC asukoht:

```lua
Config.NPC.coords = vector4(705.82, -966.91, 30.41, 177.0)
```

Contractide sihtmärgi spawnid:

```lua
Config.Contracts[1].coords = {
    vector4(x, y, z, heading),
}
```

## Võimalikud probleemid

### Menüüd ei avane
Kontrolli, et `ox_lib` on enne seda scripti ensuretud.

### Target ei ilmu
Kontrolli, et `ox_target` töötab ja script on ensure orderis pärast ox_targetit.

### Tasu ei tule
Kui kasutad black_money itemit, kontrolli, et see item on ox_inventory itemites olemas.
Kui ei taha itemit, pane `Config.PaymentItem = 'cash'`.

### High risk contract ei alga
Sul puudub `encrypted_contract` item või see pole ox_inventory itemites olemas.
