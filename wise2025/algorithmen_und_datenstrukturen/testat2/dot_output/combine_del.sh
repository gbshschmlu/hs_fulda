#!/bin/bash

# Create pdfs, combine them and delete the individual ones

dot -Tpdf tree_01.dot > tree_01.pdf
dot -Tpdf tree_02.dot > tree_02.pdf
dot -Tpdf tree_03.dot > tree_03.pdf
dot -Tpdf tree_04.dot > tree_04.pdf
dot -Tpdf tree_05.dot > tree_05.pdf
dot -Tpdf tree_06.dot > tree_06.pdf
dot -Tpdf tree_07.dot > tree_07.pdf
dot -Tpdf tree_08.dot > tree_08.pdf
dot -Tpdf tree_09.dot > tree_09.pdf
dot -Tpdf tree_10.dot > tree_10.pdf
dot -Tpdf tree_11.dot > tree_11.pdf
dot -Tpdf tree_12.dot > tree_12.pdf
dot -Tpdf tree_13.dot > tree_13.pdf
dot -Tpdf tree_14.dot > tree_14.pdf
dot -Tpdf tree_15.dot > tree_15.pdf

pdfunite tree_01.pdf tree_02.pdf tree_03.pdf tree_04.pdf tree_05.pdf tree_06.pdf tree_07.pdf tree_08.pdf tree_09.pdf tree_10.pdf tree_11.pdf tree_12.pdf tree_13.pdf tree_14.pdf tree_15.pdf tree.pdf

read -p "Press any key to continue..."

rm -f *.svg

rm -f *.dot

rm -f tree_01.pdf
rm -f tree_02.pdf
rm -f tree_03.pdf
rm -f tree_04.pdf
rm -f tree_05.pdf
rm -f tree_06.pdf
rm -f tree_07.pdf
rm -f tree_08.pdf
rm -f tree_09.pdf
rm -f tree_10.pdf
rm -f tree_11.pdf
rm -f tree_12.pdf
rm -f tree_13.pdf
rm -f tree_14.pdf
rm -f tree_15.pdf
