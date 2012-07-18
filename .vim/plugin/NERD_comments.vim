" vim global plugin that provides easy code commenting for various file types
" Last Change:  24 mar 2005
" Maintainer:   Martin Grenfell <mrg39 at student.canterbury.ac.nz>
let s:NERD_comments_version = 1.18


" For help documentation type :help NERD_comments. If this fails, Restart vim
" and try again. If it sill doesnt work... the help page is at the bottom 
" of this file.

" Section: script init stuff {{{1
if exists("loaded_nerd_comments")
   finish
endif
let loaded_nerd_comments = 1

"here we get a string that is the same length as a tabstop but with spaces
"instead of a tab. Also, we store the number of spaces in a tab
let s:tabSpace = ""
let s:spacesPerTab = &tabstop
while s:spacesPerTab > 0
    let s:tabSpace = s:tabSpace . " "
    let s:spacesPerTab = s:spacesPerTab - 1
endwhile
let s:spacesPerTab = &tabstop

" Section: Comment mapping autocommands and functions {{{1
" ============================================================================
" Section: Comment enabler autocommands {{{2
" ============================================================================
augroup commentEnablers
        " have to make it detect the filetype every time you enter a different buffer
        " otherwise you could be editing eg a C file and then open a new window with
        " the makefile in it, make some changes, close the makefile, return to the C
        " file and still have all the comment options set for makefiles! This is
        " because, by default, vi only sets the filetype when a buffer is loaded - not
        " entered.
        autocmd BufEnter * :filetype detect

        " some versions of vim dont have an h filetype... so we set it
        " ourselves
        autocmd BufEnter *.h :setfiletype h

        " set  up the autocommands that will activate the appropriate comment
        " mappings for each filetype that is encountered
        autocmd FileType c call <SID>MapDelimiters("\\\/\\\*","\\\*\\\/") 
        autocmd FileType prolog call <SID>MapDelimitersWithAlternative("%","","\\\/\\\*","\\\*\\\/", exists("NERD_use_c_style_prolog_comments")) 
        autocmd FileType java call <SID>MapDelimitersWithAlternative("\\\/\\\/","", "\\\/\\\*","\\\*\\\/", exists("NERD_use_c_style_java_comments"))
        autocmd FileType cpp call <SID>MapDelimitersWithAlternative("\\\/\\\/","", "\\\/\\\*","\\\*\\\/", exists("NERD_use_c_style_cpp_comments"))
        autocmd FileType cs call <SID>MapDelimitersWithAlternative("\\\/\\\/","", "\\\/\\\*","\\\*\\\/", exists("NERD_use_c_style_cs_comments"))
        autocmd FileType h call <SID>MapDelimitersWithAlternative("\\\/\\\/","", "\\\/\\\*","\\\*\\\/",  exists("NERD_use_c_style_h_comments") )
        autocmd FileType ada call <SID>MapDelimiters("--","") 
        autocmd FileType haskell call <SID>MapDelimiters("--","") 
        autocmd FileType lisp call <SID>MapDelimiters(";","") 
        autocmd FileType vim call <SID>MapDelimiters("\"","") 
        autocmd FileType xml,dtd,xslt,ant,html call <SID>MapDelimiters("<!--","-->") 
        autocmd FileType make,sh,perl,python,tcl,ruby call <SID>MapDelimiters("#","") 
        autocmd FileType tex call <SID>MapDelimiters("%","") 
        autocmd FileType pascal call <SID>MapDelimiters("{","}")
        autocmd FileType dosbatch call <SID>MapDelimiters("REM ","")
        autocmd FileType st call <SID>MapDelimiters("\\\"","\\\"")
augroup END

" Function: s:MapDelimiters(2) function {{{2
" This function is a wrapper for s:MapDelimiters(4) and is called when there
" is no alternative comment delimiters for the current filetype
"
" Args:
"   -cin: the left comment delimiter
"   -cout: the right comment delimiter
function s:MapDelimiters(cin, cout)
    call <SID>MapDelimitersWithAlternative(a:cin, a:cout, "", "", 0)
endfunction


