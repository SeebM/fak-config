let { tap, hold, td, combo, macro, ..} = import "fak/keycode.ncl" in
let util = import "fak/util_functions.ncl" in

#           0   1   2   3       4   5   6   7
#        8  9   10  11  12      13  14  15  16  17
#       18  19  20  21              25  26  27  28
#                   22  23      24  
let virtual_keys' = [
  combo.make 35 [0, 1], # P
  combo.make 35 [6, 7], # Q
  combo.make 30 [15, 16], # SCH
  combo.make 50 [0, 8],  # ESC
  combo.make 25 [18, 19], # TAB
  combo.make 30 [10, 11], # DOT
  combo.make 30 [14, 15], # COMMA
  combo.make 50 [22, 23], # SmartNum
  combo.make 40 [19, 20], # LT
  combo.make 40 [26, 27], # GT
  combo.make 40 [20, 21],  # SQT
  combo.make 40 [25, 26],  # DQT
] in

let virtual_key_count = std.array.length virtual_keys' in
let key_count = 29 + virtual_key_count in

# convenience aliases
# taps
let kc = tap.reg.kc in
let ks = tap.reg.ks in
let md = tap.reg.mod in
# holds
# let kch = hold.reg.kc in
# let ksh = hold.reg.ks in
let mdh = hold.reg.mod in
# layer control
let lt = hold.reg.layer in
let to = tap.layer.TO in
# boot, reset, etc
let fak = tap.custom.fak in
# media and mouse control
let media = tap.custom.media in
let mouse = tap.custom.mouse in
# keymap stuff
let tx = tap.none in
let tt = tap.trans in
let hx = hold.none in
let ht = hold.trans in

