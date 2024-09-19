" ######################################
" ######## Function Definitions ########
" ######################################

function! code_notes#code_notes#Test_Code()
    echom "Code Notes Test"
endfunction

" Function to check if open has been run and if the Code Note is still open
function! code_notes#code_notes#CNotes_Status()
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Status"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Check to see if CNoteOpen has already ran
    if !b:CNote_Open_Run
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " Open_Run has not been set, execute " .
                        \ "Cnotes_Auto_Open"
        endif

        " Check to see if auto open is set, if set, automatically open Code
        " Note
        if g:CNotes_Auto_Open
            call code_notes#code_notes#CNotes_Window_Open(
                \ g:CNotes_Split_Loc,
                \ g:CNotes_Split_Size_Type,
                \ g:CNotes_Split_Type,
                \ g:CNotes_Split_Size)
            return 1
        else
            " Debug message
            if g:CNotes_Debug
                echom l:Function_Name . " exiting function with an error"
            endif

            " Display error and exit
            echom "You must run CNoteOpen to open a Code Note before " .
                        \ "trying to paste a note"
            return 0
        endif
    endif

    " Check to see if Code Notes is already open
    if bufnr(s:CodeNote_File_Path) == -1
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " the Code Note has been cloased execute " .
                        \ "Cnotes_Auto_Open"
        endif

        " Check to see if auto open is set, if set, automatically open Code
        " Note
        if CNotes_Auto_Open
            call <SID>CNotes_Window_Open(
                \ g:CNotes_Split_Loc,
                \ g:CNotes_Split_Size_Type,
                \ g:CNotes_Split_Type,
                \ g:CNotes_Split_Size)
            return 1
        else
            " Debug message
            if g:CNotes_Debug
                echom l:Function_Name . " exiting function with an error"
            endif

            " Display error and exit
            echom "You must run CNoteOpen to open a Code Note before " .
                        \ "trying to paste a note"
            return 0
        endif
    endif

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " returning 1 as a successful status"
    endif

    return 1

endfunction

" Function to delete the line number(s) in the Code Note
function! code_notes#code_notes#CNotes_Delete(CodeNoteLine, FilePath)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Status"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Pull the starting line number or single line number
    let l:CodeNote_Line = getpos(".")[1]
    
    " Check Code Notes status
    if !code_notes#code_notes#CNotes_Status()
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " status returned 0, exit"
        endif

        return
    endif

    " Switch to the open code notes window
    call code_notes#code_notes#CNotes_Switch_Window(s:CodeNote_File_Path, l:CodeNote_Line)

    " Find a count of all occurences of the line
    redir => l:substitute_search_output 
        %substitute/^11//gn
    redir END

    " Split the output of the substitute search to get just the count of lines
    let l:line_search_count = split(l:substitute_search_output)[0]

    " Go to the start of the file to systematically find all of the lines
    execute "normal! gg"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " loop through all lines that match and delete"
    endif

    " Loop through a count of all of the found lines to be deleted
    let loop_count = 1
    while loop_count <= l:line_search_count
        " Search for the next line to be removed
        execute "normal! " . search('^' . a:CodeNoteLine . ' ')

        " Check to see if there is more than 2 lines in the current paragraph
        " If there are more than 2 lines, then delete around the paragraph
        " to prevent leaving empty lines
        if line("'}") - line("'{") > 2
            " Visually select all around the paragraph, then delete
            execute "normal! Vapd"
        " If there are less than 2 lines, then add a blank line to the end
        " Just to keep the Notes clean
        else
            " Visually select inside the paragraph, then delete
            execute "normal! Vipd"
        endif

        " Increase the loop counter
        let loop_count += 1
    endwhile

    " Go back to the original file and line
    call code_notes#code_notes#CNotes_Switch_Window(a:FilePath, a:CodeNoteLine)

endfunction

