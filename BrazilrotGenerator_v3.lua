--[[
    🇧🇷 STEAL A BRAZILROT — GERADOR CORRIGIDO
    
    COMO USAR NO STUDIO LITE:
    1. Crie um LocalScript em qualquer lugar
    2. Cole TODO esse código
    3. Clique Run
    4. Aguarde o print final no Output
    5. Delete este script
    
    LAYOUT CORRETO (igual ao SAB):
    
    [BASE1] [BASE2] [BASE3] [BASE4]
    ================================  <- ESTEIRA (centro, horizontal)
    [BASE5] [BASE6] [BASE7] [BASE8]
    
    Cada base tem:
    - Plataforma plana grande
    - Cercado com paredes baixas
    - Porta de entrada virada pra esteira
    - Cofre no centro
    - Lock visual (fica vermelho quando protegida)
]]

local Players  = game:GetService("Players")
local RS       = game:GetService("ReplicatedStorage")
local SS       = game:GetService("ServerScriptService")
local SP       = game:GetService("StarterPlayer")
local WS       = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

print("🇧🇷 Gerando Steal a Brazilrot...")

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function P(props, pai)
    local p = Instance.new("Part")
    for k,v in pairs(props) do p[k] = v end
    p.Parent = pai
    return p
end

local function W(props, pai)
    local w = Instance.new("WedgePart")
    for k,v in pairs(props) do w[k] = v end
    w.Parent = pai
    return w
end

local function Folder(nome, pai)
    local f = Instance.new("Folder")
    f.Name = nome; f.Parent = pai
    return f
end

local function Script(nome, tipo, src, pai)
    local s
    if     tipo == "local"  then s = Instance.new("LocalScript")
    elseif tipo == "module" then s = Instance.new("ModuleScript")
    else                         s = Instance.new("Script") end
    s.Name = nome; s.Source = src; s.Parent = pai
    return s
end

local function RE(nome, pai)
    local r = Instance.new("RemoteEvent"); r.Name = nome; r.Parent = pai; return r
end
local function RF(nome, pai)
    local r = Instance.new("RemoteFunction"); r.Name = nome; r.Parent = pai; return r
end

local function Billboard(adornee, txt, corTxt, offsetY)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,120,0,35)
    bb.StudsOffset = Vector3.new(0, offsetY or 3, 0)
    bb.Adornee = adornee
    bb.AlwaysOnTop = false
    bb.Parent = adornee
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = corTxt or Color3.new(1,1,1)
    l.TextScaled = true
    l.Parent = bb
    return bb
end

-- ============================================================
-- LIMPAR ESTRUTURAS ANTIGAS
-- ============================================================
for _, nome in ipairs({"Brazilrot"}) do
    if RS:FindFirstChild(nome) then RS[nome]:Destroy() end
    if SS:FindFirstChild(nome) then SS[nome]:Destroy() end
end
if WS:FindFirstChild("Mapa") then WS.Mapa:Destroy() end
if WS:FindFirstChild("SpawnLocation") then WS.SpawnLocation:Destroy() end

-- ============================================================
-- REMOTE EVENTS
-- ============================================================
local pastaRS = Folder("Brazilrot", RS)
local pastaEv = Folder("Eventos",   pastaRS)
local pastaFn = Folder("Funcoes",   pastaRS)
local pastaSS = Folder("Brazilrot", SS)

for _, nome in ipairs({
    "ComprarBrazilrot","RoubarBrazilrot","ProtegerBase",
    "RealizarRebirth","AtualizarHUD","NotificarJogador",
    "AtualizarIndex","AntiCheatAlerta"
}) do RE(nome, pastaEv) end

RF("GetDadosJogador",    pastaFn)
RF("GetListaBrazilrots", pastaFn)

-- ============================================================
-- MODULE: CONFIG
-- ============================================================
Script("Config","module",[[
local C = {}
C.TICK_RENDA          = 1
C.PROTECAO_BASE       = 60
C.ESTEIRA_INTERVALO   = 10
C.LOJA_DISPONIVEL     = false
C.MAX_BRAZILROTS      = 50
C.REBIRTH_BONUS       = 0.15
C.ANTICHEAT_MAX_GAIN  = 9999999
C.ANTICHEAT_TP_DIST   = 350
C.COR_RARIDADE = {
    Comum          = Color3.fromRGB(180,180,180),
    Incomum        = Color3.fromRGB(80,200,80),
    Raro           = Color3.fromRGB(80,120,255),
    ["Épico"]      = Color3.fromRGB(180,60,255),
    ["Lendário"]   = Color3.fromRGB(255,180,0),
    ["Mítico"]     = Color3.fromRGB(255,60,60),
    Secreto        = Color3.fromRGB(255,20,150),
    ["Brainrot God"] = Color3.fromRGB(255,215,0),
}
C.REBIRTH_REQ = {
    [1]={cash=1e6,   brs=5},
    [2]={cash=10e6,  brs=10},
    [3]={cash=100e6, brs=15},
    [4]={cash=1e9,   brs=20},
    [5]={cash=10e9,  brs=25},
}
return C
]], pastaRS)

