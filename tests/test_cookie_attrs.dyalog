 r←test_cookie_attrs dummy;result;port;url;cookie
 ⍝ Set-Cookie with Path, SameSite, and HttpOnly attributes are parsed correctly
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 result←#.HttpCommand.Get url,'/EndPoints/set_cookie_attrs'
 :If result.(rc HttpStatus)≢0 200
     →0⊣r←'request failed: rc=',⍕result.rc
 :EndIf
 :If 0∊⍴result.Cookies
     →0⊣r←'no cookies in response'
 :EndIf
 cookie←⊃result.Cookies
 :If 'token'≢cookie.Name
     →0⊣r←'wrong cookie name: expected token, got ',cookie.Name
 :EndIf
 :If 'xyz123'≢cookie.Value
     →0⊣r←'wrong cookie value: expected xyz123, got ',cookie.Value
 :EndIf
 :If '/api'≢cookie.Path
     →0⊣r←'wrong cookie path: expected /api, got ',cookie.Path
 :EndIf
 :If 'Lax'≢cookie.SameSite
     →0⊣r←'wrong SameSite: expected Lax, got ',cookie.SameSite
 :EndIf
 :If ~cookie.HttpOnly
     →0⊣r←'HttpOnly flag not set'
 :EndIf
 r←''
