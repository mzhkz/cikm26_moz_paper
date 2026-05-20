$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -halt-on-error %O %S';
$bibtex = 'bibtex %O %B';
$max_repeat = 5;

# Ensure sty/ is in the search path
ensure_path('TEXINPUTS', './sty//');
ensure_path('BSTINPUTS', './sty//');

# Copy PDF to out/ after successful build
$success_cmd = 'mkdir -p out && cp %D out/';
