-- ~/.config/VelocityNvim/lua/utils/terminal.lua
-- Native Terminal-Funktionalität ohne externe Plugins (VelocityNvime optimiert)

local M = {}

-- Compatibility layer
local uv = vim.uv or vim.loop
local api = vim.api

-- Speichert die aktiven Terminal-Buffer
local terminals = {
  horizontal = nil,
  vertical = nil,
  floating = nil,
}

-- Cached window dimensions für floating terminal (Performance-Optimierung)
local cached_dimensions = {
  width = nil,
  height = nil,
  row = nil,
  col = nil,
  last_update = 0
}

-- Cache TTL in milliseconds
local DIMENSION_CACHE_TTL = 1000

-- PERFORMANCE-OPTIMIERUNG: Terminal-Dimensionen cachen da vim.o.* Zugriffe relativ teuer sind
-- Bei häufigem Terminal-Toggle (Alt+i) spürbare Verbesserung, besonders auf älteren Systemen
local function get_floating_dimensions()
  local now = uv.hrtime() / 1000000  -- Hochauflösender Timer für präzise TTL-Kontrolle

  -- CACHE-HIT: Dimensionen sind noch aktuell (TTL nicht abgelaufen)
  if cached_dimensions.width and (now - cached_dimensions.last_update) < DIMENSION_CACHE_TTL then
    return cached_dimensions.width, cached_dimensions.height, cached_dimensions.row, cached_dimensions.col
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Cache aktualisieren
  cached_dimensions = {
    width = width,
    height = height,
    row = row,
    col = col,
    last_update = now
  }

  return width, height, row, col
end

-- Performance-optimierte Terminal-Konfiguration
local function configure_terminal_buffer(bufnr, win)
  -- Buffer-Optionen (batch-optimiert)
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].filetype = "terminal"

  -- Window-Optionen (nur wenn Window übergeben)
  if win then
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
  end
end

--- Toggle horizontales Terminal
function M.toggle_horizontal_terminal()
  if terminals.horizontal and api.nvim_buf_is_valid(terminals.horizontal) then
    -- Terminal ist offen - finde und schließe Window
    local wins = vim.fn.win_findbuf(terminals.horizontal)
    for _, win in ipairs(wins) do
      api.nvim_win_close(win, false)
    end
    terminals.horizontal = nil
  else
    -- Terminal öffnen
    vim.api.nvim_command("botright 12split")
    vim.api.nvim_command("terminal")

    local buf = api.nvim_get_current_buf()
    local win = api.nvim_get_current_win()

    terminals.horizontal = buf
    configure_terminal_buffer(buf, win)

    -- Starte im Terminal-Modus
    vim.api.nvim_command("startinsert")
  end
end

--- Toggle vertikales Terminal
function M.toggle_vertical_terminal()
  if terminals.vertical and api.nvim_buf_is_valid(terminals.vertical) then
    -- Terminal ist offen - finde und schließe Window
    local wins = vim.fn.win_findbuf(terminals.vertical)
    for _, win in ipairs(wins) do
      api.nvim_win_close(win, false)
    end
    terminals.vertical = nil
  else
    -- Terminal öffnen
    vim.api.nvim_command("vertical botright 80vsplit")
    vim.api.nvim_command("terminal")

    local buf = api.nvim_get_current_buf()
    local win = api.nvim_get_current_win()

    terminals.vertical = buf
    configure_terminal_buffer(buf, win)

    -- Starte im Terminal-Modus
    vim.api.nvim_command("startinsert")
  end
end

