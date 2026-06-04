 r←test_cookie_jar dummy;h;port;url;r1;r2
 ⍝ Cookies received in one response are stored and sent in subsequent requests
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 h←#.HttpCommand.New''
 h.URL←url,'/EndPoints/set_cookie'
 r1←h.Run
 :If r1.(rc HttpStatus)≢0 200
     →0⊣r←'first request failed: rc=',⍕r1.rc
 :EndIf
 :If 0∊⍴h.Cookies
     →0⊣r←'no cookies stored in instance after first request'
 :EndIf
 h.URL←url,'/EndPoints/echo_cookies'
 r2←h.Run
 :If r2.(rc HttpStatus)≢0 200
     →0⊣r←'second request failed: rc=',⍕r2.rc
 :EndIf
 :If ~'sessionid=abc123'(∨/⍷)r2.Data
     →0⊣r←'stored cookie not sent in second request; echo: ',r2.Data
 :EndIf
 r←''
