
digits←{ (⎕UCS ⍵) - ⎕UCS '0' }

atoi←{ 10 ⊥ digits ⍵ }

table←{ ((⍳⍴⍵)-1) ⌽ ((⍴⍵),⍴⍵) ⍴ ⍵ }

sliding←{ (table ⍵)[⍳ 1+(⍴⍵)-⍺;⍳ ⍺] }

diagonal←{ {⍵ ⍵}¨ ⍳⍵ }

id←{ ⊃∘.=/⍳¨ ⍵ ⍵ }

allsums←{ ,(1-id⍴⍵) × ⍵∘.+⍵ }

testsums←{ ⍺ ∊ allsums ⍵ }

testline←{ ⍵[⍴⍵] testsums ⍵[⍳(⍴⍵)-1] }

∇ r←invalid findsum input
  len←2
branch:
  sequences←⊂[2] len sliding input
  sums←+/¨sequences
  →(1-invalid∊sums)/next
  minmaxes←{(⌊/⍵)+⌈/⍵}¨ sequences
  r←(sums=invalid) / minmaxes
  →term
next:
  len←len+1
  →(len<⍴input)/branch
term:
∇

input←atoi¨ ⎕FIO[49] "input.txt"
lines←26 sliding input
candidates←lines[;26]
invalid←(,⊃1 - testline¨ ⊂[2] lines) / candidates

⎕←invalid findsum input
