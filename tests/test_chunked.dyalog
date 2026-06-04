 {r}←test_chunked dummy;result
 result←#.HttpCommand.Get #._httpbin,'/stream/3'
 r←0 200 'chunked'check result.(rc HttpStatus),⊂result.GetHeader'transfer-encoding'
