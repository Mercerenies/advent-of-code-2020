
' Get length of file
open "input.txt" for input as #1
lines = 0
while not(eof(#1))
    line input #1, ignored
    lines = lines + 1
wend
close #1

dim inputs(lines + 1)

' Read the file
open "input.txt" for input as #1
for i = 1 to lines
    line input #1, inputs(i)
next i
close #1

sort inputs(), 1, lines

' Include the voltage of our device and the adapter
inputs(0) = 0
inputs(lines + 1) = inputs(lines) + 3

dim backtracking(lines + 1)
backtracking(lines + 1) = 1

for i = lines + 1 to 1 step -1
    for j = 1 to 3
        if i - j >= 0 then
            if inputs(i) - inputs(i - j) <= 3 then
                backtracking(i - j) = backtracking(i - j) + backtracking(i)
            end if
        end if
    next j
next i
print backtracking(0)
end
