FIM_JOGO = false
LARGURA_TELA = 320
ALTURA_TELA = 480
MAX_METEOROS = 12
METEOROS_ATINGIDOS = 0
VENCEDOR = false
OBJETIVO = 10

aviao_14bis = {
    src = "imagens/14bis.png",
    largura = 55,
    altura = 63,
    x = LARGURA_TELA / 2 - 64 / 2,
    y = ALTURA_TELA - 64 / 2,
    tiros = {}
}

meteoros = {}

function atirar()
    som_disparo:play()

    local tiro = {
        x = aviao_14bis.x + aviao_14bis.largura / 2,
        y = aviao_14bis.y,
        largura = 16,
        altura = 16
    }
    table.insert(aviao_14bis.tiros, tiro)
end

function criaMeteoro()
    local meteoro = {
        src = "imagens/meteoro.png",
        x = math.random(LARGURA_TELA),
        y = -70,
        largura = 50,
        altura = 44,
        peso = math.random(3),
        deslocamento_horizontal = math.random(-1, 1)
    }
    table.insert(meteoros, meteoro)
end

function paraMusicaDeFundo()
    musica_ambiente:stop()
end

function tocaMusicaGameOver()
    som_game_over:play()
end

function love.load()
    love.window.setMode(LARGURA_TELA, ALTURA_TELA, { resizable = false })
    love.window.setTitle("14bis vs Meteoros")

    math.randomseed(os.time())

    background = love.graphics.newImage("imagens/background.png")
    game_over = love.graphics.newImage("imagens/gameover.png")
    vencedor_img = love.graphics.newImage("imagens/vencedor.png")

    meteoro_img = love.graphics.newImage("imagens/meteoro.png")
    tiro_img = love.graphics.newImage("imagens/tiro.png")
    aviao_14bis.imagem = love.graphics.newImage(aviao_14bis.src)

    musica_ambiente = love.audio.newSource("audios/ambiente.wav", "static")
    musica_ambiente:setLooping(true)
    musica_ambiente:play()

    som_destruicao = love.audio.newSource("audios/destruicao.wav", "static")
    som_game_over = love.audio.newSource("audios/game_over.wav", "static")
    som_vencedor = love.audio.newSource("audios/winner.wav", "static")
    som_disparo = love.audio.newSource("audios/disparo.wav", "static")

    diminuiVolume()
end

function diminuiVolume()
    musica_ambiente.setVolume(musica_ambiente, 0.1)
    som_destruicao.setVolume(som_destruicao, 0.1)
    som_game_over.setVolume(som_game_over, 0.1)
    som_vencedor.setVolume(som_vencedor, 0.1)
    som_disparo.setVolume(som_disparo, 0.1)
end

function love.update(dt)
    if not FIM_JOGO and not VENCEDOR then
        if love.keyboard.isDown('w', 'a', 's', 'd', 'up', 'down', 'right', 'left', 'right') then
            move14bis()
        end

        removeMeteoros()
        if #meteoros < MAX_METEOROS then
            criaMeteoro()
        end
        moveMeteoro()
        moveDisparo()
        checaColisoesMeteoro()
        checaColisoesDisparos()
        checaObjetivoConcluido()
    end
end

function move14bis()
    if love.keyboard.isDown('w', 'up') then
        aviao_14bis.y = aviao_14bis.y - 1
    end
    if love.keyboard.isDown('s', 'down') then
        aviao_14bis.y = aviao_14bis.y + 1
    end
    if love.keyboard.isDown('a', 'left') then
        aviao_14bis.x = aviao_14bis.x - 1
    end
    if love.keyboard.isDown('d', 'right') then
        aviao_14bis.x = aviao_14bis.x + 1
    end
end

function removeMeteoros()
    for i = #meteoros, 1, -1 do
        if meteoros[i].y > ALTURA_TELA then
            table.remove(meteoros, i)
        end
    end
end

