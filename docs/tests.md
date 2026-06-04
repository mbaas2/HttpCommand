# HttpCommand Test Suite

Tests live in `tests/`. The test runner is `setup_httpcommand_test.dyalog`, which loads all test and endpoint functions into the workspace. Most tests use a local `HttpServer` instance; a small number require external network access.

## Running tests

```apl
2 ⎕FIX '/path/to/tests/setup_httpcommand_test.dyalog'
setup_httpcommand_test ''
result←test_name 0   ⍝ '' = pass, non-empty string = failure message
```

## Infrastructure

### Local HTTP server

Most tests start `HttpServer` on port 8090 using the `Using` helper:

```apl
url←'http://localhost:',⍕port←8090 Using HttpServer
```

`Using` reuses an already-running instance if one exists on any port. Endpoint functions are in `tests/EndPoints/` and are loaded automatically by `setup_httpcommand_test`.

### External services

A few tests rely on external URLs defined by `setup_httpcommand_test`:

| Variable | Service | Used by |
|---|---|---|
| `_httpbin` | `httpbin.org` | `test_get`, `test_get_url`, `test_chunked`, `test_gzip`, `test_deflate` |
| `_typicode` | `jsonplaceholder.typicode.com` | `test_restful_get`, `test_restful_post`, `test_restful_put` |
| `_websocket` | `echo.websocket.org` | `test_sse` |

---

## Tests by feature area

### Basic connectivity

#### `test_ping`
Sends a GET to the local `/EndPoints/ping` and verifies the response is `rc=0`, `HttpStatus=200`, `Data='pong'`. Serves as a baseline connectivity check.

#### `test_CongaInit`
Verifies that HttpCommand can initialise Conga from a user-supplied `CongaPath`. Copies the Conga workspace and shared libraries to a temporary directory, resets `HttpCommand.LDRC`, sets `CongaPath` to the temporary directory, then confirms a successful GET request. Restores the original `CongaPath` on cleanup. Uses the local HttpServer to avoid external network dependency.

#### `test_closed_socket`
Confirms that HttpCommand returns `rc=1119` when the server closes the connection without sending a response. Uses the `/EndPoints/closed_socket` endpoint, which closes the Conga connection immediately.

---

### HTTP methods

#### `test_get`
Basic GET to `httpbin.org/get`. Asserts `rc=0` and `HttpStatus=200`.

#### `test_head`
Sends a HEAD request to the local `/EndPoints/echo_method`. Verifies `rc=0`, `HttpStatus=200`, and that `Data` is empty (HttpCommand does not read the response body for HEAD).

#### `test_delete`
Sends a DELETE request to `/EndPoints/echo_method`, which echoes the HTTP method name. Asserts `rc=0`, `HttpStatus=200`, `Data='delete'`.

#### `test_restful_get`
GET to `jsonplaceholder.typicode.com/posts`. Asserts `rc=0` and `HttpStatus=200`.

#### `test_restful_post`
POST a namespace (`title`, `body`, `userId`) to `jsonplaceholder.typicode.com/posts`. Asserts `rc=0` and `HttpStatus=201`.

#### `test_restful_put`
PUT a namespace to `jsonplaceholder.typicode.com/posts/1`. Asserts `rc=0` and `HttpStatus=200`.

---

### URL and parameters

#### `test_get_url`
Exercises four equivalent ways to supply query parameters to `HttpCommand.Get`:

1. Query string embedded in the URL (`?one=test&two=two%20words`)
2. Name/value pair as a second argument (`'two' 'two words'`)
3. Namespace with fields `one` and `two`
4. Pre-encoded string as the params argument

For each, verifies `rc=0`, `HttpStatus=200`, and that the server echoes back `args.one='test'` and `args.two='two words'`.

#### `test_BaseURL`
Tests all combinations of `BaseURL` and `URL`:

