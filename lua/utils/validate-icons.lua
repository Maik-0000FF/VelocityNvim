-- Icon-Referenz-Validator
-- Überprüft alle Icon-Referenzen im Code auf Existenz

local function validate_icons()
  local icons = require("core.icons")
  local errors = {}

  -- Sammle alle .lua Dateien
  local files = vim.fn.globpath("lua/plugins,lua/core", "**/*.lua", false, true)

  for _, file in ipairs(files) do
    if file:match("icons%.lua$") then
      goto continue
    end

    local content = vim.fn.readfile(file)
    for line_nr, line in ipairs(content) do
      -- Finde Icon-Referenzen: icons.xxx.yyy
      for icon_ref in line:gmatch("icons%.([%w_.]+)") do
        local parts = vim.split(icon_ref, "%.")
        local current = icons
        local path = "icons"

        for _, part in ipairs(parts) do
          path = path .. "." .. part
          if not current[part] then
            table.insert(errors, {
              file = file,
              line = line_nr,
              icon_path = path,
              full_line = line:match("^%s*(.-)%s*$"),
            })
            break
          end
          current = current[part]
        end
      end
    end
    ::continue::
  end

  if #errors > 0 then
    vim.notify(icons.status.error .. " Icon-Referenz-Fehler gefunden:", vim.log.levels.ERROR)
    for _, err in ipairs(errors) do
      print(string.format("  %s:%d - %s", err.file, err.line, err.icon_path))
    end
    return false
  else
    vim.notify(icons.status.success .. " Alle Icon-Referenzen sind gültig", vim.log.levels.INFO)
    return true
  end
end

return { validate = validate_icons }