" Function: s:MapDelimiters(5) function {{{2
" this function sets up the comment mappings
"
" Args:
"   -cin:  the string defining the comment start delimiter
"   -cout: the string defining the comment end delimiter
"   -cinAlt:  the string for the alternative comment style defining the comment start delimiter
"   -coutAlt: the string for the alternative comment style defining the comment end delimiter
"   -useAlt: a flag specifying whether to use the alternative comment style 0 is
"    false
function s:MapDelimitersWithAlternative(cin, cout, cinAlt, coutAlt, useAlt)

    " if the useAlt flag is not set then we use a:cin and a:cout
    " as the left and right comment delimiters
    if a:useAlt == 0
        let b:left = a:cin
        let b:right = a:cout
        let b:leftAlt = a:cinAlt
        let b:rightAlt = a:coutAlt
    else
        let b:left = a:cinAlt
        let b:right = a:coutAlt
        let b:leftAlt = a:cin
        let b:rightAlt = a:cout
    endif

    "if the user has defined a custom mapping to switch to the alternative
    "comment style, use it. Otherwise use the default
    if exists("g:NERD_alt_com_map")
        execute 'nmap ' . g:NERD_alt_com_map . ' :call <SID>SwitchToAlternativeDelimiters(1)<cr>'
    else
        nmap <leader>ca :call <SID>SwitchToAlternativeDelimiters(1)<cr>
    endif


    "if the user has defined a custom mapping to comment out the current line,
    "use it. Otherwise use the default
    if exists("g:NERD_com_line_map")
        execute 'nmap ' . g:NERD_com_line_map . ' :call <SID>AddDelimiters(b:left, b:right, 0)<cr>'
        execute 'vmap ' . g:NERD_com_line_map . ' :call <SID>DoVisualComment(line("' . "\'" . '<"), line("' . "\'" . '>"), col("' . "\'" . '<"), col("' . "\'" . '>"), b:left, b:right, 0)<cr><ESC>'
    else
        nmap <leader>cc :call <SID>AddDelimiters(b:left, b:right, 0)<cr>
        vmap <leader>cc :call <SID>DoVisualComment(line("'<"), line("'>"), col("'<"), col("'>"), b:left, b:right, 0)<cr><Esc>
    endif

    "if the user has defined a custom mapping to uncomment out the current line,
    "use it. Otherwise use the default
    if exists("g:NERD_uncom_line_map")
        execute 'map ' . g:NERD_uncom_line_map . ' :call <SID>RemoveDelimiters(b:left, b:right, b:leftAlt, b:rightAlt)<cr><ESC>'
    else
        map <leader>cu :call <SID>RemoveDelimiters(b:left, b:right, b:leftAlt, b:rightAlt)<cr><ESC>
    endif

    "if the user has defined a custom mapping to comment out the current line
    "and force nesting, use it. Otherwise use the default
    if exists("g:NERD_com_line_nest_map")
        execute 'nmap ' . g:NERD_com_line_nest_map . ' :call <SID>AddDelimiters(b:left, b:right, 1)<cr>'
        execute 'vmap ' . g:NERD_com_line_nest_map . ' :call <SID>DoVisualComment(line("' . "\'" . '<"), line("' . "\'" . '>"), col("' . "\'" . '<"), col("' . "\'" . '>"), b:left, b:right, 1)<cr><ESC>'
    else
        nmap <leader>cn :call <SID>AddDelimiters(b:left, b:right, 1)<cr>
        vmap <leader>cn :call <SID>DoVisualComment(line("'<"), line("'>"), col("'<"), col("'>"), b:left, b:right, 1)<cr><Esc>
    endif

    "if the user has defined a custom mapping to comment to the EOL
    "use it. Otherwise use the default
    if exists("g:NERD_com_to_end_of_line_map")
        execute 'nmap ' . g:NERD_com_to_end_of_line_map . ' :call <SID>AddDelimitersToRegion(line("."), line("."), col("."), col("$")-1, b:left, b:right, 1)<cr><ESC>'
    else
        nmap <leader>c$ :call <SID>AddDelimitersToRegion(line("."), line("."), col("."), col("$")-1, b:left, b:right, 1)<cr><ESC>
    endif

    "if the user has defined a custom mapping to add comment delimiters and
    "insert between them use it. Otherwise use the default
    if exists("g:NERD_com_in_insert_map")
        execute 'imap ' . NERD_com_in_insert_map . '<SPACE><BS><ESC>:call <SID>PlaceDelimitersAndInsBetween(b:left, b:right)<CR>'
    else
        imap <C-c> <SPACE><BS><ESC>:call <SID>PlaceDelimitersAndInsBetween(b:left, b:right)<CR>
    endif
endfunction



" Function: s:SwitchToAlternativeDelimiters() function {{{2
" This function is used to swap the delimiters that are being used to the
" alternative delimiters for that filetype. For example, if a c++ file is
" being edited and // comments are being used, after this function is called
" /**/ comments will be used.
"
" Args:
"   -printMsgs: if this is 1 then a message is echoed to the user telling them
"    if this function changed the delimiters or not 
function s:SwitchToAlternativeDelimiters(printMsgs)

    "if both of the alternative delimiters are empty then there is no
    "alternative comment style so bail out 
    if (b:leftAlt=="" && b:rightAlt=="")
        if a:printMsgs 
            echomsg "Cannot use alternative delimiters, none are specified"
        endif
        return 0
    endif

    "save the current delimiters 
    let tempLeft = b:left
    let tempRight = b:right

    "swap current delimiters for alternative 
    let b:left = b:leftAlt
    let b:right = b:rightAlt
    
    "set the previously current delimiters to be the new alternative ones 
    let b:leftAlt = tempLeft
    let b:rightAlt = tempRight

    "tell the user what comment delimiters they are now using 
    if a:printMsgs
	let leftNoEsc = substitute(b:left, "\\", "", "g")
	let rightNoEsc = substitute(b:right, "\\", "", "g")
	echomsg "Now using " . leftNoEsc . " " . rightNoEsc . " to delimit comments"
    endif

    return 1
endfunction