-- ============================================================
-- MODULE: BRAZILROTS DATA
-- ============================================================
Script("BrazilrotsData","module",[[
local B={}
B.lista={
    {id=1,  nome="Jacarézinho Pixinho",    emoji="🐊",   rar="Comum",        renda=150,     preco=500,       cor=Color3.fromRGB(0,180,60),     chance=0.20,  ev=false},
    {id=2,  nome="Frangasso Assadão",      emoji="🍗",   rar="Comum",        renda=300,     preco=1200,      cor=Color3.fromRGB(220,140,20),    chance=0.18,  ev=false},
    {id=3,  nome="Capivarão Tranquilão",   emoji="🦦",   rar="Comum",        renda=500,     preco=2000,      cor=Color3.fromRGB(140,100,60),    chance=0.16,  ev=false},
    {id=4,  nome="Ônibusão Atrasadão",     emoji="🚌",   rar="Incomum",      renda=900,     preco=5000,      cor=Color3.fromRGB(255,200,0),     chance=0.12,  ev=false},
    {id=5,  nome="Nenenzão Ronaldinho",    emoji="⚽",   rar="Incomum",      renda=1500,    preco=9000,      cor=Color3.fromRGB(0,80,200),      chance=0.10,  ev=false},
    {id=6,  nome="Vaqueirão Forrozeiro",   emoji="🤠",   rar="Incomum",      renda=2200,    preco=15000,     cor=Color3.fromRGB(180,100,0),     chance=0.09,  ev=false},
    {id=7,  nome="Baladeiro Funkadão",     emoji="🎵",   rar="Raro",         renda=4000,    preco=35000,     cor=Color3.fromRGB(200,0,200),     chance=0.06,  ev=false},
    {id=8,  nome="Papagainho Xingadão",    emoji="🦜",   rar="Raro",         renda=6500,    preco=60000,     cor=Color3.fromRGB(255,80,0),      chance=0.05,  ev=false},
    {id=9,  nome="Pizzaiolo Napolitânio",  emoji="🍕",   rar="Raro",         renda=9000,    preco=90000,     cor=Color3.fromRGB(220,50,50),     chance=0.04,  ev=false},
    {id=10, nome="Cangaceiro Sertanejo",   emoji="🌵",   rar="Épico",        renda=18000,   preco=250000,    cor=Color3.fromRGB(180,120,0),     chance=0.025, ev=false},
    {id=11, nome="Jacarézão do Pantanal",  emoji="🐊🔥", rar="Épico",        renda=30000,   preco=500000,    cor=Color3.fromRGB(0,120,40),      chance=0.020, ev=false},
    {id=12, nome="Camarão Gaúcho",         emoji="🦐",   rar="Épico",        renda=45000,   preco=800000,    cor=Color3.fromRGB(255,100,120),   chance=0.015, ev=false},
    {id=13, nome="Mãe de Santo Poderosa",  emoji="🕯️",  rar="Lendário",     renda=90000,   preco=2500000,   cor=Color3.fromRGB(100,0,150),     chance=0.008, ev=false},
    {id=14, nome="Tucano Diplomata",       emoji="🦅",   rar="Lendário",     renda=150000,  preco=5000000,   cor=Color3.fromRGB(0,100,200),     chance=0.005, ev=false},
    {id=15, nome="Foguerão Junino",        emoji="🎆",   rar="Mítico",       renda=400000,  preco=20000000,  cor=Color3.fromRGB(255,50,0),      chance=0.002, ev=false},
    {id=16, nome="Nordestino Chovião",     emoji="🌧️",  rar="Mítico",       renda=600000,  preco=40000000,  cor=Color3.fromRGB(50,100,200),    chance=0.001, ev=true},
    {id=17, nome="Boto Cor-de-Rosa",       emoji="🐬",   rar="Secreto",      renda=1000000, preco=150000000, cor=Color3.fromRGB(255,150,200),   chance=5e-4,  ev=false},
    {id=18, nome="Chico Xavier Vidente",   emoji="👁️",  rar="Secreto",      renda=1500000, preco=300000000, cor=Color3.fromRGB(200,220,255),   chance=3e-4,  ev=false},
    {id=19, nome="Pelézão Eterno",         emoji="👑",   rar="Brainrot God", renda=5000000, preco=1000000000,cor=Color3.fromRGB(255,215,0),     chance=1e-4,  ev=false},
    {id=20, nome="Lulinha do Trabalhador", emoji="🔨",   rar="Brainrot God", renda=8000000, preco=2e9,       cor=Color3.fromRGB(220,50,50),     chance=5e-5,  ev=false},
}
B.porId={}
for _,v in ipairs(B.lista) do B.porId[v.id]=v end
function B:Rand(ev)
    local pool={}
    for _,b in ipairs(self.lista) do
        if not b.ev or ev then table.insert(pool,b) end
    end
    local tot=0 for _,b in ipairs(pool) do tot=tot+b.chance end
    local r=math.random()*tot local ac=0
    for _,b in ipairs(pool) do
        ac=ac+b.chance if r<=ac then return b end
    end
    return pool[#pool]
end
return B
]], pastaRS)

-- ============================================================
-- SERVER SCRIPT: GAME MAIN
-- ============================================================
Script("GameMain","script",[[
local Players = game:GetService("Players")
local DS      = game:GetService("DataStoreService")
local RS      = game:GetService("ReplicatedStorage")
local p2      = RS:WaitForChild("Brazilrot")
local Ev      = p2:WaitForChild("Eventos")
local Fn      = p2:WaitForChild("Funcoes")
local Cfg     = require(p2:WaitForChild("Config"))
local BRD     = require(p2:WaitForChild("BrazilrotsData"))
local store   = DS:GetDataStore("Brazilrot_v2")
local estado  = {}

local function fmt(n)
    if n>=1e12 then return ("%.1fT"):format(n/1e12)
    elseif n>=1e9 then return ("%.1fB"):format(n/1e9)
    elseif n>=1e6 then return ("%.1fM"):format(n/1e6)
    elseif n>=1e3 then return ("%.1fK"):format(n/1e3)
    else return tostring(math.floor(n)) end
end

local function novo()
    return {cash=100,rebirths=0,brs={},index={},protAt=0,ganho=0,roubos=0}
end

local function renda(d)
    local base=0
    local mult=1+((d.rebirths or 0)*Cfg.REBIRTH_BONUS)
    for _,b in ipairs(d.brs) do
        local info=BRD.porId[b.id]
        if info then base=base+info.renda end
    end
    return math.floor(base*mult)
end

local function save(pl)
    local d=estado[pl.UserId] if not d then return end
    pcall(function() store:SetAsync("u_"..pl.UserId, d) end)
end

Players.PlayerAdded:Connect(function(pl)
    local d local ok,r=pcall(function() d=store:GetAsync("u_"..pl.UserId) end)
    estado[pl.UserId]=(ok and d) and d or novo()
    task.spawn(function() while pl.Parent do task.wait(60) save(pl) end end)
    task.wait(1.5)
    Ev.AtualizarHUD:FireClient(pl, estado[pl.UserId])
end)

Players.PlayerRemoving:Connect(function(pl) save(pl) estado[pl.UserId]=nil end)
game:BindToClose(function()
    for uid in pairs(estado) do
        local pl=Players:GetPlayerByUserId(uid) if pl then save(pl) end
    end
end)

-- Renda passiva
task.spawn(function()
    while true do
        task.wait(Cfg.TICK_RENDA)
        for _,pl in ipairs(Players:GetPlayers()) do
            local d=estado[pl.UserId]
            if d then
                local r=renda(d)
                if r>Cfg.ANTICHEAT_MAX_GAIN then
                    Ev.AntiCheatAlerta:FireServer(pl,"RENDA_HACK") r=0
                end
                d.cash=d.cash+r d.ganho=d.ganho+r
                Ev.AtualizarHUD:FireClient(pl,d)
            end
        end
    end
end)

-- Comprar
Ev.ComprarBrazilrot.OnServerEvent:Connect(function(pl, id)
    local d=estado[pl.UserId] if not d then return end
    if not Cfg.LOJA_DISPONIVEL then
        Ev.NotificarJogador:FireClient(pl,"❌ Loja indisponível!","erro") return
    end
    local br=BRD.porId[id] if not br then return end
    if #d.brs>=Cfg.MAX_BRAZILROTS then
        Ev.NotificarJogador:FireClient(pl,"❌ Base cheia!","erro") return
    end
    if d.cash<br.preco then
        Ev.NotificarJogador:FireClient(pl,"❌ Sem grana!","erro") return
    end
    d.cash=d.cash-br.preco
    local key=("%d_%d"):format(math.floor(tick()),math.random(1,99999))
    table.insert(d.brs,{id=br.id,nome=br.nome,key=key})
    if not d.index[br.id] then
        d.index[br.id]=true
        Ev.AtualizarIndex:FireClient(pl,d.index)
    end
    Ev.AtualizarHUD:FireClient(pl,d)
    Ev.NotificarJogador:FireClient(pl,"✅ "..br.emoji.." "..br.nome.."!","sucesso")
end)

-- Roubar
Ev.RoubarBrazilrot.OnServerEvent:Connect(function(ladrao, vitima, key)
    if ladrao==vitima then return end
    local dL=estado[ladrao.UserId] local dV=estado[vitima.UserId]
    if not dL or not dV then return end
    if tick()<(dV.protAt or 0) then
        Ev.NotificarJogador:FireClient(ladrao,"🔒 Base protegida!","erro") return
    end
    local idx=nil
    for i,b in ipairs(dV.brs) do if b.key==key then idx=i break end end
    if not idx then return end
    if #dL.brs>=Cfg.MAX_BRAZILROTS then
        Ev.NotificarJogador:FireClient(ladrao,"❌ Sua base tá cheia!","erro") return
    end
    local br=table.remove(dV.brs,idx)
    table.insert(dL.brs,br)
    dL.roubos=(dL.roubos or 0)+1
    if not dL.index[br.id] then
        dL.index[br.id]=true Ev.AtualizarIndex:FireClient(ladrao,dL.index)
    end
    Ev.AtualizarHUD:FireClient(ladrao,dL) Ev.AtualizarHUD:FireClient(vitima,dV)
    local info=BRD.porId[br.id] local em=info and info.emoji or "🧠"
    Ev.NotificarJogador:FireClient(ladrao,"🥷 Roubou "..em.." "..br.nome.."!","roubo")
    Ev.NotificarJogador:FireClient(vitima,"😡 Roubaram seu "..em.." "..br.nome.."!","alerta")
end)

-- Proteger base
Ev.ProtegerBase.OnServerEvent:Connect(function(pl)
    local d=estado[pl.UserId] if not d then return end
    local now=tick()
    if now<(d.protAt or 0) then
        Ev.NotificarJogador:FireClient(pl,"⏳ Já protegida por "..math.ceil(d.protAt-now).."s","info") return
    end
    d.protAt=now+Cfg.PROTECAO_BASE
    Ev.AtualizarHUD:FireClient(pl,d)
    Ev.NotificarJogador:FireClient(pl,"🔒 Base protegida por "..Cfg.PROTECAO_BASE.."s!","sucesso")
end)

-- Rebirth
Ev.RealizarRebirth.OnServerEvent:Connect(function(pl)
    local d=estado[pl.UserId] if not d then return end
    local prox=(d.rebirths or 0)+1
    local req=Cfg.REBIRTH_REQ[prox]
    if not req then Ev.NotificarJogador:FireClient(pl,"🏆 Rebirth máximo!","info") return end
    if d.cash<req.cash then Ev.NotificarJogador:FireClient(pl,"❌ Precisa de mais grana!","erro") return end
    if #d.brs<req.brs then Ev.NotificarJogador:FireClient(pl,"❌ Precisa de mais Brazilrots!","erro") return end
    d.rebirths=prox d.cash=100 d.brs={}
    Ev.AtualizarHUD:FireClient(pl,d)
    Ev.NotificarJogador:FireClient(pl,"🔄 REBIRTH "..prox.."! Bônus: +"..math.floor(prox*Cfg.REBIRTH_BONUS*100).."%","rebirth")
    local char=pl.Character
    if char then
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local e=Instance.new("Explosion")
            e.BlastRadius=0 e.BlastPressure=0
            e.ExplosionType=Enum.ExplosionType.NoCraters
            e.Position=hrp.Position e.Parent=workspace
        end
    end
end)

Fn.GetDadosJogador.OnServerInvoke=function(pl) return estado[pl.UserId] or novo() end
Fn.GetListaBrazilrots.OnServerInvoke=function() return BRD.lista end
print("✅ GameMain carregado!")
]], pastaSS)

-- ============================================================
-- SERVER SCRIPT: ANTI-CHEAT
-- ============================================================
Script("AntiCheat","script",[[
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local Cfg     = require(RS:WaitForChild("Brazilrot"):WaitForChild("Config"))
local alerta  = RS.Brazilrot.Eventos.AntiCheatAlerta

local posAnterior={} local flags={} local MAX=5

local function flag(pl, motivo)
    flags[pl.UserId]=(flags[pl.UserId] or 0)+1
    warn("[ANTICHEAT] "..pl.Name.." | "..motivo.." | #"..flags[pl.UserId])
    if flags[pl.UserId]>=MAX then
        pl:Kick("Banido: "..motivo)
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        for _,pl in ipairs(Players:GetPlayers()) do
            local c=pl.Character if not c then continue end
            local hrp=c:FindFirstChild("HumanoidRootPart")
            local hum=c:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local pos=hrp.Position
                local ant=posAnterior[pl.UserId]
                if ant then
                    if (pos-ant).Magnitude > Cfg.ANTICHEAT_TP_DIST then
                        flag(pl,"TELEPORTE="..math.floor((pos-ant).Magnitude))
                    end
                    if pos.Y>200 then flag(pl,"FLY Y="..math.floor(pos.Y)) end
                end
                posAnterior[pl.UserId]=pos
                if hum.WalkSpeed>30 then hum.WalkSpeed=16 flag(pl,"SPEED="..hum.WalkSpeed) end
                if hum.JumpPower>65 then hum.JumpPower=50 flag(pl,"JUMP="..hum.JumpPower) end
            end
        end
    end
end)

alerta.OnServerEvent:Connect(function(pl,m) flag(pl,m) end)
Players.PlayerRemoving:Connect(function(pl) posAnterior[pl.UserId]=nil flags[pl.UserId]=nil end)
print("🛡️ AntiCheat ativo!")
]], pastaSS)

