local rpc = require 'rpc'.server()

msgs = {}
clients = {}

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- init pieces player 1
p1 = {name = 'p1',x = 530, y = 260,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p2 = {name = 'p2',x = 610, y = 260,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p3 = {name = 'p3',x = 690, y = 260,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p4 = {name = 'p4',x = 770, y = 260,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p5 = {name = 'p5',x = 850, y = 260,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p6 = {name = 'p6',x = 930, y = 260,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p7 = {name = 'p7',x = 530, y = 340,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p8 = {name = 'p8',x = 610, y = 340,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p9 = {name = 'p9',x = 690, y = 340,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p10 = {name = 'p10',x = 770, y = 340,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p11 = {name = 'p11',x = 850, y = 340,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p12 = {name = 'p12',x = 930, y = 340,radius = 35,color={102, 0, 204},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
piecesPlayer1 = {p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12}
initPiecesPlayer1 = deepcopy(piecesPlayer1)

-- init pieces player 2
p13 = {name = 'p13',x = 530, y = 90,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p14 = {name = 'p14',x = 610, y = 90,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p15 = {name = 'p15',x = 690, y = 90,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p16 = {name = 'p16',x = 770, y = 90,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p17 = {name = 'p17',x = 850, y = 90,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p18 = {name = 'p18',x = 930, y = 90,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p19 = {name = 'p19',x = 530, y = 170,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p20 = {name = 'p20',x = 610, y = 170,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p21 = {name = 'p21',x = 690, y = 170,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p22 = {name = 'p22',x = 770, y = 170,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p23 = {name = 'p23',x = 850, y = 170,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
p24 = {name = 'p24',x = 930, y = 170,radius = 35,color={179, 0, 59},position = {l=0,c=0},dragging = { active = false, diffX = 0, diffY = 0 }}
piecesPlayer2 = {p13,p14,p15,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24}
initPiecesPlayer2 = deepcopy(piecesPlayer2)

board =  {{0,0,0,0,0},
          {0,0,0,0,0},
          {0,0,0,0,0},
          {0,0,0,0,0},
          {0,0,0,0,0},
          {0,0,0,0,0}}

initBoard = deepcopy(board)

turn = ''
piecedie = ''

function tablelength(T)
  counter = 0
  if T ~= nil then
    for index in pairs(T) do
        counter = counter + 1
    end
  end
  return counter
end

function rpc:newClient(id, name)
    if tablelength(clients) < 3 then
        print('New client: ' .. id .. ' ' .. name)
        table.insert(clients, {id = id, name = name})
        -- Quando o cliente se cadastra já recebe as peças do servidor
        if tablelength(clients) == 1 then
            turn = id
            return {pieces = piecesPlayer1, player1 = true, player2 = false, id = id, turn = id, color = {102, 0, 204}, name = name};
        elseif tablelength(clients) == 2 then
            return {pieces = piecesPlayer2, player1 = false, player2 = true, id = id, turn = false, color = {179, 0, 59}, name = name};
        end
    else
        return false
    end
end

function rpc:getPlayer1()
    if piecesPlayer1 ~= nil then
        return {pieces = piecesPlayer1, name = clients[1].name}
    end
    return nil
end

function rpc:getPlayer2()
    if piecesPlayer2 ~= nil then
        return {pieces = piecesPlayer2, name = clients[2].name}
    end
    return nil
end

function rpc:refreshPieces(idClient, pieces)
    if tablelength(clients) > 1 then
        if clients[1].id == idClient then
            piecesPlayer1 = pieces
        elseif clients[2].id == idClient then
            piecesPlayer2 = pieces
        end
    else
        piecesPlayer1 = initPiecesPlayer1
        piecesPlayer2 = initPiecesPlayer2
    end
end

function rpc:waitingPlayer2()
    if tablelength(clients) == 1 then
        return false
    elseif tablelength(clients) == 2 then
        return {pieces = piecesPlayer2, name = clients[2].name}
    end
end

function rpc:newMessage(idUser, nameUser, msg)
    if clients[1].id == idUser then
        local player1 = true
        local player2 = false
    elseif clients[2].id == idUser then
        local player1 = false
        local player2 = true
    end
    table.insert(msgs, {id = idUser, name = nameUser, msg = msg, player1 = player1, player2 = player2})
end

function rpc:getMessages(numberlocalmsgs)
    if numberlocalmsgs == tablelength(msgs) then
        return false
    else
        return msgs[tablelength(msgs)]
    end
end


function rpc:changeTurn(idUser)
    local idPlayer1 = clients[1].id
    local idPlayer2 = clients[2].id

    if idUser == idPlayer1 then
        turn =  idPlayer2
    else
        turn =  idPlayer1
    end
end

function rpc:refreshBoard(localboard)
    board = localboard[1]
    killpiece = localboard[2]
    if killpiece == true then
        return true
    else
        return killpiece
    end
end

function rpc:killpiece(namepiece)
    piecedie = namepiece
end

function rpc:getkillpiece()
    return piecedie
end

function rpc:verifyTurn()
    return turn
end

function rpc:getBoard()
    return board
end

function rpc:quit(idUser)
    if clients[1].id == idUser then
        piecesPlayer1 = nil
        piecesPlayer2 = initPiecesPlayer1
        clients[2].player1 = true
        clients[2].player2 = false
        turn = clients[2].id
        clients = {clients[2]}
    elseif clients[2].id == idUser then
        piecesPlayer2 = nil
        piecesPlayer1 = initPiecesPlayer1
        clients[1].player1 = true
        clients[1].player2 = false
        turn = clients[1].id
        clients = {clients[1]}
    end
end

function rpc:restartgame()
    board = initBoard
    piecesPlayer1 = initPiecesPlayer1
    piecesPlayer2 = initPiecesPlayer2
    
    return {piecesPlayer1, piecesPlayer2}
end

while 1 do rpc:update() end