- Neither set: `.Show` returns an error namespace with `'No URL specified'` in `msg`
- Only `BaseURL` set: request targets the base host
- Only `URL` set (no scheme): treated as a bare path with host inferred from URL
- Both set: `URL` is appended to `BaseURL`; a live `.Run` confirms `Data='pong'`

---

### Request construction

#### `test_request_only`
Verifies that `.Show` and `RequestOnly=1` both return the HTTP request as a character vector without making a network connection. Checks for the request line (`GET /path?q=1 HTTP/1.1`) and `Host:` header.

#### `test_headers`
Verifies that the `Headers` field accepts three input formats, all producing correct headers in the request (confirmed via `.Show`):

- **Matrix**: `2 2⍴'X-One' 'aaa' 'X-Two' 'bbb'`
- **Colon-delimited strings**: `'X-One: ccc' 'X-Two: ddd'`
- **Depth-3 pairs**: `('X-One' 'eee')('X-Two' 'fff')`

#### `test_suppress_headers`
Confirms that `SuppressHeaders=0` (default) includes `Host:` and `User-Agent:` in the request, and that `SuppressHeaders=1` omits them. Verified via `.Show`.

#### `test_content_type`
Verifies `ContentType` behaviour using `.Show`:

- A namespace `Params` auto-detects as `application/json`
- Setting `ContentType←'application/x-www-form-urlencoded'` overrides that and removes the JSON content type
- An arbitrary `ContentType←'text/xml; charset=utf-8'` passes through unchanged

#### `test_auth`
Tests `Auth` and `AuthType` settings in three forms (verified via `.Show` with `Secret←0`):

- `Auth←'user:secret'` produces `Authorization: Basic <base64('user:secret')>`
- `Auth←'user' 'secret'` (2-element vector) produces the same encoding
- `Auth←'mytoken123'` with `AuthType←'Bearer'` produces `Authorization: Bearer mytoken123`

Also makes a live request to `/EndPoints/echo_authorization` to confirm the header reaches the server with the correct Base64-encoded credentials.

---

### Response handling

#### `test_translate_data`
Sets `TranslateData←1` and GETs `/EndPoints/json_response` (which returns `{"status":"ok","value":42}`). Verifies the response `Data` is a namespace with `status='ok'` and `value=42`.

#### `test_get_json`
Calls `HttpCommand.GetJSON` against `/EndPoints/json_response`. Verifies the parsed namespace has the correct fields. Also calls `GetJSON` against `/EndPoints/ping` (which returns `text/plain`) and confirms that fails with `rc≠0`.

#### `test_max_payload`
Exercises `MaxPayloadSize` against `/EndPoints/large_response` (10 000 bytes):

- Default (`MaxPayloadSize=¯1`): full response received, `≢Data=10000`
- `MaxPayloadSize←100`: returns `rc=¯1` with `'MaxPayloadSize'` in the error message

#### `test_chunked`
GETs `httpbin.org/stream/3`, which responds with chunked transfer encoding. Asserts `rc=0`, `HttpStatus=200`, and `Transfer-Encoding: chunked` in the response headers.

#### `test_gzip`
GETs `httpbin.org/gzip`. Asserts `rc=0`, `HttpStatus=200`, and `Content-Encoding: gzip` in response headers. Confirms HttpCommand transparently decompresses the body.

#### `test_deflate`
GETs `httpbin.org/deflate`. Same as `test_gzip` but for deflate encoding.

---

### Redirects

#### `test_redirections`
Tests `MaxRedirections` and the `Redirections` result element against `/EndPoints/redirect` (which returns a 302 to `/EndPoints/ping`):

- `MaxRedirections←0`: response has `HttpStatus=302`, `Redirections` is empty
- Default (`MaxRedirections=10`): follows the redirect; final response has `HttpStatus=200`, `Data='pong'`, and `Redirections` contains one entry with `HttpStatus=302`

---

### Cookies

