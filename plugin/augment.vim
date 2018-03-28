"1
"2
"3
"4
"5
"6
"7
let s:markup = '<augment>'
let s:augmentation = {}
let s:on = 0
let s:recurse = 0

function! AugmentOn()
	let curpos = getcurpos()[1:]
	let s:on = 1
	let s:match_markup = matchadd("AugmentColor", s:markup . ".*$", 9)
	let s:match_conceal = matchadd('Conceal', s:markup, 10, 99)
	let s:concealcursor = &concealcursor
	set conceallevel=2
	set concealcursor=nvci
	call s:DrawAug()
	augroup augmentGroup
		autocmd!
		autocmd TextChanged * call s:TextChanged()
		autocmd TextChangedI * call s:TextChangedI()
		autocmd InsertLeave * call s:InsertLeave()
		autocmd InsertEnter * call s:InsertEnter()
	augroup END
	nnoremap u :call <SID>UndoAug()<CR>
	call cursor(curpos)
endfunction

function! AugmentOff()
	let curpos = getcurpos()[1:]
	augroup augmentGroup
		autocmd!
	augroup END
	if s:on && len(s:augmentation) != 0
		silent undo
		let s:recurse = 1
	endif
	let s:on = 0
	call matchdelete(s:match_markup)
	call matchdelete(s:match_conceal)
	let &concealcursor = s:concealcursor
	nunmap u
	call cursor(curpos)
endfunction

function! AugmentAbove(line, augmentations)
	if s:on && len(s:augmentation) != 0
		silent undo
	endif
	if !has_key(s:augmentation, a:line-1)
		let s:augmentation[a:line-1] = [""]
	endif
	let s:augmentation[a:line-1] = s:augmentation[a:line-1] + a:augmentations
	if s:on
		call s:DrawAug()
	endif
	let s:recurse = 1
endfunction

function! AugmentBelow(line, augmentations)
	if s:on && len(s:augmentation) != 0
		silent undo
	endif
	if !has_key(s:augmentation, a:line)
		let s:augmentation[a:line] = [""]
	endif
	let s:augmentation[a:line] = [s:augmentation[a:line][0]] + a:augmentations + s:augmentation[a:line][1:]
	if s:on
		call s:DrawAug()
	endif
	let s:recurse = 1
endfunction

function! AugmentRight(line, augmentation)
	if s:on && len(s:augmentation) != 0
		silent undo
	endif
	if !has_key(s:augmentation, a:line)
		let s:augmentation[a:line] = [""]
	endif
	let s:augmentation[a:line][0] .= a:augmentation
	if s:on
		call s:DrawAug()
	endif
	let s:recurse = 1
endfunction

function! s:UndoAug()
	let curpos = getcurpos()[1:]
	silent undo
	silent undo
	call s:DrawAug()
	let s:recurse = 1
	call cursor(curpos)
endfunction

function! s:ClearAug()
	let curpos = getcurpos()[1:]
	silent! execute("%substitute/" . s:markup . ".*//")
	let s:recurse = 1
	call cursor(curpos)
endfunction

function! s:DrawAug()
	let curpos = getcurpos()[1:]
	"echom "1" string(undotree().seq_cur)
	for [aline, aug] in items(s:augmentation)
	    let line = getline(aline)
		call cursor(aline, 0)

	    let line = line . s:markup . aug[0]
		call setline(aline, line)
		let adjust = 0
		if &number
			let adjust = 4
		endif

		for l in range(1, len(aug)-1)
			let linelenght = virtcol('$')
			let line = line . repeat(" ", l*(&columns-adjust)-linelenght+1) . aug[l]
			call setline(aline, line)
		endfor
	endfor
	call cursor(curpos)
endfunction

function! s:TextChanged()
	if s:recurse == 1
		let s:recurse = 0
		return
	endif
	if s:on == 0
		return
	endif
	call s:ClearAug()
	" this generates an InsertEnter + InsertLeave
	execute "normal i\<C-G>u"
	call s:DrawAug()
endfunction

function! s:TextChangedI()
endfunction

function! s:InsertEnter()
	let s:buf_at_enter = getbufline("",'^','$')
endfunction

function! s:InsertLeave()
	let buf_at_leave = getbufline("",'^','$')
	if s:buf_at_enter == buf_at_leave
		let s:recurse = 0
		return
	endif
	if s:recurse == 1
		let s:recurse = 0
		return
	endif
	let curpos = getcurpos()[1:]
	call s:ClearAug()
	let store = getbufline("",'^','$')
	silent undo
	silent undo
	execute("normal! ggdG")
	call append(1, store)
	execute("normal! ggdd")
	execute("normal i\<C-G>u")
	call s:DrawAug()
	call cursor(curpos)
endfunction

highlight AugmentColor ctermfg=green

if expand('%:t') == "augment.vim"
	map <silent> ga :call AugmentRight(4, "Test Augment")<CR>
	map <silent> gb :call AugmentBelow(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>
	map <silent> gc :call AugmentAbove(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>
	map <silent> gz :call AugmentOn()<CR>
	map <silent> gx :call AugmentOff()<CR>
endif

function! RemoveHooks()
	augroup augmentGroup
		autocmd!
	augroup END
endfunction

"noremap u uu
"what to test:
"Event:       special cases
"------------
"AugmentOn    something added, nothing added
"AugmentOff   something added, nothing added
"AugmentRight something added, nothing added, off
"type         something added, nothing added, off
"undo         something added, nothing added, off
"redo         something added, nothing added, off
"
"type:
"
"                 <
"         t       t                       >
"  >      >       >                 t     t
"  B      B       B store B         B     B
"  A type A clear A 3undo A restore A add A
