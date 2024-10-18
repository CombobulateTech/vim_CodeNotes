" Write a help menu

" ###############################################
" ######## Standard Setup Variable Stuff ########
" ###############################################

" Set Compatible Options to the value of vim
set cpo&vim

" Check to see if the plugin is already loaded
if exists('g:loaded_code_notes')
    finish
endif

" Load the plugin
let g:loaded_code_notes = 1


" Load the help files in the .vim/doc directory if it exists
if isdirectory($HOME . "/.vim/doc/code_notes")
    execute "helptags " . $HOME . "/.vim/doc"
endif

" Set a variable to check if CNoteOpen runs
let b:CNote_Open_Run = 0

" ###########################################
" ######## User assignable variables ########
" ###########################################

" Set auto save when original file save, also save the code note
if !exists('CNotes_Auto_Save')
    let CNotes_Auto_Save = 1
endif

" Set auto open, to open a Code Note when shortcuts are used
if !exists('CNotes_Auto_Open')
    let CNotes_Auto_Open = 1
endif

" Set debug mode
if !exists('CNotes_Debug')
    let CNotes_Debug = 0
endif

" Set split to be a percentage of the size rather than exact size
if !exists('CNotes_Split_Size_Operation')
    let CNotes_Split_Size_Operation = 'percentage'
endif

" Set the split size value to be used in the calculation of size
if !exists('CNotes_Split_Size_Value')
    let CNotes_Split_Size_Value = 37.0
endif

" Set the Split type defaults to vsplit
if !exists('CNotes_Split_Type')
    let CNotes_Split_Type = 'vsplit'
    let CNotes_Split_Size_Type = 'vertical'
endif

" Set the split location
if !exists('CNotes_Split_Loc')
    let CNotes_Split_Loc = 'topleft'
endif

" Set the split size based on the value and the operation
" Check the Split Metric type to determine if percentage or exact size
if CNotes_Split_Size_Operation ==? 'percentage'
    " Check if vertical to set the width, else set the height
    " Note that split size must be an integer, not a float
    if CNotes_Split_Size_Type ==? 'vertical'
        let CNotes_Split_Size =
                    \ str2nr(winwidth('%') * (CNotes_Split_Size_Value / 100))
    else
        let CNotes_Split_Size =
                    \ str2nr(winheight('%') * (CNotes_Split_Size_Value / 100))
    endif
else
    let CNotes_Split_Size = CNotes_Split_Size_Value
endif

" ###########################################
" ######## Key Mappings and Commands ########
" ###########################################

" Create a map for pulling a single line in normal mode
noremap <silent> <localleader>cnc :call code_notes#code_notes#CNotes_Copy("normal", "paste")<cr>

" Create a map for pulling lines(s) from visual mode
vnoremap <silent> <localleader>cnc
            \ :<c-u>call code_notes#code_notes#CNotes_Copy("visual", "paste")<cr>

" Create a map for replacing a single line in normal mode
noremap <silent> <localleader>cnr
            \ :call code_notes#code_notes#CNotes_Copy("normal", "replace")<cr>

" Create a map for replacing lines(s) from visual mode
vnoremap <silent> <localleader>cnr
            \ :<c-u>call code_notes#code_notes#CNotes_Copy("visual", "replace")<cr>

" Create a map for deleting a single line in normal mode
noremap <silent> <localleader>cnd :call code_notes#code_notes#CNotes_Copy("normal", "delete")<cr>

" Create a map for deleting lines(s) from visual mode
vnoremap <silent> <localleader>cnd
            \ :<c-u>call CNotes_Copy("visual", "delete")<cr>

" Command to call the function to create a new window or open an existing
" window
command! -nargs=* CNoteOpen call code_notes#code_notes#CNotes_Window_Open(
    \ CNotes_Split_Loc,
    \ CNotes_Split_Size_Type,
    \ CNotes_Split_Type,
    \ CNotes_Split_Size)

" Save the code note after saving the original file
if CNotes_Auto_Save
    augroup save_stuff
        autocmd!
        autocmd BufWritePost, * :call code_notes#code_notes#CNotes_Save()
    augroup END
endif
