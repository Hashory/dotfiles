return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      terminal = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        "<leader>e",
        function()
          local picker = Snacks.picker.get({ source = "explorer" })[1]
          if picker then
            if picker:is_focused() then
              picker:close()
            else
              picker:focus("list")
            end
          else
            Snacks.explorer()
          end
        end,
        desc = "File Explorer",
      },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<C-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    },
  },
}
