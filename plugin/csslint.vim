"=============================================================================
"  Author:          yicuan - http://plafer.info/
"  Email:           bolasblack [at] gmail
"  FileName:        csslint.vim
"  Description:     based on csslint of nodejs, check your own css code
"  Version:         0.2
"  LastChange:      2012-2-1
"  History:         at 2011-11-25 be created 
"                   at 2012-2-1 add g:CSSLint_errors and g:CSSLint_warnings as
"                   errors and warnings options of csslint, add 
"                   g:CSSLint_HighlightLevel option
"=============================================================================

if !has('python')
    finish
endif

noremap <silent> <leader>cj :call s:CSSLint_Jump("next")<cr>
noremap <silent> <leader>ck :call s:CSSLint_Jump("prev")<cr>
noremap <silent> <leader>cf :call s:CSSLint_Refresh()<cr>

command! CSSLintRefresh :call s:CSSLint_Refresh()

"autocmd CursorHold,CursorHoldI <buffer> call s:CSSLint_Refresh()
"autocmd InsertLeave <buffer> call s:CSSLint_Refresh()
autocmd BufEnter,BufWritePost <buffer> call s:CSSLint_Refresh()
autocmd BufLeave <buffer> call s:CSSLint_Clear()
autocmd CursorMoved <buffer> call s:CSSLint_GetMessage()

let g:CSSLint_Ver = "0.2"

if !exists("g:CSSLint_HighlightErrorLine")
    let g:CSSLint_HighlightErrorLine = 1
endif
if !exists("g:CSSLint_FileTypeList")
    let g:CSSLint_FileTypeList = ['css']
endif
if !exists("g:CSSLint_errors")
    let g:CSSLint_errors = ['']
endif
if !exists("g:CSSLint_warnings")
    let g:CSSLint_warnings = ['']
endif
if !exists("g:CSSLint_highlightLevel") || index(['error', 'warning'], g:CSSLint_HighlightLevel) == -1
    let g:CSSLint_HighlightLevel = ['warning', 'error']
endif

function! s:CSSLint()
    if index(g:CSSLint_FileTypeList, &filetype) == -1
        return
    endif

    highlight link CSSLintError SpellBad

    if exists("b:csslint_cleared") && b:csslint_cleared == 0
        call s:CSSLint_Clear()
    endif

    let b:csslint_matched = []
    let b:csslint_matchedLines = {}

    " Detect range
    if a:firstline == a:lastline
        let b:firstline = 1
        let b:lastline = '$'
    else 
        let b:firstline = a:firstline
        let b:lastline = a:lastline
    endif

    if executable('csslint')
        let current_file = iconv(expand('%:p'), &encoding, 'utf8')
        let errors_str = iconv(join(g:CSSLint_errors, ','), &encoding, 'utf8')
        let warnings_str = iconv(join(g:CSSLint_warnings, ','), &encoding, 'utf8')
        let s:cmd = 'csslint --format=checkstyle-xml --errors=' . errors_str . ' --warnings=' . warnings_str . ' ' . current_file
        let g:CSSLint_warnings_str = warnings_str
        let g:CSSLint_errors_str = errors_str
        let g:CSSLint_cmd = s:cmd
        let l:csslint_output = system(s:cmd)
        call s:CSSLint_ListEncode(l:csslint_output)
    else
        if v:shell_error
             echoerr 'could not invoke cssLint!'
        end
    endif
endfunction

function! s:CSSLint_Clear()
    " Delete previous matches
    let s:csslint_matcheList = getmatches()
    for s:csslint_matcheDict in s:csslint_matcheList
      if s:csslint_matcheDict['group'] == 'CSSLintError'
          call matchdelete(s:csslint_matcheDict['id'])
      endif
    endfor
    let b:csslint_matched = []
    let b:csslint_matchedLines = {}
    let b:csslint_cleared = 1
endfunction

function! s:CSSLint_WideMsg(msg)
" TODO: 显示的时候，如果信息太长会需要按 ENTER，想办法解决这个问题
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    redraw
    echo a:msg
    let &ruler=x | let &showcmd=y
endfun

function! s:CSSLint_ListEncode(lintXmlString)
python << EOF
import vim 
import xml.dom.minidom as minidom

lintXmlString = vim.eval('a:lintXmlString').replace('&', '&amp;')
errors = minidom.parseString(lintXmlString)
highlightLevel = vim.eval('g:CSSLint_HighlightLevel')
for error in errors.getElementsByTagName('error'):
    line = error.getAttribute('line')
    column = error.getAttribute('column')
    level = error.getAttribute('severity')

    if level in highlightLevel:
        message = error.getAttribute('message')
        message = message[:message.find(' at line')]
        message = message + ' at col ' + column
        vim.command('let s:csslint_matchDict = { \
            "line": "' + line + '",              \
            "column": "' + column + '",          \
            "level": "' + level + '",            \
            "message": "' + message + '"         \
        }')
        vim.command('let b:csslint_matchedLines[' + line + '] = s:csslint_matchDict')
        vim.command('call add(b:csslint_matched, s:csslint_matchDict)')
        if vim.eval('g:CSSLint_HighlightErrorLine') == '1':
            vim.command('call matchadd("CSSLintError", "\\\%" . ' + line + r' . "l\\S.*\\(\\S\\|$\\)")')
EOF
    highlight link CSSLintError SpellBad
    let b:csslint_cleared = 0
endfunction

let b:csslint_showingMessage = 0

function! s:CSSLint_GetMessage()
    let s:cursorPos = getpos(".")

    " Bail if RunCSSLint hasn't been called yet
    if !exists('b:csslint_matchedLines')
        return
    endif

    if has_key(b:csslint_matchedLines, s:cursorPos[1])
        let s:cssLint_match = get(b:csslint_matchedLines, s:cursorPos[1])
        let s:cursorPos[2] = s:cssLint_match['column']
        call s:CSSLint_WideMsg(s:cssLint_match['message'])
        let b:csslint_showingMessage = 1
        return
    endif

    if b:csslint_showingMessage == 1
        echo
        let b:csslint_showingMessage = 0
    endif
endfunction

function! s:CSSLint_Refresh()
    silent call s:CSSLint()
    call s:CSSLint_GetMessage()
endfunction

function! s:CSSLint_Jump(direction)
    let cursorPos = getpos(".")

    if !exists('b:csslint_matchedLines')
        return
    endif

    let currentLine = s:cursorPos[1]
    let lines = keys(b:csslint_matchedLines)

    let temp = []
    for line in lines
        let line = line + 0
        call add(temp, line)
    endfo

    if index(temp, currentLine) == -1
        call add(temp, currentLine)
    endif

    func! s:AscCompare(i1, i2)
        return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
    endfunc
    call sort(temp, "s:AscCompare")

    let lines = temp
    let b:lintLines = lines

    let currentIndex = index(lines, currentLine)

    if a:direction == "next"
        let nextErrorLine = get(lines, currentIndex + 1, lines[0])
    elseif a:direction == "prev"
        "如果成为负数，vim 能自动处理
        let nextErrorLine = get(lines, currentIndex - 1)
    else
        let nextErrorLine = a:direction
    endif

    call cursor(nextErrorLine, 0)
endfunction
