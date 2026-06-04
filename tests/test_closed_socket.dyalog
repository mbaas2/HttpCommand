 r←test_closed_socket dummy;result;port;url
 url←'http://localhost:',⍕port←8090 Using #.HttpServer
 result←#.HttpCommand.Get url,'/EndPoints/closed_socket'
 r←(result.rc≠1119)/'closed socket test failed: ',⍕result
