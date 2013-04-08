#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'parslet'

# Usage:
# $ ruby ./dice.rb "(5d(5 + 4)/2+(4 * d5 ))d(54/2 d 12)-21"
# => 42

# http://rubyquiz.com/quiz61.html
#
# Goal: I wanted to learn to use one of the ruby parsing libraries and
# a little bit about formal grammers (PEG, CFG, etc).
#
# <expr> := <expr> + <expr>
#        |  <expr> - <expr>
#        |  <expr> * <expr>
#        |  <expr> / <expr>
#        |  ( <expr> )
#        |  [<expr>] d <expr>
#        |  integer
#
# * Integers are positive; never zero, never negative.
# * The "d" (dice) expression XdY rolls a Y-sided die (numbered
#   from 1 to Y) X times, accumulating the results.  X is optional
#   and defaults to 1.
# * All binary operators are left-associative.
# * Operator precedence:
#           ( )      highest
#           d
#           * /
#           + -      lowest
class Dice

  def initialize(expression)
    @expression = expression
    @parser     = Parser.new
    @transform  = Transform.new
  end

  def roll
    tree = @parser.parse(@expression)
    @transform.apply(tree).evaluate
  rescue Parslet::ParseFailed => failure
    puts failure.cause
  end

  class Parser < Parslet::Parser
    rule(:digit)   { match('[0-9]') }
    rule(:space?)  { match('\s').repeat }
    rule(:integer) { digit.repeat(1).as(:int) >> space? }
    rule(:lparen)  { str('(') >> space? }
    rule(:rparen)  { str(')') >> space? }
    rule(:dice_op) { str('d').as(:op) >> space? }
    rule(:as_op)   { match('[+-]').as(:op) >> space? } # operators grouped by precedence
    rule(:md_op)   { match('[*/]').as(:op) >> space? } # "

    # x + y, x - y
    rule(:p0) { p1.as(:left) >> (as_op >> p1.as(:right)).repeat(1) | p1 }

    # x * y, x / y
    rule(:p1) { p2.as(:left) >> (md_op >> p2.as(:right)).repeat(1) | p2 }

    # x d y
    rule(:p2) { p3.maybe.as(:left) >> (dice_op >> p3.as(:right)).repeat(1) | p3 }

    # ( x )
    rule(:p3) { lparen >> p0 >> rparen | integer }

    root(:p0) # p0 is the lowest precedence operation
  end

  class Transform < Parslet::Transform
    rule( left: simple(:l)) { l }
    rule(   op: simple(:o),
         right: simple(:r)) { Expression.new(o, r) }
    rule(  int: simple(:i)) { IntLiteral.new(i) }
    rule(     sequence(:s)) { Sequence.new(s) }
  end

  class Expression < Struct.new(:operator, :right);

    def evaluate(left)
      # handle optional left side of dice expression as 1
      l = (left || IntLiteral.new(1)).evaluate
      r = right.evaluate

      case operator
      when "d"
        (1..l).reduce(0) { |sum, i| sum + rand(r)+1 }
      when "*"
        l * r
      when "/"
        l / r
      when "+"
        l + r
      when "-"
        l - r
      end
    end
  end

  class IntLiteral < Struct.new(:int);

    def evaluate
      Integer(int)
    end
  end

  class Sequence < Struct.new(:sequence);

    def evaluate
      sequence.reduce do |s, expression|
        expression.evaluate(s)
      end
    end
  end
end

dice = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times do
  print "#{dice.roll}  "
end
