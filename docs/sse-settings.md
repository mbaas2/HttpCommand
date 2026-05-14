SSE settings control whether an `HttpCommand` instance will accept Server-Sent Events (SSEs).

## Instance settings

### `EnableSSE`

|--|--|
|Description|A Boolean that enables `HttpCommand` to process Server-Sent events.<ul><li>`1` = process SSEs</li><li>`0` = do not process SSEs</li></ul>|
|Default|`0`|
|Example(s)|`h.EnableSSE←1`|
|Details|If `EnableSSE` is `0` and `HttpCommand` receives an SSE response from the host, indicated by a `content-type` header of `text/event-stream`, `HttpCommand` will terminate with `msg` of "Server responded with SSE, but EnableSSE=0"|

### `ParseSSE`

|--|--|
|Description|A Boolean the indicates whether to process received SSE event messages into a more convenient namespace format.  Valid values are:<ul><li>`1` (the default) - parse into a namespace See [Handling SSE Event Messages](sse.md#handling-sse-event-messages).</li><li>`0` - do not parse, just return the raw event message</li></ul>|
|Default|`1`|
|Example(s)|`h.ParseSSE←0 ⍝ don't parse, just use raw event message`|
|Details|If using `ParseSSE←0`, see [Parsing an event stream](https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream).|

### `OnSSEfn`

|--|--|
|Description|`OnSSEfn` is the name of the function that you write that will be called when `HttpCommand` receives an SSE event message. The function should be dyadic and not return a result. The left argument is a reference to the `HttpCommand` result namespace. The right argument is either the raw SSE event message (if `ParseSSE←0`) or a namespace containing the parsed SSE event message (if `ParseSSE←1').
|Default|`''`|
|Example(s)|The following assumes that `ParseSSE←1`.<br/><pre style="font-family:APL;">onSSE←{'done'≡⍵.event: ⍺.Close ⍝ close the listener on a "done" event<br/>       ⎕←⍵.(event id) ⍝  otherwise display the event name and id}<br/>r.OnSSEfn←'onSSE'</pre>|
|Details|If `OnSSEfn` is not specified, `HttpCommand` will display the SSE event message to the session.|