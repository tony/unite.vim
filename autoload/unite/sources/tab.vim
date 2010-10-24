"=============================================================================
" FILE: tab.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 24 Oct 2010
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

function! unite#sources#tab#define()"{{{
  return s:source
endfunction"}}}
function! unite#sources#tab#_append()"{{{
  if exists('*gettabvar')
    " Save tab access time.
    let t:unite_tab_access_time = localtime()
  endif
endfunction"}}}

let s:source = {
      \ 'name' : 'tab',
      \}

function! s:source.gather_candidates(args, context)"{{{
  let l:list = range(1, tabpagenr('$'))
  unlet l:list[tabpagenr()-1]
  if exists('*gettabvar')
    call sort(l:list, 's:compare')
  endif
  " Add current tab.
  call add(l:list, tabpagenr())


  let l:candidates = []
  for i in l:list
    let l:bufnrs = tabpagebuflist(i)
    let l:bufnr = l:bufnrs[tabpagewinnr(i) - 1]  " first window, first appears

    let l:bufname = fnamemodify((i == tabpagenr() ? bufname('#') : bufname(l:bufnr)), ':t')
    if l:bufname == ''
      let l:bufname = '[No Name]'
    endif

    if exists('*gettabvar')
      " Use gettabvar().
      let l:title = gettabvar(i, 'title')
      let l:cwd = substitute((i == tabpagenr() ? getcwd() : gettabvar(i, 'cwd')), '\\', '/', 'g')
    else
      let l:title = ''
      let l:cwd = ''
    endif

    let l:abbr = (i-1) . ': ' . l:title . l:bufname
    if l:cwd != ''
      let l:abbr .= '(' . l:cwd . ')'
    endif
    let l:wincount = tabpagewinnr(i, '$')
    if i == tabpagenr()
      let l:wincount -= 1
    endif
    if l:wincount > 1
      let l:abbr .= '{' . l:wincount . '}'
    endif
    let l:abbr .= getbufvar(bufnr('%'), '&modified') ? '[+]' : ''

    call add(l:candidates, {
          \ 'word' : l:bufname,
          \ 'abbr' : l:abbr,
          \ 'kind' : 'tab',
          \ 'source' : 'tab',
          \ 'unite_tab_nr' : i,
          \ 'unite_tab_cwd' : l:cwd,
          \ })
  endfor

  return l:candidates
endfunction"}}}

" Misc
function! s:compare(candidate_a, candidate_b)"{{{
  return gettabvar(a:candidate_b, 'unite_tab_access_time') - gettabvar(a:candidate_a, 'unite_tab_access_time')
endfunction"}}}

" vim: foldmethod=marker
