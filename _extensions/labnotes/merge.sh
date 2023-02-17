#!/bin/env bash

[[ -n $QUARTO_PROJECT_RENDER_ALL ]] || exit

script=$(dirname -- "${BASH_SOURCE[0]}")
out="_build/merged.tex"

sed -n '1,/^%\$body\$$/p' "${script}/skeleton.tex" > $out
echo "$QUARTO_PROJECT_OUTPUT_FILES" | grep '.tex$' | xargs cat >> $out
sed -n '/^%\$body\$$/,$p' "${script}/skeleton.tex" >> $out

cd _build
xelatex merged.tex 2>/dev/null