" Section: Comment delimiter add/removal functions {{{1
" ============================================================================
" Function: s:PlaceDelimitersAndInsBetween() function {{{2
" This is function is called to place comment delimiters down and place the
" cursor between them
"
" Args:
"   -left: the left comment delimiter
"   -right: the right comment delimiter
function s:PlaceDelimitersAndInsBetween(left, right)
    " get the left and right delimiters without any escape chars in them 
    let left2 = substitute(a:left, "\\", "", "g")
    let right2 = substitute(a:right, "\\", "", "g")

    " get the len of the right delim
    let lenRight = strlen(right2) 

    " stick the delimiters down and a space to take into account that
    " pressing ESC moves you left one
    execute ":normal a" . left2 . right2 . " "

    " if there is a right delimiter then we gotta move the cursor left
    " by the len of the right delimiter so we insert between the delimiters
    if lenRight > 0 
        execute ":normal " . lenRight . "h"
    endif

    startinsert
endfunction
 
" Function: s:DoVisualComment() function {{{2
" This function is called to comment out a bunch of lines in visual mode. It
" doesnt do the work itself but determines if we are in block-vis or another
" vis mode and delegates the work to another function.
"
" Args:
"   -top: the line number for the top line of code in the region
"   -bottom: the line number for the bottom line of code in the region
"   -left: the column number for the left most column in the region
"   -right: the column number for the right most column in the region
"   -cin: the left comment delimiter
"   -cout: the right comment delimiter
"   -forceNested: a flag indicating whether comments should be nested 
function s:DoVisualComment(top, bottom, left, right, cin, cout, forceNested) range
    
    "find out if we are in block vis mode or not and call the appropriate
    "function to do the commenting 
    if <SID>GetCurrentVisMode() == ""
	execute ":" . a:firstline . "," . a:lastline . "call <SID>AddDelimitersToRegion(a:top, a:bottom, a:left, a:right, a:cin, a:cout, a:forceNested)"
    else
	execute ":" . a:firstline . "," . a:lastline . "call <SID>AddDelimiters(a:cin, a:cout, a:forceNested)"
    endif
endfunction

" Function: s:AddDelimiters() function {{{2
" this function is called to add the comment delimiters to the start and end
" of the current line. 
"
" Args:
"   -left: a string representing the left delimiter of the comment
"   -right: a string representing the right delimiter of the comment, is "" if
"    there is no right delimiter
"   -forceNested: a flag indicating whether the called is requesting the comment
"    to be nested if need be
function s:AddDelimiters(left, right, forceNested)
    if <SID>GetCanCommentLine(a:left, a:right, a:forceNested)==1
        " save the old value of nlsearch and then turn hlsearch off so
        " that the results of our substitutions aren't highlighted
        let old_nohlsearch=&hlsearch
        set nohlsearch
        "save the col the cursor is on
        let oldCol = col(".")
   
        "add the left and right delimiters to the line  
        silent! execute 's/^\([ \t]*\)/\1' . a:left . '/'
        silent! execute 's/$/' . a:right . '/'

        " set the hlsearch options back to what it was before this
        " function was called
        let &hlsearch=old_nohlsearch
        "restore the column position  
        call cursor(".", oldCol)
        
    endif
endfunction

" Function: s:AddDelimitersToRegion() function {{{2
" This function is used to comment out a region of code. This region is
" specified as a bounding box by arguments to the function. Note that the
" range keyword is specified for this function. This is because this function
" cannot be applied implicitly to every line specified in visual mode
"
" Args:
"   -top: the line number for the top line of code in the region
"   -bottom: the line number for the bottom line of code in the region
"   -left: the column number for the left most column in the region
"   -right: the column number for the right most column in the region
"   -cin: the left comment delimiter
"   -cout: the right comment delimiter
"   -forceNested: a flag indicating whether comments should be nested 
function s:AddDelimitersToRegion(top, bottom, left, right, cin, cout, forceNested ) range

    "save the position the cursor was on before the commenting is done 
    let initCol = col(".")
    let initLine = line(".")

    "we must check that bottom IS actually below top, if it is not then we
    "swap top and bottom. Similarly for left and right. 
    if a:bottom < a:top
        let temp = a:top
        let top = a:bottom
        let bottom = a:top
    else 
        let top = a:top
        let bottom = a:bottom
    endif
    if a:right < a:left
        let temp = a:left
        let left = a:right
        let right = temp
    else
        let left = a:left
        let right = a:right
    endif

    "if the top or bottom line starts with tabs we have to adjust the left and
    "right boundries so that they are set as though the tabs were spaces 
    let topline = getline(top)
    let bottomline = getline(bottom)
    if topline =~ '^\t\t*'  || bottomline =~ '^\t\t*' 
	"find out how many tabs are in the top line and adjust the left
	"boundry accordingly 
	let numTabs = strlen(substitute(topline, '^\(\t*\).*$', '\1', "")) 
	if left < numTabs
	    let left = s:spacesPerTab * left
	else
	    let left = (left - numTabs) + (s:spacesPerTab * numTabs)
	endif

	"find out how many tabs are in the bottom line and adjust the right
	"boundry accordingly 
	let numTabs = strlen(substitute(bottomline, '^\(\t*\).*$', '\1', "")) 
	let right = (right - numTabs) + (s:spacesPerTab * numTabs)
    endif

    "get versions of cin/cout without the escape chars 
    let cinNoEsc = substitute(a:cin, "\\", "", "g")
    let coutNoEsc = substitute(a:cout, "\\", "", "g")

    "we need the len of cinNoEsc soon 
    let lenCinNoEsc = strlen(cinNoEsc) 

    "start the commenting from the top and keep commenting till we reach the
    "bottom
    let currentLine=top
    while currentLine <= bottom
	
	"check if we are allowed to comment this line 
	if <SID>GetCanCommentLine(a:cin, a:cout, a:forceNested)

	    "convert the leading tabs into spaces 
	    let theLine = getline(currentLine)
	    call setline(currentLine, <SID>ConvertLeadingTabsToSpaces(theLine))

	    "attempt to place the cursor in on the left of the boundary box,
	    "then check if we were successful, if not then we cant comment this
	    "line 
	    call cursor(currentLine, left)
	    if col(".") == left && line(".") == currentLine

		"stick the left delimiter down 
		execute 'normal i' . cinNoEsc

		"attempt to go the the right boundary to place the right
		"delimiter, if we cant go to the right boundary then the
		"comment delimiter will be placed on the EOL. 
		call cursor(currentLine, right+lenCinNoEsc)
		execute 'normal a' . coutNoEsc
	    endif
        endif

	"if the user doesnt have expand tabs set then we gotta set the tabs
	"back to how they were --- to be polite :P 
	if !&expandtab
	    call setline(currentLine, <SID>ConvertLeadingSpacesToTabs(getline(currentLine)))
	endif

        "move onto the next line 
        let currentLine = currentLine + 1
	call cursor(currentLine, 0)
    endwhile

    "return the cursor to its previous position 
    call cursor(initLine, initCol)

