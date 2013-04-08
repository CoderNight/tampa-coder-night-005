Given(/^a dice roller with "(.*?)"$/) do |expr|
  srand 1
  @dice =  Dice.new expr
end

Then(/^the output should be (\d+)$/) do |ans|
  @dice.roll.should == ans.to_i
end
