#!/usr/bin/env ruby

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
  def initialize str
    @scanner = StringScanner.new str
    @result = 0
  end

  def roll_function n,m
    t = 0
    (n||1).times do
      r = rand(m) + 1
      t += r
    end
    t
  end

  def roll
    @scanner.reset
    expression
  end

  # expression  = term | expression + term
  # term        = factor | term * factor
  # factor      = dice_factor | dice_factor d factor
  # dice_factor = constant | ( expression )
  # constant    = digit | digit constant
  # digit       = 0..9
  def expression
    n = term
    while next_token == '+' || next_token == '-'
      op = consume
      m = term
      n = case op
          when '+'
            n + m
          when '-'
            n - m
          else
            nil
          end
    end
    n
  end

  def term
    n = factor
    while next_token == '*' || next_token == '/'
      op = consume
      m = factor
      n = case op
          when '*'
            n * m
          when '/'
            n / m
          else
            nil
          end
    end
    n
  end

  def factor
    n = dice_factor
    while next_token == "d"
      consume
      m = dice_factor
      n = roll_function(n, m)
    end
    n
  end

  def dice_factor
    n = constant
    if n.nil? && next_token == '('
      consume
      n = expression
      if next_token == ')' then
        consume
      else
        n = nil
      end
    end
    n
  end

  def constant
    n = nil
    if next_token == '%' then
      n = 100
    else
      while (d = digit)
        n = (n||0) * 10 + d
      end
    end
    n
  end

  def digit
    next_token =~ /\d/ ? consume.to_i : nil
  end

  private

  def next_token
    @next_token ||= @scanner.scan(/./)
  end

  def consume
    t = @next_token
    @next_token = nil
    t
  end
end
