 {r}←test_restful_post dummy;params;resp
 (params←⎕NS'').(title body userId)←'foo' 'bar' 1
 r←0 201 check(resp←#.HttpCommand.Do'post'(#._typicode,'posts')params).(rc HttpStatus)
