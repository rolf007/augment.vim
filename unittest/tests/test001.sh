source "${BASH_SOURCE%/*}"/../setup.sh

cat >>$vimtestdir/test.vim <<EOL

execute("normal! ix\<esc>")
AugmentOn
EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
