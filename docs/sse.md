Server-Sent Events (SSE) is a web technology that enables a server to push real-time updates to `HttpCommand`. Unlike WebSockets, which provide full-duplex communication, SSE is unidirectional — data flows only from server to client. `HttpCommand` initiates the connection with a standard HTTP request, and the server responds with a text/event-stream content type, keeping the connection open and sending data as a stream of newline-delimited messages. Each message can include fields such as data, event, id, and retry. SSE is particularly well-suited for use cases like live feeds, log streaming, and AI chat completions, where the server needs to continuously deliver updates without the client repeatedly polling.

## Basic steps to use SSE

* Write a dyadic, non-result-returning function to process the event messages from the server. We'll call this function the "SSE handler". 
    * The right argument is the event payload.
    * The left argument is a reference to the `HttpCommand` result namespace.
    * If you do not write an SSE handler, the event message will be displayed to the APL session.
* Create an instance of `HttpCommand`. For example: `h←HttpCommand.New ''`
* Set `URL` to the address of the host server.
* Set `EnableSSE` to `1`.
* Set `OnSSEfn` to the name of the function you wrote.
* If you do **not** want `HttpCommand` to parse the event messages into a namespace format, set `ParseSSE` to `0`. 
* Run the `HttpCommand` instance, saving the reference to the result namespace. For example: `r←h.Run`<br/>This will start a listener on a separate thread.
* Every time an event message is received, `HttpCommand` with pass either:
    * If `ParseSSE` is `0`, the unmodified event message is passed as the right argument to the SSE handler.
    * If `ParseSSE` is `1`, the a namespace containing the parsed event message is passed as the right argument to the SSE handler.
* To stop the listener you can either hit interrupt or use the `Close` function in the result namespace. For example: `r.Close`.
* You can also append the raw SSE event messages to a file by specifying [`OutFile`](operational-settings.md#outfile) and optionally [`MaxPayloadSize`](operational-settings.md#maxpayloadsize). If you specify `MaxPayloadSize`, the listener will quit when appending the current event message would exceed `MaxPayloadsize`.  

## Handling SSE Event Messages
When the listener receives an SSE event message it will:

* If `OutFile` is specified, append the raw event message to the file specified by `OutFile`
* If `ParseSSE` is `1` (the default), the event message is parsed based on the [SSE specification](https://html.spec.whatwg.org/multipage/server-sent-events.html#event-stream-interpretation) into a namespace format that's more useful in an APL environment. The namespace contains:
    * `event` - the event name, or `'message'` if `event:` was not specified in the event message
    * `data` - a vector of character vectors, one per occurrence of `data:` in the event message
    * `id` - the `id:` of the event message or `''` if `id:` was not specified
    * `retry` - if specified in the event message, the reconnection time in milliseconds. Note that the current architecture is not able to do anything with `retry`.
* If you have specified `OnSSEfn`, it is called passing:
    * a reference to the `HttpCommand` result namespace as its left argument
    * as its right argument - the namespace described above if `ParseSSE←1` or the raw event message if `ParseSSE←0`
* If you have not specified `OnSSEfn` the event message is displayed in the session.

To stop the listener you can either call `r.Close` or generate an interrupt.

## `HttpCommand` Result Namespace Modifications
If you're using SSE, the `HttpCommand` result namespace has some additional elements:

* `SSEThread` is the thread on which the listener is running
* `Close` is a function to terminate the listener
* `CloseSSE` is a Boolean which the listener checks for whether to terminate or not. The `Close` function sets `CloseSSE←1`
* Additionally, the display format of the result namespace is updated whenever `msg`, `rc`, `HttpStatus`, or `HttpMessage` are updated.

## Example
<pre><code>      h←HttpCommand.New (
      URL:'https://echo.websocket.org/.sse'
      )
      h.Run
[rc: ¯1 | msg: Server responded with SSE, but EnableSSE=0 | HTTP Status: 200 "OK" | ≢Data: 0]
</code></pre>
Duh! Need to set `EnableSSE←1`
<pre><code>onSSE←{
       ⍝ ⍺ - reference to HttpCommand result namespace
       ⍝ ⍵ - SSE payload              
         '10'≡⍵.id: ⍺.Close ⍝ close listener when we get to id='10'
         ⍵.(event id)       ⍝ otherwise display the event and id    
       }                    
      
      h←HttpCommand.New (
      URL:'https://echo.websocket.org/.sse'
      EnableSSE:1
      OnSSEfn:'onSSE'
      )
      r←h.Run
 server  1
 request  2
 time  3
 time  4
 time  5
 time  6
 time  7
 time  8
 time  9
</code></pre>
