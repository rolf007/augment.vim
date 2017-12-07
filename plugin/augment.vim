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
let s:recurse = 0
function! AddAugmentationAbove(line, augmentations)
	if !has_key(s:augmentation, a:line-1)
		let s:augmentation[a:line-1] = [""]
	endif
	let s:augmentation[a:line-1] = s:augmentation[a:line-1] + a:augmentations
	call UpdateAugmentation()
endfunction

function! AddAugmentationBelow(line, augmentations)
	if !has_key(s:augmentation, a:line)
		let s:augmentation[a:line] = [""]
	endif
	let s:augmentation[a:line] = [s:augmentation[a:line][0]] + a:augmentations + s:augmentation[a:line][1:]
	call UpdateAugmentation()
endfunction

function! AddAugmentationRight(line, augmentation)
	if !has_key(s:augmentation, a:line)
		let s:augmentation[a:line] = [""]
	endif
	let s:augmentation[a:line][0] .= a:augmentation
	call UpdateAugmentation()
endfunction

function! ClearAugmentation()
	let curpos = getcurpos()[1:]
	silent! execute("%substitute/" . s:markup . ".*//")
	call cursor(curpos)
endfunction

function! UpdateAugmentation()
	if s:on == 0
		return
	endif
	echom "0" string(undotree().seq_cur)
	let curpos = getcurpos()[1:]
	call ClearAugmentation()
	echom "1" string(undotree().seq_cur)
	execute "normal i\<C-G>u"
	echom "2" string(undotree().seq_cur)
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
	echom "3" string(undotree().seq_cur)
endfunction

function! TextChanged()
	if s:recurse == 1
		let s:recurse = 0
		return
	endif
	call UpdateAugmentation()
endfunction

function! InsertLeave()
	if s:recurse == 1
		let s:recurse = 0
		return
	endif
	call UpdateAugmentation()
	let s:recurse = 1
endfunction

function! s:AugOn()
	let s:on = 1
	echom "AugOn"
	delcommand AugmentOn
	command AugmentOff call s:AugOff()
	call UpdateAugmentation()
	let s:recurse = 1
	augroup augmentGroup
		autocmd!
		autocmd TextChanged * call TextChanged()
		autocmd InsertLeave * call InsertLeave()
	augroup END
endfunction

function! s:AugOff()
	let s:on = 0
	echom "AugOff"
	delcommand AugmentOff
	command AugmentOn call s:AugOn()
	call ClearAugmentation()
	augroup augmentGroup
		autocmd!
	augroup END
endfunction

command! AugmentOn call s:AugOn()

highlight AugmentationColor ctermfg=green
let m = matchadd("AugmentationColor", s:markup . ".*$", 9)
"let m2 = matchadd('Conceal', s:markup, 10, 99)
set conceallevel=2 concealcursor=nv

map <silent> ga :call AddAugmentationRight(4, "Test Augmentation")<CR>
map <silent> gb :call AddAugmentationBelow(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>
map <silent> gc :call AddAugmentationAbove(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>


"noremap u uu
"autocmd TextChangedI * call TextChanged()
