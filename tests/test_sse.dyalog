 {r}←test_sse dummy;c;result;start
⍝ Test Server-Sent Events using echo.websocket.org/.sse
 r←''
 #.SSEEvents←⍬
 {}#.⎕FX'result sse_test_handler payload' '#.SSEEvents,←⊂payload'
 c←#.HttpCommand.New'get'(#._websocket,'.sse')
 c.EnableSSE←1
 c.OnSSEfn←'sse_test_handler'
 result←c.Run
 :If 0=result.rc
     start←⎕AI[3]
     :While (0∊⍴#.SSEEvents)∧10000>⎕AI[3]-start
         {}⎕DL 0.5
     :EndWhile
     :If 0∊⍴#.SSEEvents
         r←'No SSE events received within 10 seconds'
     :EndIf
 :Else
     r←'SSE failed to start: ',result.msg
 :EndIf
 :Trap 0 ⋄ result.Close ⋄ :EndTrap
 :Trap 0 ⋄ ⎕TSYNC result.SSEThread ⋄ :EndTrap
 {}#.⎕EX'sse_test_handler'
 {}#.⎕EX'SSEEvents'