" Function to replace the line number(s) in the Code Note
function! code_notes#code_notes#CNotes_Replace(CodeNoteLine, FilePath)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Replace"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Pull the starting line number or single line number
    let l:CodeNote_Line = getpos(".")[1]

    " Check Code Notes status
    if !code_notes#code_notes#CNotes_Status()
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " status returned 0, exit"
        endif

        return
    endif

    " Switch to the open code notes window
    call code_notes#code_notes#CNotes_Switch_Window(s:CodeNote_File_Path, l:CodeNote_Line)

    " Go to the end of the file to search backwards
    execute "normal! G"

    " Search for the last matching line with the number (reverse search)
    let l:line_number_search = search('^' . a:CodeNoteLine . '', 'b')

    if !l:line_number_search
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " line does not exist, call CNotes_Paste"
        endif

        call code_notes#code_notes#CNotes_Paste(a:CodeNoteLine, a:FilePath)
    else
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " line(s) exist, execute replace command"
        endif

        " Check to see if there is more than 2 lines in the current paragraph
        " The reason it is 2 lines is because the blank line counts
        " If there are more than 2 lines, don't add a blank line as it will
        " increase the amount of blank lines by 1
        if line("'}") - line("'{") > 2
            " Replace inner paragraph with the t register, then add the line 
            " number to the beginning
            execute "normal! Vip\"tp\<esc>{jI" . a:CodeNoteLine . " \<esc>"
        " If there are less than 2 lines, then add a blank line to the end
        " Just to keep the Notes clean
        else
            " Replace inner paragraph with the t register, add an empty line at
            " the end, then add the line number to the beginning
            execute "normal! Vip\"tp']o\<esc>{jI" . a:CodeNoteLine . " \<esc>"
        endif
    endif

    " Go back to the original file and line
    call code_notes#code_notes#CNotes_Switch_Window(a:FilePath, a:CodeNoteLine)

endfunction

" Function to save the Code Note after the original file is saved
function! code_notes#code_notes#CNotes_Save()
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Save"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Check to see if the Code Note has been opened
    if !b:CNote_Open_Run
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " Code Note is not currently open"
        endif

        return
    endif

    " Pull the current file name and full path to submit to the paste
    " so that we can return to the file after the paste is complete
    let l:File_Path = expand('%:p')

    " Pull the starting line number or single line number
    let l:CodeNote_Line = getpos(".")[1]


    " Check if Code Note is still open
    if code_notes#code_notes#CNotes_Open_Check(s:CodeNote_File_Path)
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " Code Note is still open, save Code Note"
        endif

        call code_notes#code_notes#CNotes_Switch_Window(s:CodeNote_File_Path, l:CodeNote_Line)
        echom "Switched Windows " . l:CodeNote_Line
        " Save the file
        write
        " Switch back to Original File and line number
        call code_notes#code_notes#CNotes_Switch_Window(l:File_Path, l:CodeNote_Line)
    endif

endfunction

" Function to get line number(s) and yank text from line numbers
function! code_notes#code_notes#CNotes_Copy(CNoteMode, CNoteType)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Copy"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Check if running in visual mode
    " Visual mode has different commands than normal mode
    if a:CNoteMode ==? 'visual'
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " execute the visual copy command"
        endif

        " Yank the visual lines into the t register
        execute "normal! `<v`>\"tY"

    " If normal mode, yank the line into the t register
    elseif a:CNoteMode ==? 'normal'
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " execute the normal copy command"
        endif

        " Yank the line in the T register
        execute "normal! \"tY"
    endif

    " Pull the starting line number or single line number
    let l:CodeNote_Line = getpos(".")[1]

    " Pull the current file name and full path to submit to the paste
    " so that we can return to the file after the paste is complete
    let l:File_Path = expand('%:p')

     if a:CNoteType ==? 'paste'
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " call CNotes_Paste function"
        endif

        call code_notes#code_notes#CNotes_Paste(CodeNote_Line, File_Path)
     endif

     if a:CNoteType ==? 'replace'
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " call CNotes_Replace function"
        endif

         call code_notes#code_notes#CNotes_Replace(CodeNote_Line, File_Path)
     endif

     if a:CNoteType ==? 'delete'
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " call CNotes_Delete function"
        endif

         call code_notes#code_notes#CNotes_Delete(CodeNote_Line, File_Path)
     endif

endfunction

