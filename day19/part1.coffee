
fs = require 'fs'

isTerm = (x) ->
  typeof x == 'string'

isNonterm = (x) ->
  typeof x == 'number'

class Rule

  constructor: (@number, @options) ->

  @parse: (line) ->
    [number, values] = line.split(": ")
    number = parseInt number
    values = values.split(" | ").map (opt) ->
      opt.split(" ").map (term) -> Rule.parseTerm(term)
    new Rule(number, values)

  @parseTerm: (term) ->
    if term[0] == '"'
      term.slice(1, -1)
    else
      parseInt term

class Rules

  constructor: (@rules={}) ->

  addRule: (rule) ->
    @rules[rule.number] = rule

  getRule: (number) ->
    @rules[number]

  allRuleOptions: ->
    for rule in Object.values(@rules)
      for opt in rule.options
        yield [rule.number, opt]

  parseImplList: (string, pos, list, lpos) ->
    if lpos >= list.length
      yield pos
    else
      for p from this.parseImpl(string, pos, list[lpos])
        yield from this.parseImplList(string, p, list, lpos + 1)

  parseImpl: (string, pos, ruleValue) ->
    if isTerm(ruleValue)
      if string[pos] == ruleValue
        yield pos + 1
      return
    else
      rule = this.getRule(ruleValue)
      for opt in rule.options
        yield from this.parseImplList(string, pos, opt, 0)

  parse: (string) ->
    for p from this.parseImpl string, 0, 0
      return true if p == string.length
    false

lines = fs.readFileSync('input.txt', 'utf8').split("\n")
line_number = 0

# Parse rules
rules = new Rules
while lines[line_number] != ""
  rules.addRule Rule.parse(lines[line_number])
  line_number += 1

count = 0
line_number += 1
while line_number < lines.length
  curr = lines[line_number]
  if rules.parse(curr)
    count += 1
  line_number += 1
console.log(count)
