return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 30,
      },
    })
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        require("nvim-tree.api").tree.open()
      end,
    })
  end,
}