function moveMeteoro()
    for k, meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.peso + 1
        meteoro.x = meteoro.x + meteoro.deslocamento_horizontal
    end
end

function moveDisparo()
    for i = #aviao_14bis.tiros, 1, -1 do
        if aviao_14bis.tiros[i].y > 0 then
            aviao_14bis.tiros[i].y = aviao_14bis.tiros[i].y - 2
        else
            table.remove(aviao_14bis.tiros[i])
        end
    end
end

function checaColisoesMeteoro()
    for k, meteoro in pairs(meteoros) do
        local obj1 = {
            X1 = meteoro.x,
            Y1 = meteoro.y,
            L1 = meteoro.largura,
            A1 = meteoro.altura
        }
        local obj2 = {
            X2 = aviao_14bis.x,
            Y2 = aviao_14bis.y,
            L2 = aviao_14bis.largura,
            A2 = aviao_14bis.altura,
        }
        if temColisao(obj1, obj2) then
            destroiAviao()
            FIM_JOGO = true
        end
    end
end

function temColisao(obj1, obj2)
    return obj2.X2 < obj1.X1 + obj1.L1 and
        obj1.X1 < obj2.X2 + obj2.L2 and
        obj2.Y2 < obj1.Y1 + obj1.A1 and
        obj1.Y1 < obj2.Y2 + obj2.A2
end

function destroiAviao()
    paraMusicaDeFundo()
    tocaMusicaGameOver()
    som_destruicao:play()
    aviao_14bis.src = "imagens/explosao_nave.png"
    aviao_14bis.imagem = love.graphics.newImage(aviao_14bis.src)
    aviao_14bis.largura = 67
    aviao_14bis.altura = 77
end

function checaColisoesDisparos()
    for i = #aviao_14bis.tiros, 1, -1 do
        for j = #meteoros, 1, -1 do
            local obj1 = {
                X1 = meteoros[j].x,
                Y1 = meteoros[j].y,
                L1 = meteoros[j].largura,
                A1 = meteoros[j].altura
            }
            local obj2 = {
                X2 = aviao_14bis.tiros[i].x,
                Y2 = aviao_14bis.tiros[i].y,
                L2 = aviao_14bis.tiros[i].largura,
                A2 = aviao_14bis.tiros[i].altura,
            }
            if temColisao(obj1, obj2) then
                table.remove(aviao_14bis.tiros, i)
                METEOROS_ATINGIDOS = METEOROS_ATINGIDOS + 1
                table.remove(meteoros, j)
            end
        end
    end
end

function checaObjetivoConcluido()
    if METEOROS_ATINGIDOS >= OBJETIVO then
        paraMusicaDeFundo()
        VENCEDOR = true
        som_vencedor:play()
        
    end
end

function love.keypressed(tecla)
    if tecla == "escape" then
        love.event.quit()
    end

    if tecla == "space" then
        atirar()
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(aviao_14bis.imagem, aviao_14bis.x, aviao_14bis.y)

    love.graphics.print("Meteoros restantes: " .. OBJETIVO - METEOROS_ATINGIDOS, 0, 0)

    desenhaMeteoros()
    desenhaDisparos()
    isGameOver()
    isVencedor()
end

function desenhaMeteoros()
    for k, meteoro in pairs(meteoros) do
        love.graphics.draw(meteoro_img, meteoro.x, meteoro.y)
    end
end

function desenhaDisparos()
    for k, disparo in pairs(aviao_14bis.tiros) do
        love.graphics.draw(tiro_img, disparo.x, disparo.y)
    end
end

function isGameOver()
    if FIM_JOGO then
        love.graphics.draw(game_over, LARGURA_TELA/2 - game_over:getWidth()/2 , ALTURA_TELA/2 - game_over:getHeight()/2)
    end
end

function isVencedor()
    if VENCEDOR then
        love.graphics.draw(vencedor_img, LARGURA_TELA/2 - game_over:getWidth()/2 , ALTURA_TELA/2 - game_over:getHeight()/2)
    end
end