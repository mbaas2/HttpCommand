 r←test_cookie_delete_maxage dummy;h;port;url;r1;r2
 ⍝ A Set-Cookie with Max-Age=0 removes the matching cookie from the jar
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 h←#.HttpCommand.New''
 h.URL←url,'/EndPoints/set_cookie'
 r1←h.Run
 :If r1.(rc HttpStatus)≢0 200
     →0⊣r←'setup request failed: rc=',⍕r1.rc
 :EndIf
 :If 0∊⍴h.Cookies
     →0⊣r←'cookie not stored after first request'
 :EndIf
 h.URL←url,'/EndPoints/delete_cookie_maxage'
 r2←h.Run
 :If r2.(rc HttpStatus)≢0 200
     →0⊣r←'delete request failed: rc=',⍕r2.rc
 :EndIf
 :If ~0∊⍴h.Cookies
     →0⊣r←'cookie jar not empty after Max-Age=0 deletion; still contains: ',⊃h.Cookies.Name
 :EndIf
 r←''
