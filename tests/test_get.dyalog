 {r}←test_get dummy;port
 port←8090 #.Using #.HttpServer
 r←0 200 check(#.HttpCommand.Get'localhost:',(⍕port),'/EndPoints/get').(rc HttpStatus)
