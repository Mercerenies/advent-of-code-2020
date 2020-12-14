
List maximumBy := method(key, self reduce(acc, x, if(key call(acc) >= key call(x), acc, x)))
List sortByKey := method(key, self sortBy(block(a, b, key call(a) < key call(b))))
List all := method(key, self detect(v, key call(v) not) not)

Constraint := Object clone
Constraint make := method(id, offset,
  obj := self clone
  obj busID := id
  obj offset := if(id, (offset % id + id) % id, offset)
  obj
)
Constraint isSatisfied := method(t,
  if(self busID,
    t % self busID == self offset,
    true
  )
)
Constraint busID := nil
Constraint offset := 0

solveConstraints := method(a, b,
  value := a offset
  delta := a busID
  while(b isSatisfied(value) not,
    value = value + delta
  )
  Constraint make(a busID * b busID ifNilEval(1), value)
)

idConstraint := Constraint make(1, 0)

file := File with("input.txt") openForReading

file readLine asNumber # Ignore first line
buses := file readLine split(",") map(v, if(v == "x", nil, v asNumber))

file close

busConstraints := buses map(i, v,
  Constraint make(v, if(v, v - i, 0))
) sortByKey(block(x,
  x busID ifNilEval(Number integerMin)
))

totalConstraint := busConstraints reduce(acc, x, solveConstraints(acc, x), idConstraint)
# asString(0, 0) to prevent scientific notation from being printed.
totalConstraint offset asString(0, 0) println