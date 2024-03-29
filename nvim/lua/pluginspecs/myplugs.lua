return {
  { "mihaifm/bufstop", enabled = true },
  { name = "bufstop-dev", dir = "D:/Syncbox/Projects/bufstop", enabled = false },

  ----------------

  { "mihaifm/vimpanel", enabled = true },
  { name = "vimpanel-dev", dir = "D:/Syncbox/Projects/vimpanel", enabled = false },

  ----------------

  { "mihaifm/4colors", enabled = false,
    config = function() vim.cmd.colorscheme("4colors") end
  },
  { name = "4colors-dev", dir = "D:/Syncbox/Projects/4colors", enabled = false,
    config = function() vim.cmd.colorscheme("4colors") end
  }
}
