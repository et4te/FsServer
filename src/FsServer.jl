#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

module FsServer
using FsBert
#------------------------------------------------------------------------------
# TODO: External modules should be searched for, not provided to the server in
# this manner
#------------------------------------------------------------------------------
using FsExtern
#------------------------------------------------------------------------------
include("types.jl")
include("socket_io.jl")
include("gen_server.jl")
include("response.jl")
include("request.jl")
include("server.jl")
end
