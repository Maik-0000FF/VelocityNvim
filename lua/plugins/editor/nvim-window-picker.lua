local ok, window_picker = pcall(require, "window-picker")
if not ok then
  return
end

window_picker.setup({
  hint = "floating-big-letter",
  picker_config = {
    floating_big_letter = {
      font = "ansi-shadow",
    },
  },
  filter_rules = {
    bo = {
      filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
      buftype = { "terminal", "quickfix" },
    },
  },
})

_G.VelocityWindowPicker = window_picker