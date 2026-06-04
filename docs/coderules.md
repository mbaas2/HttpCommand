# Additional Rules

- read and acknowledge this file. do not deviate from it.
- Never use en-dash or em-dash characters in APL code or comments
- use setup_httpcommand_test to set up the testing environment

# Testing HttpCommand

- the test environment can be initialized by doing 
    - 2 ⎕FIX '/git/HttpCommand/tests/setup_httpcommand_test.dyalog
    - setup_httpcommand_test ''
- setup_httpcommand_test will define HttpCommand, HttpServer, Using, and other code needed to run the tests and load all tests and endpoints into the workspace
- the HttpCommand documentation can be found at https://dyalog.github.io/HttpCommand


## Using HttpServer for Tests

- Using can be used to start an instance of HttpServer
- /tests/HttpServer.dyalog can be used to test behavior that's not easily replicated by a publicly available URL
- an example of using HttpServer can be found in test_ping.aplf
- you use HttpServer by creating a custom endpoint function (like ping.aplf for the test*ping.aplf test). this function returns the behavior intended to be tested by the test* function

## using httpbin for tests

- https://httpbin.org is a web service with endpoints to test various types of HTTP interation

## using websocket.org for testing SSE

- https://echo.websocket.org/.sse can be used to test SSE

