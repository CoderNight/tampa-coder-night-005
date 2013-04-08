
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Dice do
  before(:each) do
    class Dice
      def roll_function n,m
        (n||1) * m/2
      end
    end
  end
  
  it "should handle 1 digit" do
    Dice.new("1").roll.should == 1
  end

  it "should handle constants", focus: true do
    Dice.new("123").roll.should == 123
  end

  it "should handle dice factor" do
    Dice.new("3d10").roll.should == 15
  end

  it "should handle factor" do
    Dice.new("3d10*20").roll.should == 300
  end

  it "should handle term" do
    Dice.new("3d10*20+1d9").roll.should == 304
  end

  it "should handle roll" do
    Dice.new("3d10*(10+10)+1d9").roll.should == 304
  end

  it "should handle default value before d" do
    Dice.new("d2").roll.should == 1
  end

  it "should handle d%" do
    Dice.new("d%").roll.should == 50
  end
  
end