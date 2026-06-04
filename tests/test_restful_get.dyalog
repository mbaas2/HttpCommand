 {r}←test_restful_get dummy
 r←0 200 check(#.HttpCommand.Get #._typicode,'posts').(rc HttpStatus)
