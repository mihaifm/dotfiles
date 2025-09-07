local M = {}

M.tips = {
  "Use :arga to quickly add files to the argument list: `:arga **/*.lua`. Cycle them with :n and :N",
  "Perfom find and replace in multiple files with `:vim /TODO/ ** | cdo s/TODO/DONE/g`",
  "Open multiple files directly in a vertical split: `nvim -O file1 file2 file3`",
  "Diff every window against the first with `:windo diffthis`, then clear diffs with `:diffoff!`",
  "Reload the file discarding all unsaved changes with `:e!`",
  "Go to the beginning of the next method with `]m`",
  "Navigate to the middle of the screen with M, to the top with H (high) and to the bottom with L (low)",
  "Toggle between last two files with `<C-^>` for rapid context switching",
  "Find and edit a file in a folder (including subfolders): `:set path=/folder/** | find file.txt`",
  "Cycle through jumps with `<C-i>` and `<C-o>`",
  "Cycle through changes with `g;` and `g,`",
  "Negate and option with !:  `:set hls!`",
  "Quickly create a term buffer at the bottom: `:bo 15sp +te`",
  "Split all files in the argument list with `:vert sall`",
  "Make a copy of the global argument list, local to the current window with `:argl`",
  "Grep all files in the args list with `:vimgrep /TODO/ ##`",
  "Split window and find file: `:sf file`",
  "Paste the contents of an expression, variable etc: `\"=&runtimepath` then `p`",
  "Paste the output of a vim command to the current buffer with the expression register: `\"=execute('hi')` then `p`",
  "Allow gf and :find to search vim runtime: `:set path+=$VIMRUNTIME`",
  "Change directory of the current window to the head of the current file with `:lcd %:h`",
  "Make current window the only one: `:only` or `:on` or `<C-w>o`",
  "Separate two commands with a | in a mapping by using <bar>: `nnoremap <space> :silent make <bar> redraw!<CR>`",
  "Press <C-f> in the command line to open command editor",
  "Run `:first` to go to the first file in the argument list",
  "Insert a line matched by a pattern at the cursor position: `:/pattern/t.`. Requires `:/` (using `/` won't do it)",
  "Use `:tj` to jump to a tag",
  "You can specify any separator for the search command to avoid escaping: `:s#/home#/usr#gc`",
  "Prefer `:diffoff! for clearing diffs. `:diffoff` only clears diffs for the current file",
}

function M.random_tip()
  local n = #M.tips
  if n == 0 then return "" end

  local idx = (vim.uv.hrtime() % n) + 1
  return "Tip: " .. M.tips[idx]
end

return M
