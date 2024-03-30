function BufstopConfig()
  vim.keymap.set('n', '<leader>D',
    function()
      vim.cmd('BufstopBack'); vim.cmd('bw! #')
    end,
    { desc = 'Bufstop wipe buffer without closing window' })

  vim.keymap.set('n', '<leader>b', function() vim.cmd('Bufstop') end,
    { desc = 'Bufstop' })
  vim.keymap.set('n', '<leader>b', function() vim.cmd('BufstopPreview') end,
    { desc = 'Bufstop Preview' })
  vim.keymap.set('n', '<leader>a', function() vim.cmd('BufstopModeFast') end,
    { desc = 'Bufstop in the command line' })

  vim.g.BufstopAutoSpeedToggle = 1
  vim.g.BufstopSplit = 'topleft'
  -- vim.g.BufstopFileSymbolFunc = 'MyGetFileTypeSymbol'
end

function VimpanelConfig()
  vim.cmd('cabbrev ss VimpanelSessionMake')
  vim.cmd('cabbrev sl VimpanelSessionLoad')
  vim.cmd('cabbrev vp Vimpanel')
  vim.cmd('cabbrev vl VimpanelLoad')
  vim.cmd('cabbrev vc VimpanelCreate')
  vim.cmd('cabbrev ve VimpanelEdit')
  vim.cmd('cabbrev vo VimpanelOpen')
  vim.cmd('cabbrev vr VimpanelRemove')
end

return {
  {
    "mihaifm/bufstop",
    enabled = true,
    config = BufstopConfig
  },
  {
    name = "bufstop-dev",
    enabled = false,
    config = BufstopConfig,
    dir = "D:/Syncbox/Projects/bufstop"
  },

  ---------------------------------------------

  {
    "mihaifm/vimpanel",
    enabled = true,
    config = VimpanelConfig
  },
  {
    name = "vimpanel-dev",
    enabled = false,
    dir = "D:/Syncbox/Projects/vimpanel",
    config = VimpanelConfig
  },

  ---------------------------------------------

  {
    "mihaifm/4colors",
    enabled = false,
    config = function() vim.cmd.colorscheme("4colors") end
  },
  {
    name = "4colors-dev",
    enabled = false,
    dir = "D:/Syncbox/Projects/4colors",
    config = function() vim.cmd.colorscheme("4colors") end
  }
}
