# KROOKS HITMAN

Ainult NPC-dele mõeldud Hitman Contracts script QBCore serveritele.

## Sõltuvused

* qb-core
* ox_lib
* ox_target
* ox_inventory
* oxmysql

## Paigaldus

1. Pane `krks-hitman` kaust oma `resources` kausta.
2. Lisa see oma `server.cfg` faili:

```cfg
ensure krks-hitman
```

Soovitatud ensure järjekord:

```cfg
ensure oxmysql
ensure ox_lib
ensure qb-core
ensure ox_target
ensure ox_inventory
ensure krks-hitman
```

## Kasutamine

* NPC kaudu: mine `Config.NPC.coords` asukohta ja räägi kontaktiga.
* Commandiga: `/hitman`

## Tähtis

See script on tehtud NPC sihtmärkide jaoks, mitte päris mängijate tapmise contractideks.
See aitab vältida serveri muutumist griefimiseks.

## Itemid ox_inventory jaoks

Kui kasutad high risk contracti jaoks `Config.Contracts` sees itemit `encrypted_contract`, lisa see oma ox_inventory itemite faili:

```lua
['encrypted_contract'] = {
    label = 'Encrypted Contract',
    weight = 100,
    stack = true,
    close = true,
    description = 'Krüpteeritud illegaalne tööleping'
},
```

Kui `Config.PaymentItem = 'black_money'`, peab see item sul ox_inventorys olemas olema. Kui ei ole, lisa:

```lua
['black_money'] = {
    label = 'Black Money',
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
Kui sul on oma dispatch, muuda configis:

```lua
Config.Dispatch.useCustomEvent = true
Config.Dispatch.customClientEvent = 'your_dispatch:event'
```

Siis saad oma dispatchi ühendada `client/main.lua` failis oleva `PoliceDispatch` funktsiooni kaudu.

## Discord logid

Configis:

```lua
Config.Discord.enabled = true
Config.Discord.webhook = 'YOUR_WEBHOOK'
```

Logib:

* contract alustamine
* contract lõpetamine
* contract failimine
* disconnect aktiivse contractiga

## Gang whitelist

Kui tahad, et ainult kindlad gangid saaksid seda kasutada:

```lua
Config.UseGangWhitelist = true
Config.AllowedGangs = {
    cartel = true,
    crips = true,
}
```

Gangi nimi peab olema QBCore gang name, mitte label.

## Config asukohad

NPC asukoht:

```lua
Config.NPC.coords = vector4(705.82, -966.91, 30.41, 177.0)
```

Contracti sihtmärkide spawn asukohad:

```lua
Config.Contracts[1].coords = {
    vector4(x, y, z, heading),
}
```

## Võimalikud probleemid

### Menüüd ei avane

Kontrolli, et `ox_lib` oleks enne seda scripti ensuretud.

### Target ei ilmu

Kontrolli, et `ox_target` töötaks ja see script oleks ensure järjekorras pärast ox_targetit.

### Tasu ei tule

Kui kasutad black_money itemit, kontrolli, et see item oleks ox_inventory itemites olemas.
Kui sa ei taha itemit kasutada, pane `Config.PaymentItem = 'cash'`.

### High risk contract ei alga

Sul puudub `encrypted_contract` item või seda ei ole ox_inventory itemites olemas.

# PREVIEW

<img width="341" height="381" alt="image" src="https://github.com/user-attachments/assets/7a63f7e5-ef2d-4ef3-87bd-1f9ae8c8e774" />