-- ============================================================
-- SERVER SCRIPT: ESTEIRA MANAGER
-- ============================================================
Script("EsteiraManager","script",[[
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local p2      = RS:WaitForChild("Brazilrot")
local Cfg     = require(p2:WaitForChild("Config"))
local BRD     = require(p2:WaitForChild("BrazilrotsData"))
local Ev      = p2:WaitForChild("Eventos")
local mapa    = workspace:WaitForChild("Mapa")
local esteira = mapa:WaitForChild("Esteira")

local eventoAtivo=false

local function spawn()
    local br=BRD:Rand(eventoAtivo)

    local item=Instance.new("Part")
    item.Name="BRItem_"..br.id
    item.Size=Vector3.new(4,4,4)
    item.Color=br.cor
    item.Material=Enum.Material.Neon
    item.Anchored=true
    item.CanCollide=false
    item.CastShadow=false
    -- começa numa extremidade da esteira
    item.Position = esteira.Position + Vector3.new(-esteira.Size.X/2 - 2, 3, 0) + Vector3.new(0,0,-esteira.Size.Z/2+2)
    item.Parent=workspace

    -- Etiqueta
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,200,0,75)
    bb.StudsOffset=Vector3.new(0,5,0)
    bb.AlwaysOnTop=true
    bb.Parent=item

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundColor3=Color3.fromRGB(15,15,15)
    lbl.BackgroundTransparency=0.15
    lbl.Font=Enum.Font.GothamBold
    lbl.TextScaled=true
    lbl.Parent=bb

    local Cfg2=require(RS.Brazilrot.Config)
    lbl.TextColor3=Cfg2.COR_RARIDADE[br.rar] or Color3.new(1,1,1)
    lbl.Text=br.emoji.."  "..br.nome.."\n["..br.rar.."]  💰"..br.preco

    Instance.new("UICorner",lbl).CornerRadius=UDim.new(0,6)

    -- Mover pela esteira (eixo Z)
    task.spawn(function()
        local vel=18 -- studs/s
        local dur=esteira.Size.Z/vel
        local t=0
        while t<dur do
            task.wait(0.05)
            t=t+0.05
            if item.Parent then
                item.Position=item.Position+Vector3.new(0,0,vel*0.05)
            else return end
        end
        if item.Parent then item:Destroy() end
    end)

    -- Toque do jogador = compra
    local debounce={}
    item.Touched:Connect(function(hit)
        local char=hit.Parent
        local pl=Players:GetPlayerByCharacter(char)
        if pl and not debounce[pl.UserId] then
            debounce[pl.UserId]=true
            Ev.ComprarBrazilrot:FireClient(pl, br.id)
            item:Destroy()
        end
    end)
end

-- Loop da esteira
task.spawn(function()
    while true do
        task.wait(Cfg.ESTEIRA_INTERVALO)
        pcall(spawn)
    end
end)

-- Evento de chuva (a cada 8min, dura 90s)
task.spawn(function()
    while true do
        task.wait(480)
        eventoAtivo=true
        for _,pl in ipairs(Players:GetPlayers()) do
            Ev.NotificarJogador:FireClient(pl,"🌧️ EVENTO! Nordestino Chovião surgiu!","evento")
        end
        task.wait(90)
        eventoAtivo=false
        for _,pl in ipairs(Players:GetPlayers()) do
            Ev.NotificarJogador:FireClient(pl,"☀️ Evento encerrado!","info")
        end
    end
end)

print("🚂 EsteiraManager ativo!")
]], pastaSS)

