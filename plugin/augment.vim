"1
"2
"3
"4
"5
"6
"7
let s:markup = '>>>>>' . '>'
let s:augmentation = {}
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

function! UpdateAugmentation()
	let curpos = getcurpos()[1:]
	silent! execute("%substitute/" . s:markup . ".*//")
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

highlight AugmentationColor ctermfg=green
let m = matchadd("AugmentationColor", s:markup . ".*$", 9)
"let m2 = matchadd('Conceal', s:markup, 10, 99)
set conceallevel=2 concealcursor=nv

map <silent> ga :call AddAugmentationRight(4, "Test Augmentation")<CR>
map <silent> gb :call AddAugmentationBelow(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>
map <silent> gc :call AddAugmentationAbove(4, ["line one", "line 2", "line three", "line four", "line five"])<CR>

"noremap u uu
"autocmd TextChanged * call UpdateAugmentation()
"autocmd TextChangedI * call UpdateAugmentation()