endfunction

" Function: s:RemoveDelimiters() function {{{2
" this function is called to remove the first left comment delimiter and the
" last right delimiter of the current line. 
"
" The args left and right must be strings. If there is no right delimiter (as
" is the case for e.g vim file comments) them the arg right should be ""
"
" Args:
"   -left: the left comment delimiter
"   -right: the right comment delimiter
"   -leftAlt: the alternative left comment delimiter
"   -rightAlt: the alternative right comment delimiter
function s:RemoveDelimiters(left, right, leftAlt, rightAlt)

    "get the left and right delimiters without the esc chars. Also, get their
    "lengths
    let l:left = substitute(a:left, "\\", "", "g")
    let l:right = substitute(a:right, "\\", "", "g")
    let lenLeft = strlen(left)
    let lenRight = strlen(right)

    "save the line before we attempt to uncomment it. Later we need to know if
    "we changed the line or not
    let lineBefore = getline(".")

    "look for the left delimiter, if we find it, remove it. 
    let leftIndx = <SID>FindDelimiterIndex(a:left, getline("."))
    if leftIndx != -1
        let line = getline(".")
        call setline(line("."), strpart(line, 0, leftIndx) . strpart(line, leftIndx+lenLeft))
    endif

    "look for the right delimiter, if we find it, remove it 
    let rightIndx = <SID>FindDelimiterIndex(a:right, getline("."))
    if rightIndx != -1
        let line = getline(".")
        call setline(line("."), strpart(line, 0, rightIndx) . strpart(line, rightIndx+lenRight))
    endif

    "check if we found either of the left/right delimiters... if we didnt (and
    "the user hasnt otherwise) look for the alternative delimiters and remove
    "them
    if getline(".") == lineBefore && !exists("NERD_dont_remove_alt_coms")

        "get the left/right alternative delimters without the esc chars and
        "get their lengths
        let l:leftAlt = substitute(a:leftAlt, "\\", "", "g")
        let l:rightAlt = substitute(a:rightAlt, "\\", "", "g")
        let lenLeftAlt = strlen(leftAlt)
        let lenRightAlt = strlen(rightAlt)

        "look for the left alternative delimiter, if we find it, remove it. 
        let leftIndx = <SID>FindDelimiterIndex(a:leftAlt, getline("."))
        if leftIndx != -1
            let line = getline(".")
            call setline(line("."), strpart(line, 0, leftIndx) . strpart(line, leftIndx+lenLeftAlt))
        endif

        "look for the right alternative delimiter, if we find it, remove it. 
        let rightIndx = <SID>FindDelimiterIndex(a:rightAlt, getline("."))
        if rightIndx != -1
            let line = getline(".")
            call setline(line("."), strpart(line, 0, rightIndx) . strpart(line, rightIndx+lenRightAlt))
        endif

    endif
endfunction

" Section: Other helper functions {{{1
" ============================================================================
" Function: s:GetCanCommentLine() function {{{2
"This function is used to determine whether the current line can be commented
"It returns true (1) if either the current line has not been commented or if
"   - the forceNested flag is set and the comment style has no right delimiter
"   - or if the NERD_use_nested_comments_default option is set and the comment
"     style has no right delimiter
"
" Args:
"   -left: The left comment delimiter
"   -right: the right comment delimiter
"   -forceNested: a flag indicating whether the caller wants comments to be nested
"    if the current line is already commented
function s:GetCanCommentLine(left, right, forceNested)
    " make sure we don't comment lines that are just spaces or tabs or empty.
    if getline(".") !~ "^[ \t]*$" 

        "if the line isnt commented return true
        if <SID>FindDelimiterIndex(a:left, getline(".")) == -1
            return 1
        else

            "if the line is commented, check if the either the forceNested flag 
            "or the g:NERD_allow_nested_comments flag is set. Also, make sure the
            "right delimiter is null to avoid compiler errors
            if (a:forceNested==1 ||exists("g:NERD_use_nested_comments_default")) && a:right==""
                return 1
            endif
        endif
    endif

    return 0
