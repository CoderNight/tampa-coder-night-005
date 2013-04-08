#!/usr/bin/env line

@wip
Feature: Expression
  In order to parse and evaluate an expression
  As a user
  I want to evaluate dice roller expression

  # srand 1
  # d1: [1]
  # d2: [2,2]
  # d3: [2,1]
  # d4: [2,4,1]
  # d5: [4,5,1,2,4]
  # d6: [6,4]
  # d8: [6, 4, 5, 1, 8, 2, 4, 6, 8, 1, 1, 2]
  Scenario Outline: Evaluate expression
    Given a dice roller with "<expr>"
    Then the output should be <result>
  
  Examples:
    | expr              | result |
    | d1                | 1      |
    | d2                | 2      |
    | 2d2               | 4      |
    | 2d2+1             | 5      |
    | 2d(2+1)           | 3      |
    | 2d(2*3)           | 10     |
    | (1+2)d4           | 7      |
    | (2*3-2)d(1+4)     | 12     |
    | (8/4+1)d(1+4)     | 10     |
    | d4                | 2      |
    | 5d5               | 16     |
    | 12d8              | 48     |
    | 5d5-4             | 12     |
    | d(16/d4)          | 4      |
    | (5d5-4)d(16/d4)+3 | 56     |
