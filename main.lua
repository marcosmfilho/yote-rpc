require('board')
require('table')
require('tables')
local utf8 = require('utf8')
local suit = require('suit')
local chat = require('chat')

local idUser
local world = {}
local updaterate = 0.1
local controlTime
local input = {text = ""}
local init

function love.load()
    rpc = require 'rpc'.client('localhost', 2021)
    math.randomseed(os.time())
    idUser = tostring(math.random(9999))
    screen = 1
    enter = "Enter your nickname and press enter"
    love.keyboard.setKeyRepeat(true)
    background = love.graphics.newImage("images/bg.jpg")
    love.window.setMode(1000, 600, {resizable=false, vsync=false, minwidth=1000, minheight=540})
    player1 = false
    player2 = false
    piecesPlayer1 = nil
    piecesPlayer2 = nil
    nameUser = ''
    turn = ''
    colorUser = ''
    opponentname = ''
    board.load()
    chat.load()
    controlTime = 0
end


function love.update(dt)
    if screen == 1 then
        suit.layout:reset(250,350)
        suit.Input(input, suit.layout:row(500,30))
    else
        controlTime = controlTime + dt
        if controlTime > updaterate then
            board.update(dt)
            rpc:refreshPieces(idUser, pieces)
            controlTime = controlTime - updaterate
        end

        if player1 and (piecesPlayer2 == nil or piecesPlayer2 == '') then
            wp = rpc:waitingPlayer2()
            if wp ~= false then
                opponentname = wp.name
                piecesPlayer2 = wp.pieces
            end
        end

        suit.layout:reset(10,555)
        if suit.Button("Restart", suit.layout:row(215,30)).hit then
            love.event.quit()
        end
        suit.layout:reset(235,555)
        if suit.Button("Quit", suit.layout:row(215,30)).hit then
            love.event.quit()
        end
        chat.update(dt)
        turn = rpc:verifyTurn()
        boardarray = rpc:getBoard()

        local diepiece = rpc:getkillpiece()
        for k,v in pairs(pieces) do
             if v.name == diepiece then
                 pieces[k] = nil
             end
        end

    end
end

function love.textinput(t)
  if screen == 1 then
    if string.len(input.text) < 20 then
      suit.textinput(t)
    end
  else
    chat.textinput(t)
  end
end

function love.keypressed(key)
  if screen == 1 then
    suit.keypressed(key)
    if key == "return" and input.text ~= "" then
        nameUser = input.text
        screen = screen + 1
        newClient = rpc:newClient(idUser, nameUser)
        if newClient ~= false then
            init = newClient
            pieces = init.pieces
            turn = init.turn
            colorUser = init.color
            player1 = init.player1
            player2 = init.player2
            if player2 == true and piecesPlayer1 == nil then
                piecesPlayer2 = ''
                p1 = rpc:getPlayer1()
                piecesPlayer1 = p1.pieces
                opponentname = p1.name
            end
        end
    end
  else
    chat.keypressed(key, idUser, nameUser)
  end
end

function love.wheelmoved(x,y)
  if screen ~= 1 then
    chat.wheelmoved(x,y)
  end
end

function love.mousepressed(x, y, button)
     if turn == idUser and piecesPlayer2 ~= nil then
        board.mousepressed(x, y, button)
     end
end

function love.mousereleased(x, y, button)
    if screen ~= 1 then
        if turn == idUser and piecesPlayer2 ~= nil then
            valuePiece = board.mousereleased(x, y, button)
            if valuePiece then
                print(table.tostring(valuePiece))
                rpc:changeTurn(idUser)
                refresh = rpc:refreshBoard(valuePiece)
                if refresh ~= true then
                    rpc:killpiece(refresh)
                end
            end
        end
    end
end

function love.draw()
    if screen == 1 then
        love.graphics.setColor(255,255,255,255);
        love.graphics.draw(background, 0,0)
        love.graphics.setFont(love.graphics.newFont('fonts/accid.ttf',22))
        love.graphics.setColor(44, 62, 80)
        love.graphics.setFont(love.graphics.newFont('fonts/accid.ttf',22))
        love.graphics.printf(enter, 100, 300, 800, 'center')
        suit.draw()
    else
        love.graphics.setColor(255,255,255,255);
        love.graphics.draw(background, 0,0)
        board.draw()
        chat.draw()
        if piecesPlayer2 == nil  then
            love.graphics.setColor(77, 38, 0);
            love.graphics.print('Waiting for the second player...', 510, 10)
        else
            if turn == idUser then
                love.graphics.setColor(colorUser)
                love.graphics.print("It's your turn, move one piece!", 510, 10)
            else
                love.graphics.setColor(77, 38, 0)
                love.graphics.print('Time of the player ' .. opponentname, 510, 10)
            end
        end

        love.graphics.setFont(love.graphics.newFont('fonts/accid.ttf',20))

        -- pintando as minhas peças nos valores iniciais caso só tenha um adversário
        if tablelength(pieces) > 0 then
            for key, value in pairs(pieces) do
                love.graphics.setColor(value.color)
                love.graphics.circle("fill", value.x, value.y, value.radius)
            end
        end

        -- pintando as peças do player2 caso eu seja player 1
        if piecesPlayer2 ~= nil and piecesPlayer2 ~= '' then
            for key, value in pairs(piecesPlayer2) do
                love.graphics.setColor(value.color)
                love.graphics.circle("fill", value.x, value.y, value.radius)
            end
            piecesPlayer2 = rpc:getPlayer2().pieces
        end

        -- pintando as peças do player1 caso eu seja player 2
        if piecesPlayer1 ~= nil and piecesPlayer1 ~= '' then
            for key, value in pairs(piecesPlayer1) do
                love.graphics.setColor(value.color)
                love.graphics.circle("fill", value.x, value.y, value.radius)
            end
            piecesPlayer1 = rpc:getPlayer1().pieces
        end
    end
end

function tablelength(T)
  counter = 0
  if T ~= nil then
    for index in pairs(T) do
        counter = counter + 1
    end
  end
  return counter
end