--- Toggle Floating Terminal (mit caching und optimiertem styling)
function M.toggle_floating_terminal()
  if terminals.floating and api.nvim_buf_is_valid(terminals.floating) then
    -- Terminal ist offen - finde und schließe Window
    local wins = vim.fn.win_findbuf(terminals.floating)
    for _, win in ipairs(wins) do
      api.nvim_win_close(win, false)
    end
    terminals.floating = nil
  else
    -- Terminal öffnen
    local buf = api.nvim_create_buf(false, true)
    local width, height, row, col = get_floating_dimensions()

    -- Icons für konsistentes Styling
    local icons = require("core.icons")

    local win = api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      title = " " .. icons.misc.terminal .. " Terminal ",
      title_pos = "center",
      zindex = 50,
    })

    -- Terminal erstellen
    vim.api.nvim_command("terminal")
    terminals.floating = buf
    configure_terminal_buffer(buf, win)

    -- Starte im Terminal-Modus
    vim.api.nvim_command("startinsert")
  end
end

--- Alle Terminal-Instanzen schließen mit erweiterten Edge Cases
function M.close_all_terminals()
  local closed_count = 0
  local failed_count = 0
  local icons = require("core.icons")

  -- EDGE CASE: Mehr als 10 Terminals könnten Performance-Problem darstellen
  local terminal_count = 0
  for _ in pairs(terminals) do terminal_count = terminal_count + 1 end

  if terminal_count > 10 then
    local choice = vim.fn.confirm(
      string.format("Warnung: %d Terminal-Instanzen gefunden. Alle schließen?", terminal_count),
      "&Ja\n&Nein\n&Nur aktive",
      2
    )
    if choice == 2 then return end
    if choice == 3 then
      -- Nur wirklich sichtbare Terminals schließen
      for term_type, buf in pairs(terminals) do
        if buf and api.nvim_buf_is_valid(buf) then
          local wins = vim.fn.win_findbuf(buf)
          if #wins > 0 then
            for _, win in ipairs(wins) do
              local success = pcall(api.nvim_win_close, win, false)
              if success then
                closed_count = closed_count + 1
              else
                failed_count = failed_count + 1
              end
            end
            terminals[term_type] = nil
          end
        end
      end
      local utils = require("utils")
      utils.notify(string.format("%s %d aktive Terminal(s) geschlossen", icons.misc.terminal, closed_count), vim.log.levels.INFO)
      return
    end
  end

  for term_type, buf in pairs(terminals) do
    if buf and api.nvim_buf_is_valid(buf) then
      -- EDGE CASE: Terminal könnte in unschließbarem Window sein
      local wins = vim.fn.win_findbuf(buf)
      for _, win in ipairs(wins) do
        local success = pcall(api.nvim_win_close, win, false)
        if not success then
          -- Force-Close falls normales Schließen fehlschlägt
          pcall(api.nvim_buf_delete, buf, { force = true })
          failed_count = failed_count + 1
        end
      end
      terminals[term_type] = nil
      closed_count = closed_count + 1
    else
      -- EDGE CASE: Stale Buffer-Referenzen bereinigen
      terminals[term_type] = nil
    end
  end

  if closed_count > 0 or failed_count > 0 then
    local utils = require("utils")
    local message = string.format("%s %d Terminal(s) geschlossen", icons.misc.terminal, closed_count)
    if failed_count > 0 then
      message = message .. string.format(" (%d force-closed)", failed_count)
    end
    utils.notify(message, vim.log.levels.INFO)
  end
end

--- Terminal-Status anzeigen
function M.get_terminal_status()
  local status = {}
  local icons = require("core.icons")

  for term_type, buf in pairs(terminals) do
    if buf and api.nvim_buf_is_valid(buf) then
      local wins = vim.fn.win_findbuf(buf)
      table.insert(status, {
        type = term_type,
        buffer = buf,
        windows = #wins,
        icon = term_type == "floating" and icons.misc.terminal or
               term_type == "horizontal" and "─" or "│"
      })
    end
  end

  return status
end

