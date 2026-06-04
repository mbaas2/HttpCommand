 {r}←test_get_url dummy;z;param;url
⍝ test url arguments
 :For (url param) :In ('?one=test&two=two%20words' '')('?one=test'('two' 'two words'))(''({t←⎕NS'' ⋄ t.(one two)←'test' 'two words' ⋄ t}''))('' 'one=test&two=two%20words')
     →0↓⍨0∊⍴r←0 200 check(z←#.HttpCommand.Get(#._httpbin,'/get',url)param).(rc HttpStatus)
     :Trap 0
         →0↓⍨0∊⍴r←'test' 'two words'check(⎕JSON z.Data).args.(one two)
     :Else
         →0⊣r←''check⊃⎕DM
     :EndTrap
 :EndFor
