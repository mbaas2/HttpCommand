 r←test_cookie_maxage dummy;result;port;url;cookie
 ⍝ Max-Age attribute causes Expires to be set to a future time
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 result←#.HttpCommand.Get url,'/EndPoints/set_cookie_maxage'
 :If result.(rc HttpStatus)≢0 200
     →0⊣r←'request failed: rc=',⍕result.rc
 :EndIf
 :If 0∊⍴result.Cookies
     →0⊣r←'no cookies in response'
 :EndIf
 cookie←⊃result.Cookies
 :If 'session'≢cookie.Name
     →0⊣r←'wrong cookie name: expected session, got ',cookie.Name
 :EndIf
 :If '12345'≢cookie.Value
     →0⊣r←'wrong cookie value: expected 12345, got ',cookie.Value
 :EndIf
 :If 0∊⍴cookie.Expires
     →0⊣r←'Expires not set by Max-Age'
 :EndIf
 :If 80=⎕DR cookie.Expires
     →0⊣r←'Expires is not numeric (expected IDN from Max-Age)'
 :EndIf
 r←''
