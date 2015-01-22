#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

module FsServer
using FsBert
#------------------------------------------------------------------------------
# FIXME: There is probably a better way of dynamically including modules.
#------------------------------------------------------------------------------
using FsFootball
#------------------------------------------------------------------------------
include("types.jl")
include("socket_io.jl")
include("gen_server.jl")
include("response.jl")
include("request.jl")
include("server.jl")
end
