return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertLeave" },
    opts = {
      format_on_save = function()
        if not vim.g.autoformat then
          return
        end
        return { async = false, timeout_ms = 500, lsp_fallback = false }
      end,
      formatters_by_ft = {
        sh = { "shfmt" },
        zsh = { "shfmt" },
        bash = { "shfmt" },
        rust = { "rustfmt" },
        go = { "goimports", "gofmt" },
        javascript = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier", "markdownlint-cli2" },
        python = { "isort", "ruff_format" },
        terraform = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
        tex = { "latexindent" },
        toml = { "taplo" },
        typst = { "typstfmt" },
        yaml = { "yamlfmt" },
      },
    },
    config = function(_, opts)
      local conform = require("conform")

      opts.preformat = function(bufnr)
        local ft = vim.bo[bufnr].filetype -- ← istället för vim.api.nvim_buf_get_option
        if ft == "lua" then
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local tmpfile = vim.fn.tempname() .. ".lua"
          vim.fn.writefile(lines, tmpfile)
          vim.fn.system({ "stylua", tmpfile })
          local new_lines = vim.fn.readfile(tmpfile)
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
          vim.fn.delete(tmpfile)
        end
      end

      conform.setup(opts)

      -- Shell
      conform.formatters.shfmt = { prepend_args = { "-i", "2", "-ci" } }

      -- Lua
      conform.formatters.stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } }

      -- YAML
      conform.formatters.yamlfmt =
        { prepend_args = { "-formatter", "indent=2,include_document_start=true,retain_line_breaks_single=true" } }

      -- Prettier
      conform.formatters.prettier = { prepend_args = { "--tab-width", "2" } }

      -- Taplo
      conform.formatters.taplo = { prepend_args = { "--indent", "2" } }
    end,
  },

  {
    "folke/flash.nvim",
    opts = {},
    keys = {
      {
        "ss",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            pattern = ".",
            search = {
              mode = function(pattern)
                if pattern:sub(1, 1) == "." then
                  pattern = pattern:sub(2)
                end
                return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
              end,
            },
          })
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
    },
  },

  {
    "echasnovski/mini.surround",
    event = { "BufReadPre", "BufNewFile" },
    opts = { n_lines = 50 },
  },

  {
    "gbprod/substitute.nvim",
    keys = {
      {
        "s",
        function()
          require("substitute").operator()
        end,
        desc = "Substitute",
      },
      {
        "s",
        mode = "x",
        function()
          require("substitute").visual()
        end,
        desc = "Substitute",
      },
    },
    opts = {},
  },

  {
    {
      "folke/todo-comments.nvim",
      event = "BufReadPre",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { highlight = { multiline = false } },
      keys = {
        {
          "<leader>sT",
          function()
            local Snacks = require("snacks")
            Snacks.picker.todo_comments()
          end,
          desc = "Todo",
        },
      },
    },
  },

  {
    "allaman/emoji.nvim",
    dev = true,
    ft = "markdown",
    opts = { enable_cmp_integration = true, plugin_path = vim.fn.expand("~/workspace/github.com/johsve-source") },
  },

  {
    "saghen/blink.cmp",
    dependencies = { "allaman/emoji.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        default = { "emoji" },
        providers = {
          emoji = {
            name = "emoji",
            module = "blink.compat.source",
            transform_items = function(_, items)
              local kind = require("blink.cmp.types").CompletionItemKind.Text
              for i = 1, #items do
                items[i].kind = kind
              end
              return items
            end,
          },
        },
      },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      { "<leader>R", "", desc = "Search & Replace" },
      { "<leader>RG", "<cmd>GrugFar<cr>", desc = "Open" },
      {
        "<leader>Rg",
        "<cmd>lua require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })<cr>",
        desc = "Open (Limit to current file)",
      },
      {
        "<leader>Rw",
        "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<cr>",
        desc = "Search word under cursor",
      },
      {
        "<leader>Rs",
        mode = "v",
        "<cmd>lua require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand('%') } })<cr>",
        desc = "Search selection",
      },
    },
  },

  {
    "echasnovski/mini.align",
    keys = {
      { "ga", mode = { "v" }, desc = "Align" },
      { "gA", mode = { "v" }, desc = "Align with Preview" },
    },
    opts = {},
  },
}
