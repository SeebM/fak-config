let { tap, hold, td, combo, macro, ..} = import "fak/keycode.ncl" in
let util = import "fak/util_functions.ncl" in

#   00 01 02 03 04    05 06 07 08 09
#  10 11 12 13 14      15 16 17 18 19
# 20 21 22 23 24   25   26 27 28 29 30

let virtual_keys' = [
  combo.make 40 [17, 18], # SCH
  combo.make 40 [1, 10],  # ESC
  combo.make 40 [1, 2], # TAB
  combo.make 40 [12, 13], # DOT
  combo.make 40 [17, 16], # COMMA
  combo.make 40 [3, 12],  # COLON
  combo.make 40 [6, 17],  # SEMI
  combo.make 30 [7, 8], # Enter
  combo.make 40 [21, 22], # LT
  combo.make 40 [28, 29], # GT
  combo.make 40 [22, 23],  # SQT
  combo.make 40 [27, 28],  # DQT
] in

let virtual_key_count = std.array.length virtual_keys' in
let key_count = 31 + virtual_key_count in

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
  NEOSEEB = "QVKC.,HGFPUIAEODNRTSXZYLMBWJ",
} in

let make_hrm = fun key_idx =>
  let htb_hrm_base = fun eager => {
    timeout_ms = 175,
    # quick_tap_ms = 100,
    # quick_tap_interrupt_ms = 500,
    # global_quick_tap_ms = 80,
    # eager_decision = eager,
    timeout_decision = 'hold,
  } in

  let virtual_interrupts = std.array.replicate virtual_key_count ki.hr in

  let htb_hrm_left = fun eager => htb_hrm_base eager & {
    key_interrupts = [
          ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,  ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
        ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.tp, ki.tp, ki.tp, ki.tp, ki.hr,  ki.hr,  ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
    ] @ virtual_interrupts
  } in

  let htb_hrm_right = fun eager => htb_hrm_base eager & {
    key_interrupts = [
          ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,  ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
        ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,      ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,  ki.hr,  ki.hr, ki.tp, ki.tp, ki.tp, ki.tp,
    ] @ virtual_interrupts
  } in

  let hrm_mods = [
    mdh.lgui, mdh.lalt, mdh.lsft, mdh.lctl,
    mdh.lctl, mdh.lsft, mdh.lalt, mdh.lgui,
  ] in

  let hrm_key_indices = [20, 11, 12, 13, 16, 17, 18, 30] in

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
    kc.TAB & lt 2 & hold.reg.behavior thumb_behavior,
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
  # copy custom stuff from example
  brc1  = macro.make [
    macro.press mdh.lsft,
    macro.tap kc.N8,
    macro.tap kc.N9,
    macro.release mdh.lsft,
    macro.tap kc.LEFT,
  ],
  brc2  = macro.make [
    macro.press mdh.ralt,
    macro.tap kc.N8,
    macro.tap kc.N9,
    macro.release mdh.ralt,
    macro.tap kc.LEFT,
  ],
  brc3  = macro.make [
    macro.press mdh.ralt,
    macro.tap kc.N7,
    macro.tap kc.N0,
    macro.release mdh.ralt,
    macro.tap kc.LEFT,
  ],
  SNIP = md.lsft & md.lgui & kc.S,
} in

let combos_base = [
  cu.SCH, kc.ESC, kc.TAB, kc.DOT, kc.COMMA, md.lsft & kc.DOT, md.lsft & kc.COMMA, kc.ENTER,kc.NUBS,md.lsft & kc.NUBS,md.lsft & kc.NUHS, md.lsft & kc.N2
] in
let combos_num = [
  tx & hx, kc.GRAVE, kc.TAB, kc.DOT, kc.COMMA, ks.COLN, kc.SCLN, kc.ENTER,md.ralt &kc.NUBS, md.ralt & kc.RBRC,tx & hx,md.lsft & kc.N0,
] in
let combos_none = [
  tx & hx, kc.ESC, kc.TAB, kc.DOT, kc.COMMA, tx & hx, tx & hx, kc.ENTER,tx & hx,tx & hx,tx & hx,tx & hx,
] in

### Keymap itself! ###
{
  virtual_keys = virtual_keys',
  layers = [
    let base = fun key_idx => (alphas layouts.NEOSEEB) |> std.array.at key_idx in
    # ALPHAS
    [
          base 0,  base 1,  base 2,  base 3,      media.MUTE  ,  md.lgui & md.lalt & kc.K,  base 6,  base 7,  base 8,  base 9,
        base 10, base 11, base 12, base 13, base 14,         base 15, base 16, base 17, base 18, base 19,
      base 20, base 21, base 22, base 23, thumb 0,   thumb 1,  thumb 2, base 24, base 25, base 26, base 27,
    ] @ combos_base,
    # NUM
    [
          kc.F1,             kc.F2,           kc.F3,           kc.F4,          kc.F5,          kc.F6,   kc.F7,           kc.F8,           kc.F9,                 kc.F10,
        kc.N1,             kc.N2 & ht,      kc.N3 & ht,      kc.N4 & ht,      kc.N5,             kc.N6,   kc.N7 & ht,     kc.N8 & ht,      kc.N9 & ht,             kc.N0,
      kc.DEL,             cu.brc3,         cu.brc2,         cu.brc1,        tt & ht,   tt & ht,   tt & ht, kc.RBRC & ht,    kc.SLASH & ht,  md.lsft & kc.RBRC & ht, md.lsft & kc.N7,
    ] @ combos_num,
    # NAV
    [
          kc.TAB,         kc.HOME,        kc.UP,          kc.END,         cu.SNIP,              md.lsft & kc.N5,         md.lsft & kc.N2,    kc.BSLS,     kc.GRAVE,         kc.NUHS,
        kc.DEL,         kc.LEFT & ht,        kc.DOWN & ht,        kc.RGHT & ht,        md.lsft & kc.S,           md.lsft & kc.N0, kc.RBRC & ht,       kc.SLASH & ht,      md.lsft & kc.RBRC & ht, md.lsft & kc.N7,
      md.lctl & kc.Y, md.lctl & kc.X, md.lctl & kc.C, md.lctl & kc.V, tt & ht,          tt & ht,    tt & ht,         md.lsft & kc.N6,    md.ralt & kc.BSLS, md.ralt & kc.RBRC,      md.ralt & kc.MINUS,
    ] @ combos_none,
    # DE
    [
          md.ralt & kc.Q, tt & ht, tt & ht, tt & ht, tt & ht,          fak.BOOT,tt & ht, tt & ht, tt & ht, kc.ENTER & ht,
        kc.LBRC, tt & ht, kc.QUOT & ht, md.ralt & kc.E & ht, kc.SCLN,      tt & ht, md.lsft & kc.N1 & ht, md.lsft & kc.MINUS & ht, tt & ht, kc.MINUS,
      tt & ht, tt & ht, tt & ht, tt & ht,        tt & ht, tt & ht, tt & ht, tt & ht, tt & ht, tt & ht, tt & ht,
    ] @ combos_none,
  ]
}
