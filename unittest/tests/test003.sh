source "${BASH_SOURCE%/*}"/../setup.sh

cat >>$vimtestdir/test.vim <<EOL

execute("normal! ax\<esc>")
execute("normal i\<C-G>u")
execute("normal! ay\<esc>")
execute("normal i\<C-G>u")
execute("normal! oz\<esc>")
execute("normal i\<C-G>u")

call AugmentRight(1, "hey")
call AugmentOn()
execute("normal i\<C-G>u")
execute("normal! ow\<esc>")
execute("normal i\<C-G>u")
execute("normal! ow\<esc>")
execute("normal i\<C-G>u")
"call RemoveHooks()
"call assert_equal([['x'],['xy'],['xy','z'],['xy','z','w'],['xy<augment>hey','z','w']], GetUndoHistory())
"UndotreeToggle
EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
