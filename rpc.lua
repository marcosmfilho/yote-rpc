-- RPC for Lua
-- From: https://gist.github.com/airstruck/5e0d0336231cfdefd3f6424afe6e75dc
-- License: MIT https://opensource.org/licenses/MIT

local socket = require 'socket' -- https://github.com/diegonehab/luasocket
local binser = require 'binser-master/binser' -- https://github.com/bakpakin/binser

local DEFAULT_HOST_SERVER = '127.0.0.1'
local DEFAULT_PORT_SERVER = 2020
local DEFAULT_HOST_CLIENT = '127.0.0.1'
local DEFAULT_PORT_CLIENT = 2021

local unpack = unpack or table.unpack

-- Escape and unescape data for network transfer.
-- Escapes line breaks, they signal end of data.

local ESC = string.char(27)
local ESC_ESC = ESC .. '1'
local ESC_LF = ESC .. '2'

local function escape (data)
    return (data:gsub(ESC, ESC_ESC):gsub('\n', ESC_LF))
end

local function unescape (data)
    return (data:gsub(ESC_LF, '\n'):gsub(ESC_ESC, ESC))
end

-- Serialize and deserialize data.

local function serialize (...)
    return escape(binser.serialize(...)) .. '\n'
end

local function deserialize (data)
    local results, len = binser.deserialize(unescape(data))
    return unpack(results, 1, len)
end

-- Client stuff.

-- Call an RPC method and return the results.
local function call (client, ...)
    local tcp = socket.tcp()
    tcp:settimeout(1)
    tcp:connect(DEFAULT_HOST_SERVER, DEFAULT_PORT_SERVER)

    assert(tcp:send(serialize(...)))

    local result = assert(tcp:receive())
    tcp:close()

    return select(2, assert(deserialize(result)))
end

-- Indexing an undefined field creates an RPC method.
local clientMeta = {
    __index = function (t, k)
        t[k] = function (t, ...) return call(t, k, ...) end
        return t[k]
    end,
}

-- Client constructor.
local function createClient (host, port)
    local client = {}

    client.host = host or DEFAULT_HOST_CLIENT
    client.port = port or DEFAULT_PORT_CLIENT

    print('Client on ' .. client.host .. ' ' .. client.port)
    return setmetatable(client, clientMeta)
end

-- Server stuff

-- Execute an RPC method.
local function execute (server, ok, proc, ...)
    if not ok then return ok, proc, ... end
    return pcall(server.exports[proc], server, ...)
end

-- Handles clients. Call server:update() in a loop.
local function update (server)
    local tcp = server.socket:accept()
    if not tcp then return end
    local data, ip, port = tcp:receive()
    if data then
        rawset(server, 'client', tcp) -- expose client socket to remote procs
        tcp:send(serialize(execute(server, pcall(deserialize, data))))
    else
        tcp:send(serialize(false, 'no data'))
    end
    tcp:close()
end

-- User-defined methods are exposed to RPC clients.
local serverMeta = {
    __newindex = function (t, k, v) t.exports[k] = v end,
    __index = function (t, k) return t.exports[k] end,
}

-- Server constructor
local function createServer (host, port)
    local server = {}

    server.update = update
    if host then
        server.host = host
        DEFAULT_HOST_SERVER = host
    else
        server.host = DEFAULT_HOST_SERVER
    end
    if port then
        server.port = port
        DEFAULT_PORT_SERVER = port
    else
        server.port = DEFAULT_PORT_SERVER
    end

    server.exports = {}
    server.socket = assert(socket.bind(server.host, server.port))
    server.socket:settimeout(1)

    print('RPC on', server.socket:getsockname())

    return setmetatable(server, serverMeta)
end

return { client = createClient, server = createServer }