-- ============================================================
-- LOCAL SCRIPT: HUD CONTROLLER
-- ============================================================
local SPS = SP:WaitForChild("StarterPlayerScripts")

Script("HUDController","local",[[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local pl=Players.LocalPlayer
local p2=RS:WaitForChild("Brazilrot")
local Ev=p2:WaitForChild("Eventos")

-- ScreenGui principal
local G=Instance.new("ScreenGui")
G.Name="HUD" G.ResetOnSpawn=false G.IgnoreGuiInset=true G.Parent=pl.PlayerGui

-- Painel info (canto inferior esquerdo)
local pan=Instance.new("Frame")
pan.Size=UDim2.new(0,280,0,210) pan.Position=UDim2.new(0,10,1,-220)
pan.BackgroundColor3=Color3.fromRGB(10,10,10) pan.BackgroundTransparency=0.15
pan.BorderSizePixel=0 pan.Parent=G
local c=Instance.new("UICorner",pan) c.CornerRadius=UDim.new(0,14)
local st=Instance.new("UIStroke",pan) st.Color=Color3.fromRGB(0,200,70) st.Thickness=2

-- Banner verde topo
local bar=Instance.new("Frame")
bar.Size=UDim2.new(1,0,0,38) bar.BackgroundColor3=Color3.fromRGB(0,130,35)
bar.BorderSizePixel=0 bar.Parent=pan
Instance.new("UICorner",bar).CornerRadius=UDim.new(0,14)
local barT=Instance.new("TextLabel")
barT.Size=UDim2.new(1,0,1,0) barT.BackgroundTransparency=1
barT.Text="🇧🇷  STEAL A BRAZILROT" barT.Font=Enum.Font.GothamBold
barT.TextColor3=Color3.fromRGB(255,220,0) barT.TextScaled=true barT.Parent=bar

local function row(y,txt,cor)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-12,0,26) l.Position=UDim2.new(0,6,0,y)
    l.BackgroundTransparency=1 l.TextXAlignment=Enum.TextXAlignment.Left
    l.Font=Enum.Font.GothamBold l.TextScaled=true
    l.TextColor3=cor or Color3.new(1,1,1) l.Text=txt l.Parent=pan
    return l
end

local lDin  = row(43,  "💰 R$ 100",          Color3.fromRGB(255,220,0))
local lRend = row(73,  "📈 R$ 0/s",           Color3.fromRGB(80,255,80))
local lBR   = row(103, "🧠 Brazilrots: 0",    Color3.new(1,1,1))
local lReb  = row(133, "🔄 Rebirth: 0",       Color3.fromRGB(180,120,255))

local function makebtn(txt,cor,ax,ay,aw)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(aw,0,0,31) b.Position=UDim2.new(ax,0,0,ay)
    b.BackgroundColor3=cor b.Text=txt b.Font=Enum.Font.GothamBold
    b.TextColor3=Color3.new(1,1,1) b.TextScaled=true b.BorderSizePixel=0 b.Parent=pan
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    return b
end

local bProt=makebtn("🔒 TRANCAR", Color3.fromRGB(180,0,0),   0.04,170,0.44)
local bReb =makebtn("🔄 REBIRTH", Color3.fromRGB(110,0,190), 0.52,170,0.44)

-- Notif (topo centro)
local nG=Instance.new("ScreenGui")
nG.Name="Notif" nG.ResetOnSpawn=false nG.IgnoreGuiInset=true nG.Parent=pl.PlayerGui
local nFr=Instance.new("Frame")
nFr.Size=UDim2.new(0,370,0,52) nFr.Position=UDim2.new(0.5,-185,0,10)
nFr.BackgroundTransparency=1 nFr.Visible=false nFr.Parent=nG
local nLbl=Instance.new("TextLabel")
nLbl.Size=UDim2.new(1,0,1,0) nLbl.BackgroundTransparency=0.1
nLbl.Font=Enum.Font.GothamBold nLbl.TextColor3=Color3.new(1,1,1)
nLbl.TextScaled=true nLbl.Parent=nFr
Instance.new("UICorner",nLbl).CornerRadius=UDim.new(0,10)

local CORES={
    sucesso=Color3.fromRGB(0,155,65), erro=Color3.fromRGB(175,0,0),
    roubo=Color3.fromRGB(210,110,0),  alerta=Color3.fromRGB(195,30,30),
    info=Color3.fromRGB(55,95,210),   rebirth=Color3.fromRGB(130,0,210),
    evento=Color3.fromRGB(0,150,210),
}

local function notif(txt,tipo)
    nLbl.Text=txt nLbl.BackgroundColor3=CORES[tipo] or Color3.fromRGB(40,40,40)
    nFr.Visible=true task.delay(3.5,function() nFr.Visible=false end)
end

local function fmt(n)
    if n>=1e12 then return ("%.1fT"):format(n/1e12)
    elseif n>=1e9 then return ("%.1fB"):format(n/1e9)
    elseif n>=1e6 then return ("%.1fM"):format(n/1e6)
    elseif n>=1e3 then return ("%.1fK"):format(n/1e3)
    else return tostring(math.floor(n)) end
end

Ev:WaitForChild("AtualizarHUD").OnClientEvent:Connect(function(d)
    lDin.Text="💰 R$ "..fmt(d.cash)
    lBR.Text ="🧠 Brazilrots: "..#d.brs
    lReb.Text="🔄 Rebirth: "..(d.rebirths or 0)
    local BRD=require(RS.Brazilrot.BrazilrotsData)
    local Cfg=require(RS.Brazilrot.Config)
    local r=0 local m=1+((d.rebirths or 0)*Cfg.REBIRTH_BONUS)
    for _,br in ipairs(d.brs) do
        local info=BRD.porId[br.id] if info then r=r+info.renda end
    end
    lRend.Text="📈 R$ "..fmt(math.floor(r*m)).."/s"
    local prot=tick()<(d.protAt or 0)
    bProt.BackgroundColor3=prot and Color3.fromRGB(0,140,0) or Color3.fromRGB(180,0,0)
    bProt.Text=prot and "🔒 PROTEGIDA" or "🔒 TRANCAR"
end)

Ev:WaitForChild("NotificarJogador").OnClientEvent:Connect(notif)
bProt.MouseButton1Click:Connect(function() Ev.ProtegerBase:FireServer() end)

local pendente=false
bReb.MouseButton1Click:Connect(function()
    if pendente then
        pendente=false bReb.Text="🔄 REBIRTH"
        Ev.RealizarRebirth:FireServer()
    else
        pendente=true bReb.Text="⚠️ CONFIRMAR?"
        task.delay(4,function() if pendente then pendente=false bReb.Text="🔄 REBIRTH" end end)
    end
end)
print("🎮 HUD pronto!")
]], SPS)

