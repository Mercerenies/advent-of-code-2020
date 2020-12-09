
digits←{ (⎕UCS ⍵) - ⎕UCS '0' }

atoi←{ 10 ⊥ digits ⍵ }

table←{ ((⍳⍴⍵)-1) ⌽ ((⍴⍵),⍴⍵) ⍴ ⍵ }

sliding←{ (table ⍵)[⍳ 1+(⍴⍵)-⍺;⍳ ⍺] }

diagonal←{ {⍵ ⍵}¨ ⍳⍵ }

id←{ ⊃∘.=/⍳¨ ⍵ ⍵ }

allsums←{ ,(1-id⍴⍵) × ⍵∘.+⍵ }

testsums←{ ⍺ ∊ allsums ⍵ }

testline←{ ⍵[⍴⍵] testsums ⍵[⍳(⍴⍵)-1] }

input←atoi¨ ⎕FIO[49] "input.txt"
lines←26 sliding input
candidates←lines[;26]
⎕←(,⊃1 - testline¨ ⊂[2] lines) / candidates
