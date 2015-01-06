#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export read_erlang_term, read_binary_stream
export write_erlang_term, write_binary_stream

#------------------------------------------------------------------------------
# Byte Reading Functions
#------------------------------------------------------------------------------

function read_erlang_term (s::TCPSocket)
    bytes = Array(Uint8, 0)
    length_header = readbytes(s, 4)
    nbytes = decode_integer(length_header)
    nbytes_read = 0
    while nbytes_read < nbytes
        next_bytes = readbytes(s, nbytes)
        nbytes_read += length(next_bytes)
        bytes = vcat(next_bytes, bytes)
    end
    vcat(length_header, bytes)
end

function read_binary_stream (s::TCPSocket)
    bytes = Array(Uint8, 0)
    length_header = readbytes(s, 4)
    nbytes = decode_integer(length_header)
    nbytes_read_total = 0
    while nbytes > 0
        nbytes_read = 0
        while nbytes_read < nbytes
            next_bytes = readbytes(s, nbytes)
            nbytes_read += length(next_bytes)
            bytes = vcat(next_bytes, bytes)
        end
        nbytes_read_total += nbytes_read
        length_header = readbytes(s, 4)
        nbytes = decode_integer(length_header)
    end
    bytes, nbytes_read_total
end

#------------------------------------------------------------------------------
# Byte Writing Functions
#------------------------------------------------------------------------------

function write_erlang_term (s::TCPSocket, bytes::Array{Uint8})
    nbytes = length(bytes)
    nbytes_written = 0
    nbytes_written_total = 0
    while nbytes_written < nbytes
        nbytes_written = write(s, bytes)
        bytes = bytes[nbytes_written:end]
        nbytes_written_total += nbytes_written
    end
    flush(s)
    nbytes_written_total
end

function write_binary_stream (s::TCPSocket, bytes::Array{Uint8})
    length_header = encode_integer(uint32(length(bytes)))
    bytes = vcat(length_header, bytes)
    bytes = vcat(bytes, uint8([0,0,0,0]))
    nbytes = length(bytes)
    nbytes_written = 0
    while nbytes_written < nbytes
        nbytes_written = write(s, bytes)
        bytes = bytes[nbytes_written:end]
        nbytes_written_total += nbytes_written
    end
    flush(s)
    nbytes_written_total
end

