 {r}←test_restful_put dummy;params;result
 (params←⎕NS'').(title body userId id)←'foo' 'bar' 1 200
 r←0 200 check(result←#.HttpCommand.Do'put'(#._typicode,'posts/1')params).(rc HttpStatus)
