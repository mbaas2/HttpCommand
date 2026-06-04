 r←test_cookie_path_filter dummy;h;port;url;r1;r2
 ⍝ Cookies with a Path attribute are only sent to requests matching that path
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 h←#.HttpCommand.New''
 h.URL←url,'/EndPoints/set_cookie_pathonly'
 r1←h.Run
 :If r1.(rc HttpStatus)≢0 200
     →0⊣r←'setup request failed: rc=',⍕r1.rc
 :EndIf
 :If 0∊⍴h.Cookies
     →0⊣r←'path-restricted cookie not stored after first request'
 :EndIf
 h.URL←url,'/EndPoints/echo_cookies'  ⍝ path /EndPoints does not match /api
 r2←h.Run
 :If r2.(rc HttpStatus)≢0 200
     →0⊣r←'echo request failed: rc=',⍕r2.rc
 :EndIf
 :If 'apikey=secret'(∨/⍷)r2.Data
     →0⊣r←'path-restricted cookie was incorrectly sent to non-matching path'
 :EndIf
 r←''
