local chat = {}
local utf8 = require("utf8")
local suit = require 'suit'
local  input = {text = ""}
local localmsgs = {}

function tablelength(T)
  counter = 0
  if T ~= nil then
    for index in pairs(T) do
        counter = counter + 1
    end
  end
  return counter
end

function chat.load()
  rpc = require 'rpc'.client('localhost', 2021)
  love.keyboard.setKeyRepeat(true)
  list = require 'listbox'
  tlist = {x=475, y=390,font=font,ismouse=true,
                 w=500,h=150,showindex=true, rounded=true,
                 hor=true,fcolor={102, 0, 204},bordercolor={0, 0, 153},
                 bgcolor={230, 250, 255},selectedcolor={102, 204, 255},
                 fselectedcolor={102, 0, 204},radius=8,adjust=true,expand=false,
                 font = love.graphics.newFont('fonts/accid.ttf',22)}
  list:newprop(tlist)
  numberlocalmsgs = 0
  player = ''
end

function chat.textinput(t)
    if string.len(input.text) < 45 then
      suit.textinput(t)
    end
end

function chat.draw()
  suit.draw()
  list:draw(player)
end

function chat.update(dt)
    list:update(dt)
    suit.layout:reset(475,555)
    suit.Input(input, suit.layout:row(500,30))
    suit.layout:row()
    msg = rpc:getMessages(numberlocalmsgs)
    if msg then
        if msg ~= false then
            local newmsg = msg.name .. ': ' .. msg.msg
            if msg.player1 == true then
                list:additem(newmsg  ,"",true, 'player1')
                numberlocalmsgs = numberlocalmsgs + 1
            else
                list:additem(newmsg  ,"",true, 'player2')
                numberlocalmsgs = numberlocalmsgs + 1
            end
        end
    end
end

function chat.keypressed(key, idUser, nameUser)
    suit.keypressed(key)
    list:key(key,true)
    if key == "return" and input.text ~= "" then
        rpc:newMessage(idUser, nameUser, input.text)
        input.text = ""
    end
end

function chat.wheelmoved(x,y)
  list:mousew(x,y)
end

return chat