endfunction


" Function: s:FindDelimiterIndex() function {{{2
" This function is used to get the string index of the input comment delimiter
" on the input line. If no valid comment delimiter is found in the line then
" -1 is returned
" Args:
"   -delimiter: the delimiter we are looking to find the index of
"   -line: the line we are looking for delimiter on
function s:FindDelimiterIndex(delimiter, line)
     
    "make sure the delimiter isnt empty otherwise we go into an infintie loop.
    if a:delimiter == ""
        return -1
    endif

    "get the delimiter without esc chars and its length
    let l:delimiter = substitute(a:delimiter, "\\", "", "g")
    let lenDel = strlen(l:delimiter)

    "get the index of the first occurance of the delimter 
    let delIndx = stridx(a:line, l:delimiter)

    "keep looping thru the line till we either find a real comment delimiter
    "or run off the EOL 
    while delIndx != -1

        "if we are not off the EOL get the str before the possible delimiter
        "in question and check if it really is a delimiter. If it is, return
        "its position 
        if delIndx != -1
            if <SID>IsDelimValid(l:delimiter, delIndx, a:line)
                return delIndx
            endif
        endif

        "we have not yet found a real comment delimiter so move past the
        "current one we are lookin at 
        let restOfLine = strpart(a:line, delIndx + lenDel)
        let distToNextDelim = stridx(restOfLine , l:delimiter)

        "if distToNextDelim is -1 then there is no more potential delimiters
        "on the line so set delIndx to -1. Otherwise, move along the line by
        "distToNextDelim 
        if distToNextDelim == -1
            let delIndx = -1
        else
            let delIndx = delIndx + lenDel + distToNextDelim
        endif
    endwhile

    "there is no comment delimiter on this line 
    return -1
endfunction

" Function: s:IsDelimValid() function {{{2
" This function is responsible for determining whether a given instance of a
" comment delimiter is a real delimiter or not. For example, in java the
" // string is a comment delimiter but in the line:
"               System.out.println("//");
" it does not count as a comment delimiter. This function is responsible for
" distinguishing between such cases. It does so by applying a set of
" heuristics that are not fool proof but should work most of the time.
"
" Args:
"   -delimiter: the delimiter we are validating
"   -delIndx: the position of delimiter in line
"   -line: the line that delimiter occurs in
"
" Returns:
" 0 if the given delimiter is not a real delimiter (as far as we can tell) , 
" 1 otherwise
function s:IsDelimValid(delimiter, delIndx, line)
    "get the delimiter without the escchars 
    let l:delimiter = substitute(a:delimiter, "\\", "", "g")

    "get the string before the delimiter 
    let preComStr = strpart(a:line, 0, a:delIndx)

    "to check if the delimiter is real, make sure it isnt preceded by
    "an odd number of quotes (which would indicate that it is part of
    "a string and therefore is not a comment
    if !<SID>IsNumEven(<SID>CountNonESCedOccurances(preComStr, '"', "\\")) 
        return 0
    endif
    if !<SID>IsNumEven(<SID>CountNonESCedOccurances(preComStr, "'", "\\"))
        return 0
    endif
    if !<SID>IsNumEven(<SID>CountNonESCedOccurances(preComStr, "`", "\\"))
        return 0
    endif

    "if the comment delimiter is escaped, assume it isnt a real delimiter 
    if <SID>IsEscaped(a:line, a:delIndx, "\\")
        return 0
    endif
    
    "vim comments are so fuckin stupid!! Why the hell do they have comment
    "delimiters that are used elsewhere in the syntax?!?! We need to check
    "some conditions especially for vim 
    if &filetype == "vim"
        
        "if the delimiter is on the very first char of the line or is the
        "first non-tab/space char on the line then it is a valid comment delimiter 
        if a:delIndx == 0 || a:line =~ "^[ \t]\\{" . a:delIndx . "\\}\".*$"
            return 1
        endif

        let numLeftParen =<SID>CountNonESCedOccurances(preComStr, "(", "\\") 
        let numRightParen =<SID>CountNonESCedOccurances(preComStr, ")", "\\") 

        "if the quote is inside brackets then assume it isnt a comment 
        if numLeftParen > numRightParen
           return 0
        endif

        "if the line has an even num of unescaped "'s then we can assume that
        "any given " is not a comment delimiter
        if <SID>IsNumEven(<SID>CountNonESCedOccurances(a:line, "\"", "\\"))
            return 0
        endif
    endif

    return 1

endfunction

" Function: s:IsNumEven() function {{{2
" A small function the returns 1 if the input number is even and 0 otherwise
" Args:
"   -num: the number to check
function s:IsNumEven(num)
    return (a:num % 2) == 0
endfunction

" Function: s:CountNonESCedOccurances() function {{{2
" This function counts the number of substrings contained in another string.
" These substrings are only counted if they are not escaped with escChar
" Args:
"   -str: the string to look for searchstr in
"   -searchstr: the substring to search for in str
"   -escChar: the escape character which, when preceding an instance of
"    searchstr, will cause it not to be counted
function s:CountNonESCedOccurances(str, searchstr, escChar)
    "get the index of the first occurance of searchstr
    let indx = stridx(a:str, a:searchstr)


    "if there is an instance of searchstr in str process it
    if indx != -1 
        "get the remainder of str after this instance of searchstr is removed
        let lensearchstr = strlen(a:searchstr)
        let strLeft = strpart(a:str, indx+lensearchstr)

        "if this instance of searchstr is not escaped, add one to the count
        "and recurse. If it is escaped, just recurse 
        if !<SID>IsEscaped(a:str, indx, a:escChar)
            return 1 + <SID>CountNonESCedOccurances(strLeft, a:searchstr, a:escChar)
        else
            return <SID>CountNonESCedOccurances(strLeft, a:searchstr, a:escChar)
        endif
    endif
