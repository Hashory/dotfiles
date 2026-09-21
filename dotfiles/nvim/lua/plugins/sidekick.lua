return {
  {
    "folke/sidekick.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      nes = { enabled = true },
      cli = {
        tools = {
          agy = {
            cmd = { "agy" },
            is_proc = "\\<agy\\>",
          },
        },
        win = {
          keys = {
            hide_alt = { "<A-q>", "hide", mode = { "n", "t" } },
            blur_alt = { "<A-z>", "blur", mode = { "n", "t" } },
            nav_left_alt = { "<A-h>", "nav_left", mode = { "n", "t" }, expr = true },
            nav_down_alt = { "<A-j>", "nav_down", mode = { "n", "t" }, expr = true },
            nav_up_alt = { "<A-k>", "nav_up", mode = { "n", "t" }, expr = true },
            nav_right_alt = { "<A-l>", "nav_right", mode = { "n", "t" }, expr = true },
          },
        },
      },
    },
    keys = {
      { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "AI CLI Toggle" },
      { "<leader>as", function() require("sidekick.cli").select() end, desc = "AI CLI Select" },
      {
        "<leader>ao",
        function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
        desc = "OpenCode",
      },
      {
        "<leader>ax",
        function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
        desc = "Codex",
      },
      {
        "<leader>ay",
        function() require("sidekick.cli").toggle({ name = "agy", focus = true }) end,
        desc = "Antigravity",
      },
      { "<leader>ad", function() require("sidekick.cli").close() end, desc = "AI CLI Detach" },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "AI Prompt",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Send File" },
      {
        "<c-.>",
        function() require("sidekick.cli").focus() end,
        desc = "AI CLI Focus",
        mode = { "n", "t", "i", "x" },
      },
    },
  },
}
