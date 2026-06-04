 r←test_cookie_multiple dummy;result;port;url;names;values
 ⍝ Multiple Set-Cookie headers in one response are each parsed into result.Cookies
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 result←#.HttpCommand.Get url,'/EndPoints/set_multiple_cookies'
 :If result.(rc HttpStatus)≢0 200
     →0⊣r←'request failed: rc=',⍕result.rc
 :EndIf
 :If 3≠≢result.Cookies
     →0⊣r←'expected 3 cookies, got ',⍕≢result.Cookies
 :EndIf
 names←result.Cookies.Name
 values←result.Cookies.Value
 :If ~∧/('alpha' 'beta' 'gamma')∊names
     →0⊣r←'expected cookies alpha, beta, gamma; got: ',⍕names
 :EndIf
 :If ~∧/('one' 'two' 'three')∊values
     →0⊣r←'expected values one, two, three; got: ',⍕values
 :EndIf
 r←''
