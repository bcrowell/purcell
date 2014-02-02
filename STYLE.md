Chapter and section headings
========

Only the first word of the headings should be capitalized. (This is
different from the style used in the 1965 edition, which used titlecase.)

Units
========
Where Purcell writes "5 amp," write "$5\ \ampunit$," and similarly
for "ohm" -> \ohmunit.

Modern units and symbols for units should be used: s, not sec; A, not amp; g, not gm;
pF, not uuF; nm, not angstroms. In expressions like N.m for mechanical work,
use a dot (LaTeX command \unitdot), not a dash as Purcell does (N-m).
Hyphenate expressions like "0.05-microfarad capacitor," but not
"0.05 uF capacitor." Use keV, not kev. Don't pluralize units, e.g.,
dyne/cm, not dynes/cm.

Variables
=======
Use the LaTeX macro \der for derivatives and \vc{F} for a vector F.
Use \div and \curl where Purcell writes "div" and "curl." For gradients,
use \grad, which comes out as a bold-faced del symbol (triangle).
Where the symbol occurs as a scalar, e.g., in Poisson's equation,
use \nabla. For the Greek letter phi, where it occurs as the electric
potential, use \pot; for a phase angle, use \phi.

Equations
=========
Use \boxed{...} for single-line equations with boxes around them,
\begin{framed}...\end{framed} for equations that are more than one
line. When a multiline equation has a single number, do
\begin{align}    \begin{split}  ... \end{split} \end{align}.

Figures
=======
Three-color figures have gray background with a gray level of 118/255 (hex 767676).
When retouching text in figures, use Linux Libertine 10.8 bold, 11.3 bold italic.
Gray figures in the margin with a full bleed have a standard width of 78.5 mm.
Bitmaps are 300 dpi.
