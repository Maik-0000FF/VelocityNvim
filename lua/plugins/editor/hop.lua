local ok, hop = pcall(require, "hop")
if not ok then
  return
end

hop.setup({
  keys = "etovxqpdygfblzhckisuran",
  jump_on_sole_occurrence = true,
  case_insensitive = true,
})
