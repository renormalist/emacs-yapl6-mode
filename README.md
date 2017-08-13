# yapl6-mode

Yet Another Perl6 emacs mode.

# Approach

## Main idea

This mode calls out to `Perl6::Parser` to parse the source code and
return detailed information which type of symbol is located where with
start/end markers.

## Negotiatable approach

It then creates Emacs `overlays` which augment the text with
pre-declared faces. This is mostly meant as initial start to
understand how things work, because it directly uses the information
provided by Perl6::Parser.

This keeps the highlighting until the next time quite static and only
up to date as long as Emacs can keep track of start/end points, which
it can inside words and between words but not well on word boundaries.

The behaviour might remind you of the very early Emacs "hilite" modes
before there was font-lock. I think it is similar.

We might trigger the highlighting explicitely with a key or
implicitely when idle.

## Issues and mitigation ideas

1. It can only work on successfully parsable files.

   - the highlighting stays around until it is syntactically ok again

1. Although calling out to perl6 is quick enough nowadays running
   `Perl6::Parser` is slow for larger files.

   It even seems to parse used modules, which can mean awhole tree of
   dependencies, not sure if I observed and understood that correctly.
   
   - maybe we can parse balanced snippets of code with Perl6::Parser?

1. The interaction with the Perl6 glue code which generates the lisp
   code is not elegant and for now uses temporary files or whole
   programs in strings or whatever helps.

   - This will just evolve.