-- ============================================================
-- LOCAL SCRIPT: LOJA (INDISPONÍVEL)
-- ============================================================
Script("LojaController","local",[[
local pl=game:GetService("Players").LocalPlayer
local G=Instance.new("ScreenGui")
G.Name="Loja" G.ResetOnSpawn=false G.Parent=pl.PlayerGui

local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,100,0,36) btn.Position=UDim2.new(1,-108,0,8)
btn.BackgroundColor3=Color3.fromRGB(18,18,36) btn.TextColor3=Color3.fromRGB(200,200,200)
btn.Text="🛒 LOJA" btn.Font=Enum.Font.GothamBold btn.TextScaled=true btn.BorderSizePixel=0 btn.Parent=G
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

local pan=Instance.new("Frame")
pan.Size=UDim2.new(0,390,0,460) pan.Position=UDim2.new(0.5,-195,0.5,-230)
pan.BackgroundColor3=Color3.fromRGB(12,12,28) pan.Visible=false pan.ZIndex=10 pan.Parent=G
Instance.new("UICorner",pan).CornerRadius=UDim.new(0,16)
Instance.new("UIStroke",pan).Color=Color3.fromRGB(80,80,200)

local tit=Instance.new("TextLabel")
tit.Size=UDim2.new(1,0,0,50) tit.BackgroundColor3=Color3.fromRGB(25,25,70)
tit.BorderSizePixel=0 tit.Text="🛒  LOJA DE BRAZILROTS"
tit.Font=Enum.Font.GothamBold tit.TextColor3=Color3.fromRGB(255,220,0)
tit.TextScaled=true tit.ZIndex=11 tit.Parent=pan
Instance.new("UICorner",tit).CornerRadius=UDim.new(0,16)

local av=Instance.new("Frame")
av.Size=UDim2.new(0.88,0,0.6,0) av.Position=UDim2.new(0.06,0,0.2,0)
av.BackgroundColor3=Color3.fromRGB(50,0,0) av.BorderSizePixel=0 av.ZIndex=11 av.Parent=pan
Instance.new("UICorner",av).CornerRadius=UDim.new(0,12)

local avL=Instance.new("TextLabel")
avL.Size=UDim2.new(1,0,1,0) avL.BackgroundTransparency=1 avL.ZIndex=12 avL.Parent=av
avL.Text="🚧  LOJA INDISPONÍVEL\n\nEm breve você vai poder\ncomprar Brazilrots aqui!\n\n🇧🇷 Fique ligado!"
avL.Font=Enum.Font.GothamBold avL.TextColor3=Color3.fromRGB(255,80,80) avL.TextScaled=true

local fc=Instance.new("TextButton")
fc.Size=UDim2.new(0,38,0,38) fc.Position=UDim2.new(1,-43,0,6)
fc.BackgroundColor3=Color3.fromRGB(155,0,0) fc.Text="✕" fc.Font=Enum.Font.GothamBold
fc.TextColor3=Color3.new(1,1,1) fc.TextScaled=true fc.BorderSizePixel=0 fc.ZIndex=12 fc.Parent=pan
Instance.new("UICorner",fc).CornerRadius=UDim.new(0,8)

btn.MouseButton1Click:Connect(function() pan.Visible=not pan.Visible end)
fc.MouseButton1Click:Connect(function() pan.Visible=false end)
]], SPS)

