% based on http://tex.stackexchange.com/a/70884

\ProvidesClass{purcell}


\LoadClass[10pt,twoside,openright]{memoir}
\usepackage[paperwidth=8.5in, paperheight=11in,bindingoffset=.75in]{geometry}
\usepackage{url,framed}
\RequirePackage{amsmath,amssymb,graphicx,enumerate,mathrsfs}
% enumerate is for lc roman numerals; see http://tex.stackexchange.com/questions/54055/using-lower-case-roman-numerals-in-enumerate-lists ;
%    used in section 4.8
% mathrsfs is for script letters

% The following is set up so vectors are in upright bold.
\newcommand{\vc}[1]{\ensuremath{\mathbf{#1}}}
\newcommand{\der}{\operatorname{d\!}}
%   ... differentials upright rather than italicized as in Purcell
%       the \! is a negative thin space to keep the d close to the variable that comes after it
%       http://tex.stackexchange.com/questions/14821/whats-the-proper-way-to-typeset-a-differential-operator
%   old: \newcommand{\der}{\textup{d}}
\newcommand{\zu}[1]{\textup{#1}}

\renewcommand{\theequation}{\arabic{equation}}

\newcommand{\intro}[1]{\emph{#1}\index{#1}}

% some convenience commands for math:
\renewcommand{\div}{\operatorname{div}} % the built-in is a division sign
\newcommand{\curl}{\operatorname{curl}} % Purcell sometimes spells out curl, sometimes uses del x (e.g., p. 198)
\newcommand{\grad}{\boldsymbol{\nabla}} % Purcell uses bold nabla for gradient operator, but not, e.g., in Laplacian
\newcommand{\xhat}{\hat{\vc{x}}}
\newcommand{\yhat}{\hat{\vc{y}}}
\newcommand{\zhat}{\hat{\vc{z}}}
\newcommand{\rhat}{\hat{\vc{r}}}
\newcommand{\nhat}{\hat{\vc{n}}}
\newcommand{\phihat}{\hat{\boldsymbol{\varphi}}}
\newcommand{\pot}{\varphi} % the style of phi with only a tail, not head, used for the potential
\newcommand{\degunit}{\ensuremath{\mspace{0mu}^\circ}} % the \mspace{0mu} is a zero-width math space; need it so that, e.g., $2\times10^{-3}\degunit$ doesn't get
                                                       % interpreted as a double superscript
\newcommand{\degcunit}{\degunit\textup{C}}
\newcommand{\esu}{\zu{esu}}
\newcommand{\cmunit}{\zu{cm}}
\newcommand{\sunit}{\zu{s}}
\newcommand{\unitdot}{\!\cdot\!}
\newcommand{\bell}{\boldsymbol{\ell}}
\newcommand{\emf}{\mathcal{E}}
\newcommand{\ohmunit}{\Omega} % Purcell uses "ohm"
\newcommand{\ampunit}{A} % purcell uses "amp"
\newcommand{\btorque}{\boldsymbol{\tau}}% Purcell uses N for torque
\newcommand{\torque}{\tau}

% Get a script J that doesn't lean over so much:
% http://tex.stackexchange.com/questions/21452/how-to-typeset-this-symbol
\DeclareSymbolFont{rsfso}{U}{rsfso}{m}{n}
\DeclareSymbolFontAlphabet{\mathscr}{rsfso}
% Also need a bold version. See
% http://tex.stackexchange.com/a/23741/6853
% The mathdesign solution works, but gives a more sloping J, which doesn't match the non-bold one.

\newcommand{\scrj}{\mathscr{J}}
\newcommand{\bscrj}{\pmb{\scrj}}
