" Smart keyboard switching

if !has("macunix")
	finish
endif

" Properties

" Index of default keyboard layout 
if !exists("g:kls_defaultInputSourceIndex")
  let g:kls_defaultInputSourceIndex = 0 " Use 0 if you are using default english keyboard layout (U.S.)
endif

" Path to KeyboardLayoutSwitcher binary
if !exists("g:kls_switcherPath")
  let g:kls_switcherPath = findfile('bin/KeyboardLayoutSwitcher', &rtp)
endif

" Layout storing when Vim’s focus is lost / gained
if !exists("g:kls_focusSwitching")
  let g:kls_focusSwitching = 1 " Enabled
endif

" Storing layouts of each tab
if !exists("g:kls_tabSwitching")
  let g:kls_tabSwitching = 1 " Enabled
endif

" Storing layout on InsertLeave and restoring on InsertEnter
if !exists("g:kls_insertEnterRestoresLast")
  let g:kls_insertEnterRestoresLast = 0 " Disabled
endif

" Set mappings
if !exists("g:kls_mappings")
  let g:kls_mappings = 1 " Enabled
endif


" Methods

" Store index of current keyboard layout into variable
function! Kls_StoreCurrentInputSource()
  let t:kls_currentInputSourceIndex = system(g:kls_switcherPath) 

  return t:kls_currentInputSourceIndex
endfunction

" Switch to default input source (kls_defaultInputSourceIndex)
function! Kls_SwitchToDefaultInputSource()
  return system(g:kls_switcherPath . " " . g:kls_defaultInputSourceIndex)
endfunction

" Restore stored index of keyboard layout from variable
function! Kls_RestoreLastInputSource()
  if exists("t:kls_currentInputSourceIndex")
    return system(g:kls_switcherPath . " " . t:kls_currentInputSourceIndex)
  else
    return Kls_SwitchToDefaultInputSource()
  endif
endfunction

" Store index of current keyboard layout into variable and
" switch to default input source (kls_defaultInputSourceIndex)
function! Kls_StoreCurrentAndSwitchToDefaultInputSource()
  call Kls_StoreCurrentInputSource()
  call Kls_SwitchToDefaultInputSource()
endfunction

" Events

if g:kls_focusSwitching != 0
  autocmd FocusLost * call Kls_StoreCurrentInputSource()
  autocmd FocusGained * call Kls_RestoreLastInputSource()
endif

if g:kls_tabSwitching != 0
  autocmd TabLeave * call Kls_StoreCurrentInputSource()
  autocmd TabEnter * call Kls_RestoreLastInputSource()
endif

autocmd VimEnter * call Kls_SwitchToDefaultInputSource()

if g:kls_insertEnterRestoresLast != 0
  autocmd InsertEnter * call Kls_RestoreLastInputSource()
  autocmd InsertLeave * call Kls_StoreCurrentAndSwitchToDefaultInputSource()
else
  autocmd InsertLeave * call Kls_SwitchToDefaultInputSource()
endif

" Keys mappings

if g:kls_mappings != 0
  noremap <silent> <Esc><Esc> :silent call Kls_SwitchToDefaultInputSource()<Esc><Esc>
endif
