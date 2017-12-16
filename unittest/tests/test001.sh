source "${BASH_SOURCE%/*}"/../setup.sh

cat >>$vimtestdir/test.vim <<EOL

execute("normal! ax\<esc>")
execute("normal i\<C-G>u")
execute("normal! ay\<esc>")
execute("normal i\<C-G>u")
execute("normal! oz\<esc>")
execute("normal i\<C-G>u")

call AugmentOn()
call AugmentRight(1, "hey")
execute("normal i\<C-G>u")
call AugmentRight(1, "grey")
call RemoveHooks()
call assert_equal([['x'],['xy'],['xy','z'],['xy>>>>>>heygrey','z']], GetUndoHistory())
"UndotreeToggle
EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
