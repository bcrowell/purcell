% based on http://tex.stackexchange.com/a/70884

\ProvidesClass{purcell}


\LoadClass[10pt,twoside,openright]{memoir}
\usepackage[paperwidth=8.5in, paperheight=11in,bindingoffset=.75in]{geometry}
\usepackage{url,framed}
\RequirePackage{amsmath}

% The following is set up so vectors are in upright bold.
\newcommand{\vc}[1]{\ensuremath{\mathbf{#1}}}

\renewcommand{\theequation}{\arabic{equation}}