#### `test_cookie_jar`
Confirms cookie persistence in instance mode. Makes two requests on the same instance: the first to `/EndPoints/set_cookie` (sets `sessionid=abc123`), the second to `/EndPoints/echo_cookies`. Asserts the second response body contains `sessionid=abc123`, proving the cookie was stored and re-sent.

#### `test_cookie_multiple`
GETs `/EndPoints/set_multiple_cookies`, which sets three cookies (`alpha=one`, `beta=two`, `gamma=three`) in a single response. Asserts `≢result.Cookies=3` and that all three names and values are present.

#### `test_cookie_attrs`
GETs `/EndPoints/set_cookie_attrs`, which sets a cookie with `Path=/api`, `SameSite=Lax`, and `HttpOnly`. Verifies each attribute is parsed correctly into the cookie namespace (`Name`, `Value`, `Path`, `SameSite`, `HttpOnly`).

#### `test_cookie_maxage`
GETs `/EndPoints/set_cookie_maxage`, which sets a cookie with `Max-Age=3600`. Verifies that `Expires` is set to a numeric IDN value (not a string) derived from the Max-Age.

#### `test_cookie_delete`
Two-request sequence: set a cookie via `/EndPoints/set_cookie`, then send a request to `/EndPoints/delete_cookie` (which replies with a past `Expires` date). Asserts the cookie jar is empty after the second request.

#### `test_cookie_delete_maxage`
Same as `test_cookie_delete` but the deletion endpoint uses `Max-Age=0` instead of a past `Expires` date.

#### `test_cookie_path_filter`
GETs `/EndPoints/set_cookie_pathonly`, which sets `apikey=secret` with `Path=/api`. Then GETs `/EndPoints/echo_cookies` (path `/EndPoints`). Asserts the path-restricted cookie is NOT sent because `/EndPoints` does not match `/api`.

---

### Connection management

#### `test_timeout`
Uses the local `/EndPoints/timeout` endpoint (10-second delay):

- `Timeout←5`: request times out, `rc=100`
- `Timeout←15`: request completes, `rc=0`

#### `test_keep_alive`
Makes two consecutive requests on the same instance with `KeepAlive=1` (default) and then with `KeepAlive=0`. Asserts `rc=0` for all four requests, confirming both modes complete successfully.

#### `test_closed_socket`
*(See Basic connectivity above.)*

---

### File output

#### `test_outfile`
Tests all three `OutFile` write modes against `dyalog.com`:

- No `OutFile`: response data arrives in `Data`
- `OutFile←filename`: data written to file; `BytesWritten` matches file size; `Data` is not populated
- Attempting to write again with default (no overwrite) returns `rc=¯1` with a "not empty" error
- `OutFile←filename 1` (overwrite): succeeds; file content matches original
- `OutFile←filename 2` (append): file is twice as large; `BytesWritten` accounts for the appended bytes

---

### Utility functions

#### `test_base64`
Tests `HttpCommand.Base64Encode` and `Base64Decode`:

- `Base64Encode 'hello'` = `'aGVsbG8='`
- `Base64Decode 'aGVsbG8='` = `'hello'`
- Round-trip of `'Hello, World!'`
- Round-trip of empty string

#### `test_url_encode_decode`
Tests `HttpCommand.UrlEncode` and `UrlDecode`:

- `UrlEncode 'hello world'` = `'hello%20world'`
- `UrlDecode 'hello%20world'` = `'hello world'`
- `UrlDecode 'hello+world'` = `'hello world'` (`+` decoded as space)
- `'q' UrlEncode 'hello world'` = `'q=hello%20world'`
- Round-trip of `'hello world'`

---

### Server-Sent Events

#### `test_sse`
Connects to `echo.websocket.org/.sse` with `EnableSSE←1` and `OnSSEfn` set to a handler that appends events to `#.SSEEvents`. Waits up to 10 seconds for at least one event. Asserts `rc=0` on start and that at least one event was received. Closes the SSE connection and synchronises the thread on teardown.
