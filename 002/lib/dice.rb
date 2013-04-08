class Dice

  OPERATOR_PRECEDENCE = {
    '(' => 0,
    ')' => 0,
    '+' => 1,
    '-' => 1,
    '*' => 2,
    '/' => 2,
    'd' => 3
  }

  attr_accessor :dice_expression

  def initialize dice_expression
    @dice_expression = dice_expression
  end

  def roll
    evaluate_dice_expression dice_expression
  end

  private

  def evaluate_dice_expression expression
    clear_expression_stacks

    expression = expression.gsub /d%/, 'd100'

    valid_chars = OPERATOR_PRECEDENCE.keys.map { |operator|
      operator == 'd' ? operator : "\\#{operator}"
    }.join('|') + '|\d+'

    expression_regex = Regexp.new '(' + valid_chars + ')'
    expression_chars = expression.scan(expression_regex).flatten

    expression_chars.each_with_index do |char, index|
      # found digit
      if !OPERATOR_PRECEDENCE.keys.include? char
        expression_values.push char.to_i
        next
      end

      # handle operators
      while true
        if should_push_operator char
          # do we need to insert an implicit 1? (e.g. 16/d4 #=> 16/1d4)
          # found via seeing 2 operators in a row when neither are '('
          prev_operator = expression_operators.last
          prev_char = expression_chars[index-1]
          if prev_char && prev_char != '(' && char != '(' && prev_char == prev_operator
            expression_values.push 1
          end

          expression_operators.push char
          break
        end

        operator = expression_operators.pop
        break if operator == '(' # ignore opening parens

        result = evaluate_current_next_two_values_with_operator operator
        expression_values.push result
      end
    end

    # evaluate remaining values/operators
    while !expression_operators.empty?
      operator = expression_operators.pop
      result = evaluate_current_next_two_values_with_operator operator
      expression_values.push result
    end

    expression_values.pop.ceil
  end

  def evaluate_expression operator, value_a, value_b
    case operator
    when '+'
      value_a + value_b
    when '-'
      value_a - value_b
    when '/'
      value_a / value_b
    when '*'
      value_a * value_b
    when 'd'
      (1..value_a).reduce(0) { |val| val += (rand(value_b) + 1) }
    else
      raise ArgumentError, "invalid operator: #{operator}"
    end
  end

  def evaluate_current_next_two_values_with_operator operator
    value_b = expression_values.pop
    value_a = expression_values.pop
    evaluate_expression operator, value_a, value_b
  end

  def should_push_operator char
    expression_operators.empty? || char == '(' ||
      (OPERATOR_PRECEDENCE[char] > OPERATOR_PRECEDENCE[expression_operators[-1]])
  end

  def expression_values
    @expression_values ||= []
  end

  def expression_operators
    @expression_operators ||= []
  end

  def clear_expression_stacks
    expression_values.clear
    expression_operators.clear
  end
end
