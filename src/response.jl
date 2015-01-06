#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export handle_response

#------------------------------------------------------------------------------
# Response Handlers
#------------------------------------------------------------------------------

function handle_response (s::TCPSocket, x::Any)
    info("[response] Response $x")
    reply_close(s, x)
end

#= 
When a list of bytes is provided as a response, it is automatically assumed to 
be streamed out. It is assumed that each byte array is one 'chunk' terminated
by a 4 byte 0 header. This should change soon.
=#

function handle_response (s::TCPSocket, bytes::Array{Uint8})
    info("[response] Forming streaming response")
    reply_info(s, :stream, [])
    reply_stream_close(s, bytes)
end