--- Terminal-Informationen ausgeben
function M.print_terminal_info()
  local status = M.get_terminal_status()
  local icons = require("core.icons")

  print(icons.misc.terminal .. " Terminal Status:")

  if #status == 0 then
    print("  " .. icons.status.info .. " Keine aktiven Terminals")
  else
    for _, term in ipairs(status) do
      print(string.format("  %s %s: Buffer %d (%d Window%s)",
        term.icon, term.type:gsub("^%l", string.upper), term.buffer,
        term.windows, term.windows == 1 and "" or "s"))
    end
  end

  -- Keybindings anzeigen
  print("\n" .. icons.status.list .. " Verfügbare Befehle:")
  print("  Alt+- - Horizontales Terminal")
  print("  Alt+\\ - Vertikales Terminal")
  print("  Alt+i - Floating Terminal")
  print("  <leader>tf - Floating Terminal")
  print("  <leader>tc - Alle Terminals schließen")
end

--- Setup-Funktion mit optimierten Autocommands und Which-Key Integration
function M.setup()
  -- Terminal-spezifische Autocommands (gruppiert für Performance)
  local terminal_group = vim.api.nvim_create_augroup("VelocityTerminal", { clear = true })

  -- Automatisch in Terminal-Modus wechseln
  vim.api.nvim_create_autocmd("TermOpen", {
    group = terminal_group,
    desc = "Configure terminal on open",
    callback = function(ev)
      local bufnr = ev.buf

      -- Buffer-Konfiguration
      configure_terminal_buffer(bufnr)

      -- Starte im Insert-Modus
      vim.schedule(function()
        if api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_command("startinsert")
        end
      end)
    end,
  })

  -- Auto-Insert beim Betreten von Terminal-Buffern
  vim.api.nvim_create_autocmd("BufEnter", {
    group = terminal_group,
    pattern = "term://*",
    desc = "Auto insert in terminal buffers",
    callback = function()
      if vim.bo.buftype == "terminal" then
        vim.api.nvim_command("startinsert")
      end
    end,
  })

  -- Cache invalidieren bei Resize
  vim.api.nvim_create_autocmd("VimResized", {
    group = terminal_group,
    desc = "Invalidate dimension cache on resize",
    callback = function()
      cached_dimensions.last_update = 0
    end,
  })

  -- Keymaps einrichten
  local keymap_opts = { silent = true, noremap = true }

  -- Alt-Tastenkombinationen (Ihre gewünschten Keybindings)
  vim.keymap.set("n", "<A-->", M.toggle_horizontal_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal horizontal" }))
  vim.keymap.set("n", "<A-\\>", M.toggle_vertical_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal vertikal" }))

  -- Floating Terminal mit Alt+i (wichtigste Terminal-Funktion)
  vim.keymap.set("n", "<A-i>", M.toggle_floating_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal floating" }))

  -- Leader-basierte Keymaps für Which-Key Gruppierung
  vim.keymap.set("n", "<leader>tf", M.toggle_floating_terminal,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal floating" }))
  vim.keymap.set("n", "<leader>tc", M.close_all_terminals,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal alle schließen" }))
  vim.keymap.set("n", "<leader>ti", M.print_terminal_info,
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal info" }))

  -- Terminal-Modus Keymaps
  vim.keymap.set("t", "jk", [[<C-\><C-n>]],
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal-Modus verlassen" }))
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]],
    vim.tbl_extend("force", keymap_opts, { desc = "Terminal-Modus verlassen" }))

  -- Window-Navigation aus Terminal
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], { desc = "Links" })
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], { desc = "Unten" })
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], { desc = "Oben" })
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], { desc = "Rechts" })

  -- Which-Key Registrierung (defer für Verfügbarkeit)
  vim.defer_fn(function()
    local ok, which_key = pcall(require, "which-key")
    if ok then
      local icons = require("core.icons")
      which_key.add({
        { "<leader>t", group = icons.misc.terminal .. " Terminal" },
        { "<leader>tf", desc = "Floating Terminal" },
        { "<leader>tc", desc = "Alle schließen" },
        { "<leader>ti", desc = "Terminal Info" },
      })
    end
  end, 100)
end

return M