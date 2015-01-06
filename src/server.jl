#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export serve

#------------------------------------------------------------------------------
# External Server API
#------------------------------------------------------------------------------

function serve (portno::Integer)
    info("[server] Listening on port $portno")
    srv = listen(portno)
    @async accept_loop(srv)
end

#------------------------------------------------------------------------------
# Internal Functions
#------------------------------------------------------------------------------

function accept_loop (srv)
    while true
        s = accept(srv)
        info("[server] Accepted connection, handling request")
        @async handle_request(s)
    end
end
