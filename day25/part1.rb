
Modulo = 20201227

def solve(key, subject_number)
  loop_size = 0
  value = 1
  while value != key
    loop_size += 1
    value = (value * subject_number) % Modulo
  end
  loop_size
end

def iterate(subject_number, loop_size)
  value = 1
  loop_size.times do
    value = (value * subject_number) % Modulo
  end
  value
end

key_a = nil
key_b = nil
File.open("input.txt") do |file|
  key_a = file.readline.to_i
  key_b = file.readline.to_i
end

loop_a = solve(key_a, 7)
puts iterate(key_b, loop_a)
