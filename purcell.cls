% based on http://tex.stackexchange.com/a/70884

\ProvidesClass{purcell}


\LoadClass[10pt,twoside,openright]{memoir}
\usepackage[paperwidth=8.5in, paperheight=11in,bindingoffset=.75in]{geometry}
\usepackage{url,framed}
\RequirePackage{amsmath}

% The following is set up so vectors are in upright bold.
\newcommand{\vc}[1]{\ensuremath{\mathbf{#1}}}
\newcommand{\der}{d} % match Purcell's style of italicizing the differential, but keep the option of changing later
\newcommand{\zu}[1]{\textup{#1}}

\renewcommand{\theequation}{\arabic{equation}}

% some convenience commands:
\renewcommand{\div}{\operatorname{div}} % the built-in is a division sign
\newcommand{\curl}{\operatorname{curl}}
\newcommand{\grad}{\boldsymbol{\nabla}} % Purcell uses bold nabla for gradient operator, but not, e.g., in Laplacian
\newcommand{\xhat}{\hat{\vc{x}}}
\newcommand{\yhat}{\hat{\vc{y}}}
\newcommand{\zhat}{\hat{\vc{z}}}
\newcommand{\pot}{\varphi} % the style of phi with only a tail, not head, used for the potential
