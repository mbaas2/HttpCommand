 {r}←test_deflate dummy;result
 result←#.HttpCommand.Get #._httpbin,'/deflate'
 r←0 200 'deflate'check result.(rc HttpStatus),⊂result.GetHeader'content-encoding'
