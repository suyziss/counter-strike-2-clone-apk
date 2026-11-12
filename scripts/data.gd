extends RefCounted
class_name BPData

const WEAPONS := {
 "Viper-9":{"price":200,"damage":28,"rpm":420,"spread":0.035,"recoil":0.9,"mag":15,"reserve":90,"reload":1.65,"kind":"pistol"},
 "Stinger":{"price":1250,"damage":23,"rpm":850,"spread":0.055,"recoil":1.3,"mag":30,"reserve":120,"reload":2.0,"kind":"smg"},
 "Krait AR":{"price":2700,"damage":32,"rpm":700,"spread":0.028,"recoil":1.4,"mag":30,"reserve":90,"reload":2.2,"kind":"rifle"},
 "Sentinel":{"price":4750,"damage":85,"rpm":55,"spread":0.008,"recoil":2.5,"mag":5,"reserve":30,"reload":2.8,"kind":"sniper"},
 "Breacher 12":{"price":1100,"damage":18,"rpm":85,"spread":0.15,"recoil":2.2,"mag":8,"reserve":32,"reload":2.5,"kind":"shotgun"},
 "Bulwark":{"price":5200,"damage":29,"rpm":760,"spread":0.07,"recoil":1.8,"mag":60,"reserve":180,"reload":3.3,"kind":"lmg"},
 "Pike-45":{"price":700,"damage":35,"rpm":330,"spread":0.045,"recoil":1.0,"mag":12,"reserve":72,"reload":1.8,"kind":"pistol"},
 "Raptor SMG":{"price":1600,"damage":25,"rpm":950,"spread":0.07,"recoil":1.5,"mag":35,"reserve":140,"reload":2.1,"kind":"smg"},
 "Mantis AR":{"price":3100,"damage":36,"rpm":650,"spread":0.025,"recoil":1.5,"mag":25,"reserve":75,"reload":2.15,"kind":"rifle"},
 "Longbow DMR":{"price":3900,"damage":58,"rpm":180,"spread":0.012,"recoil":1.7,"mag":10,"reserve":50,"reload":2.4,"kind":"dmr"},
 "Hammer 9":{"price":900,"damage":42,"rpm":180,"spread":0.09,"recoil":1.6,"mag":7,"reserve":42,"reload":2.0,"kind":"pistol"},
 "Arc SMG":{"price":1900,"damage":27,"rpm":780,"spread":0.06,"recoil":1.4,"mag":28,"reserve":112,"reload":2.0,"kind":"smg"}
}
const SKINS := [
 ["Ash Circuit","Обычный"],["Foundry Dust","Обычный"],["Harbor Salt","Обычный"],["Carbon Thread","Обычный"],["Rust Bloom","Обычный"],
 ["Copper Grid","Редкий"],["Blue Relay","Редкий"],["Signal Lime","Редкий"],["Night Alloy","Редкий"],["Crimson Rail","Редкий"],
 ["Ion Frost","Элитный"],["Magma Weave","Элитный"],["Deep Current","Элитный"],["Violet Pulse","Элитный"],["Solar Mesh","Элитный"],
 ["Blackglass","Легендарный"],["Aurora Core","Легендарный"],["Phantom Forge","Легендарный"],["Royal Circuit","Легендарный"],["Ember Crown","Легендарный"],
 ["Void Regent","Контрабанда"],["Starbreaker","Контрабанда"],["Null Horizon","Контрабанда"],["Crownfall","Контрабанда"]
]
const CASES := {
 "Foundry Case":[0,1,5,6,10,15],
 "Harbor Case":[2,3,7,12,16,20],
 "Relay Case":[4,8,9,13,17,21],
 "Blacksite Case":[5,11,14,18,22,23]
}
const RARITY_VALUE := {"Обычный":150,"Редкий":400,"Элитный":900,"Легендарный":2200,"Контрабанда":6000}
const RARITY_CHANCE := {"Обычный":0.48,"Редкий":0.28,"Элитный":0.15,"Легендарный":0.075,"Контрабанда":0.02}

static func rarity_color(r:String)->Color:
 match r:
  "Обычный": return Color("#9aa3ad")
  "Редкий": return Color("#48a9ff")
  "Элитный": return Color("#b65cff")
  "Легендарный": return Color("#ffb83d")
  _: return Color("#ff4d67")
