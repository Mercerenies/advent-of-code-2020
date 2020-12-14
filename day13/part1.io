
List maximumBy := method(key, self reduce(acc, x, if(key call(acc) >= key call(x), acc, x)))

file := File with("input.txt") openForReading

time := file readLine asNumber
buses := file readLine split(",") map(v, if(v == "x", nil, v asNumber))

file close

busID := buses maximumBy(block(v, if(v, time % v, -999)))
waitTime := busID - (time % busID)
(busID * waitTime) println
