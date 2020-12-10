
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

ones = 0
threes = 0
for i = 0 to lines
    select case inputs(i + 1) - inputs(i)
        case 1
            ones = ones + 1
        case 3
            threes = threes + 1
    end select
next i
print ones * threes
end
