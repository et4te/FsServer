#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export handle_request

#------------------------------------------------------------------------------
# Base Request Handler
#------------------------------------------------------------------------------

function handle_request (s::TCPSocket)
    r = nothing

    while isopen(s)
        r = form_request(s, r)

        info("[request] Formed request $r, dispatching")
        
        handle_request(s, r)
    end
end

#------------------------------------------------------------------------------
# Generic Request Handlers
#------------------------------------------------------------------------------

function handle_request (s::TCPSocket, r::CallRequest)
    x::Any = r.fun((r.args)...)
    info("[request] Applied $(r.fun) to $(r.args)")
    handle_response(s, x)
end

function handle_request (s::TCPSocket, r::CastRequest)
    info("[request] CastRequest received")
    noreply(s)
    x::Any = r.fun((r.args)...)
    x
end

function handle_request (s::TCPSocket, r::InfoRequest)
    info("[request] InfoRequest received")
    noreply(s)
end

function handle_request (s::TCPSocket, r::ErrorRequest)
    info("[request] ErrorRequest received")
    noreply_close(s)
    error("Error request $r signaled")
end

function handle_request (s::TCPSocket, r::StreamingCallRequest)
    info("[request] StreamingCallRequest received")
    bytes::Array{Uint8} = read_binary_stream(s)
    x::Any = r.fun((r.args)..., bytes)
    handle_response(s, x)
end

function handle_request (s::TCPSocket, r::CallbackCastRequest)
    info("[request] CallbackCastRequest received")
    noreply(s)
    x::Any = r.fun((r.args)...)
    # TODO: Initiate callback in the connected client
    msg = (:call, r.callback_mod, r.callback_fun, tuple(x))
end

#------------------------------------------------------------------------------
# Request Formation Functions
#------------------------------------------------------------------------------

function form_request (s::TCPSocket, r::Union(Request,Void))
    if r == nothing
        next_request(s)
    else
        next = next_request(s)
        modify(next, r)
    end
end

function next_request (s::TCPSocket)
    info("[request] Reading next request")
    bytes = read_erlang_term(s)
    info("[request] Read erlang term $bytes")
    msg, nbytes = decode_message(bytes)
    info("[request] Decoded erlang message $msg")
    is(msg[1], :call) ? call_request(msg[2], msg[3], tuple(msg[4]...)) :
    is(msg[1], :cast) ? cast_request(msg[2], msg[3], tuple(msg[4]...)) :
    is(msg[1], :info) ? InfoRequest(msg[2], msg[3]) :
    is(msg[1], :error) ? ErrorRequest(msg[2]) :
    error("[request] Message does not conform to protocol")
end

#------------------------------------------------------------------------------
# Request Modification Functions
#------------------------------------------------------------------------------

function modify(r1::InfoRequest, r2::InfoRequest)
    InfoRequest(r2)
end

function modify(r1::CallRequest, r2::InfoRequest)
    if is(r2.command, :stream)
        StreamingCallRequest(r2)
    else
        r1
    end
end

function modify(r1::CastRequest, r2::InfoRequest)
    if is(r2.command, :callback)
        CallbackCastRequest(r2)
    else
        r1
    end
end

