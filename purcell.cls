% based on http://tex.stackexchange.com/a/70884

\ProvidesClass{purcell}


\LoadClass[10pt,twoside,openright]{memoir}
\usepackage[paperwidth=8.5in, paperheight=11in,bindingoffset=.75in]{geometry}
\usepackage{url,framed}
\RequirePackage{amsmath,amssymb,graphicx,enumerate}
% enumerate is for lc roman numerals; see http://tex.stackexchange.com/questions/54055/using-lower-case-roman-numerals-in-enumerate-lists ;
%    used in section 4.8

% The following is set up so vectors are in upright bold.
\newcommand{\vc}[1]{\ensuremath{\mathbf{#1}}}
\newcommand{\der}{d} % match Purcell's style of italicizing the differential, but keep the option of changing later
\newcommand{\zu}[1]{\textup{#1}}

\renewcommand{\theequation}{\arabic{equation}}

\newcommand{\intro}[1]{\emph{#1}\index{#1}}

% some convenience commands for math:
\renewcommand{\div}{\operatorname{div}} % the built-in is a division sign
\newcommand{\curl}{\operatorname{curl}}
\newcommand{\grad}{\boldsymbol{\nabla}} % Purcell uses bold nabla for gradient operator, but not, e.g., in Laplacian
\newcommand{\xhat}{\hat{\vc{x}}}
\newcommand{\yhat}{\hat{\vc{y}}}
\newcommand{\zhat}{\hat{\vc{z}}}
\newcommand{\rhat}{\hat{\vc{r}}}
\newcommand{\nhat}{\hat{\vc{n}}}
\newcommand{\pot}{\varphi} % the style of phi with only a tail, not head, used for the potential
\newcommand{\degunit}{\ensuremath{\mspace{0mu}^\circ}} % the \mspace{0mu} is a zero-width math space; need it so that, e.g., $2\times10^{-3}\degunit$ doesn't get
                                                       % interpreted as a double superscript
\newcommand{\esu}{\zu{esu}}
\newcommand{\cmunit}{\zu{cm}}
\newcommand{\sunit}{\zu{s}}
\newcommand{\unitdot}{\!\cdot\!}