endfunction

" Function: s:IsEscaped() {{{2
" This function takes a string, an index into that string and an esc char and
" returns 1 if the char at the index is escaped (i.e if it is preceded by an
" odd number of esc chars)
" Args:
"   -str: the string to check
"   -indx: the index into str that we want to check
"   -escChar: the escape char the char at indx may be ESCed with
function s:IsEscaped(str, indx, escChar)
    "initialise numEscChars to 0 and look at the char before indx 
    let numEscChars = 0
    let curIndx = a:indx-1

    "keep going back thru str until we either reach the start of the str or
    "run out of esc chars 
    while curIndx >= 0 && strpart(a:str, curIndx, 1) == a:escChar
        
        "we have found another esc char so add one to the count and move left
        "one char
        let numEscChars  = numEscChars + 1
        let curIndx = curIndx - 1

    endwhile

    "if there is an odd num of esc chars directly before the char at indx then
    "the char at indx is escaped
    return !<SID>IsNumEven(numEscChars)
endfunction

" Function: s:ConvertLeadingTabsToSpaces() {{{2
" This function takes a line and converts all leading spaces on that line into
" tabs
"
" Args:
"   -line: the line whose leading spaces will be converted
function s:ConvertLeadingTabsToSpaces(line)
    let toReturn  = a:line
    while toReturn =~ '^\( *\)\t'
	let toReturn = substitute(toReturn, '^\( *\)\t',  '\1' . s:tabSpace , "")
    endwhile
    
    return toReturn
endfunction

" Function: s:ConvertLeadingSpacesToTabs() {{{2
" This function takes a line and converts all leading tabs on that line into
" spaces
"
" Args:
"   -line: the line whose leading tabs will be converted
function s:ConvertLeadingSpacesToTabs(line)
    let toReturn  = a:line
    while toReturn =~ '^' . s:tabSpace . '\(.*\)$'
	let toReturn = substitute(toReturn, '^' . s:tabSpace . '\(.*\)$'  ,  '\t\1' , "")
    endwhile
    
    return toReturn
endfunction

" Function: s:GetCurrentVisMode() {{{2
" Returns the current visual mode,  if visual block, 
" v if normal visual, V if line visual
function s:GetCurrentVisMode() range
    let toReturn = visualmode()
    return toReturn
endfunction

