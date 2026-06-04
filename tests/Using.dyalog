 Using←{
 ⍝ start or use an instance of ⍵ (generally HttpServer) on port ⍺
 ⍝ if an instance is already running, use it (and its port)
 ⍝ ← is the port number the instance is listening on
     0∊⍴i←⎕INSTANCES ⍵:⍺⊣⍵.Run ⍺
     (⊃⊃i).Running:(⊃⊃i).Port
     0=1⊃2⊃(⊃⊃i).Run ⍺:⍺
     ∘∘∘
 }
