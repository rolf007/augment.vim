"1
"2
"3
"4
"5
"6
"7
let s:markup = '>>>>>' . '>'
let s:augmentation = {}
let s:on = 0
let s:something = 0
let s:recurse = 0
let s:textChangedI = 0

function! AugmentOn()
	let s:on = 1
	call s:DrawAug()
	augroup augmentGroup
		autocmd!
		autocmd TextChanged * call s:TextChanged()
		autocmd TextChangedI * call s:TextChangedI()
		autocmd InsertLeave * call s:InsertLeave()
		autocmd InsertEnter * call s:InsertEnter()
	augroup END
endfunction

function! s:AugmentOff()
	let s:on = 0
	call s:ClearAug()
endfunction
function! AugmentAbove(line, augmentations)
	if !has_key(s:augmentation, a:line-1)
		let s:augmentation[a:line-1] = [""]
	endif
	let s:augmentation[a:line-1] = s:augmentation[a:line-1] + a:augmentations
	call s:UpdateAug()
endfunction

function! AugmentBelow(line, augmentations)
	if !has_key(s:augmentation, a:line)
		let s:augmentation[a:line] = [""]
	endif
	let s:augmentation[a:line] = [s:augmentation[a:line][0]] + a:augmentations + s:augmentation[a:line][1:]
	call s:UpdateAug()
endfunction

function! AugmentRight(line, augmentation)
	if !has_key(s:augmentation, a:line)
		let s:augmentation[a:line] = [""]
	endif
	let s:augmentation[a:line][0] .= a:augmentation
	call s:UpdateAug()
endfunction

function! s:UpdateAug()
	if s:on == 0
		return
	endif
	call s:ClearAug()
	" this generates an InsertEnter + InsertLeave
	execute "normal i\<C-G>u"
	let s:beforeAug = getbufline("",'^','$')
	call s:DrawAug()
	let afterAug = getbufline("",'^','$')
	if afterAug == s:beforeAug
		echom "nothing added"
		let s:something = 0
	else
		echom "something added"
		let s:something = 1
		let s:recurse = 1
	endif
endfunction

function! s:ClearAug()
	let curpos = getcurpos()[1:]
	let before = getbufline("",'^','$')
	silent! execute("%substitute/" . s:markup . ".*//")
	let after = getbufline("",'^','$')
	if after == before
		echom "nothing cleared"
	else
		echom "something cleared"
		let s:recurse = 1
	endif
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
	call s:UpdateAug()
endfunction

function! s:TextChangedI()
	let s:textChangedI = 1
endfunction

function! s:InsertEnter()
endfunction

function! s:InsertLeave()
	if s:recurse == 1
		let s:recurse = 0
		return
	endif
	if s:textChangedI == 1
		return
	endif
	let s:textChangedI = 0
	call s:UpdateAugmentation()
endfunction

highlight AugmentColor ctermfg=green
let m = matchadd("AugmentColor", s:markup . ".*$", 9)
"let m2 = matchadd('Conceal', s:markup, 10, 99)
set conceallevel=2 concealcursor=nv

map <silent> ga :call AugmentRight(4, "Test Augmentation")<CR>
map <silent> gb :call AugmentBelow(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>
map <silent> gc :call AugmentAbove(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>

"noremap u uu
