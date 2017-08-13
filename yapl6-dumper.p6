#!/usr/bin/env perl6

use v6.c;
use lib '../lib';
use Perl6::Parser;

sub MAIN(Str $filename, Bool :$ruler = False)
{
    my $text = $filename.IO.slurp;
    my $pt = Perl6::Parser.new;
    if $ruler { say $pt.ruler( $text ); return; }
    my $p = $pt.parse( $text );

    # say '(load-file "yapl6-faces.el")';
    # say '(defun yapl6-highlight () "Perl6 highlighting"';
    # say '  (progn';
    say "    (remove-overlays)";

    # list
    my @elems = $pt.to-tokens-only( $text );
    my $blacklist =
        Perl6::WS|
        Perl6::Semicolon|
        Perl6::Newline|
        Perl6::Block::Enter|
        Perl6::Block::Exit|
        Perl6::Balanced::Enter|
        Perl6::Balanced::Exit
        ;

    for (grep { .WHAT !~~ $blacklist }, @elems) -> $t {
        my $f = True;
        my $face;
        given $t.WHAT {
            # order matters - more specific beats less specific

            # language constructs
            when Perl6::Bareword                        { $face = "bareword" }
            when Perl6::Comment                         { $face = "comment" }
            when Perl6::ColonBareword                   { $face = "colon-bareword" }

            # operator
            when Perl6::Operator::PostCircumfix         { $face = "op-postcircumfix" }
            when Perl6::Operator::Circumfix             { $face = "op-circumfix" }
            when Perl6::Operator::Postfix               { $face = "op-postfix" }
            when Perl6::Operator::Prefix                { $face = "op-prefix" }
            when Perl6::Operator::Infix                 { $face = "op-infix" }
            when Perl6::Operator::Hyper                 { $face = "op-hyper" }
            when Perl6::Operator                        { $face = "op" }

            # number
            when Perl6::Number::Decimal                 { $face = "num-decimal" }
            when Perl6::Number::Octal                   { $face = "num-octal" }
            when Perl6::Number::Radix                   { $face = "num-radix" }
            when Perl6::Number::Binary                  { $face = "num-binary" }
            #when Perl6::Number::Imaginary              { $face = "num-imaginary" } # problem
            #when Perl6::Number::Decimal::FloatingPoint { $face = "num-float" } # problem
            when Perl6::Number::Decimal                 { $face = "num-decimal" }
            when Perl6::Number::Hexadecimal             { $face = "num-hexdecimal" }
            when Perl6::Number                          { $face = "num" }

            # variable
            when Perl6::Variable::Callable              { $face = "callable" }
            when Perl6::Variable::Hash                  { $face = "hash" }
            when Perl6::Variable::Array                 { $face = "array" }
            when Perl6::Variable::Scalar                { $face = "var-scalar" }
            when Perl6::Variable                        { $face = "var" }

            # string
            when Perl6::String::Interpolation           { $face = "str-interpolation" }
            when Perl6::String::Escaping                { $face = "str-escaping" }
            when Perl6::String                          { $face = "str" }

            # regex
            when Perl6::Regex                           { $face = "regex" }

            # nothing found
            default                                     { $f = False }
        }
        say "    (overlay-put (make-overlay {$t.from+1} {$t.to+1}) 'face 'yapl6-face-{$face})" if $f;
    }
    # say "  ) ;; progn";
    # say ") ;; defun";
}