-- ============================================================
-- LOCAL SCRIPT: INDEX
-- ============================================================
Script("IndexController","local",[[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local pl=Players.LocalPlayer
local p2=RS:WaitForChild("Brazilrot")
local Ev=p2:WaitForChild("Eventos")
local BRD=require(p2:WaitForChild("BrazilrotsData"))
local Cfg=require(p2:WaitForChild("Config"))

local G=Instance.new("ScreenGui")
G.Name="Index" G.ResetOnSpawn=false G.Parent=pl.PlayerGui

local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,100,0,36) btn.Position=UDim2.new(1,-108,0,50)
btn.BackgroundColor3=Color3.fromRGB(10,50,10) btn.TextColor3=Color3.fromRGB(80,255,80)
btn.Text="📖 INDEX" btn.Font=Enum.Font.GothamBold btn.TextScaled=true btn.BorderSizePixel=0 btn.Parent=G
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

local pan=Instance.new("Frame")
pan.Size=UDim2.new(0,420,0,510) pan.Position=UDim2.new(0.5,-210,0.5,-255)
pan.BackgroundColor3=Color3.fromRGB(10,10,10) pan.Visible=false pan.ZIndex=10 pan.Parent=G
Instance.new("UICorner",pan).CornerRadius=UDim.new(0,16)
Instance.new("UIStroke",pan).Color=Color3.fromRGB(0,200,80)

local tit=Instance.new("TextLabel")
tit.Size=UDim2.new(1,0,0,48) tit.BackgroundColor3=Color3.fromRGB(0,90,25)
tit.BorderSizePixel=0 tit.Text="📖  ÍNDICE (0/20)"
tit.Font=Enum.Font.GothamBold tit.TextColor3=Color3.fromRGB(255,220,0)
tit.TextScaled=true tit.ZIndex=11 tit.Parent=pan
Instance.new("UICorner",tit).CornerRadius=UDim.new(0,16)

local scrl=Instance.new("ScrollingFrame")
scrl.Size=UDim2.new(1,-10,1,-58) scrl.Position=UDim2.new(0,5,0,53)
scrl.BackgroundTransparency=1 scrl.BorderSizePixel=0
scrl.ScrollBarThickness=6 scrl.CanvasSize=UDim2.new(0,0,0,0)
scrl.ZIndex=11 scrl.Parent=pan
local layout=Instance.new("UIListLayout",scrl)
layout.Padding=UDim.new(0,4) layout.SortOrder=Enum.SortOrder.LayoutOrder

local unicos={}

local function popular()
    for _,c in ipairs(scrl:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local col=0 for _ in pairs(unicos) do col=col+1 end
    tit.Text="📖  ÍNDICE ("..col.."/"..#BRD.lista..")"
    for _,br in ipairs(BRD.lista) do
        local got=unicos[br.id]==true
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-10,0,42) row.LayoutOrder=br.id
        row.BackgroundColor3=got and Color3.fromRGB(18,42,18) or Color3.fromRGB(26,26,26)
        row.BorderSizePixel=0 row.ZIndex=12 row.Parent=scrl
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,-10,1,0) l.Position=UDim2.new(0,6,0,0)
        l.BackgroundTransparency=1 l.Font=Enum.Font.Gotham
        l.TextScaled=true l.TextXAlignment=Enum.TextXAlignment.Left
        l.ZIndex=13 l.Parent=row
        if got then
            l.TextColor3=Cfg.COR_RARIDADE[br.rar] or Color3.new(1,1,1)
            l.Text=br.emoji.."  "..br.nome.."  ["..br.rar.."]"
        else
            l.TextColor3=Color3.fromRGB(65,65,65)
            l.Text="❓  ???  ["..br.rar.."]"
        end
    end
    scrl.CanvasSize=UDim2.new(0,0,0,#BRD.lista*46)
end

Ev:WaitForChild("AtualizarIndex").OnClientEvent:Connect(function(u)
    unicos=u if pan.Visible then popular() end
end)

local fc=Instance.new("TextButton")
fc.Size=UDim2.new(0,38,0,38) fc.Position=UDim2.new(1,-43,0,5)
fc.BackgroundColor3=Color3.fromRGB(155,0,0) fc.Text="✕" fc.Font=Enum.Font.GothamBold
fc.TextColor3=Color3.new(1,1,1) fc.TextScaled=true fc.BorderSizePixel=0 fc.ZIndex=12 fc.Parent=pan
Instance.new("UICorner",fc).CornerRadius=UDim.new(0,8)

btn.MouseButton1Click:Connect(function()
    pan.Visible=not pan.Visible if pan.Visible then popular() end
end)
fc.MouseButton1Click:Connect(function() pan.Visible=false end)
]], SPS)

