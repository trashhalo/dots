#!/usr/bin/env lua

-- SunnyDay Theme Generator
-- Generates both Neovim and Zed theme files from a single source

local json = require("json") or require("dkjson") or require("cjson")

-- Unified color palette
local colors = {
  white = "#FFFFFF",
  black = "#000000",
  navy = "#000080",
  dark_red = "#8B0000",
  dark_green = "#006400",
  purple = "#4B0082",
  gray = "#CCCCCC",
  light_blue = "#ADD8E6",
  yellow = "#FFFF00",
  red = "#FF0000",
  orange = "#FF8C00",
  blue = "#0000CD",
  dark_gray = "#555555",
  teal = "#008080",
  magenta = "#800080",
  cyan = "#008B8B",
  light_gray = "#DDDDDD",
  medium_gray = "#999999",
  light_green = "#32CD32",
  light_red = "#FF6347",
  gold = "#FFD700",
}

-- Theme metadata
local theme = {
  name = "SunnyDay",
  author = "Stephen Solka",
  appearance = "light",
}

-- Syntax mappings (shared logic)
local syntax = {
  -- Comments
  comment = { fg = colors.dark_gray, italic = true },

  -- Keywords and control flow
  keyword = { fg = colors.navy, bold = true },
  conditional = { fg = colors.navy, bold = true },
  ["repeat"] = { fg = colors.navy, bold = true },

  -- Functions
  ["function"] = { fg = colors.dark_red },
  method = { fg = colors.dark_red },

  -- Types
  type = { fg = colors.purple, bold = true },
  ["enum"] = { fg = colors.purple, bold = true },

  -- Literals
  string = { fg = colors.dark_green },
  number = { fg = colors.purple },
  boolean = { fg = colors.purple, bold = true },

  -- Variables
  variable = { fg = colors.black },
  variable_builtin = { fg = colors.navy, italic = true },

  -- Operators
  operator = { fg = colors.black, bold = true },

  -- Special
  tag = { fg = colors.navy, bold = true },
  attribute = { fg = colors.purple, italic = true },
}

-- UI mappings
local ui = {
  background = colors.white,
  foreground = colors.black,
  cursor_line = colors.gray,
  selection = colors.light_blue,
  border = colors.gray,
  border_focused = colors.navy,
  line_number = colors.dark_gray,
  line_number_active = colors.navy,
  search = colors.yellow,
  error = colors.red,
  warning = colors.orange,
  info = colors.blue,
  hint = colors.teal,
}

-- Generate Neovim theme
function generate_neovim_theme()
  local lines = {}

  -- Header
  table.insert(lines, "-- " .. theme.name .. " Neovim Color Scheme")
  table.insert(lines, "-- Generated from sunnyday-generator.lua")
  table.insert(lines, "-- Author: " .. theme.author)
  table.insert(lines, "")
  table.insert(lines, "local M = {}")
  table.insert(lines, "")

  -- Color palette
  table.insert(lines, "-- Color Palette")
  table.insert(lines, "local colors = {")
  for name, hex in pairs(colors) do
    table.insert(lines, string.format('\t%s = "%s",', name, hex))
  end
  table.insert(lines, '\tnone = "NONE",')
  table.insert(lines, "}")
  table.insert(lines, "")

  -- Setup function
  table.insert(lines, "function M.setup()")
  table.insert(lines, '\tvim.cmd("highlight clear")')
  table.insert(lines, '\tif vim.fn.exists("syntax_on") then')
  table.insert(lines, '\t\tvim.cmd("syntax reset")')
  table.insert(lines, '\tend')
  table.insert(lines, '\tvim.g.colors_name = "' .. string.lower(theme.name) .. '"')
  table.insert(lines, "")

  -- Highlights
  table.insert(lines, "\t-- Define highlight groups")
  table.insert(lines, "\tlocal highlights = {")

  -- UI highlights
  table.insert(lines, "\t\t-- UI Elements")
  table.insert(lines, string.format('\t\tNormal = { fg = colors.%s, bg = colors.%s },',
    "black", "white"))
  table.insert(lines, string.format('\t\tCursorLine = { bg = colors.%s },', "gray"))
  table.insert(lines, string.format('\t\tCursorLineNr = { fg = colors.%s, bold = true },', "navy"))
  table.insert(lines, string.format('\t\tLineNr = { fg = colors.%s },', "dark_gray"))
  table.insert(lines, string.format('\t\tVisual = { bg = colors.%s },', "light_blue"))
  table.insert(lines, string.format('\t\tSearch = { fg = colors.black, bg = colors.%s },', "yellow"))
  table.insert(lines, "")

  -- Syntax highlights
  table.insert(lines, "\t\t-- Basic Syntax")
  table.insert(lines, '\t\tComment = { fg = colors.dark_gray, italic = true },')
  table.insert(lines, '\t\tString = { fg = colors.dark_green },')
  table.insert(lines, '\t\tNumber = { fg = colors.purple },')
  table.insert(lines, '\t\tBoolean = { fg = colors.purple, bold = true },')
  table.insert(lines, '\t\tFunction = { fg = colors.dark_red },')
  table.insert(lines, '\t\tKeyword = { fg = colors.navy, bold = true },')
  table.insert(lines, '\t\tType = { fg = colors.purple, bold = true },')
  table.insert(lines, '\t\tOperator = { fg = colors.black, bold = true },')

  -- Add more as needed...
  table.insert(lines, "\t}")
  table.insert(lines, "")

  -- Apply highlights
  table.insert(lines, "\t-- Apply highlights")
  table.insert(lines, "\tfor group, styles in pairs(highlights) do")
  table.insert(lines, "\t\tvim.api.nvim_set_hl(0, group, styles)")
  table.insert(lines, "\tend")
  table.insert(lines, "end")
  table.insert(lines, "")
  table.insert(lines, "return M")

  return table.concat(lines, "\n")
