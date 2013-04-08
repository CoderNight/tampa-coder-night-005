Ruby Quiz
Dice Roller (#61)
by Matthew D Moss

Time to release your inner nerd.

The task for this Ruby Quiz is to write a dice roller. You should write a program that takes two arguments: a dice expression followed by the number of times to roll it (being optional, with a default of 1). So to calculate those stats for your AD&D character, you would do this:

> roll.rb "3d6" 6
6 6 9 11 9 13

Or, for something more complicated:

> roll.rb "(5d5-4)d(16/d4)+3"
31

[NOTE: You'll usually want quotes around the dice expression to hide parenthesis from the shell, but the quotes are not part of the expression.]

The main code of roll.rb should look something like this:

ruby
d = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times { print "#{d.roll} " }

The meat of this quiz is going to be parsing the dice expression (i.e., implementing Dice.new). Let's first go over the grammar, which I present in a simplified BNF notation with some notes:

<expr> := <expr> + <expr>
| <expr> - <expr>
| <expr> * <expr>
| <expr> / <expr>
| ( <expr> )
| [<expr>] d <expr>
| integer

* Integers are positive; never zero, never negative.
* The "d" (dice) expression XdY rolls a Y-sided die (numbered
from 1 to Y) X times, accumulating the results. X is optional
and defaults to 1.
* All binary operators are left-associative.
* Operator precedence:
( ) highest
d
* /
+ - lowest

[NOTE: The BNF above is simplified here for clarity and space. If requested, I will make available the full BNF description I've used in my own solution, which incorporates the association and precedence rules.]

A few more things... Feel free to either craft this by hand or an available lexing/parsing library. Handling whitespace between integers and operators is nice. Some game systems use d100 quite often, and may abbreviate it as "d%" (but note that '%' is only allowed immediately after a 'd').
