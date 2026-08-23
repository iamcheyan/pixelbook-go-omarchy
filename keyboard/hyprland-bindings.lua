-- Pixelbook Go Atlas action-row overrides.
-- Merge this block into ~/.config/hypr/bindings.lua.

hl.unbind("F24")
hl.unbind("code:58")

hl.unbind("F3")
hl.bind("F3", hl.dsp.exec_cmd("omarchy-capture-screenshot"), {
  description = "Pixelbook screenshot"
})

hl.unbind("F4")
hl.bind("F4", hl.dsp.exec_cmd("omarchy-menu toggle"), {
  description = "Pixelbook Omarchy menu"
})