" Function to paste the line number(s) and text from line numbers
function! code_notes#code_notes#CNotes_Paste(CodeNoteLine, FilePath)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Paste"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Check Code Notes status
    if !code_notes#code_notes#CNotes_Status()
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " status returned 0, exit"
        endif

        return
    endif

    " Switch to the open code notes window
    call code_notes#code_notes#CNotes_Switch_Window(s:CodeNote_File_Path, a:CodeNoteLine)

    " Go to the end of the Code Note
    " Create a new line
    " Insert the line number
    " Paste the line(s)
    execute "normal! Go" . a:CodeNoteLine . " \<c-r>t\<esc>"

    " Go back to the original file and line
    call code_notes#code_notes#CNotes_Switch_Window(a:FilePath, a:CodeNoteLine)

endfunction

" Function to find and switch to a new window based on file name
function! code_notes#code_notes#CNotes_Switch_Window(FullPathFile,LineNumber)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Switch_Window"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Get the Buffer Number of the file
    let l:File_Buffer_Num = bufnr(a:FullPathFile)

    " Get the Window Buffer Number from the buffer number
    let l:Window_Buffer_Num = win_findbuf(l:File_Buffer_Num)[0]

    " Switch to the Window Buffer for the file
    execute win_gotoid(l:Window_Buffer_Num)

    " Go back to the original line number
    execute "normal! " . a:LineNumber . "G"

endfunction

" Create a local script function to open a new window or move to existing
" window
function! code_notes#code_notes#CNotes_Window_Open(SplitLoc, SplitSizeType, SplitType, SplitSize)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Window_Open"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Use regex to search last part of extension of the file for codenotes
    if matchstr(expand('%:e'), 'codenotes$') ==? "codenotes"
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " this is a code note, error and exit"
        endif

        " Display error and exit
        echom "You cannot create a codenote of an existing codenote"
        return
    endif

    " Set the original file path, buffer, and window to be used as the buffer
    " name
    let s:Original_File_Path = expand('%:p')
    let s:Original_File_Buffer = bufnr(expand('%:p'))
    let s:Original_File_Window = winnr()

    " Assign the start line to return to after paste
    let l:Original_Start_Line = getpos(".")[1]

    " Check to see if codenotes is already open
    " If it is, exit CNotes_Window_Open
    if code_notes#code_notes#CNotes_Open_Check(s:Original_File_Path . ".codenotes")
        return
    endif

    " Open a new split
    execute a:SplitLoc . ' ' .
                \ a:SplitSizeType . ' ' .
                \ a:SplitSize .
                \ ' split ' . 
                \ expand('%:p') . 
                \ '.codenotes'

    " Remove line numbering to free up space in the smaller split
    setlocal nonumber
    " Set wrapping to make it easier to read notes in the smaller split
    setlocal wrap

    " Set the Code Notes file path, buffer, and window to be used as the buffer
    " name
    let s:CodeNote_File_Path = expand('%:p')
    let s:CodeNote_File_Buffer = bufnr(expand('%:p'))

    " Set a variable to set CNoteOpen has ran
    let b:CNote_Open_Run = 1

    " Check to see if the file is empty
    if getfsize(s:CodeNote_File_Path) < 1
        " Insert a header at the top
        execute "normal! ggI# This is your Codes Notes file\<cr>\<esc>"
    endif

    " Switch back to the original file
    call code_notes#code_notes#CNotes_Switch_Window(s:Original_File_Path, Original_Start_Line)

endfunction

" Function to check if the file is still open
function! code_notes#code_notes#CNotes_Open_Check(FilePath)
    " Define a variable for the function that is running
    let l:Function_Name = "CNotes_Open_Check"

    " Debug message
    if g:CNotes_Debug
        echom l:Function_Name . " has begun"
    endif

    " Check to see if there is an active buffer for the file
    if bufnr(a:FilePath) == -1
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " no buffer exists, return 0"
        endif

        let CNote_File_Open = 0
    else
        " Debug message
        if g:CNotes_Debug
            echom l:Function_Name . " buffer exists, return 1"
        endif

        let CNote_File_Open = 1
    endif
    " Return whether the file is open or closed
    return CNote_File_Open

endfunction
