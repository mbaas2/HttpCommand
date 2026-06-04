 r←teardown_httpcommand_test;i
 :If ~0∊⍴i←⎕INSTANCES HttpServer
     i.Stop
 :EndIf
 r←''