" Function: s:InstallDocumentation(full_name, revision)              {{{2
"   Install help documentation.
" Arguments:
"   full_name: Full name of this vim plugin script, including path name.
"   revision:  Revision of the vim script. #version# mark in the document file
"              will be replaced with this string with 'v' prefix.
" Return:
"   1 if new document installed, 0 otherwise.
" Note: Cleaned and generalized by guo-peng Wen.
"
" Note about authorship: this function was taken from the vimspell plugin
" which can be found at http://www.vim.org/scripts/script.php?script_id=465
"
function s:InstallDocumentation(full_name, revision)
    " Name of the document path based on the system we use:
    if (has("unix"))
        " On UNIX like system, using forward slash:
        let l:slash_char = '/'
        let l:mkdir_cmd  = ':silent !mkdir -p '
    else
        " On M$ system, use backslash. Also mkdir syntax is different.
        " This should only work on W2K and up.
        let l:slash_char = '\'
        let l:mkdir_cmd  = ':silent !mkdir '
    endif

    let l:doc_path = l:slash_char . 'doc'
    let l:doc_home = l:slash_char . '.vim' . l:slash_char . 'doc'

    " Figure out document path based on full name of this script:
    let l:vim_plugin_path = fnamemodify(a:full_name, ':h')
    let l:vim_doc_path    = fnamemodify(a:full_name, ':h:h') . l:doc_path
    if (!(filewritable(l:vim_doc_path) == 2))
        echomsg "Doc path: " . l:vim_doc_path
        execute l:mkdir_cmd . '"' . l:vim_doc_path . '"'
        if (!(filewritable(l:vim_doc_path) == 2))
            " Try a default configuration in user home:
            let l:vim_doc_path = expand("~") . l:doc_home
            if (!(filewritable(l:vim_doc_path) == 2))
                execute l:mkdir_cmd . '"' . l:vim_doc_path . '"'
                if (!(filewritable(l:vim_doc_path) == 2))
                    " Put a warning:
                    echomsg "Unable to open documentation directory"
                    echomsg " type :help add-local-help for more informations."
                    echo l:vim_doc_path
                    return 0
                endif
            endif
        endif
    endif

    " Exit if we have problem to access the document directory:
    if (!isdirectory(l:vim_plugin_path)
        \ || !isdirectory(l:vim_doc_path)
        \ || filewritable(l:vim_doc_path) != 2)
        return 0
    endif

    " Full name of script and documentation file:
    let l:script_name = fnamemodify(a:full_name, ':t')
    let l:doc_name    = fnamemodify(a:full_name, ':t:r') . '.txt'
    let l:plugin_file = l:vim_plugin_path . l:slash_char . l:script_name
    let l:doc_file    = l:vim_doc_path    . l:slash_char . l:doc_name

    " Bail out if document file is still up to date:
    if (filereadable(l:doc_file)  &&
        \ getftime(l:plugin_file) < getftime(l:doc_file))
        return 0
    endif

    " Prepare window position restoring command:
    if (strlen(@%))
        let l:go_back = 'b ' . bufnr("%")
    else
        let l:go_back = 'enew!'
    endif

    " Create a new buffer & read in the plugin file (me):
    setl nomodeline
    exe 'enew!'
    exe 'r ' . l:plugin_file

    setl modeline
    let l:buf = bufnr("%")
    setl noswapfile modifiable

    norm zR
    norm gg

    " Delete from first line to a line starts with
    " === START_DOC
    1,/^=\{3,}\s\+START_DOC\C/ d

    " Delete from a line starts with
    " === END_DOC
    " to the end of the documents:
    /^=\{3,}\s\+END_DOC\C/,$ d

    " Remove fold marks:
    % s/{\{3}[1-9]/    /

    " Add modeline for help doc: the modeline string is mangled intentionally
    " to avoid it be recognized by VIM:
    call append(line('$'), '')
    call append(line('$'), ' v' . 'im:tw=78:ts=8:ft=help:norl:')

    " Replace revision:
    "exe "normal :1s/#version#/ v" . a:revision . "/\<CR>"
    exe "normal :%s/#version#/ v" . a:revision . "/\<CR>"

    " Save the help document:
    exe 'w! ' . l:doc_file
    exe l:go_back
    exe 'bw ' . l:buf

    " Build help tags:
    exe 'helptags ' . l:vim_doc_path

    return 1
endfunction

" Section: Doc installation call {{{1
call s:InstallDocumentation(expand('<sfile>:p'), s:NERD_comments_version)

finish
"=============================================================================
" Section: The help file {{{1 
" ============================================================================
=== START_DOC
*NERD_comments.txt*                                                  #version#


                        NERD_COMMENTS REFERENCE MANUAL~





==============================================================================
CONTENTS {{{2                                         *NERD_comments-contents* 

    1.Intro                               : |NERD_comments|
    2.Functionality provided              : |NERD_com-Functionality|
    3.Customisation                       : |NERD_com-Customisation|
    4.Issues with the script              : |NERD_com-issues|
    5.TODO list                           : |NERD_com-todo|
    6.Credits                             : |NERD_com-credits|

==============================================================================
1. Intro {{{2                                                  *NERD_comments*

NERD_comments provides a set of handy key mappings for commenting code. These
mappings are consistent across all supported filetypes. 



==============================================================================
2. Functionality provided {{{2                        *NERD_com-Functionality*

The following key mappings are provided by default:

Note: <leader> is a user defined key that is used to start keymappings and 
defaults to \. Check out |<leader>| for details.

<leader>cc      Comments out the current line. If multiple lines are selected
in visual mode, they are all commented out.  If a block is selected in
visual-block mode then this block will be commented out. The left and right
comment delimiters will line up down the left side and right sides of the
selection box. If a line ends before the right side of the selection box the
delimiter will be placed on the EOL. If a line finishes before the left side
of the selection box or is empty, it will not be commented.  Works in
normal,visual and visual block modes.  The keys for this mappings can be
overridden with the |NERD_com_line_map| option.

<leader>cu      Uncomments the current line. If multiple lines are selected in
visual mode then they are all uncommented. If the current filetype has
alternate comment delimiters and the line(s) are commented using these
then, by default, these comments delimiters will be removed if none of the
normal delimiters are detected --- see |NERD_dont_remove_alt_coms|. Works in
normal,visual modes.  The keys for this mappings can be overridden with the
|NERD_uncom_line_map| option.

<leader>cn      Nested commenting. Works the same as <leader>cc except that if
a line is commented, it will be commented again (provided that the current
commenting style has no right delimiter which could cause compiler errors)
Works in normal,visual modes.  The keys for this mappings can be overridden
with the |NERD_com_line_nest_map| option.

<leader>c$      Comments the current line from the current cursor position up
to the end of the line. Works in normal mode. The keys for this mappings can
be overridden with the |NERD_com_to_end_of_line_map| option.

<leader>ca      Changes to the alternative commenting style if one is
available. For example, if the user is editing a c++ file using // comments
and they hit <leader>ca then they will switched over to /**/ comments.  Works
in normal mode. The keys for this mappings can be overridden with the
|NERD_alt_com_map| option. See also |NERD_dont_remove_alt_coms|.

<C-c>       Adds comment delimiters at the current cursor position and inserts
between them. Works in insert mode. The keys for this mappings can be 
overridden with the |NERD_com_in_insert_map| option.

Files that can be commented by this plugin:
ada ant-build-files c c# c++ dosbatchfiles dtd h haskell html java
lisp Makefiles pascal perl prolog python ruby sh smalltalk tcl tex
vim xml xslt


==============================================================================
3. Customisation {{{2                                 *NERD_com-Customisation*

General options
-----------------------------------------------------------------------------
                                                       *loaded_nerd_comments*
If this script is making you insane you can turn it off by placing >
    let loaded_nerd_comments=1
<
in your vimrc

                                                   *NERD_dont_remove_alt_coms*
When uncommenting a line when there is an alternative commenting style for the
current filetype, this option tells the script not to look for, and remove,
comments delimiters of the alternative style. >
    let NERD_dont_remove_alt_coms=1
<


Comment style options
-----------------------------------------------------------------------------

                                            *NERD_use_nested_comments_default*

When this option is turned on comments are nested automatically. That is, if
you hit <leader>cc on a line that is already, or contains comments, it will
be commented again. Note: comments are only nested if the commenting style 
has no right delimiter. This is to avoid compiler errors in languages like
c but will allow, for example, // Java comments to be nested. >
    let NERD_use_nested_comments_default=1
<

                                                 *NERD_use_c_style_h_comments*
When set, this option forces /* */ style comments to be used with .h files.
This option is needed because h files can be used with c as well as c++ or 
c#. The later two allow // style commenting whereas c doesnt >
    let NERD_use_c_style_h_comments=1
<
                                              *NERD_use_c_style_java_comments*
NERD_comments can be told to use /* */ style comments instead of // for java 
with this option >
    let NERD_use_c_style_java_comments=1
<
                                               *NERD_use_c_style_cpp_comments*
NERD_comments can be told to use /* */ c++ style comments instead of // with
this option >
    let NERD_use_c_style_cpp_comments=1
<
                                                *NERD_use_c_style_cs_comments*
NERD_comments can be told to use /* */ style c# comments instead of // with 
this option >
    let NERD_use_c_style_cs_comments=1
<
                                            *NERD_use_c_style_prolog_comments*
NERD_comments can be told to use /* */ comments for prolog instead of % with 
this option >
    let NERD_use_c_style_prolog_comments=1
<

Comment key mapping customisation options
-----------------------------------------------------------------------------

                                     *NERD_com_line_map* *NERD_uncom_line_map*
                             *NERD_com_line_nest_map* *NERD_com_in_insert_map* 
                                                 *NERD_com_to_end_of_line_map*
                                                            *NERD_alt_com_map*
These options are used to override the default keys that are used for the
commenting mappings. Their values must be set to strings. As an example: if
you wanted to use the mapping <leader>foo to uncomment lines of code then 
you would place this line in your vimrc >
    let NERD_uncom_line_map="<leader>foo"
<

Check out |NERD_com-Functionality| for details about what the following 
mappings do.
                                
To override the <leader>cc mapping, set this option >
    let NERD_com_line_map="<new mapping>"
<
To override the <leader>cu mapping, set this option >
    let NERD_uncom_line_map="<new mapping>"
<
To override the <leader>cn mapping, set this option >
    let NERD_com_line_nest_map="<new mapping>"
<
To override the <leader>c$ mapping, set this option >
    let NERD_com_to_end_of_line_map="<new mapping>"
<
To override the <leader>ca mapping, set this option >
    let NERD_alt_com_map="<new mapping>"
<
To override the <C-c> mapping, set this option >
    let NERD_com_in_insert_map="<new mapping>"
<

==============================================================================
4. Issues with the script{{{2                                *NERD_com-issues*


Heuristics used to distinguish the real comment delimiters
------------------------------------------------------------------------------
Because we have comment mappings that place delimiters in the middle of lines,
for example <leader>c$ |NERD_com-Functionality|, removing comment delimiters
is a bit tricky. The reason being that just because comment delimiters 
appear in a line doesnt mean they really are delimiters. For example, Java
uses // comments but the line >
    System.out.println("//");
<
clearly contains no real comment delimiters. 

To distinguish between "real" comment delimiters and "fake" ones we use a set
of heuristics. For example, one such heuristic states that any comment
delimiter that has an odd number of non-escaped " characters preceding it on
the line is not a comment because it is probably part of a string. These 
heuristics, while usually pretty accurate, will not work all the time.


Commenting .vim files
------------------------------------------------------------------------------
Vim files are exceptionally evil to get commenting right for. This is because
the comment delimiter " is used for other things than delimiting comments. To
help comment vim files properly a set of heuristics have been written
especially for .vim files. Vim files are now commented correctly MOST of the
time.


Because this plugin approaches commenting on a line by line basis...
------------------------------------------------------------------------------
Note that, although this plugin can comment multiple lines at once, it still
performs commenting on a line by line basis. This means that comments like,
for example > 
    /*
     * FOOBAR BABY!
     */
<
will not be uncommented properly.

==============================================================================
5. TODO list {{{2                                              *NERD_com-todo*


If a line is commented using two commenting styles simultaneously e.g, >
    /* //foo */
<
currently the active commenting styles delimiters are removed first if 
<leader>cu is pressed. I think the outer most comment delimiters should be 
removed first regardless of whether they are the alternate delimiters or not.
    


==============================================================================
6. Credits {{{2                                             *NERD_com-credits*

Thanks and respect to the following people:

Thanks to Nick Brettell for his ideas. A bloody good bastard.
:.-1s/good //

Thanks to Matthew Hawkins for his awesome refactoring!

Thanks to the authors of the vimspell who's documentation installation
function I stole :)

=== END_DOC
" vim: set foldmethod=marker :