let ki = {
  hp = { decision = 'hold, trigger_on = 'press },
  tp = { decision = 'tap, trigger_on = 'press },
  hr = { decision = 'hold, trigger_on = 'release },
  tr = { decision = 'tap, trigger_on = 'release },
  xx = { decision = 'none },
} in

let layouts = {
  NEOSEEB = "VKC.,HGFUIAEODNRTSXZYLMBWJ",
} in

let make_hrm = fun key_idx =>
  let htb_hrm_base = fun eager => {
    timeout_ms = 250,
    # quick_tap_ms = 100,
    # quick_tap_interrupt_ms = 500,
    # global_quick_tap_ms = 80,
    # eager_decision = none,
    timeout_decision = 'hold,
  } in

  let virtual_interrupts = std.array.replicate virtual_key_count ki.hr in

  let htb_hrm_left = fun eager => htb_hrm_base eager & {
    key_interrupts = [
           ki.tp, ki.tp, ki.tp, ki.tp,  ki.hr, ki.hr, ki.hr, ki.hr, 
        ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.tp, ki.tp, ki.tp, ki.tp, ki.hr,  ki.hr,  ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
    ] @ virtual_interrupts
  } in

  let htb_hrm_right = fun eager => htb_hrm_base eager & {
    key_interrupts = [
           ki.hr, ki.hr, ki.hr, ki.hr,  ki.tp, ki.tp, ki.tp, ki.tp,
        ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,      ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,  ki.hr,  ki.hr, ki.tp, ki.tp, ki.tp, ki.tp,
    ] @ virtual_interrupts
  } in

  let hrm_mods = [
    mdh.lgui, mdh.lalt, mdh.lsft, mdh.lctl,
    mdh.lctl, mdh.lsft, mdh.lalt, mdh.lgui,
  ] in

  let hrm_key_indices = [18, 9, 10, 11, 14, 15, 16, 28] in

  if std.array.elem key_idx hrm_key_indices then
    let mod_idx = util.array.index_of key_idx hrm_key_indices in
    let side = if mod_idx < (std.array.length hrm_mods / 2) then 'left else 'right in
    let mod = std.array.at mod_idx hrm_mods in

    mod & hold.reg.behavior (
      (if side == 'left then htb_hrm_left else htb_hrm_right)
      (if true then 'none else 'hold)
    )
  else
    {}
in

let alphas = fun layout => layout
  |> std.string.characters
  |> util.array.enumerate
  |> std.array.map (
      fun { index, value } => kc."%{value}"
      & make_hrm index
    )
in

let thumb = fun thumb_idx =>
  let thumb_behavior = {
    timeout_ms = 150,
    timeout_decision = 'hold,
    key_interrupts = std.array.replicate key_count ki.hr,
  } in
  [
    kc.SPC   & lt 1 & hold.reg.behavior thumb_behavior,
    kc.ENTER & lt 2 & hold.reg.behavior thumb_behavior,
    kc.BSPC  & lt 3 & hold.reg.behavior thumb_behavior,
  ]
  |> std.array.at thumb_idx
in

let cu = {
  # copy custom stuff from example
  SCH  = macro.make [
    macro.tap kc.S,
    macro.release mdh.lsft,
    macro.tap kc.C,
    macro.tap kc.H,
  ],
  SNIP = md.lsft & md.lgui & kc.S,
} in

let combos_base = [
  kc.Q, kc.P,cu.SCH, kc.ESC, kc.TAB, kc.DOT, kc.COMMA,  tap.layer.TO 1,kc.NUBS,md.lsft & kc.NUBS,md.lsft & kc.NUHS, md.lsft & kc.N2
] in
let combos_num = [
 kc.F1, kc.F10, tx & hx, kc.GRAVE, kc.TAB, kc.DOT, kc.COMMA, tap.tlex & hx,kc.NUBS,md.lsft & kc.NUBS,md.lsft & kc.NUHS, md.lsft & kc.N2
] in
let combos_none = [
  tx & hx, tx & hx, tx & hx, tx & hx, tx & hx, tx & hx, tx & hx, tap.tlex & hx,tx & hx,tx & hx,tx & hx,tx & hx,
] in

### Keymap itself! ###
{
  virtual_keys = virtual_keys',
  layers = [
    let base = fun key_idx => (alphas layouts.NEOSEEB) |> std.array.at key_idx in
    # ALPHAS
    [
                  base 0,  base 1,  base 2,  base 3,      base 4,  base 5,  base 6,  base 7, 
        base 8, base 9 , base 10, base 11, base 12,         base 13, base 14, base 15, base 16, base 17,
      base 18, base 19, base 20, base 21, thumb 0,   thumb 1,  thumb 2, base 22, base 23, base 24, base 25,
    ] @ combos_base,
    # NUM hier weitermachen!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    [
                            kc.F2,           kc.F3,           kc.F4,           kc.F5,      kc.F6,   kc.F7,           kc.F8,           kc.F9,
        kc.N1,             kc.N2 & ht,      kc.N3 & ht,      kc.N4 & ht,      kc.N5,          kc.N6,   kc.N7 & ht,      kc.N8 & ht,      kc.N9 & ht,      kc.N0,
      md.lsft & kc.NUHS, md.ralt & kc.N7, md.ralt & kc.N8, md.lsft & kc.N8, tap.tlex,  tt & ht,  kc.DOT, md.lsft & kc.N9, md.ralt & kc.N9, md.ralt & kc.N0, md.lsft & kc.N2,
    ] @ combos_num,
    # NAV
    [
                          kc.HOME,        kc.UP,          kc.END,         cu.SNIP,              kc.GRAVE,        md.lsft & kc.N2,    md.lsft & kc.N4,    md.ralt & kc.E,
        kc.DEL,         kc.LEFT & ht,        kc.DOWN & ht,        kc.RGHT & ht,        md.lsft & kc.S,           md.lsft & kc.N0, kc.RBRC & ht,       kc.SLASH & ht,      md.lsft & kc.RBRC & ht, md.lsft & kc.N7,
      md.lctl & kc.Y, md.lctl & kc.X, md.lctl & kc.C, md.lctl & kc.V, tt & ht,          tt & ht,    kc.TAB,         md.lsft & kc.N5,    md.ralt & kc.MINUS, md.ralt & kc.RBRC,      md.lsft & kc.N6,
    ] @ combos_none,
    # DE
    [
                tt & ht, tt & ht, tt & ht, tt & ht,       fak.BOOT,   tt & ht, tt & ht, tt & ht,
        kc.LBRC, tt & ht, kc.QUOT & ht, md.ralt & kc.E & ht, kc.SCLN,      tt & ht, tt & ht, tt & ht, tt & ht, kc.MINUS,
      tt & ht, tt & ht, tt & ht, tt & ht,        tt & ht, tt & ht, tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,
    ] @ combos_none,
  ]
}