#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export call_request, cast_request

abstract Request
abstract Response

#= Requests

Straightforward request types are defined here. The surprising aspect here is
that requests do not contain a module. Instead, modules are resolved as soon
as the request is made given a symbol which represents that module. As an 
example, an Erlang node may make a call request (:FsExtern, :test_f, [1024]).
Here, the call_request constructor will be invoked in order to lookup FsExtern
module and use this to find the function test_f which will then become part
of the constructed request type. 

=#

type CallRequest <: Request
    fun::Function
    args::Tuple
end

type StreamingCallRequest <: Request
    fun::Function
    args::Tuple

    StreamingCallRequest(r::CallRequest) = begin
        new(r.fun, r.args)
    end
end

type CastRequest <: Request
    fun::Function
    args::Tuple
end

type InfoRequest <: Request
    command::Symbol
    options::Array{Any}
end

type ErrorRequest <: Request
    err::Any
end

type CallbackCastRequest <: Request
    fun::Function
    args::Tuple
    callback_mod::Symbol
    callback_fun::Symbol

    CallbackCastRequest(r1::CastRequest, r2::InfoRequest) = begin
        new(r1.fun, r1.args, r2.options[:mod], r2.options[:fun])
    end
end

#= External Constructors

These were created in order to ensure that the inputs to the later constructed
types are correctly formed. In the case of call / cast requests for example, 
symbols are mapped to module / function objects.

=#

function call_request (mod_sym::Symbol, fun_sym::Symbol, args::Tuple)
    mod::Module = eval(mod_sym)
    fun::Function = eval(mod, fun_sym)
    CallRequest(fun, args)
end

function cast_request (mod_sym::Symbol, fun_sym::Symbol, args::Tuple)
    mod::Module = eval(mod_sym)
    fun::Function = eval(mod, fun_sym)
    CastRequest(fun, args)
end