print("  ✅ LocalScripts criados")

-- ============================================================
-- MAPA — LAYOUT CORRETO IGUAL AO SAB
--
-- Vista de cima:
--
--  [B1][B2][B3][B4]   <- 4 bases no lado NORTE
--  ================   <- ESTEIRA (centro, eixo Z)
--  [B5][B6][B7][B8]   <- 4 bases no lado SUL
--
-- Esteira: comprimento no eixo Z, larga no eixo X
-- Cada base: plataforma quadrada com paredes e porta virada pra esteira
-- ============================================================
local mapa = Folder("Mapa", WS)

-- CHÃO GERAL (enorme, verde)
P({
    Name="Chao", Size=Vector3.new(500,1,500),
    Position=Vector3.new(0,-0.5,0), Anchored=true,
    BrickColor=BrickColor.new("Bright green"),
    Material=Enum.Material.Grass, CanCollide=true, CastShadow=false
}, mapa)

-- ESTEIRA (centro do mapa, corre no eixo Z)
-- Comprimento 180 (Z), largura 10 (X), altura fina
local ESTEIRA_Y  = 0.5  -- altura da esteira
local ESTEIRA_LZ = 180  -- comprimento eixo Z
local ESTEIRA_LX = 10   -- largura eixo X

local esteiraP = P({
    Name="Esteira", Size=Vector3.new(ESTEIRA_LX, 0.6, ESTEIRA_LZ),
    Position=Vector3.new(0, ESTEIRA_Y, 0), Anchored=true,
    BrickColor=BrickColor.new("Dark grey"),
    Material=Enum.Material.SmoothPlastic
}, mapa)

-- Listras amarelas na esteira (movimento visual)
for i = -8, 8 do
    P({
        Name="Listra", Size=Vector3.new(ESTEIRA_LX, 0.05, 1.5),
        Position=Vector3.new(0, ESTEIRA_Y+0.31, i*10),
        Anchored=true, CanCollide=false, CastShadow=false,
        BrickColor=BrickColor.new("Bright yellow"),
        Material=Enum.Material.SmoothPlastic
    }, mapa)
end

-- Bordas laterais da esteira (trilhos)
for _, sx in ipairs({-(ESTEIRA_LX/2+0.6), (ESTEIRA_LX/2+0.6)}) do
    P({
        Name="Trilho", Size=Vector3.new(1.2, 1.5, ESTEIRA_LZ),
        Position=Vector3.new(sx, ESTEIRA_Y+0.5, 0),
        Anchored=true, CanCollide=true,
        BrickColor=BrickColor.new("Dark stone grey"),
        Material=Enum.Material.Metal
    }, mapa)
end

-- ======================
-- BASES
-- ======================
-- 4 bases ao norte (Z negativo) e 4 ao sul (Z positivo)
-- Espaçamento lateral: 40 studs entre bases
-- Distância da esteira: 30 studs do centro

local BASE_SZ    = 30   -- tamanho da base (quadrado)
local BASE_WALL  = 3    -- altura das paredes
local DIST_EST   = BASE_SZ/2 + ESTEIRA_LX/2 + 4  -- distância centro base → esteira
local ESPAC      = 42   -- espaçamento entre bases no eixo X

-- Posições X das 4 bases: centralizado
-- Centros em X: -63, -21, +21, +63
local xs = {-3*ESPAC/2, -ESPAC/2, ESPAC/2, 3*ESPAC/2}

local coresBases = {
    BrickColor.new("Bright blue"),
    BrickColor.new("Bright red"),
    BrickColor.new("Bright yellow"),
    BrickColor.new("Lime green"),
    BrickColor.new("Hot pink"),
    BrickColor.new("Bright orange"),
    BrickColor.new("Cyan"),
    BrickColor.new("Lavender"),
}

local nomesBases = {"BASE 1","BASE 2","BASE 3","BASE 4","BASE 5","BASE 6","BASE 7","BASE 8"}

for i = 1, 8 do
    local lado  = (i <= 4) and -1 or 1          -- -1 = norte, +1 = sul
    local xi    = xs[(i-1) % 4 + 1]             -- X da base
    local zi    = lado * DIST_EST                -- Z da base (lado da esteira)
    local cor   = coresBases[i]

    local baseM = Instance.new("Model")
    baseM.Name  = "Base"..i
    baseM.Parent= mapa

    -- Plataforma da base
    local piso = P({
        Name="Piso", Size=Vector3.new(BASE_SZ, 0.6, BASE_SZ),
        Position=Vector3.new(xi, 0.3, zi),
        Anchored=true, BrickColor=cor,
        Material=Enum.Material.SmoothPlastic
    }, baseM)

    -- Paredes (3 lados — deixa abertura virada pra esteira)
    -- Parede de fundo (oposta à esteira)
    P({
        Name="ParedeFundo", Size=Vector3.new(BASE_SZ, BASE_WALL*2, 1),
        Position=Vector3.new(xi, BASE_WALL, zi - lado*(BASE_SZ/2)),
        Anchored=true, BrickColor=cor,
        Material=Enum.Material.SmoothPlastic, Transparency=0.4
    }, baseM)

    -- Parede esquerda
    P({
        Name="ParedeEsq", Size=Vector3.new(1, BASE_WALL*2, BASE_SZ),
        Position=Vector3.new(xi - BASE_SZ/2, BASE_WALL, zi),
        Anchored=true, BrickColor=cor,
        Material=Enum.Material.SmoothPlastic, Transparency=0.4
    }, baseM)

    -- Parede direita
    P({
        Name="ParedeDir", Size=Vector3.new(1, BASE_WALL*2, BASE_SZ),
        Position=Vector3.new(xi + BASE_SZ/2, BASE_WALL, zi),
        Anchored=true, BrickColor=cor,
        Material=Enum.Material.SmoothPlastic, Transparency=0.4
    }, baseM)

    -- Metades da parede frontal (com porta no meio)
    -- Parede frontal esquerda
    P({
        Name="FrenteEsq", Size=Vector3.new(BASE_SZ/2 - 4, BASE_WALL*2, 1),
        Position=Vector3.new(xi - (BASE_SZ/4 + 2), BASE_WALL, zi + lado*(BASE_SZ/2)),
        Anchored=true, BrickColor=cor,
        Material=Enum.Material.SmoothPlastic, Transparency=0.4
    }, baseM)

    -- Parede frontal direita
    P({
        Name="FrenteDir", Size=Vector3.new(BASE_SZ/2 - 4, BASE_WALL*2, 1),
        Position=Vector3.new(xi + (BASE_SZ/4 + 2), BASE_WALL, zi + lado*(BASE_SZ/2)),
        Anchored=true, BrickColor=cor,
        Material=Enum.Material.SmoothPlastic, Transparency=0.4
    }, baseM)

    -- Cofre (centro da base, neon dourado)
    local cofre = P({
        Name="Cofre", Size=Vector3.new(5, 5, 5),
        Position=Vector3.new(xi, 3, zi),
        Anchored=true, BrickColor=BrickColor.new("Gold"),
        Material=Enum.Material.Neon, CastShadow=false
    }, baseM)

    -- Número da base (billboard acima do cofre)
    local bb = Instance.new("BillboardGui")
    bb.Size        = UDim2.new(0,110,0,34)
    bb.StudsOffset = Vector3.new(0,7,0)
    bb.Adornee     = cofre
    bb.AlwaysOnTop = false
    bb.Parent      = baseM

    local bbl = Instance.new("TextLabel")
    bbl.Size             = UDim2.new(1,0,1,0)
    bbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bbl.BackgroundTransparency = 0.4
    bbl.Font             = Enum.Font.GothamBold
    bbl.TextColor3       = Color3.new(1,1,1)
    bbl.TextScaled       = true
    bbl.Text             = nomesBases[i]
    bbl.Parent           = bb
    Instance.new("UICorner",bbl).CornerRadius=UDim.new(0,6)
