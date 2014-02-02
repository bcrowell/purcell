% based on http://tex.stackexchange.com/a/70884

\ProvidesClass{purcell}

\LoadClass[11pt]{book}
% Note that 11 pt does work with pdflatex, even though 11 pt is not one of the sizes
% of CM. I don't know whether it scales up 10 pt or scales down 12 pt, but anyway, it
% works.
%====================== counters =====================================================
\newcounter{dqctr}[subsection]
\newcounter{egctr}[chapter]
\newcounter{scctr}[chapter]
\newcounter{hwctr}[chapter]
%====================== packages =====================================================
\usepackage{url,framed}
\RequirePackage{amsmath,amssymb,graphicx,enumerate,mathrsfs,learn-cmd-syntax}
% enumerate is for lc roman numerals; see http://tex.stackexchange.com/questions/54055/using-lower-case-roman-numerals-in-enumerate-lists ;
%    used in section 4.8
% mathrsfs is for script letters
\StartSaveCommands % for learn-cmd-syntax
%====================== pull in sub-packages =====================================================
\RequirePackage{lmlanguage,lmlayout,lmcommon,lmfigs,lmenvironments}

\renewcommand{\descriptionlabel}[1]{\hspace{\labelsep}\emph{#1}} % http://stackoverflow.com/a/7629070/1142217

\renewcommand{\theequation}{\arabic{equation}}

\newcommand{\intro}[1]{\emph{#1}\index{#1}}

% redefine some stuff that's defined in lmmath or elsewhere:
\renewcommand{\curl}{\operatorname{curl}} % Purcell sometimes spells out curl, sometimes uses del x (e.g., p. 198)
\renewcommand{\grad}{\boldsymbol{\nabla}} % Purcell uses bold nabla for gradient operator, but not, e.g., in Laplacian
\renewcommand{\div}{\operatorname{div}} % the built-in is a division sign

% some convenience commands for math:
\newcommand{\xhat}{\hat{\vc{x}}}
\newcommand{\yhat}{\hat{\vc{y}}}
\newcommand{\zhat}{\hat{\vc{z}}}
\newcommand{\rhat}{\hat{\vc{r}}}
\newcommand{\nhat}{\hat{\vc{n}}}
\newcommand{\phihat}{\hat{\boldsymbol{\varphi}}}
\newcommand{\pot}{\varphi} % the style of phi with only a tail, not head, used for the potential
\newcommand{\esu}{\zu{esu}}
\newcommand{\cmunit}{\zu{cm}}
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


\StopSaveCommands % for learn-cmd-syntax
\WriteSaveCommands  % for learn-cmd-syntax
