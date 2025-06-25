--local colorschemeName = nixCats('colorscheme')
--if not require('nixCatsUtils').isNixCats then
--  colorschemeName = 'onedark'
--end
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!
--vim.cmd.colorscheme(colorschemeName)

-- It's good practice to set the background first
vim.o.background = 'dark'

-- Set the colorscheme
vim.cmd.colorscheme 'tokyonight'

require("conf.plugins.oil")

require('lze').load {
  { import = "conf.plugins.telescope", },
  { import = "conf.plugins.treesitter", },
  {
    "indent-blankline.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require("ibl").setup()
    end,
  },
}
