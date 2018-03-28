source "${BASH_SOURCE%/*}"/../setup.sh

cat >>$vimtestdir/Makefile <<EOL
all: compile_error

compile_error: compile_error.cpp
	g++ compile_error.cpp -o compile_error
EOL

cat >>$vimtestdir/test.vim <<EOL

function QuickFixAugment()
	call AugmentClear()
	let qflist = getqflist()                     
	for i in qflist
		if i.valid
			call AugmentAbove(i.lnum, [i.text])
			let tabs = count(getline(i.lnum), "\t")
			call AugmentBelow(i.lnum, [repeat("-", i.col+(&ts-1)*tabs-1) . "^"])
		endif
	endfor       
endfunction

au QuickfixCmdPost make call QuickFixAugment()
highlight AugmentColor ctermfg=darkred

nnoremap gm :make<CR>
nnoremap gn :cnext<CR>
nnoremap gp :cprev<CR>

set errorformat+=%f:%l:%c:\ %m
set aw
set number
set columns=100

"execute("normal! a\n")
execute("normal! a#include <iostream>\n")
execute("normal! aint main()\n")
execute("normal! a{\n")
execute("normal! a	std::cout << \"hello\" << foo << std::endl;\n")
execute("normal! a	std::cout << \"hello\" << bar << std::endl;\n")
execute("normal! a	return 0;\n")
execute("normal i\<C-G>u")
execute("normal! a}\n")
w
make
call AugmentOn()

call RemoveHooks()
let undo_history = GetUndoHistory()
call assert_equal("#include <iostream>", undo_history[0][0])
call assert_equal("int main()", undo_history[0][1])
call assert_equal("{", undo_history[0][2])
call assert_equal("\tstd::cout << \"hello\" << foo << std::endl;", undo_history[0][3])
call assert_equal("\tstd::cout << \"hello\" << bar << std::endl;", undo_history[0][4])
call assert_equal("\treturn 0;", undo_history[0][5])
call assert_equal("", undo_history[0][6])

call assert_equal("#include <iostream>", undo_history[1][0])
call assert_equal("int main()", undo_history[1][1])
call assert_equal("{", undo_history[1][2])
call assert_equal("\tstd::cout << \"hello\" << foo << std::endl;", undo_history[1][3])
call assert_equal("\tstd::cout << \"hello\" << bar << std::endl;", undo_history[1][4])
call assert_equal("\treturn 0;", undo_history[1][5])
call assert_equal("}", undo_history[1][6])
call assert_equal("",undo_history[1][7])

call assert_equal("#include <iostream>", undo_history[2][0])
call assert_equal("int main()", undo_history[2][1])
call assert_equal("{<augment>                                                                                       error: 'foo' was not declared in this scope", undo_history[2][2])
call assert_equal("\tstd::cout << \"hello\" << foo << std::endl;<augment>                                           ----------------------------^                                                                    error: 'bar' was not declared in this scope", undo_history[2][3])
call assert_equal("\tstd::cout << \"hello\" << bar << std::endl;<augment>                                           ----------------------------^", undo_history[2][4])
call assert_equal("\treturn 0;", undo_history[2][5])
call assert_equal("}", undo_history[2][6])
call assert_equal("", undo_history[2][7])


EOL

HOME=$vimtestdir vim -X compile_error.cpp

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
