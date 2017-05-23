require 'love.timer'
rpc = require 'rpc'.client('localhost', 5050)

i = 1
channel = love.thread.getChannel("messages")

while true do
  love.timer.sleep(1)
  msg = rpc:getMessages()
  if msg ~= nil or msg ~= '' then
    channel:push(msg .. ' ' .. i)
    i = i + 1
  end
end