end

-- ======================
-- SPAWN POINTS (entre as bases, próximo à esteira)
-- ======================
for i = 1, 8 do
    local lado = (i<=4) and -1 or 1
    local xi   = xs[(i-1)%4+1]
    local zi   = lado * (DIST_EST - BASE_SZ/2 - 2)

    local sp = Instance.new("SpawnLocation")
    sp.Name     = "Spawn"..i
    sp.Size     = Vector3.new(4,0.4,4)
    sp.Position = Vector3.new(xi, 0.2, zi)
    sp.BrickColor = coresBases[i]
    sp.Anchored = true
    sp.Material = Enum.Material.Neon
    sp.CastShadow = false
    sp.TeamColor  = coresBases[i]
    sp.Parent     = WS
end

-- ======================
-- LOJA DE ITENS (ao lado da esteira, eixo X positivo)
-- ======================
local lojaX = ESTEIRA_LX/2 + 18
P({
    Name="LojaBase", Size=Vector3.new(20,0.6,20),
    Position=Vector3.new(lojaX, 0.3, 0),
    Anchored=true, BrickColor=BrickColor.new("Reddish brown"),
    Material=Enum.Material.WoodPlanks
}, mapa)

-- Parede fundo da loja
P({
    Name="LojaPaFundo", Size=Vector3.new(20,8,1),
    Position=Vector3.new(lojaX, 4.6, -10),
    Anchored=true, BrickColor=BrickColor.new("Reddish brown"),
    Material=Enum.Material.WoodPlanks
}, mapa)

-- Paredes laterais loja
for _, lx in ipairs({lojaX-10, lojaX+10}) do
    P({
        Name="LojaPaLateral", Size=Vector3.new(1,8,20),
        Position=Vector3.new(lx, 4.6, 0),
        Anchored=true, BrickColor=BrickColor.new("Reddish brown"),
        Material=Enum.Material.WoodPlanks
    }, mapa)
end

-- Placa da loja
local placaLoja = P({
    Name="PlacaLoja", Size=Vector3.new(14,3,0.5),
    Position=Vector3.new(lojaX, 7.5, 9.8),
    Anchored=true, BrickColor=BrickColor.new("Bright red"),
    Material=Enum.Material.SmoothPlastic
}, mapa)

local bbLoja = Instance.new("BillboardGui")
bbLoja.Size        = UDim2.new(0,200,0,55)
bbLoja.StudsOffset = Vector3.new(0,0,0.5)
bbLoja.Adornee     = placaLoja
bbLoja.Parent      = mapa

local lblLoja = Instance.new("TextLabel")
lblLoja.Size             = UDim2.new(1,0,1,0)
lblLoja.BackgroundTransparency = 1
lblLoja.Font             = Enum.Font.GothamBold
lblLoja.TextColor3       = Color3.new(1,1,1)
lblLoja.TextScaled       = true
lblLoja.Text             = "🛒  LOJA  🇧🇷"
lblLoja.Parent           = bbLoja

-- ======================
-- LIGHTING (visual bonito)
-- ======================
Lighting.Brightness    = 2.2
Lighting.TimeOfDay     = "13:30:00"
Lighting.FogEnd        = 1400
Lighting.Ambient       = Color3.fromRGB(85,85,65)
Lighting.OutdoorAmbient= Color3.fromRGB(100,100,80)

local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    or Instance.new("Atmosphere", Lighting)
atm.Density = 0.2
atm.Offset  = 0.2
atm.Color   = Color3.fromRGB(190,210,255)
atm.Haze    = 0.7
atm.Glare   = 0.15

-- ======================
-- RELATÓRIO
-- ======================
print("")
print("🇧🇷 ======================================= 🇧🇷")
print("     STEAL A BRAZILROT — PRONTO!")
print("")
print("  MAPA:")
print("  [B1][B2][B3][B4]  <- norte")
print("  ================  <- ESTEIRA")
print("  [B5][B6][B7][B8]  <- sul")
print("  [LOJA] ao lado da esteira")
print("")
print("  Scripts criados:")
print("  ✅ Config, BrazilrotsData (20 BRs)")
print("  ✅ GameMain + AntiCheat + EsteiraManager")
print("  ✅ HUD + Loja(INDISPONÍVEL) + Index")
print("  ✅ 8 Bases + Esteira + Loja + Spawns")
print("🇧🇷 ======================================= 🇧🇷")
print("  ⚠️ Delete este LocalScript após rodar!")
