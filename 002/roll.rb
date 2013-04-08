require_relative 'lib/dice'
dice = ARGV[0]
rolls = ARGV[1] || 1
dice = Dice.new(dice)
rolls.to_i.times { print "#{dice.roll} " }
