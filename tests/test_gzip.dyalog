 {r}←test_gzip dummy;result
 result←#.HttpCommand.Get #._httpbin,'/gzip'
 r←0 200 'gzip'check result.(rc HttpStatus),⊂result.GetHeader'content-encoding'