end

-- Generate Zed theme
function generate_zed_theme()
  local zed_theme = {
    ["$schema"] = "https://zed.dev/schema/themes/v0.1.0.json",
    name = theme.name,
    author = theme.author,
    themes = {
      {
        name = theme.name,
        appearance = theme.appearance,
        style = {
          -- Base colors
          background = ui.background,
          ["background.appearance"] = "opaque",
          border = ui.border,
          ["border.variant"] = ui.border,
          ["border.focused"] = ui.border_focused,
          ["border.selected"] = ui.border_focused,
          ["elevated_surface.background"] = ui.background,
          ["surface.background"] = ui.background,

          -- Text colors
          text = ui.foreground,
          ["text.muted"] = colors.dark_gray,
          ["text.placeholder"] = colors.medium_gray,
          ["text.disabled"] = colors.medium_gray,
          ["text.accent"] = colors.navy,

          -- Editor specific
          ["editor.foreground"] = ui.foreground,
          ["editor.background"] = ui.background,
          ["editor.active_line.background"] = ui.cursor_line,
          ["editor.line_number"] = ui.line_number,
          ["editor.active_line_number"] = ui.line_number_active,

          -- Search
          ["search.match_background"] = ui.search,

          -- Diagnostics
          error = ui.error,
          ["error.background"] = ui.error .. "20",
          warning = ui.warning,
          ["warning.background"] = ui.warning .. "20",
          info = ui.info,
          ["info.background"] = ui.info .. "20",
          hint = ui.hint,
          ["hint.background"] = ui.hint .. "20",

          -- Syntax highlighting
          syntax = {}
        }
      }
    }
  }

  -- Convert syntax mappings to Zed format
  local zed_syntax = {}

  -- Map our syntax definitions to Zed's syntax tokens
  zed_syntax.comment = {
    color = syntax.comment.fg,
    font_style = syntax.comment.italic and "italic" or nil
  }

  zed_syntax.keyword = {
    color = syntax.keyword.fg,
    font_weight = syntax.keyword.bold and 700 or nil
  }

  zed_syntax["function"] = {
    color = syntax["function"].fg
  }

  zed_syntax.string = {
    color = syntax.string.fg
  }

  zed_syntax.number = {
    color = syntax.number.fg
  }

  zed_syntax.boolean = {
    color = syntax.boolean.fg,
    font_weight = syntax.boolean.bold and 700 or nil
  }

  zed_syntax.type = {
    color = syntax.type.fg,
    font_weight = syntax.type.bold and 700 or nil
  }

  zed_syntax.operator = {
    color = syntax.operator.fg,
    font_weight = syntax.operator.bold and 700 or nil
  }

  zed_syntax.variable = {
    color = syntax.variable.fg
  }

  zed_syntax["variable.builtin"] = {
    color = syntax.variable_builtin.fg,
    font_style = syntax.variable_builtin.italic and "italic" or nil
  }

  -- Assign to theme
  zed_theme.themes[1].style.syntax = zed_syntax

  return json.encode(zed_theme, { indent = true })
end

-- Main execution
function main()
  local neovim_theme = generate_neovim_theme()
  local zed_theme = generate_zed_theme()

  -- Write Neovim theme
  local nvim_file = io.open(os.getenv("HOME") .. "/.config/nvim/colors/sunnyday.lua", "w")
  if nvim_file then
    nvim_file:write(neovim_theme)
    nvim_file:close()
    print("✓ Generated Neovim theme: ~/.config/nvim/colors/sunnyday.lua")
  else
    print("✗ Failed to write Neovim theme")
  end

  -- Write Zed theme
  local zed_file = io.open(os.getenv("HOME") .. "/.config/zed/themes/sunnyday.json", "w")
  if zed_file then
    zed_file:write(zed_theme)
    zed_file:close()
    print("✓ Generated Zed theme: ~/.config/zed/themes/sunnyday.json")
  else
    print("✗ Failed to write Zed theme")
  end
end

-- Run if executed directly
if arg and arg[0]:match("sunnyday%-generator%.lua$") then
  main()
end

return {
  colors = colors,
  theme = theme,
  syntax = syntax,
  ui = ui,
  generate_neovim_theme = generate_neovim_theme,
  generate_zed_theme = generate_zed_theme,
}
