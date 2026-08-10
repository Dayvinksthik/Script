local function checkExistingPanel()
    local coreGui = game:GetService("CoreGui") or game:GetService("StarterGui")
    for _, child in pairs(coreGui:GetChildren()) do
        if child.Name == "KoalaHubAutoType" then
            return true
        end
    end
    return false
end

if checkExistingPanel() then
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function autoEscolherLetraSmart(currentPrefix)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then 
        return false 
    end
    
    local screenGui = nil
    for _, child in pairs(playerGui:GetChildren()) do
        if child:IsA("ScreenGui") and child:FindFirstChild("ChoiceList") then
            screenGui = child
            break
        end
    end
    
    if not screenGui then 
        return false 
    end
    
    local choiceList = screenGui:FindFirstChild("ChoiceList")
    if not choiceList then 
        return false 
    end
    
    if not choiceList.Visible then 
        return false 
    end
    
    local opcoes = {}
    
    for _, child in pairs(choiceList:GetChildren()) do
        if child:IsA("ImageButton") or child:IsA("ImageLabel") or child:IsA("TextButton") then
            if child.Visible then
                table.insert(opcoes, child)
            end
        end
    end
    
    if #opcoes == 0 then
        for _, child in pairs(choiceList:GetDescendants()) do
            if child:IsA("ImageButton") or child:IsA("ImageLabel") or child:IsA("TextButton") then
                if child.Visible then
                    table.insert(opcoes, child)
                end
            end
        end
    end
    
    if #opcoes == 0 then 
        return false 
    end
    
    local unicas = {}
    local seen = {}
    for _, op in ipairs(opcoes) do
        if not seen[op] then
            seen[op] = true
            table.insert(unicas, op)
        end
    end
    
    if #unicas < 2 then 
        return false 
    end
    
    local bestOption = nil
    local bestWordCount = -1
    
    for _, opcao in ipairs(unicas) do
        local letra = nil
        if opcao:IsA("TextButton") and opcao.Text then
            letra = opcao.Text:sub(1, 1):upper()
        elseif opcao:FindFirstChild("TextLabel") and opcao.TextLabel.Text then
            letra = opcao.TextLabel.Text:sub(1, 1):upper()
        elseif opcao:FindFirstChild("Text") and opcao.Text.Text then
            letra = opcao.Text.Text:sub(1, 1):upper()
        end
        
        if letra and letra:match("^[A-Z]$") then
            local testPrefix = (currentPrefix or "") .. letra
            local candidatas = encontrarPalavras(testPrefix, palavrasTentadas, true)
            local wordCount = #candidatas
            
            -- Check if this prefix would lead to valid words
            if wordCount > bestWordCount then
                bestWordCount = wordCount
                bestOption = opcao
            end
        end
    end
    
    -- If no smart choice found, fall back to random
    if not bestOption then
        bestOption = unicas[math.random(1, #unicas)]
    end
    
    local sucesso = false
    pcall(function()
        local absPos = bestOption.AbsolutePosition
        local absSize = bestOption.AbsoluteSize
        local clickX = absPos.X + absSize.X / 2
        local clickY = absPos.Y + absSize.Y / 2
        
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, nil, 0)
        task.wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, nil, 0)
        task.wait(0.03)
        
        sucesso = true
    end)
    
    return sucesso
end

-- Keep the old function for backward compatibility
local function autoEscolherLetra()
    return autoEscolherLetraSmart(ultimaBase)
end

local palavrasPT = {
    ["CURTAS"] = {
        "A", "O", "E", "I", "U", "Ao", "Ar", "As", "At", "Ah", "Ai", "Al", "Am", "An",
        "Da", "De", "Di", "Do", "Du", "Em", "Eu", "Ex", "Eh", "Er",
        "Fa", "Fe", "Fi", "Fo", "Fu", "Fim", "Ha", "He", "Hi", "Ho", "Hu",
        "Ia", "Io", "Ir", "Is", "It", "Iu",
        "Ja", "Je", "Ji", "Jo", "Ju",
        "Ka", "Ke", "Ki", "Ko", "Ku", "La", "Le", "Li", "Lo", "Lu", "Lua", "Ly",
        "Ma", "Me", "Mi", "Mo", "Mu", "Mar", "Mao", "Mel", "Mau",
        "Na", "Ne", "Ni", "No", "Nu", "Nao", "Nos", "Ny",
        "Oh", "Oi", "Ol", "Om", "On", "Or", "Os", "Ou", "Ox",
        "Pa", "Pe", "Pi", "Po", "Pu", "Paz", "Pau", "Pe",
        "Ra", "Re", "Ri", "Ro", "Ru", "Rua", "Rio", "Ria",
        "Sa", "Se", "Si", "So", "Su", "Sol", "Sim", "Sou", "Sal",
        "Ta", "Te", "Ti", "To", "Tu", "Tal", "Tao",
        "Ua", "Ui", "Um", "Uns", "Uma", "Umas", "Ur",
        "Va", "Ve", "Vi", "Vo", "Vu", "Vai", "Vem", "Viu", "Vos",
        "Xa", "Xe", "Xi", "Xo", "Xu", "Xis",
        "Yu", "Yun", "Yur",
        "Za", "Ze", "Zi", "Zo", "Zu",
        "Ic", "Ica", "Ice", "Ico", "Icu",
        "Um", "Uma", "Ume", "Umi", "Umo",
        "Sac", "Saca", "Sace", "Saci", "Saco", "Sacu",
        "Cos", "Cosa", "Cose", "Cosi", "Coso", "Cosu",
        "Of", "Ofa", "Ofe", "Ofi", "Ofo", "Ofu",
        "Alp", "Alpa", "Alpe", "Alpi", "Alpo", "Alpu",
        "Esv", "Esva", "Esve", "Esvi", "Esvo", "Esvu",
        "Eo", "Eol", "Eon", "Eos", "Eou"
    },
    ["COMPLETAS"] = {
        "Amor", "Amigo", "Agua", "Arvore", "Abacate", "Alegria", "Animal", "Anjo", "Alma", "Ave", "Ato", "Amante", "Aluno", "Aluna", "Aula", "Alto", "Antes", "Assim", "Ano", "Amo", "Ama", "Areia", "Azeitona",
        "Bola", "Boneca", "Bala", "Bolo", "Bebe", "Boca", "Braco", "Branco", "Bomba", "Brisa", "Beleza", "Batata", "Banana", "Bicicleta", "Boi", "Bau", "Bem", "Bom",
        "Casa", "Carro", "Cama", "Cachorro", "Ceu", "Copo", "Carta", "Cinto", "Cego", "Coxa", "Cor", "Cadeira", "Cavalo", "Cobra", "Cozinha", "Cao", "Com", "Cem",
        "Chave", "Chuva", "Chao", "Chama", "Chocolate", "Choro", "Chumbo", "Chique", "Chinelo", "Charme", "Churrasco", "Chaveiro", "Chamine", "Chiclete",
        "Dado", "Dedo", "Doce", "Dente", "Dia", "Deus", "Danca", "Dor", "Duna", "Dica", "Dom", "Dinheiro", "Diamante", "Duvida", "Dar", "Dez",
        "Escola", "Estrela", "Elefante", "Escada", "Emo", "Erva", "Eixo", "Eco", "Etica", "Era", "Esperanca", "Espada", "Espelho", "Estrada", "Ela", "Ele", "Eles", "Elas",
        "Faca", "Festa", "Fogo", "Flor", "Frio", "Fome", "Forte", "Fe", "Fuga", "Fase", "Fim", "Fazenda", "Foguete", "Fronteira", "Foz", "Fez",
        "Gato", "Gelo", "Gota", "Gol", "Grande", "Grato", "Gente", "Grito", "Grama", "Gula", "Garfo", "Garagem", "Gaveta", "Girassol", "Gas",
        "Hora", "Hotel", "Hino", "Habilidade", "Harpa", "Haste", "Hiena", "Humor", "Homem", "Honra",
        "Igreja", "Ilha", "Ima", "Inseto", "Idade", "Idolo", "Irado", "Impar", "Indio", "Irmao", "Irma", "Ir", "Ia", "Iate", "Iara",
        "Janela", "Jogo", "Jato", "Joia", "Jovem", "Junto", "Janta", "Jaz", "Juba", "Jardim", "Jornal", "Jogador", "Jus",
        "Kaki", "Karma", "Kart", "Kebab", "Ketchup", "Kilo", "Kit", "Kiwi", "Kaiser", "Karaoke", "Karate", "Kayak", "Kimono", "Kiosque", "Koala", "Kombi",
        "Lata", "Leao", "Lua", "Livro", "Lindo", "Largo", "Leite", "Lousa", "Lince", "Lixo", "Laranja", "Limao", "Luzes", "Luz", "Ler", "Leu",
        "Mala", "Mao", "Mesa", "Moto", "Mundo", "Morto", "Muito", "Monge", "Mamilo", "Moca", "Macaco", "Madeira", "Mochila", "Moeda", "Mas", "Meu", "Meus",
        "Nada", "Nave", "Ninho", "Nove", "Noite", "Nobre", "Norte", "Nexo", "Nata", "Nuca", "Navio", "Noticia", "Novela", "Nem", "Num",
        "Ovo", "Olho", "Ouro", "Osso", "Ontem", "Ordem", "Oeste", "Oleo", "Onda", "Orgao", "Ovelha", "Oculos", "Orelha", "Onde",
        "Pato", "Peixe", "Pena", "Pote", "Porta", "Pedra", "Prato", "Presa", "Pombo", "Preto", "Palavra", "Pessoa", "Pequeno", "Problema", "Programa", "Presente", "Professor", "Pipoca", "Pirata", "Por", "Pos",
        "Queijo", "Quadro", "Quarto", "Quente", "Quase", "Querer", "Queda", "Queixo", "Quilo", "Quadrado", "Quarenta", "Quilometro", "Quintal", "Quinze", "Que", "Quem",
        "Rato", "Rede", "Rio", "Roda", "Roupa", "Rico", "Rapido", "Rima", "Roxo", "Rugby", "Relogio", "Remedio", "Riqueza", "Rir",
        "Sapo", "Sino", "Sol", "Suco", "Sala", "Santo", "Sorte", "Selva", "Seta", "Sim", "Sistema", "Semente", "Segredo", "Sentido", "Silencio", "Sorvete", "Sombra", "Saudade", "Sapato", "Ser", "Seu", "Seus",
        "Tatu", "Tela", "Teto", "Tigre", "Terra", "Tempo", "Tudo", "Trono", "Tora", "Tufo", "Trabalho", "Telefone", "Tamanho", "Tesoura", "Tomate", "Tenis", "Tigela", "Tartaruga", "Ter", "Teu", "Teus", "Tua", "Tuas",
        "Uva", "Urso", "Unha", "Uno", "Ultimo", "Unico", "Urgente", "Utero", "Urano",
        "Vaca", "Vela", "Vento", "Vidro", "Velho", "Verde", "Vida", "Vulcao", "Valsa", "Vulto", "Viagem", "Vizinho", "Vassoura", "Vestido", "Vez", "Ver",
        "Xadrez", "Xarope", "Xerife", "Xerox", "Xicara", "Xingo", "Xixi", "Xodo", "Xucro", "Xenon", "Xereta", "Xampu", "Xale", "Xara", "Xavante", "Xisto",
        "Zebra", "Zero", "Zangado", "Ziper", "Zona", "Zoo", "Zumbi",
        
        -- Palavras com "EO"
        "Eolicas", "Eolico", "Eolicos", "Eolica", "Eolismo", "Eolismos",
        "Eon", "Eons", "Eonico", "Eonicos", "Eonica", "Eonicas",
        "Eosina", "Eosinas", "Eosinofilo", "Eosinofilos",
        "Eosinopenia", "Eosinopenias", "Eosinofilia", "Eosinofilias",
        "Eouve", "Eouves", "Eouvem", "Eouvir",
        
        "Icaro", "Icara", "Icarai", "Iceberg", "Icebergs", "Ichthyologia", "Ichthyologico", "Ichthyologo",
        "Iciclo", "Iciclos", "Icneumon", "Icneumons", "Icneumonideo", "Icneumonideos",
        "Icnita", "Icnitas", "Icnofossil", "Icnofosseis", "Icnologia", "Icnologico",
        "Icone", "Icones", "Iconico", "Iconicos", "Iconica", "Iconicas",
        "Iconoclasta", "Iconoclastas", "Iconoclastia", "Iconoclastico",
        "Iconografia", "Iconografico", "Iconografica", "Iconografias",
        "Iconolatra", "Iconolatras", "Iconolatria", "Iconolatrico",
        "Iconologia", "Iconologico", "Iconologica", "Iconologias",
        "Iconoscopio", "Iconoscopios", "Iconostase", "Iconostases",
        "Icor", "Icores", "Icosaedro", "Icosaedros", "Icosaedrico", "Icosaedricos",
        "Ictericia", "Ictericias", "Icterico", "Ictericos", "Icterica", "Ictericas",
        "Ictiocola", "Ictiofagia", "Ictiofago", "Ictiofagos",
        "Ictiografia", "Ictiografico", "Ictiologo", "Ictiologos",
        "Ictiologia", "Ictiologico", "Ictiologica", "Ictiose", "Ictioses",
        "Ictiossauro", "Ictiossauros", "Ictus",
        
        "Um", "Uma", "Umas", "Uns",
        "Umbanda", "Umbandas", "Umbela", "Umbelas", "Umbelado", "Umbelados",
        "Umbigo", "Umbigos", "Umbilicado", "Umbilicados", "Umbilical", "Umbilicais",
        "Umbla", "Umblas", "Umbral", "Umbrais",
        "Umbria", "Umbrias", "Umbro", "Umbros", "Umbroso", "Umbrosa", "Umbrosos", "Umbrosas",
        "Umedecer", "Umedecido", "Umedecida", "Umedecidos", "Umedecidas",
        "Umidade", "Umidades", "Umido", "Umidos", "Umida", "Umidas",
        "Umidificar", "Umidificado", "Umidificada",
        
        "Saca", "Sacas", "Sacada", "Sacadas", "Sacado", "Sacados",
        "Sacabuxa", "Sacabuxas", "Sacacorcho", "Sacacorchos",
        "Sacadela", "Sacadelas", "Sacadinha", "Sacadinhas",
        "Sacana", "Sacanas", "Sacanagem", "Sacanagens",
        "Sacanear", "Sacaneado", "Sacaneada", "Sacaneados", "Sacaneadas",
        "Sacao", "Sacoes", "Sacerdocio", "Sacerdocios",
        "Sacerdotal", "Sacerdotais", "Sacerdotalismo", "Sacerdotalismos",
        "Sacerdote", "Sacerdotes", "Sacerdotisa", "Sacerdotisas",
        "Sachola", "Sacholas", "Saci", "Sacia", "Sacias", "Saciado", "Saciados",
        "Saciar", "Saciante", "Saciantes", "Saciavel", "Saciaveis",
        "Sacola", "Sacolas", "Sacolada", "Sacoladas", "Sacolejar", "Sacolejado",
        "Sacolejo", "Sacolejos", "Saco", "Sacos",
        "Sacolao", "Sacoloes", "Sacudida", "Sacudidas",
        "Sacudir", "Sacudido", "Sacudidos", "Sacudida", "Sacudidas",
        "Sacramento", "Sacramentos", "Sacramental", "Sacramentais",
        "Sacral", "Sacrais", "Sacralidade", "Sacralidades",
        "Sacralizar", "Sacralizado", "Sacralizada", "Sacralizacao",
        "Sacrario", "Sacrarios", "Sacrificar", "Sacrificado",
        "Sacrificio", "Sacrificios", "Sacrificante", "Sacrificantes",
        "Sacrilegio", "Sacrilegios", "Sacrilego", "Sacrilegos", "Sacrilega", "Sacrilegas",
        "Sacro", "Sacros", "Sacra", "Sacras", "Sacrossanto", "Sacrossantos",
        
        "Cosa", "Cosas", "Cosaco", "Cosacos", "Cosaca", "Cosacas",
        "Cose", "Coses", "Cosedura", "Coseduras", "Cosecha", "Cosechas",
        "Coselho", "Coselhos", "Coser", "Cosido", "Cosidos", "Cosida", "Cosidas",
        "Cosmetico", "Cosmeticos", "Cosmetica", "Cosmeticas",
        "Cosmetologia", "Cosmetologico", "Cosmetologista",
        "Cosmico", "Cosmicos", "Cosmica", "Cosmicas",
        "Cosmismo", "Cosmismos", "Cosmista", "Cosmistas",
        "Cosmo", "Cosmos", "Cosmocracia", "Cosmocracias",
        "Cosmodromo", "Cosmodromos", "Cosmogenia", "Cosmogenias",
        "Cosmogonia", "Cosmogonias", "Cosmogonico", "Cosmogonicos",
        "Cosmografia", "Cosmografias", "Cosmografico", "Cosmograficos",
        "Cosmologo", "Cosmologos", "Cosmologa", "Cosmologas",
        "Cosmologia", "Cosmologias", "Cosmologico", "Cosmologicos",
        "Cosmonauta", "Cosmonautas", "Cosmonautica", "Cosmonauticas",
        "Cosmopolita", "Cosmopolitas", "Cosmopolitismo", "Cosmopolitismos",
        "Cosmorama", "Cosmoramas", "Cosmovisao", "Cosmovisoes",
        "Coso", "Cosos", "Cossa", "Cossas", "Cosso", "Cossos",
        "Cossaco", "Cossacos", "Cossaca", "Cossacas",
        "Cosseno", "Cossenos", "Cossoide", "Cossoides",
        "Costa", "Costas", "Costado", "Costados", "Costeira", "Costeiras",
        "Costal", "Costais", "Costela", "Costelas", "Costeleta", "Costeletas",
        "Costumar", "Costumado", "Costume", "Costumes",
        "Costura", "Costuras", "Costurar", "Costurado", "Costurada",
        "Costureira", "Costureiras", "Costureiro", "Costureiros",
        
        "Ofegante", "Ofegantes", "Ofegar", "Ofegado", "Ofegada",
        "Ofego", "Ofegos", "Ofegueira", "Ofegueiras",
        "Ofensor", "Ofensores", "Ofensora", "Ofensoras",
        "Ofensa", "Ofensas", "Ofensivo", "Ofensivos", "Ofensiva", "Ofensivas",
        "Ofendido", "Ofendidos", "Ofendida", "Ofendidas",
        "Ofender", "Ofende", "Ofendem",
        "Ofertar", "Ofertado", "Ofertada", "Oferta", "Ofertas",
        "Oferenda", "Oferendas", "Ofertante", "Ofertantes",
        "Ofertorio", "Ofertorios", "Ofertar",
        "Ofiaco", "Ofiacos", "Ofiase", "Ofiases",
        "Ofidiario", "Ofidiarios", "Ofidico", "Ofidicos", "Ofidica", "Ofidicas",
        "Ofidio", "Ofidios", "Ofidiofobia", "Ofidiofobias",
        "Ofidiologo", "Ofidiologos", "Ofidiologia", "Ofidiologias",
        "Ofidismo", "Ofidismos", "Ofidiotoxina", "Ofidiotoxinas",
        "Ofiolatra", "Ofiolatras", "Ofiolatria", "Ofiolatrias",
        "Ofiologia", "Ofiologias", "Ofiologico", "Ofiologicos",
        "Ofiomancia", "Ofiomancias", "Ofiomante", "Ofiomantes",
        "Ofion", "Ofions", "Ofionimo", "Ofionimos",
        "Ofita", "Ofitas", "Ofitico", "Ofiticos",
        "Ofito", "Ofitos", "Ofiucomorfo", "Ofiucomorfos",
        "Ofiuco", "Ofiucos", "Ofiuculo", "Ofiuculos",
        "Ofuscante", "Ofuscantes", "Ofuscar", "Ofuscado", "Ofuscada",
        "Ofuscacao", "Ofuscacoes", "Ofuscador", "Ofuscadores",
        "Oftalmia", "Oftalmias", "Oftalmica", "Oftalmicas",
        "Oftalmico", "Oftalmicos", "Oftalmitis",
        "Oftalmo", "Oftalmos", "Oftalmologia", "Oftalmologias",
        "Oftalmologista", "Oftalmologistas", "Oftalmologico",
        "Oftalmoplegia", "Oftalmoplegias", "Oftalmorreia", "Oftalmorreias",
        "Oftalmoscopio", "Oftalmoscopios", "Oftalmotomia", "Oftalmotomias",
        
        "Alpaca", "Alpacas", "Alpaco", "Alpacos",
        "Alparca", "Alparcas", "Alpargata", "Alpargatas",
        "Alpargataria", "Alpargatarias", "Alpargateiro", "Alpargateiros",
        "Alpaxa", "Alpaxas", "Alpaz", "Alpazes",
        "Alpe", "Alpes", "Alpestre", "Alpestres",
        "Alpi", "Alpis", "Alpico", "Alpicos",
        "Alpinia", "Alpinias", "Alpinismo", "Alpinismos",
        "Alpinista", "Alpinistas", "Alpinistico", "Alpinisticos",
        "Alpino", "Alpinos", "Alpina", "Alpinas",
        "Alpo", "Alpos", "Alpoim", "Alpoins",
        "Alpude", "Alpudes", "Alpujarra", "Alpujarras",
        "Alpurgar", "Alpurgado", "Alpurgada",
        "Alqueire", "Alqueires", "Alqueireiro", "Alqueireiros",
        "Alquimia", "Alquimias", "Alquimico", "Alquimicos",
        "Alquimista", "Alquimistas", "Alquimizar", "Alquimizado",
        "Alquitar", "Alquitado", "Alquitara", "Alquitaras",
        "Alcor", "Alcores", "Alcorano", "Alcoranos",
        "Alcoranico", "Alcoranicos", "Alcoranista", "Alcoranistas",
        "Alcova", "Alcovas", "Alcoviteiro", "Alcoviteiros",
        "Alcovitice", "Alcovitices", "Alcovitar", "Alcovitado",
        "Alcunha", "Alcunhas", "Alcunhar", "Alcunhado",
        "Alcunhador", "Alcunhadores", "Alcunhante", "Alcunhantes",
        "Aldeia", "Aldeias", "Aldeao", "Aldeoes", "Aldea", "Aldeas",
        "Aldeamento", "Aldeamentos", "Aldear", "Aldeado",
        
        "Esvair", "Esvai", "Esvaiu", "Esvaindo", "Esvairam",
        "Esvaido", "Esvaidos", "Esvaida", "Esvaidas",
        "Esvaziar", "Esvaziado", "Esvaziada", "Esvaziados", "Esvaziadas",
        "Esvaziamento", "Esvaziamentos", "Esvaziante", "Esvaziantes",
        "Esvaziador", "Esvaziadores", "Esvaziadora", "Esvaziadoras",
        "Esvaziavel", "Esvaziaveis",
        "Esverdear", "Esverdeado", "Esverdeada", "Esverdeados", "Esverdeadas",
        "Esverdeamento", "Esverdeamentos", "Esverdeante", "Esverdeantes",
        "Esverdinho", "Esverdinhos", "Esverdinha", "Esverdinhas",
        "Esverdinhado", "Esverdinhados", "Esverdinhada", "Esverdinhadas",
        "Esvoacar", "Esvoacado", "Esvoacada", "Esvoacados", "Esvoacadas",
        "Esvoacante", "Esvoacantes", "Esvoacador", "Esvoacadores",
        "Esvoacamento", "Esvoacamentos", "Esvoacavel", "Esvoacaveis",
        "Esvanecer", "Esvanecido", "Esvanecida", "Esvanecidos", "Esvanecidas",
        "Esvanecimento", "Esvanecimentos", "Esvanescente", "Esvanescentes",
        "Esvanescencia", "Esvanescencias", "Esvanecivel", "Esvaneciveis",
        "Esvanear", "Esvaneado", "Esvaneada", "Esvaneados", "Esvaneadas",
        "Esvaporar", "Esvaporado", "Esvaporada", "Esvaporados", "Esvaporadas",
        "Esvaporacao", "Esvaporacoes", "Esvaporante", "Esvaporantes",
        "Esvaporavel", "Esvaporaveis", "Esvaporizar", "Esvaporizado",
        "Esvasiado", "Esvasiados", "Esvasiada", "Esvasiadas",
        "Esvazio", "Esvazios", "Esvazia", "Esvazias",
    }
}

local palavrasEN = {
    ["CURTAS"] = {
        "A", "I", "O", "Y", "Am", "An", "As", "At", "Ah", "Ai", "Al", "Ar", "Ax",
        "Be", "By", "Bo", "Bi", "Co", "Ca", "Ce", "Ci", "Cu",
        "Do", "Da", "De", "Di", "Du", "Em", "El", "Es", "Ex", "Er",
        "Fa", "Fe", "Fi", "Fo", "Fu", "Go", "Ga", "Ge", "Gi", "Gu",
        "Ha", "He", "Hi", "Ho", "Hu",
        "If", "In", "Is", "It",
        "La", "Le", "Li", "Lo", "Lu", "Ly",
        "Ma", "Me", "Mi", "Mo", "Mu", "My",
        "Na", "Ne", "Ni", "No", "Nu", "Ny", "Of", "Oh", "Oi", "Ok", "On", "Or", "Os", "Ow", "Ox",
        "Pa", "Pe", "Pi", "Po", "Pu", "Qu", "Ra", "Re", "Ri", "Ro", "Ru",
        "Sa", "Se", "Sh", "Si", "So", "St", "Su", "Ta", "Te", "Th", "Ti", "To", "Tu",
        "Um", "Un", "Up", "Us", "Va", "Ve", "Vi", "Vo", "Vu",
        "Wa", "We", "Wi", "Wo", "Wu", "Xe", "Xi", "Xu", "Ya", "Ye", "Yi", "Yo", "Yu", "Za", "Ze", "Zi", "Zo", "Zu",
        "Ic", "Ice", "Ich", "Ico",
        "Um", "Umb", "Ump",
        "Sac", "Sack", "Saco",
        "Cos", "Cosh", "Cosm",
        "Of", "Off", "Oft",
        "Alp", "Alps", "Alph",
        "Esv",
        "Eo", "Eon", "Eos", "Eoh"
    },
    ["COMPLETAS"] = {
        "Ace", "Act", "Add", "Age", "Ago", "Aid", "Aim", "Air", "All", "And", "Ant", "Any", "Ape", "Arc", "Are", "Ark", "Arm", "Art", "Ash", "Ask", "Ate", "Awe", "Axe",
        "Bad", "Bag", "Ban", "Bar", "Bat", "Bay", "Bed", "Bet", "Bid", "Big", "Bin", "Bit", "Bog", "Bow", "Box", "Boy", "Bud", "Bug", "Bun", "Bus", "But", "Buy",
        "Cab", "Cam", "Can", "Cap", "Car", "Cat", "Cop", "Cow", "Cry", "Cub", "Cup", "Cur", "Cut",
        "Dad", "Dam", "Day", "Den", "Dew", "Did", "Dig", "Dim", "Dip", "Dog", "Dot", "Dry", "Dug", "Duo", "Dye",
        "Ear", "Eat", "Eel", "Egg", "Elf", "Elm", "Emu", "End", "Era", "Eve", "Eye",
        "Fan", "Far", "Fat", "Fax", "Fed", "Few", "Fig", "Fin", "Fir", "Fit", "Fix", "Fly", "Fog", "For", "Fox", "Fry", "Fun", "Fur",
        "Gag", "Gap", "Gas", "Get", "Gig", "Gin", "God", "Got", "Gum", "Gun", "Gut", "Guy", "Gym",
        "Had", "Ham", "Has", "Hat", "Hay", "Hen", "Her", "Hew", "Hid", "Him", "Hip", "His", "Hit", "Hog", "Hop", "Hot", "How", "Hub", "Hue", "Hug", "Hum", "Hut",
        "Ice", "Icy", "Icon", "Idea", "Idle", "Idol", "Inch", "Into", "Iron", "Isle", "Issue", "Item", "Itch",
        "Jab", "Jag", "Jam", "Jar", "Jaw", "Jay", "Jet", "Jig", "Job", "Jog", "Jot", "Joy", "Jug", "Jut",
        "Keg", "Ken", "Key", "Kid", "Kin", "Kit", "Kite", "Knee", "Knew", "Knit", "Knob", "Knot", "Know", "Keen", "Keep", "Kept", "Kick", "Kill", "Kind", "King", "Kiss",
        "Lab", "Lad", "Lag", "Lap", "Law", "Lay", "Led", "Leg", "Let", "Lid", "Lip", "Lit", "Log", "Lot", "Low",
        "Mad", "Man", "Map", "Mat", "Maw", "Men", "Met", "Mid", "Mix", "Mob", "Mod", "Mom", "Mop", "Mow", "Mud", "Mug", "Mum",
        "Nab", "Nag", "Nap", "Net", "New", "Nil", "Nip", "Nit", "Nod", "Nor", "Not", "Now", "Nut",
        "Oak", "Oar", "Oat", "Odd", "Off", "Oil", "Old", "One", "Opt", "Orb", "Ore", "Our", "Out", "Owl", "Own",
        "Pad", "Pal", "Pan", "Paw", "Pea", "Peg", "Pen", "Pet", "Pie", "Pig", "Pin", "Pit", "Pod", "Pop", "Pot", "Pry", "Pub", "Pug", "Pun", "Pup", "Pus", "Put",
        "Rag", "Ram", "Ran", "Rat", "Raw", "Ray", "Red", "Rib", "Rid", "Rig", "Rim", "Rob", "Rod", "Rot", "Row", "Rub", "Rug", "Run", "Rut",
        "Sad", "Sag", "Sap", "Sat", "Saw", "Say", "Sea", "Set", "She", "Shy", "Sin", "Sip", "Sir", "Sit", "Six", "Ski", "Sky", "Sly", "Sob", "Son", "Sop", "Sot", "Sow", "Soy", "Spa", "Spy", "Sub", "Sum", "Sun", "Sup",
        "Tab", "Tag", "Tan", "Tap", "Tar", "Tax", "Tea", "Ten", "The", "Tie", "Tin", "Tip", "Toe", "Ton", "Too", "Top", "Tow", "Toy", "Try", "Tub", "Tug", "Two",
        "Urn", "Use", "Van", "Vat", "Vet", "Vow",
        "Wag", "War", "Was", "Wax", "Way", "Web", "Wet", "Who", "Why", "Wig", "Win", "Wit", "Woe", "Wok", "Won", "Woo", "Wow",
        "Zap", "Zen", "Zig", "Zip", "Zoo",
        
        -- EO Words
        "Eolithic", "Eon", "Eons", "Eonian", "Eonism", "Eonisms",
        "Eosin", "Eosinophil", "Eosinophils", "Eosinophilia",
        "Eosinophilic", "Eohippus", "Eohippuses",
        
        "Icarus", "Ice", "Iceberg", "Icebergs", "Icebound", "Icebox", "Iceboxes",
        "Icebreaker", "Icebreakers", "Icecap", "Icecaps", "Icecream", "Icecreams",
        "Iced", "Icefall", "Icefalls", "Icefield", "Icefields",
        "Icehouse", "Icehouses", "Icelander", "Icelanders",
        "Iceland", "Icelandic", "Iceless", "Icemaker", "Icemakers",
        "Iceman", "Icemen", "Ices", "Iceskate", "Iceskates",
        "Ich", "Ichnite", "Ichnites", "Ichnofossil", "Ichnofossils",
        "Ichnology", "Ichnologic", "Ichnological",
        "Ichor", "Ichors", "Ichorous",
        "Ichneumon", "Ichneumons", "Ichneumonid", "Ichneumonids",
        "Ichthyology", "Ichthyologist", "Ichthyosaur", "Ichthyosaurs",
        "Ichthyosis", "Ichthyotic", "Icicle", "Icicles", "Icicled",
        "Icily", "Iciness", "Icing", "Icings",
        "Icon", "Icons", "Iconic", "Iconical", "Iconically",
        "Iconoclasm", "Iconoclast", "Iconoclasts",
        "Iconoclastic", "Iconographic", "Iconographical",
        "Iconography", "Iconolater", "Iconolaters",
        "Iconolatry", "Iconologic", "Iconological",
        "Iconology", "Iconophile", "Iconophiles",
        "Iconoscope", "Iconoscopes", "Iconostasis", "Iconostases",
        "Icosahedral", "Icosahedron", "Icosahedrons", "Icosahedra",
        "Icterical", "Icterine", "Icteroid", "Icterus",
        "Ictic", "Ictus", "Ictuses", "Icy", "Icier", "Iciest",
        
        "Umb", "Umbel", "Umbels", "Umbeled", "Umbellate", "Umbellated",
        "Umbellifer", "Umbellifers", "Umbelliferous",
        "Umber", "Umbers", "Umbilic", "Umbilical", "Umbilically",
        "Umbilicate", "Umbilicated", "Umbilication", "Umbilications",
        "Umbilicus", "Umbilici", "Umbilicuses",
        "Umbo", "Umbones", "Umbos", "Umbonal", "Umbonate",
        "Umbra", "Umbras", "Umbrae", "Umbrage", "Umbrages",
        "Umbrageous", "Umbrageously", "Umbrageousness",
        "Umbral", "Umbratic", "Umbratile",
        "Umbrella", "Umbrellas", "Umbrellaless",
        "Umbriferous", "Umbrine", "Umbrous",
        "Umi", "Umiak", "Umiaks",
        "Umlaut", "Umlauts", "Umlauted",
        "Umm", "Ummah", "Ummahs",
        "Ump", "Umps", "Umpirage", "Umpirages",
        "Umpire", "Umpires", "Umpired", "Umpiring",
        "Umpteen", "Umpteenth", "Umteenth",
        
        "Sac", "Sacs", "Saccade", "Saccades", "Saccadic",
        "Saccate", "Sacchate", "Sacchates",
        "Sacchar", "Sacchars", "Saccharic",
        "Saccharide", "Saccharides", "Sacchariferous",
        "Saccharify", "Saccharified", "Saccharifying",
        "Saccharimeter", "Saccharimeters",
        "Saccharin", "Saccharins", "Saccharine",
        "Saccharize", "Saccharized",
        "Saccharoid", "Saccharoidal",
        "Saccharose", "Saccharoses",
        "Sacciform", "Sacculus",
        "Saccule", "Saccules", "Sacculi", "Saccular",
        "Sacculate", "Sacculated", "Sacculation",
        "Sacker", "Sackers", "Sacking", "Sackings",
        "Sackbut", "Sackbuts", "Sackcloth", "Sackcloths",
        "Sacrament", "Sacraments", "Sacramental", "Sacramentals",
        "Sacraria", "Sacrarium", "Sacraria",
        "Sacred", "Sacredly", "Sacredness",
        "Sacrifice", "Sacrifices", "Sacrificed",
        "Sacrificial", "Sacrificially",
        "Sacrilege", "Sacrileges", "Sacrilegious",
        "Sacrilegiously", "Sacrilegiousness",
        "Sacring", "Sacrings", "Sacrist", "Sacrists",
        "Sacristan", "Sacristans", "Sacristy",
        "Sacro", "Sacrococcygeal",
        "Sacrosanct", "Sacrosanctity",
        "Sacrum", "Sacrums", "Sacra",
        
        "Cos", "Cosec", "Cosecant", "Cosecants",
        "Coseismal", "Coseismic",
        "Cosh", "Cosher", "Coshing",
        "Cosign", "Cosigned", "Cosigner", "Cosigners",
        "Cosine", "Cosines", "Cosiness",
        "Cosmetic", "Cosmetics", "Cosmetically",
        "Cosmetician", "Cosmeticians",
        "Cosmetologist", "Cosmetologists", "Cosmetology",
        "Cosmic", "Cosmical", "Cosmically",
        "Cosmism", "Cosmisms", "Cosmist", "Cosmists",
        "Cosmo", "Cosmochemistry",
        "Cosmocrat", "Cosmocrats", "Cosmocratic",
        "Cosmodrome", "Cosmodromes",
        "Cosmogenesis", "Cosmogenetic", "Cosmogenic",
        "Cosmogonic", "Cosmogonical",
        "Cosmogonist", "Cosmogonists", "Cosmogony",
        "Cosmographer", "Cosmographers",
        "Cosmographic", "Cosmographical", "Cosmography",
        "Cosmolatry", "Cosmologic", "Cosmological",
        "Cosmologist", "Cosmologists", "Cosmology",
        "Cosmonaut", "Cosmonauts", "Cosmonautic",
        "Cosmopolis", "Cosmopolitan", "Cosmopolitans",
        "Cosmopolitanism", "Cosmopolite", "Cosmopolites",
        "Cosmopolitism", "Cosmorama", "Cosmoramas",
        "Cosmos", "Cosmoses", "Cosmosphere",
        "Cosmotron", "Cosmotrons",
        "Cossack", "Cossacks",
        "Cosset", "Cossets", "Cosseted",
        "Cost", "Costs", "Costa", "Costae",
        "Costal", "Costalgia", "Costally",
        "Costard", "Costards", "Costate",
        "Costermonger", "Costermongers",
        "Costful", "Costing", "Costless",
        "Costly", "Costlier", "Costliest",
        "Costmary", "Costrel", "Costrels",
        "Costume", "Costumes", "Costumed",
        "Costumer", "Costumers", "Costumier",
        "Costus", "Costuses",
        
        "Of", "Ofay", "Ofays", "Off", "Offal", "Offals",
        "Offbeat", "Offbeats", "Offcast", "Offcasts",
        "Offcut", "Offcuts", "Offed",
        "Offence", "Offences", "Offenceless",
        "Offend", "Offended", "Offender", "Offenders",
        "Offending", "Offends",
        "Offense", "Offenses", "Offenseless",
        "Offensive", "Offensives", "Offensively",
        "Offensiveness",
        "Offer", "Offers", "Offerable",
        "Offeree", "Offerees", "Offerer", "Offerers",
        "Offering", "Offerings", "Offertory",
        "Offhand", "Offhanded", "Offhandedly",
        "Office", "Offices", "Officeholder",
        "Officer", "Officers", "Officered",
        "Official", "Officials", "Officialdom",
        "Officialese", "Officialism",
        "Officialize", "Officialized", "Officially",
        "Officiant", "Officiants",
        "Officiate", "Officiated", "Officiates",
        "Officiating", "Officiator",
        "Officinal", "Officious", "Officiously",
        "Offing", "Offings", "Offish",
        "Offlap", "Offload", "Offloaded",
        "Offprint", "Offprints", "Offput",
        "Offs", "Offsaddle",
        "Offscourings", "Offscum",
        "Offseason", "Offseasons",
        "Offset", "Offsets", "Offsetting",
        "Offshoot", "Offshoots",
        "Offshore", "Offshored", "Offshores",
        "Offside", "Offsides",
        "Offspring", "Offsprings",
        "Offstage", "Offtake", "Offtakes",
        "Offwhite", "Offwhites",
        
        "Alp", "Alps", "Alpaca", "Alpacas",
        "Alpargata", "Alpargatas",
        "Alpenglow", "Alpenglows",
        "Alpenhorn", "Alpenhorns",
        "Alpenstock", "Alpenstocks",
        "Alpestrine", "Alpha", "Alphas",
        "Alphabet", "Alphabets",
        "Alphabetic", "Alphabetical", "Alphabetically",
        "Alphabetize", "Alphabetized", "Alphabetizing",
        "Alphanumeric", "Alphanumerical",
        "Alphas", "Alpine", "Alpinely",
        "Alpinism", "Alpinisms",
        "Alpinist", "Alpinists",
        "Alprazolam", "Alprazolams",
        
        "Esv", "Esva", "Esvac",
        "Esvade", "Esvaded", "Esvades",
        "Esvage", "Esvaged", "Esvages",
        "Esvail", "Esvails",
        "Esvain", "Esvains",
        "Esvair", "Esvairs",
        "Esvan", "Esvans",
        "Esvanish", "Esvanished", "Esvanishes",
        "Esvaporate", "Esvaporated", "Esvaporates",
        "Esvaporation", "Esvaporations",
        "Esvault", "Esvaults",
        "Esvelte", "Esvelter", "Esveltest",
        "Esvent", "Esvents",
        "Esver", "Esvers",
        "Esviate", "Esviated", "Esviates",
        "Esvict", "Esvicts", "Esvicted",
        "Esviction", "Esvictions",
        "Esvie", "Esvied", "Esvies",
        "Esvile", "Esviler", "Esvilest",
        "Esvilify", "Esvilified",
        "Esvince", "Esvinced", "Esvinces",
        "Esvine", "Esvined", "Esvines",
        "Esviolate", "Esviolated", "Esviolates",
        "Esviolation", "Esviolations",
        "Esvir", "Esviral",
        "Esvire", "Esvired", "Esvires",
        "Esvirgin", "Esvirginal",
        "Esviril", "Esvirile",
        "Esvirtue", "Esvirtues",
        "Esvis", "Esvisage", "Esvisaged",
        "Esviscera", "Esvisceral",
        "Esviscerate", "Esviscerated",
        "Esvisco", "Esviscoid",
        "Esvise", "Esvised",
        "Esvisible", "Esvisibly",
        "Esvision", "Esvisions",
        "Esvisit", "Esvisits", "Esvisited",
        "Esvisitor", "Esvisitors",
        "Esvisor", "Esvisors",
        "Esvista", "Esvistas",
        "Esvisual", "Esvisualise", "Esvisualised",
        "Esvisualize", "Esvisualized",
        "Esvital", "Esvitally",
        "Esvitiate", "Esvitiated",
        "Esvitre", "Esvitreous",
        "Esvitric", "Esvitrics",
        "Esvitrify", "Esvitrified",
        "Esvitriol", "Esvitriolic",
        "Esvivace", "Esvivacious",
        "Esvive", "Esvived",
        "Esvivid", "Esvividly",
        "Esvivify", "Esvivified",
        "Esviviparous", "Esvivisect", "Esvivisected",
        "Esvocal", "Esvocals",
        "Esvocation", "Esvocations",
        "Esvocative", "Esvociferate",
        "Esvogue", "Esvogued",
        "Esvoke", "Esvoked", "Esvokes",
        "Esvol", "Esvola",
        "Esvolatile", "Esvolatility",
        "Esvolcanic", "Esvolcanically",
        "Esvolcano", "Esvolcanos",
        "Esvolent", "Esvolently",
        "Esvolitant", "Esvolitate",
        "Esvolition", "Esvolitions",
        "Esvolt", "Esvoltaic",
        "Esvoltmeter", "Esvolts",
        "Esvoluble", "Esvolubleness",
        "Esvolume", "Esvolumed",
        "Esvolumetric", "Esvoluminous",
        "Esvoluntary", "Esvoluntarily",
        "Esvolunteer", "Esvolunteered",
        "Esvoluptuous", "Esvoluptuously",
        "Esvolute", "Esvoluted",
        "Esvolution", "Esvolutions",
        "Esvolutionary", "Esvolutionist",
        "Esvolve", "Esvolved", "Esvolves",
        "Esvomit", "Esvomited", "Esvomiting",
        "Esvoodoo", "Esvoodoos",
        "Esvoracious", "Esvoraciously",
        "Esvoracity", "Esvoracities",
        "Esvortex", "Esvortexes",
        "Esvortical", "Esvortices",
        "Esvote", "Esvoted", "Esvotes",
        "Esvotive", "Esvotively",
        "Esvouch", "Esvouched",
        "Esvows", "Esvox",
        "Esvoyage", "Esvoyaged", "Esvoyager",
        "Esvoyeur", "Esvoyeurs",
    }
}

local palavrasES = {
    ["CURTAS"] = {
        "A", "O", "E", "I", "U", "Y", "Al", "Am", "An", "Ar", "As", "Ay",
        "Be", "Bi", "Bo", "Bu", "Ca", "Ce", "Ci", "Co", "Cu", "Da", "De", "Di", "Do", "Du",
        "El", "En", "Es", "Ex", "Fa", "Fe", "Fi", "Fo", "Fu",
        "Ga", "Ge", "Gi", "Go", "Gu", "Ha", "He", "Hi", "Ho", "Hu",
        "Ia", "Io", "Ir", "Is", "It",
        "La", "Le", "Li", "Lo", "Lu",
        "Ma", "Me", "Mi", "Mo", "Mu",
        "Na", "Ne", "Ni", "No", "Nu",
        "Oh", "Oi", "Ol", "Om", "On", "Or", "Os", "Ou", "Ox",
        "Pa", "Pe", "Pi", "Po", "Pu", "Qu", "Ra", "Re", "Ri", "Ro", "Ru",
        "Sa", "Se", "Si", "So", "Su", "Ta", "Te", "Ti", "To", "Tu",
        "Un", "Una", "Unas", "Unos", "Va", "Ve", "Vi", "Vo", "Vu",
        "Ya", "Ye", "Yi", "Yo", "Yu", "Za", "Ze", "Zi", "Zo", "Zu",
        "Ic", "Ica", "Ice", "Ico", "Icu",
        "Um", "Uma", "Ume", "Umi", "Umo",
        "Sac", "Saca", "Sace", "Saci", "Saco", "Sacu",
        "Cos", "Cosa", "Cose", "Cosi", "Coso", "Cosu",
        "Of", "Ofa", "Ofe", "Ofi", "Ofo", "Ofu",
        "Alp", "Alpa", "Alpe", "Alpi", "Alpo", "Alpu",
        "Esv", "Esva", "Esve", "Esvi", "Esvo", "Esvu",
        "Eo", "Eol", "Eon", "Eos"
    },
    ["COMPLETAS"] = {
        "Aceite", "Agua", "Aire", "Alegre", "Alma", "Amigo", "Amor", "Animal", "Arbol",
        "Bebe", "Bello", "Beso", "Blanco", "Boca", "Bola", "Brazo", "Brisa", "Bueno", "Buscar",
        "Calor", "Cama", "Carta", "Casa", "Chapa", "Charco", "Chica", "Chico", "Chino", "Chiste", "Chocolate", "Chuleta", "Ciego", "Cielo", "Cine", "Copa", "Cuerpo",
        "Dado", "Danza", "Dedo", "Dia", "Diente", "Dios", "Dolor", "Don", "Dulce", "Duna",
        "Eco", "Edad", "Eje", "Elefante", "Enano", "Entrar", "Era", "Escuela", "Estrella", "Etico",
        "Fama", "Fase", "Fe", "Fiesta", "Fin", "Flor", "Foca", "Frio", "Fuego", "Fuga",
        "Gato", "Gente", "Gol", "Gota", "Grama", "Grande", "Grato", "Grito", "Gula",
        "Habilidad", "Harpa", "Hielo", "Hiena", "Hijo", "Himno", "Hoja", "Hora", "Hotel", "Humor",
        "Idolo", "Iglesia", "Iman", "India", "Insecto", "Invierno", "Ir", "Isla",
        "Jabon", "Jamon", "Jefe", "Jesus", "Jirafa", "Joven", "Joya", "Juego", "Junto",
        "Kilo", "Karma", "Karate", "Kayak", "Kebab", "Ketchup", "Kiwi", "Koala",
        "Largo", "Lata", "Leche", "Leon", "Libro", "Lince", "Lindo", "Loco", "Luna", "Luz",
        "Madre", "Malo", "Mano", "Mar", "Mesa", "Miel", "Moto", "Mucho", "Muerto", "Mundo",
        "Nada", "Nave", "Nido", "Nieto", "Noble", "Noche", "Norte", "Nube", "Nueve", "Nuez",
        "Obra", "Ocho", "Oeste", "Ojo", "Ola", "Orden", "Oreja", "Oro", "Oso",
        "Pan", "Pato", "Paz", "Pena", "Pez", "Piedra", "Piel", "Piso", "Plato", "Puerta",
        "Queso", "Quimica", "Quince", "Quitar", "Querer", "Quieto",
        "Rama", "Rapido", "Raton", "Red", "Rey", "Rico", "Rio", "Ropa", "Rosa", "Rueda",
        "Sal", "Santo", "Sapo", "Sed", "Seda", "Selva", "Si", "Silla", "Sol", "Suerte",
        "Taza", "Techo", "Tela", "Tiempo", "Tierra", "Tigre", "Todo", "Toro", "Tren", "Trono",
        "Una", "Unico", "Union", "Uno", "Urgente", "Uso", "Uva",
        "Vaca", "Valle", "Vaso", "Vela", "Verde", "Vida", "Vidrio", "Viejo", "Viento", "Voz",
        "Zona", "Zoo", "Zapato", "Zanahoria",
        
        -- EO Words
        "Eolico", "Eolicos", "Eolica", "Eolicas", "Eolismo", "Eolismos",
        "Eon", "Eones", "Eonio", "Eonios",
        "Eosina", "Eosinas", "Eosinofilo", "Eosinofilos",
        "Eosinofilia", "Eosinofilias",
        
        "Icaco", "Icacos", "Icaro", "Icaros",
        "Iceberg", "Icebergs",
        "Iciclo", "Iciclos", "Icnita", "Icnitas",
        "Icnofosil", "Icnofosiles",
        "Icnologia", "Icnologico",
        "Icono", "Iconos", "Iconico", "Iconicos",
        "Iconoclasta", "Iconoclastas",
        "Iconografia", "Iconografias",
        "Iconografico", "Iconograficos",
        "Iconolatra", "Iconolatras",
        "Iconolatria", "Iconolatrias",
        "Iconologia", "Iconologias",
        "Iconologico", "Iconologicos",
        "Iconoscopio", "Iconoscopios",
        "Iconostasio", "Iconostasios",
        "Icor", "Icores",
        "Icosaedro", "Icosaedros",
        "Ictericia", "Ictericias",
        "Icterico", "Ictericos",
        "Ictiofagia", "Ictiofago",
        "Ictiologia", "Ictiologico",
        "Ictiologo", "Ictiologos",
        "Ictiosauro", "Ictiosauros",
        
        "Umbela", "Umbelas", "Umbelifero", "Umbeliferos",
        "Umbilical", "Umbilicales", "Umbilicado", "Umbilicados",
        "Umbral", "Umbrales", "Umbra", "Umbras",
        "Umbrela", "Umbrelas", "Umbria", "Umbrias",
        "Umbrio", "Umbrios", "Umbroso", "Umbrosa",
        "Umedecer", "Umedecido", "Umedecida",
        "Umedo", "Umedos", "Umeda", "Umedas",
        "Umita", "Umitas",
        "Umbilicar", "Umbilicado", "Umbilicacion",
        
        "Saca", "Sacas", "Sacada", "Sacadas", "Sacado", "Sacados",
        "Sacabocado", "Sacabocados", "Sacabotas",
        "Sacacorchos", "Sacapuntas",
        "Sacarina", "Sacarinas", "Sacarificar", "Sacarificado",
        "Sacaro", "Sacaros",
        "Sacerdocio", "Sacerdocios", "Sacerdotal", "Sacerdotales",
        "Sacerdote", "Sacerdotes", "Sacerdotisa", "Sacerdotisas",
        "Sachar", "Sachado", "Sachada", "Sacho", "Sachos",
        "Saciar", "Saciado", "Saciada", "Saciable", "Saciables",
        "Saco", "Sacos", "Sacola", "Sacolas",
        "Sacramento", "Sacramentos", "Sacramental", "Sacramentales",
        "Sacrificar", "Sacrificado", "Sacrificio", "Sacrificios",
        "Sacrilego", "Sacrilegos", "Sacrilegio", "Sacrilegios",
        "Sacro", "Sacros", "Sacrosanto", "Sacrosantos",
        "Sacudir", "Sacudido", "Sacudida", "Sacudimiento",
        "Saculo", "Saculos", "Sacular", "Saculares",
        
        "Cosa", "Cosas", "Cosaco", "Cosacos", "Cosaca", "Cosacas",
        "Coscar", "Coscado", "Coscoja", "Coscojas", "Coscojo", "Coscojos",
        "Coscorron", "Coscorrones", "Cosecante", "Cosecantes",
        "Cosecha", "Cosechas", "Cosechar", "Cosechado", "Cosechadora",
        "Coser", "Cosido", "Cosidos", "Cosida", "Cosidas",
        "Cosmetico", "Cosmeticos", "Cosmetica", "Cosmeticas",
        "Cosmico", "Cosmicos", "Cosmica", "Cosmicas",
        "Cosmo", "Cosmos", "Cosmogonico", "Cosmogonicos",
        "Cosmogonia", "Cosmogonias", "Cosmografia", "Cosmografias",
        "Cosmografico", "Cosmograficos", "Cosmologo", "Cosmologos",
        "Cosmologia", "Cosmologias", "Cosmologico", "Cosmologicos",
        "Cosmonauta", "Cosmonautas", "Cosmopolita", "Cosmopolitas",
        "Cosmopolitismo", "Cosmopolitismos", "Cosmorama", "Cosmoramas",
        "Cosmovision", "Cosmovisiones", "Coso", "Cosos",
        "Cosquillas", "Cosquillear", "Cosquilleo", "Cosquilleos",
        "Costa", "Costas", "Costado", "Costados", "Costal", "Costales",
        "Costar", "Costado", "Coste", "Costes", "Costero", "Costeros",
        "Costilla", "Costillas", "Costillar", "Costillares",
        "Costo", "Costos", "Costoso", "Costosos", "Costosa", "Costosas",
        "Costumbre", "Costumbres", "Costura", "Costuras",
        "Costurar", "Costurado", "Costurera", "Costureras",
        
        "Ofa", "Ofas", "Ofelia", "Ofelias",
        "Ofender", "Ofendido", "Ofendida", "Ofendidos", "Ofendidas",
        "Ofensa", "Ofensas", "Ofensivo", "Ofensivos", "Ofensiva", "Ofensivas",
        "Ofensor", "Ofensores", "Ofensora", "Ofensoras",
        "Ofertar", "Ofertado", "Ofertada", "Oferta", "Ofertas",
        "Ofertorio", "Ofertorios", "Oferente", "Oferentes",
        "Oficial", "Oficiales", "Oficialmente", "Oficialidad",
        "Oficiar", "Oficiado", "Oficiante", "Oficiantes",
        "Oficina", "Oficinas", "Oficinista", "Oficinistas",
        "Ofidio", "Ofidios", "Ofidico", "Ofidicos",
        "Ofiologia", "Ofiologias", "Ofiologico", "Ofiologicos",
        "Ofita", "Ofitas", "Ofitico", "Ofiticos",
        "Oftalmia", "Oftalmias", "Oftalmico", "Oftalmicos",
        "Oftalmologia", "Oftalmologias", "Oftalmologico",
        "Oftalmologo", "Oftalmologos", "Oftalmoscopio",
        "Ofuscante", "Ofuscantes", "Ofuscar", "Ofuscado",
        "Ofuscacion", "Ofuscaciones", "Ofuscamiento",
        
        "Alpaca", "Alpacas", "Alparca", "Alparcas",
        "Alpargata", "Alpargatas", "Alpargatero", "Alpargateros",
        "Alpax", "Alpaxes", "Alpe", "Alpes",
        "Alpestre", "Alpestres", "Alpico", "Alpicos",
        "Alpinismo", "Alpinismos", "Alpinista", "Alpinistas",
        "Alpino", "Alpinos", "Alpina", "Alpinas",
        "Alpiste", "Alpistes", "Alpistero", "Alpisteros",
        "Alpo", "Alpos", "Alpujarra", "Alpujarras",
        "Alquimia", "Alquimias", "Alquimico", "Alquimicos",
        "Alquimista", "Alquimistas", "Alquitar", "Alquitado",
        "Alquitrabe", "Alquitrabes",
        "Alcor", "Alcores", "Alcoranico", "Alcoranicos",
        "Alcova", "Alcovas",
        "Alcuza", "Alcuzas", "Alcuzado", "Alcuzados",
        "Aldea", "Aldeas", "Aldeano", "Aldeanos",
        "Aldehuela", "Aldehuelas", "Aldeita", "Aldeitas",
        
        "Esvair", "Esvais", "Esvae", "Esvaen",
        "Esvaido", "Esvaidos", "Esvaida", "Esvaidas",
        "Esvanecer", "Esvanecido", "Esvanecida",
        "Esvanecimiento", "Esvanecimientos",
        "Esvaporar", "Esvaporado", "Esvaporada",
        "Esvaporacion", "Esvaporaciones",
        "Esvasar", "Esvasado", "Esvasada",
        "Esvasadura", "Esvasaduras",
        "Esvelto", "Esveltos", "Esvelta", "Esveltas",
        "Esveltez", "Esvelteces", "Esvelteza", "Esveltezas",
        "Esvirar", "Esvirado", "Esvirada",
        "Esviril", "Esviriles", "Esvirilar", "Esvirilado",
        "Esviscerar", "Esviscerado", "Esviscerada",
        "Esvitar", "Esvitado", "Esvitada",
        "Esvoacar", "Esvoacado", "Esvoacada",
        "Esvoacante", "Esvoacantes",
        "Esvol", "Esvoles", "Esvolar", "Esvolado",
        "Esvolumen", "Esvolumenes", "Esvoluminoso",
        "Esvotar", "Esvotado", "Esvotada",
        "Esvult", "Esvultos",
        "Esvulgar", "Esvulgado", "Esvulgada",
        "Esvulnerar", "Esvulnerado", "Esvulnerada",
    }
}

local palavrasHardMode = {
    Y = {"yabby", "yacht", "yachts", "yachting", "yachtsman", "yak", "yaks", "yam", "yams", "yank", "yanks", "yap", "yaps", "yard", "yards", "yarn", "yarns", "yaw", "yaws", "yawn", "yawns", "yea", "yeah", "year", "years", "yearly", "yearn", "yearns", "yeast", "yeasts", "yell", "yells", "yellow", "yellows", "yelp", "yelps", "yen", "yens", "yep", "yes", "yet", "yew", "yews", "yield", "yields", "yoga", "yogurt", "yogurts", "yoke", "yokes", "yolk", "yolks", "you", "young", "younger", "your", "yours", "youth", "youths", "youtube", "yuck", "yucky", "yule", "yum", "yummy", "yurt", "yurts"},
    W = {"allow", "arrow", "below", "blow", "borrow", "bow", "brew", "brow", "chew", "claw", "cow", "crew", "dew", "draw", "drew", "elbow", "few", "flow", "follow", "grew", "grow", "how", "jaw", "knew", "know", "law", "low", "narrow", "new", "now", "pillow", "plow", "raw", "renew", "row", "saw", "sew", "shadow", "show", "slow", "snow", "sow", "sparrow", "spew", "stew", "straw", "swallow", "thaw", "throw", "tomorrow", "tow", "view", "vow", "widow", "willow", "yellow"},
    LY = {"actually", "barely", "basically", "beautifully", "briefly", "carefully", "certainly", "clearly", "closely", "commonly", "completely", "constantly", "currently", "daily", "deeply", "definitely", "directly", "easily", "effectively", "entirely", "equally", "especially", "eventually", "exactly", "extremely", "fairly", "finally", "firmly", "formerly", "frequently", "fully", "generally", "gently", "gladly", "greatly", "hardly", "heavily", "highly", "honestly", "immediately", "increasingly", "initially", "jointly", "kindly", "largely", "lately", "likely", "literally", "lonely", "mainly", "merely", "mostly", "nearly", "necessarily", "newly", "normally", "obviously", "occasionally", "originally", "partially", "particularly", "perfectly", "personally", "physically", "poorly", "possibly", "precisely", "presently", "presumably", "previously", "primarily", "probably", "properly", "publicly", "quickly", "quietly", "rarely", "readily", "really", "recently", "relatively", "repeatedly", "reportedly", "roughly", "routinely", "sadly", "scarcely", "seemingly", "separately", "seriously", "severely", "shortly", "significantly", "similarly", "simply", "slightly", "slowly", "smoothly", "solely", "specifically", "steadily", "strictly", "strongly", "suddenly", "sufficiently", "supposedly", "surely", "tightly", "totally", "truly", "typically", "ultimately", "undoubtedly", "unfortunately", "unlikely", "usually", "virtually", "widely", "willingly"},
    XX = {"box", "fox", "fix", "mix", "six", "tax", "wax", "axe", "hex", "jinx", "lynx", "max", "next", "ox", "relax", "remix", "sex", "sixty", "text", "vex", "annex", "apex", "complex", "crux", "duplex", "flex", "flux", "helix", "hoax", "ibex", "index", "latex", "matrix", "onyx", "paradox", "phoenix", "prefix", "reflex", "sphinx", "suffix", "syntax", "thorax", "vertex", "vortex", "xerox"},
    POP = {"pop", "pops", "popcorn", "popcorns", "pope", "popes", "poplar", "poplars", "poppy", "poppies", "popular", "popularly", "popularity", "popularize", "popularized", "popularizing", "populate", "populated", "populates", "populating", "population", "populations", "populist", "populists", "populism", "populous", "popup", "popups", "popover", "popovers", "popinjay", "popinjays", "popish", "popishly", "popliteal", "poplin", "poplins", "popsicle", "popsicles", "populace", "populaces", "poppyseed", "poppyseeds", "popgun", "popguns", "popery", "poperies", "popedom", "popedoms"},
    EO = {"eon", "eons", "eonian", "eonism", "eonisms", "eolithic", "eosin", "eosinophil", "eosinophils", "eosinophilia", "eosinophilic", "eohippus", "eohippuses", "eolian", "eolic", "eolienne", "eolipile", "eolipiles", "eolithic", "eolopile", "eolopiles", "eos", "eosate", "eosates", "eosin", "eosins", "eosine", "eosines", "eosinic", "eosinophil", "eosinophilic", "eosinophilia", "eosinophilias", "eosinopenic", "eosinopenias", "eosinopenic", "eosinopenia"}
}

local hardModeCategorias = {"Y", "W", "LY", "XX", "POP", "EO"}

--Github words
local WORDS_BASE_URL = "https://raw.githubusercontent.com/Dayvinksthik/Script/main/words/"

local palavrasENExtra = {}
local extraLoadedLetters = {}
local extraLoadFailed = {}

local function loadExtraWords(prefixo)
    local letter = tostring(prefixo or ""):sub(1, 1):upper()
    if not letter:match("^[A-Z]$") then
        return
    end
    if extraLoadedLetters[letter] or extraLoadFailed[letter] then
        return
    end

    local ok, data = pcall(function()
        local source = game:HttpGet(WORDS_BASE_URL .. letter .. ".lua")
        return loadstring(source)()
    end)

    if ok and type(data) == "table" then
        for key, words in pairs(data) do
            palavrasENExtra[key] = words
        end
        extraLoadedLetters[letter] = true
    else
        extraLoadFailed[letter] = true
        warn("[KoalaHub] Failed to load word list for " .. letter)
    end
end


local palavrasInvalidas = {}
local palavrasUsadasNoJogo = {}
local palavrasValidas = {}
local ultimaPalavraTentada = nil

-- Smart selection:
-- SAFE = reliability first
-- SMART = reliability + look-ahead
-- AGGRESSIVE = prioritize difficult follow-up positions
local strategyMode = "SMART"
local lookAhead = true
local stats = {played = 0, accepted = 0, rejected = 0, misses = 0}

local function countFollowUps(word)
    local pfx = tostring(word):upper()
    if #pfx > 3 then pfx = pfx:sub(-3) end
    local seen, count = {}, 0
    for _, langTable in ipairs({palavrasEN, palavrasPT, palavrasES}) do
        if type(langTable) == "table" then
            for _, bucket in pairs(langTable) do
                if type(bucket) == "table" then
                    for _, p in pairs(bucket) do
                        local pu = tostring(p):upper()
                        if not seen[pu] and pu:sub(1, #pfx) == pfx
                            and #pu > #pfx and pu:match("^[A-Z]+$")
                            and not palavrasInvalidas[pu]
                            and not palavrasUsadasNoJogo[pu] then
                            seen[pu] = true
                            count = count + 1
                            if count >= 80 then return count end
                        end
                    end
                end
            end
        end
    end
    return count
end

local function scoreWord(word, base, totalCandidates)
    local pu = tostring(word):upper()
    if palavrasInvalidas[pu] or palavrasUsadasNoJogo[pu] then
        return -math.huge
    end

    local score = 0
    local extra = math.max(0, #pu - #base)

    if palavrasValidas[pu] then score = score + 140 end
    score = score + math.max(0, 30 - extra * 3)
    score = score + math.min(totalCandidates or 0, 20) * 0.4

    if strategyMode == "SAFE" then
        score = score + (palavrasValidas[pu] and 80 or 0) - extra * 4
    elseif strategyMode == "AGGRESSIVE" then
        if lookAhead then
            score = score + math.max(0, 60 - countFollowUps(pu) * 2)
        end
    else
        if lookAhead then
            score = score + math.max(0, 42 - countFollowUps(pu) * 1.25)
        end
    end

    return score
end

local function rankCandidates(candidates, base)
    local ranked = {}
    for _, word in ipairs(candidates) do
        ranked[#ranked + 1] = {word = word, score = scoreWord(word, base, #candidates)}
    end
    table.sort(ranked, function(a, b)
        if a.score == b.score then
            return tostring(a.word):lower() < tostring(b.word):lower()
        end
        return a.score > b.score
    end)
    return ranked
end


local coreGui = game:GetService("CoreGui") or game:GetService("StarterGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KoalaHubAutoType"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 50
screenGui.Parent = coreGui

local scriptAtivo = true
local PADDING = 10

local COLORS = {
    bg = Color3.fromRGB(8, 9, 14),
    panel = Color3.fromRGB(13, 15, 22),
    card = Color3.fromRGB(18, 20, 29),
    card2 = Color3.fromRGB(22, 24, 35),
    border = Color3.fromRGB(43, 46, 62),
    purple = Color3.fromRGB(132, 67, 255),
    purple2 = Color3.fromRGB(92, 42, 190),
    purpleSoft = Color3.fromRGB(175, 130, 255),
    text = Color3.fromRGB(235, 235, 245),
    muted = Color3.fromRGB(145, 148, 166),
    green = Color3.fromRGB(57, 225, 119),
    red = Color3.fromRGB(255, 83, 103),
    yellow = Color3.fromRGB(255, 191, 71),
    blue = Color3.fromRGB(77, 176, 255),
}

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function gradient(obj, colorA, colorB, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    g.Rotation = rotation or 0
    g.Parent = obj
    return g
end

local function label(parent, text, size, pos, font, textSize, color)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or COLORS.text
    l.Font = font or Enum.Font.Gotham
    l.TextSize = math.floor((textSize or 10) * 1.30 + 0.5)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function button(parent, text, size, pos, bg, color, textSize)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = bg or COLORS.card2
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = color or COLORS.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = math.floor((textSize or 9) * 1.30 + 0.5)
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 7)
    return b
end

local function card(parent, size, pos)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = COLORS.card
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 10)
    gradient(f, COLORS.card, COLORS.card2, 90)
    stroke(f, COLORS.border, 1, 0.15)
    return f
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "KoalaHubWindow"
mainFrame.Size = UDim2.new(0, 780, 0, 500)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

--uiscale
local GUI_SCALE = 0.70
local uiScale = Instance.new("UIScale")
uiScale.Scale = GUI_SCALE

mainFrame.BackgroundColor3 = COLORS.bg
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
uiScale.Parent = mainFrame

-- Floating KoalaHub button: hide/show the main GUI.
local floatingToggle = Instance.new("TextButton")
floatingToggle.Name = "KoalaHubToggle"
floatingToggle.Size = UDim2.new(0, 54, 0, 54)
floatingToggle.AnchorPoint = Vector2.new(0, 0.5)
floatingToggle.Position = UDim2.new(0, 14, 0.5, 0)
floatingToggle.BackgroundColor3 = COLORS.purple2
floatingToggle.Text = "K"
floatingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingToggle.Font = Enum.Font.GothamBlack
floatingToggle.TextSize = 21
floatingToggle.AutoButtonColor = false
floatingToggle.ZIndex = 100
floatingToggle.Parent = screenGui
corner(floatingToggle, 27)
stroke(floatingToggle, COLORS.purpleSoft, 1.5, 0.05)

local TweenService = game:GetService("TweenService")

local floatingVisible = true
local toggleBusy = false

local function setMainGuiVisible(visible)
    if toggleBusy or floatingVisible == visible then return end
    toggleBusy = true
    floatingVisible = visible

    if visible then
        mainFrame.Visible = true
        uiScale.Scale = GUI_SCALE * 0.92
        floatingToggle.BackgroundColor3 = COLORS.purple2
        floatingToggle.TextColor3 = Color3.fromRGB(255,255,255)

        local tween = TweenService:Create(
            uiScale,
            TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Scale = GUI_SCALE}
        )
        tween:Play()
        tween.Completed:Wait()
    else
        local tween = TweenService:Create(
            uiScale,
            TweenInfo.new(0.13, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Scale = GUI_SCALE * 0.92}
        )
        tween:Play()
        tween.Completed:Wait()

        mainFrame.Visible = false
        uiScale.Scale = GUI_SCALE
        floatingToggle.BackgroundColor3 = COLORS.card2
        floatingToggle.TextColor3 = COLORS.purpleSoft
    end

    toggleBusy = false
end

-- Activated works with mouse, touch, and controller.
floatingToggle.Activated:Connect(function()
    setMainGuiVisible(not floatingVisible)
end)

floatingToggle.MouseEnter:Connect(function()
    TweenService:Create(
        floatingToggle,
        TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 57, 0, 57)}
    ):Play()
end)

floatingToggle.MouseLeave:Connect(function()
    TweenService:Create(
        floatingToggle,
        TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 54, 0, 54)}
    ):Play()
end)

corner(mainFrame, 14)
mainFrame.BackgroundColor3 = COLORS.bg
local outerStroke = stroke(mainFrame, COLORS.purple, 1.5, 0.12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = COLORS.bg
titleBar.BorderSizePixel = 0
titleBar.BackgroundColor3 = COLORS.bg
titleBar.Parent = mainFrame
corner(titleBar, 14)

local titleAccent = Instance.new("Frame")
titleAccent.Size = UDim2.new(1, -24, 0, 2)
titleAccent.Position = UDim2.new(0, 12, 1, -3)
titleAccent.BackgroundColor3 = COLORS.purple
titleAccent.BorderSizePixel = 0
titleAccent.Parent = titleBar
corner(titleAccent, 2)

local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 28, 0, 28)
logo.Position = UDim2.new(0, 12, 0, 7)
logo.BackgroundColor3 = COLORS.purple2
logo.Parent = titleBar
corner(logo, 10)
local logoText = label(logo, "K", UDim2.new(1,0,1,0), UDim2.new(), Enum.Font.GothamBlack, 15, Color3.fromRGB(255,255,255))
logoText.TextXAlignment = Enum.TextXAlignment.Center

local titleLabel = label(titleBar, "Koala", UDim2.new(0, 65, 0, 22), UDim2.new(0, 48, 0, 4), Enum.Font.GothamBlack, 17, COLORS.text)
local titlePurple = label(titleBar, "Hub", UDim2.new(0, 45, 0, 22), UDim2.new(0, 108, 0, 4), Enum.Font.GothamBlack, 17, COLORS.purpleSoft)
local subtitle = label(titleBar, "Finish The Word", UDim2.new(0, 140, 0, 15), UDim2.new(0, 49, 0, 23), Enum.Font.Gotham, 8, COLORS.muted)

local minimizeBtn = button(titleBar, "−", UDim2.new(0, 26, 0, 24), UDim2.new(1, -62, 0, 9), COLORS.card2, COLORS.muted, 15)
local closeBtn = button(titleBar, "×", UDim2.new(0, 26, 0, 24), UDim2.new(1, -31, 0, 9), Color3.fromRGB(70, 24, 35), COLORS.red, 15)

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -12, 1, -50)
contentContainer.Position = UDim2.new(0, 6, 0, 46)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 154, 1, 0)
sidebar.BackgroundColor3 = COLORS.panel
sidebar.BorderSizePixel = 0
sidebar.Parent = contentContainer
corner(sidebar, 11)
stroke(sidebar, COLORS.border, 1, 0.25)

label(sidebar, "NAVIGATION", UDim2.new(1, -24, 0, 20), UDim2.new(0, 12, 0, 12), Enum.Font.GothamBold, 8, COLORS.muted)

local pages = {}
local navButtons = {}
local navY = 40

local function makeNav(name, glyph)
    local b = button(sidebar, glyph .. "  " .. name, UDim2.new(1, -16, 0, 34), UDim2.new(0, 8, 0, navY), COLORS.panel, COLORS.muted, 9)
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "   " .. glyph .. "  " .. name
    corner(b, 9)
    local indicator = Instance.new("Frame")
    indicator.Name = "ActiveIndicator"
    indicator.Size = UDim2.new(0, 3, 0, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.BackgroundColor3 = COLORS.purpleSoft
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = b
    corner(indicator, 2)
    b:SetAttribute("HasIndicator", true)
    navY = navY + 39
    navButtons[name] = b
    return b
end

local mainNav = makeNav("Main", "◆")
local suggestionsNav = makeNav("Suggestions", "✦")
local statsNav = makeNav("Stats", "▥")
local learnedNav = makeNav("Learned Words", "◇")
local settingsNav = makeNav("Settings", "⚙")
local aboutNav = makeNav("About", "ⓘ")

local gameStatus = card(sidebar, UDim2.new(1, -16, 0, 62), UDim2.new(0, 8, 1, -72))
local sideDot = Instance.new("Frame")
sideDot.Size = UDim2.new(0, 8, 0, 8)
sideDot.Position = UDim2.new(0, 10, 0, 12)
sideDot.BackgroundColor3 = COLORS.green
sideDot.Parent = gameStatus
corner(sideDot, 5)
label(gameStatus, "GAME STATUS", UDim2.new(1, -32, 0, 14), UDim2.new(0, 25, 0, 5), Enum.Font.GothamBold, 7, COLORS.muted)
local gameStatusLabel = label(gameStatus, "Finish The Word", UDim2.new(1, -16, 0, 16), UDim2.new(0, 10, 0, 25), Enum.Font.GothamBold, 9, COLORS.text)

local pagesFrame = Instance.new("Frame")
pagesFrame.Size = UDim2.new(1, -164, 1, 0)
pagesFrame.Position = UDim2.new(0, 164, 0, 0)
pagesFrame.BackgroundTransparency = 1
pagesFrame.Parent = contentContainer

local function makePage(name)
    local p = Instance.new("Frame")
    p.Name = name .. "Page"
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = pagesFrame
    pages[name] = p
    return p
end

local mainPage = makePage("Main")
local suggestionsPage = makePage("Suggestions")
local statsPage = makePage("Stats")
local learnedPage = makePage("LearnedWords")
local settingsPage = makePage("Settings")
local aboutPage = makePage("About")

local pageTitle = {}
for name, page in pairs(pages) do
    pageTitle[name] = label(page, name == "LearnedWords" and "Learned Words" or name, UDim2.new(1, -20, 0, 28), UDim2.new(0, 8, 0, 2), Enum.Font.GothamBlack, 16, COLORS.purpleSoft)
end

local function activateNav(name)
    for key, b in pairs(navButtons) do
        local active = key == name
        b.BackgroundColor3 = active and COLORS.purple2 or COLORS.panel
        b.TextColor3 = active and COLORS.text or COLORS.muted
        local indicator = b:FindFirstChild("ActiveIndicator")
        if indicator then indicator.Visible = active end
    end
    for key, page in pairs(pages) do
        page.Visible = key == name
    end
end

mainNav.MouseButton1Click:Connect(function() activateNav("Main") end)
suggestionsNav.MouseButton1Click:Connect(function() activateNav("Suggestions") end)
statsNav.MouseButton1Click:Connect(function() activateNav("Stats") end)
learnedNav.MouseButton1Click:Connect(function() activateNav("LearnedWords") end)
settingsNav.MouseButton1Click:Connect(function() activateNav("Settings") end)
aboutNav.MouseButton1Click:Connect(function() activateNav("About") end)

-- MAIN PAGE
local prefixCard = card(mainPage, UDim2.new(1, -16, 0, 112), UDim2.new(0, 8, 0, 36))
label(prefixCard, "CURRENT PREFIX", UDim2.new(0.45, 0, 0, 18), UDim2.new(0, 18, 0, 13), Enum.Font.GothamBold, 8, COLORS.muted)
local prefixValue = label(prefixCard, "-", UDim2.new(0.45, 0, 0, 42), UDim2.new(0, 18, 0, 31), Enum.Font.GothamBlack, 31, COLORS.text)
prefixValue.TextXAlignment = Enum.TextXAlignment.Center
label(prefixCard, "YOUR TURN", UDim2.new(0.45, 0, 0, 18), UDim2.new(0.52, 0, 0, 13), Enum.Font.GothamBold, 8, COLORS.muted)
local targetValue = label(prefixCard, "Waiting...", UDim2.new(0.45, 0, 0, 36), UDim2.new(0.52, 0, 0, 34), Enum.Font.GothamBlack, 20, COLORS.purpleSoft)
targetValue.TextXAlignment = Enum.TextXAlignment.Center
local progressBack = Instance.new("Frame")
progressBack.Size = UDim2.new(1, -36, 0, 5)
progressBack.Position = UDim2.new(0, 18, 1, -20)
progressBack.BackgroundColor3 = COLORS.card2
progressBack.Parent = prefixCard
corner(progressBack, 3)
local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0.35, 0, 1, 0)
progressFill.BackgroundColor3 = COLORS.purple
progressFill.Parent = progressBack
corner(progressFill, 3)

local controlCard = card(mainPage, UDim2.new(0.62, -10, 0, 212), UDim2.new(0, 8, 0, 158))
label(controlCard, "CONTROL PANEL", UDim2.new(1, -24, 0, 20), UDim2.new(0, 12, 0, 10), Enum.Font.GothamBlack, 10, COLORS.purpleSoft)

local autoLabel = label(controlCard, "AUTO TYPE", UDim2.new(0, 85, 0, 16), UDim2.new(0, 12, 0, 42), Enum.Font.GothamBold, 8, COLORS.text)
local autoTypeToggle = button(controlCard, "AUTO", UDim2.new(0, 84, 0, 28), UDim2.new(0, 12, 0, 63), COLORS.purple2, COLORS.text, 9)

local strategyLabel = label(controlCard, "STRATEGY", UDim2.new(0, 85, 0, 16), UDim2.new(0, 112, 0, 42), Enum.Font.GothamBold, 8, COLORS.text)
local strategyToggle = button(controlCard, "SMART  ▾", UDim2.new(0, 112, 0, 28), UDim2.new(0, 112, 0, 63), COLORS.card2, COLORS.purpleSoft, 9)

local function createSwitch(parent, x, y, title, enabled)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0.29, -4, 0, 42)
    c.Position = UDim2.new(x, 0, 0, y)
    c.BackgroundColor3 = COLORS.card2
    c.Parent = parent
    corner(c, 8)
    stroke(c, COLORS.border, 1, 0.2)
    local t = label(c, title, UDim2.new(1, -44, 1, 0), UDim2.new(0, 9, 0, 0), Enum.Font.GothamBold, 7, COLORS.text)
    t.TextWrapped = true
    local s = button(c, enabled and "ON" or "OFF", UDim2.new(0, 30, 0, 20), UDim2.new(1, -38, 0.5, -10), enabled and Color3.fromRGB(35,80,52) or COLORS.card, enabled and COLORS.green or COLORS.muted, 7)
    return c, s, t
end

local _, lookToggle = createSwitch(controlCard, 0.02, 105, "LOOK AHEAD", lookAhead)
local _, hardToggleBtn = createSwitch(controlCard, 0.35, 105, "HARD MODE", true)
local _, fastToggleBtn = createSwitch(controlCard, 0.68, 105, "FAST TYPING", false)
local _, missToggle = createSwitch(controlCard, 0.02, 153, "RANDOM MISSES", false)
local _, safeToggleBtn = createSwitch(controlCard, 0.35, 153, "SAFE MODE", true)
local powerToggle = button(controlCard, "POWER  ON", UDim2.new(0.29, -4, 0, 42), UDim2.new(0.68, 0, 0, 153), Color3.fromRGB(28, 74, 48), COLORS.green, 8)

local rightPanel = card(mainPage, UDim2.new(0.38, -6, 0, 212), UDim2.new(0.62, 0, 0, 158))
label(rightPanel, "SESSION INFO", UDim2.new(1, -24, 0, 20), UDim2.new(0, 12, 0, 10), Enum.Font.GothamBlack, 10, COLORS.purpleSoft)

local function info(parent, y, name, value, color)
    label(parent, name, UDim2.new(0.58, 0, 0, 18), UDim2.new(0, 12, 0, y), Enum.Font.Gotham, 8, COLORS.muted)
    return label(parent, value, UDim2.new(0.35, 0, 0, 18), UDim2.new(0.62, 0, 0, y), Enum.Font.GothamBold, 9, color or COLORS.text)
end

local detIdioma = info(rightPanel, 39, "Language", "EN", COLORS.green)
local detPalavras = info(rightPanel, 66, "Available", "0")
local detMesa = info(rightPanel, 93, "Table", "-")
local detPalavra = info(rightPanel, 120, "Prefix", "-")
detPalavra.TextColor3 = COLORS.purpleSoft
local detUsadas = info(rightPanel, 147, "Used Words", "0")
local detErros = info(rightPanel, 174, "Strikes", "0", COLORS.red)

local statusFrame = card(mainPage, UDim2.new(1, -16, 0, 72), UDim2.new(0, 8, 1, -80))
local greenDot = Instance.new("Frame")
greenDot.Size = UDim2.new(0, 10, 0, 10)
greenDot.Position = UDim2.new(0, 14, 0, 18)
greenDot.BackgroundColor3 = COLORS.green
greenDot.Parent = statusFrame
corner(greenDot, 5)
label(statusFrame, "AUTO TYPE STATUS", UDim2.new(0, 150, 0, 15), UDim2.new(0, 32, 0, 8), Enum.Font.GothamBold, 7, COLORS.muted)
local statusLabel = label(statusFrame, "Ready — waiting for your turn...", UDim2.new(0.52, 0, 0, 20), UDim2.new(0, 32, 0, 28), Enum.Font.GothamBold, 9, COLORS.text)
local knownValidLabel = label(statusFrame, "KNOWN VALID  0", UDim2.new(0, 105, 0, 18), UDim2.new(0.60, 0, 0, 18), Enum.Font.GothamBold, 7, COLORS.green)
local knownInvalidLabel = label(statusFrame, "INVALID  0", UDim2.new(0, 85, 0, 18), UDim2.new(0.78, 0, 0, 18), Enum.Font.GothamBold, 7, COLORS.red)

-- Suggestions page
local suggestionSortMode = "SHORTEST"

local suggestionsInfo = label(suggestionsPage, "Valid unused words • rejected/used words are hidden • ranked by the active strategy", UDim2.new(1, -20, 0, 22), UDim2.new(0, 8, 0, 34), Enum.Font.Gotham, 8, COLORS.muted)
local suggestionLabel = label(suggestionsPage, "Waiting for a prefix...", UDim2.new(0.60, 0, 0, 20), UDim2.new(0, 8, 0, 58), Enum.Font.GothamBold, 9, COLORS.text)

local suggestionSortBtn = button(suggestionsPage, "MODE: SHORTEST", UDim2.new(0.35, -8, 0, 24), UDim2.new(0.63, 0, 0, 56), COLORS.card2, COLORS.green, 8)

local updateSuggestions -- forward reference

suggestionSortBtn.MouseButton1Click:Connect(function()
    if suggestionSortMode == "SHORTEST" then
        suggestionSortMode = "LONGEST"
        suggestionSortBtn.Text = "MODE: LONGEST"
        suggestionSortBtn.TextColor3 = COLORS.purpleSoft
    else
        suggestionSortMode = "SHORTEST"
        suggestionSortBtn.Text = "MODE: SHORTEST"
        suggestionSortBtn.TextColor3 = COLORS.green
    end
    if updateSuggestions then
        pcall(function() updateSuggestions(ultimaBase or "", palavrasTentadas or {}) end)
    end
end)

local suggestionScroll = Instance.new("ScrollingFrame")
suggestionScroll.Size = UDim2.new(1, -16, 1, -88)
suggestionScroll.Position = UDim2.new(0, 8, 0, 86)
suggestionScroll.BackgroundTransparency = 1
suggestionScroll.BorderSizePixel = 0
suggestionScroll.ScrollBarThickness = 4
suggestionScroll.ScrollBarImageColor3 = COLORS.purpleSoft
suggestionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
suggestionScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
suggestionScroll.Parent = suggestionsPage

local suggestionGrid = Instance.new("UIGridLayout")
suggestionGrid.CellSize = UDim2.new(0.49, -2, 0, 30)
suggestionGrid.CellPadding = UDim2.new(0, 4, 0, 4)
suggestionGrid.SortOrder = Enum.SortOrder.LayoutOrder
suggestionGrid.Parent = suggestionScroll

local suggestionButtons = {}

-- Stats page
local statCards = {}
local statData = {
    {"WORDS PLAYED", "0", COLORS.text},
    {"ACCEPTED", "0", COLORS.green},
    {"REJECTED", "0", COLORS.red},
    {"RANDOM MISSES", "0", COLORS.yellow},
}
for i, data in ipairs(statData) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    local c = card(statsPage, UDim2.new(0.49, -4, 0, 82), UDim2.new(col == 0 and 0 or 0.51, 0, 0, 38 + row * 94))
    label(c, data[1], UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 9), Enum.Font.GothamBold, 7, COLORS.muted)
    statCards[data[1]] = label(c, data[2], UDim2.new(1, -20, 0, 38), UDim2.new(0, 10, 0, 29), Enum.Font.GothamBlack, 22, data[3])
end
local statsHint = label(statsPage, "Statistics are tracked for the current session/game.", UDim2.new(1, -20, 0, 20), UDim2.new(0, 8, 1, -34), Enum.Font.Gotham, 8, COLORS.muted)

-- Learned words page
local knownCard = card(learnedPage, UDim2.new(0.49, -4, 0, 120), UDim2.new(0, 8, 0, 42))
label(knownCard, "KNOWN VALID", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 10), Enum.Font.GothamBold, 8, COLORS.green)
local knownCount = label(knownCard, "0", UDim2.new(1, -20, 0, 45), UDim2.new(0, 10, 0, 34), Enum.Font.GothamBlack, 28, COLORS.green)
local invalidCard = card(learnedPage, UDim2.new(0.49, -4, 0, 120), UDim2.new(0.51, 0, 0, 42))
label(invalidCard, "KNOWN INVALID", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 10), Enum.Font.GothamBold, 8, COLORS.red)
local invalidCount = label(invalidCard, "0", UDim2.new(1, -20, 0, 45), UDim2.new(0, 10, 0, 34), Enum.Font.GothamBlack, 28, COLORS.red)
local learnedHint = label(learnedPage, "Accepted words are promoted; rejected words are blocked for the current game.", UDim2.new(1, -20, 0, 36), UDim2.new(0, 8, 0, 174), Enum.Font.Gotham, 8, COLORS.muted)
learnedHint.TextWrapped = true

-- Settings page
local settingsCard = card(settingsPage, UDim2.new(1, -16, 0, 240), UDim2.new(0, 8, 0, 38))
label(settingsCard, "AUTOMATION", UDim2.new(1, -20, 0, 20), UDim2.new(0, 12, 0, 10), Enum.Font.GothamBlack, 9, COLORS.purpleSoft)
label(settingsCard, "Strategy", UDim2.new(0, 120, 0, 25), UDim2.new(0, 12, 0, 45), Enum.Font.GothamBold, 9, COLORS.text)
local settingsStrategy = button(settingsCard, "SMART", UDim2.new(0, 140, 0, 30), UDim2.new(0, 145, 0, 42), COLORS.card2, COLORS.purpleSoft, 9)
label(settingsCard, "Look Ahead", UDim2.new(0, 120, 0, 25), UDim2.new(0, 12, 0, 88), Enum.Font.GothamBold, 9, COLORS.text)
local settingsLook = button(settingsCard, "ON", UDim2.new(0, 70, 0, 30), UDim2.new(0, 145, 0, 85), Color3.fromRGB(35,80,52), COLORS.green, 8)
label(settingsCard, "Random Misses", UDim2.new(0, 120, 0, 25), UDim2.new(0, 12, 0, 131), Enum.Font.GothamBold, 9, COLORS.text)
local settingsMiss = button(settingsCard, "OFF", UDim2.new(0, 70, 0, 30), UDim2.new(0, 145, 0, 128), COLORS.card2, COLORS.muted, 8)
label(settingsCard, "Language", UDim2.new(0, 120, 0, 25), UDim2.new(0, 12, 0, 174), Enum.Font.GothamBold, 9, COLORS.text)
local settingsLanguage = button(settingsCard, "AUTO", UDim2.new(0, 140, 0, 30), UDim2.new(0, 145, 0, 171), COLORS.card2, COLORS.text, 8)

-- About page
local aboutCard = card(aboutPage, UDim2.new(1, -16, 0, 250), UDim2.new(0, 8, 0, 38))
local aboutLogo = Instance.new("Frame")
aboutLogo.Size = UDim2.new(0, 56, 0, 56)
aboutLogo.Position = UDim2.new(0, 16, 0, 18)
aboutLogo.BackgroundColor3 = COLORS.purple2
aboutLogo.Parent = aboutCard
corner(aboutLogo, 18)
local aboutK = label(aboutLogo, "K", UDim2.new(1,0,1,0), UDim2.new(), Enum.Font.GothamBlack, 28, COLORS.text)
aboutK.TextXAlignment = Enum.TextXAlignment.Center
label(aboutCard, "KoalaHub", UDim2.new(1, -100, 0, 28), UDim2.new(0, 88, 0, 20), Enum.Font.GothamBlack, 19, COLORS.text)
label(aboutCard, "Finish The Word", UDim2.new(1, -100, 0, 20), UDim2.new(0, 88, 0, 48), Enum.Font.Gotham, 9, COLORS.purpleSoft)
label(aboutCard, "Original KoalaHub interface", UDim2.new(1, -32, 0, 22), UDim2.new(0, 16, 0, 100), Enum.Font.GothamBold, 9, COLORS.text)
local aboutText = label(aboutCard, "Smart word ranking, learned validity, look-ahead analysis, multilingual dictionaries, and a dedicated Suggestions workspace.", UDim2.new(1, -32, 0, 65), UDim2.new(0, 16, 0, 128), Enum.Font.Gotham, 8, COLORS.muted)
aboutText.TextWrapped = true

-- Controls / state
local botAtivo = true
local autoType = true
local randomMisses = false
local hardMode = true
local safeMode = true
local fastMode = false

local function updateSwitch(btn, enabled, onText, offText)
    btn.Text = enabled and (onText or "ON") or (offText or "OFF")
    btn.BackgroundColor3 = enabled and Color3.fromRGB(35, 80, 52) or COLORS.card
    btn.TextColor3 = enabled and COLORS.green or COLORS.muted
end

powerToggle.MouseButton1Click:Connect(function()
    botAtivo = not botAtivo
    powerToggle.Text = botAtivo and "POWER  ON" or "POWER  OFF"
    powerToggle.BackgroundColor3 = botAtivo and Color3.fromRGB(28,74,48) or Color3.fromRGB(70,28,38)
    powerToggle.TextColor3 = botAtivo and COLORS.green or COLORS.red
    sideDot.BackgroundColor3 = botAtivo and COLORS.green or COLORS.red
    greenDot.BackgroundColor3 = botAtivo and COLORS.green or COLORS.red
end)

autoTypeToggle.MouseButton1Click:Connect(function()
    autoType = not autoType
    autoTypeToggle.Text = autoType and "AUTO" or "MANUAL"
    autoTypeToggle.BackgroundColor3 = autoType and COLORS.purple2 or Color3.fromRGB(75,60,34)
    autoTypeToggle.TextColor3 = autoType and COLORS.text or COLORS.yellow
end)

local function cycleStrategy()
    strategyMode = strategyMode == "SAFE" and "SMART" or strategyMode == "SMART" and "AGGRESSIVE" or "SAFE"
    strategyToggle.Text = strategyMode .. "  ▾"
    settingsStrategy.Text = strategyMode
    local c = strategyMode == "SAFE" and COLORS.green or strategyMode == "SMART" and COLORS.purpleSoft or COLORS.yellow
    strategyToggle.TextColor3 = c
    settingsStrategy.TextColor3 = c
end
strategyToggle.MouseButton1Click:Connect(cycleStrategy)
settingsStrategy.MouseButton1Click:Connect(cycleStrategy)

lookToggle.MouseButton1Click:Connect(function()
    lookAhead = not lookAhead
    updateSwitch(lookToggle, lookAhead, "ON", "OFF")
    updateSwitch(settingsLook, lookAhead, "ON", "OFF")
end)
settingsLook.MouseButton1Click:Connect(function()
    lookAhead = not lookAhead
    updateSwitch(lookToggle, lookAhead, "ON", "OFF")
    updateSwitch(settingsLook, lookAhead, "ON", "OFF")
end)

missToggle.MouseButton1Click:Connect(function()
    randomMisses = not randomMisses
    updateSwitch(missToggle, randomMisses, "ON", "OFF")
    updateSwitch(settingsMiss, randomMisses, "ON", "OFF")
end)
settingsMiss.MouseButton1Click:Connect(function()
    randomMisses = not randomMisses
    updateSwitch(missToggle, randomMisses, "ON", "OFF")
    updateSwitch(settingsMiss, randomMisses, "ON", "OFF")
end)

hardToggleBtn.MouseButton1Click:Connect(function()
    hardMode = not hardMode
    updateSwitch(hardToggleBtn, hardMode, "ON", "OFF")
end)
safeToggleBtn.MouseButton1Click:Connect(function()
    safeMode = not safeMode
    updateSwitch(safeToggleBtn, safeMode, "ON", "OFF")
end)
fastToggleBtn.MouseButton1Click:Connect(function()
    fastMode = not fastMode
    updateSwitch(fastToggleBtn, fastMode, "ON", "OFF")
end)

-- Keep settings language informational; actual language remains auto-detected by the game.
settingsLanguage.MouseButton1Click:Connect(function()
    settingsLanguage.Text = detIdioma.Text or "EN"
end)

local isMinimized = false
local originalSize = mainFrame.Size
local minimizedSize = UDim2.new(0, 300, 0, 42)
local animating = false

local function animateSize(size)
    if animating then return end
    animating = true
    local tw = TweenService:Create(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = size})
    tw:Play()
    tw.Completed:Wait()
    animating = false
end

minimizeBtn.MouseButton1Click:Connect(function()
    if animating then return end
    isMinimized = not isMinimized
    if isMinimized then
        contentContainer.Visible = false
        animateSize(minimizedSize)
        minimizeBtn.Text = "+"
    else
        animateSize(originalSize)
        contentContainer.Visible = true
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    scriptAtivo = false
    screenGui:Destroy()
end)

-- Dragging
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging
        and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

activateNav("Main")


local function detectarIdioma()
    local locale = nil
    pcall(function() locale = player.LocaleId end)
    if locale then
        locale = locale:lower()
        if locale:find("pt") then return "PT-BR", palavrasPT end
        if locale:find("es") then return "ES", palavrasES end
    end
    return "EN", palavrasEN
end

local idioma, palavrasCategoria = detectarIdioma()

-- Words rejected by the game are learned as invalid for the current session.
local function encontrarPalavras(prefixo, tentadas, allowExternal)
    allowExternal = allowExternal == true
    local candidatas = {}
    local primeiraLetra = prefixo:sub(1, 1):upper()
    local duasLetras = prefixo:sub(1, 2):upper()
    local tresLetras = prefixo:sub(1, 3):upper()
    
    if hardMode then
        local categoriasEmbaralhadas = {}
        for _, cat in ipairs(hardModeCategorias) do
            table.insert(categoriasEmbaralhadas, cat)
        end
        for i = #categoriasEmbaralhadas, 2, -1 do
            local j = math.random(i)
            categoriasEmbaralhadas[i], categoriasEmbaralhadas[j] = categoriasEmbaralhadas[j], categoriasEmbaralhadas[i]
        end
        
        for _, categoria in ipairs(categoriasEmbaralhadas) do
            local listaPalavras = palavrasHardMode[categoria]
            if listaPalavras then
                for _, p in pairs(listaPalavras) do
                    local pu = p:upper()
                    if pu:sub(1, #prefixo) == prefixo and #pu > #prefixo and pu:match("^[A-Z]+$") and not tentadas[pu] and not palavrasInvalidas[pu] and not palavrasUsadasNoJogo[pu] then
                        table.insert(candidatas, p)
                    end
                end
            end
        end
    end
    
    if #candidatas == 0 and palavrasCategoria["COMPLETAS"] then
        for _, p in pairs(palavrasCategoria["COMPLETAS"]) do
            local pu = p:upper()
            if pu:sub(1, #prefixo) == prefixo and #pu > #prefixo and pu:match("^[A-Z]+$") and not tentadas[pu] and not palavrasInvalidas[pu] and not palavrasUsadasNoJogo[pu] then
                table.insert(candidatas, p)
            end
        end
    end
    
    if #candidatas == 0 and palavrasCategoria["CURTAS"] then
        for _, p in pairs(palavrasCategoria["CURTAS"]) do
            local pu = p:upper()
            if pu:sub(1, #prefixo) == prefixo and #pu > #prefixo and pu:match("^[A-Z]+$") and not tentadas[pu] and not palavrasInvalidas[pu] and not palavrasUsadasNoJogo[pu] then
                table.insert(candidatas, p)
            end
        end
    end
    if allowExternal and (idioma == "EN" or #candidatas == 0) then
        loadExtraWords(prefixo)
        -- For single-letter prefixes, iterate all 26 two-letter buckets that start with that letter
        local bucketsToSearch = {}
        if #prefixo == 1 then
            for _, ch in ipairs({"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}) do
                table.insert(bucketsToSearch, prefixo:upper() .. ch)
            end
        else
            table.insert(bucketsToSearch, prefixo:sub(1, 2):upper())
        end
        for _, bucketKey in ipairs(bucketsToSearch) do
            local bucket = palavrasENExtra[bucketKey]
            if bucket then
                for _, p in ipairs(bucket) do
                    local pu = tostring(p):upper()
                    if pu:sub(1, #prefixo) == prefixo
                        and #pu > #prefixo
                        and pu:match("^[A-Z]+$")
                        and not tentadas[pu]
                        and not palavrasInvalidas[pu]
                        and not palavrasUsadasNoJogo[pu] then
                        table.insert(candidatas, p)
                    end
                end
            end
        end
    end

    -- Final safety filter shared by Auto Type and Suggestions.
    local unicas = {}
    local seen = {}
    for _, p in pairs(candidatas) do
        local pu = p:upper()
        if not seen[pu] and not tentadas[pu] and not palavrasInvalidas[pu] and not palavrasUsadasNoJogo[pu] then
            seen[pu] = true
            table.insert(unicas, p)
        end
    end
    
    return unicas
end

-- Helper: clear all children (except UIGridLayout) from a scroll panel
local function clearScroll(scroll)
    for _, child in ipairs(scroll:GetChildren()) do
        if not child:IsA("UIGridLayout") and not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

-- Forward declaration so addWordBtn click handler can reference digitarResto
local digitarResto

-- Helper: add a word button to a scroll panel
local function addWordBtn(scroll, word, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = COLORS.card
    btn.TextColor3 = COLORS.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Text = word:upper()
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.AutoButtonColor = true
    local cor = Instance.new("UICorner")
    cor.CornerRadius = UDim.new(0, 5)
    cor.Parent = btn
    btn.Parent = scroll
    -- Click to type the word in manual mode
    btn.MouseButton1Click:Connect(function()
        if not autoType then
            local resto = word:upper():sub(#(ultimaBase or "") + 1)
            if #resto > 0 then
                pcall(function() digitarResto(word, ultimaBase or "") end)
            end
        end
    end)
    return btn
end

updateSuggestions = function(prefix, tentadas)
    clearScroll(suggestionScroll)
    if not prefix or prefix == "" then
        suggestionLabel.Text = "Waiting for a prefix..."
        return
    end

    local candidates = encontrarPalavras(prefix:upper(), tentadas or {}, true)

    if #candidates == 0 then
        suggestionLabel.Text = "Suggestions • none"
        return
    end

    local sorted = {}
    for _, c in ipairs(candidates) do table.insert(sorted, c) end
    table.sort(sorted, function(a, b)
        if suggestionSortMode == "SHORTEST" then
            if #a ~= #b then return #a < #b end
        else
            if #a ~= #b then return #a > #b end
        end
        return a:lower() < b:lower()
    end)

    local total = #sorted
    local MAX_TOTAL = 300

    suggestionLabel.Text = "Suggestions • " .. total .. " words (" .. suggestionSortMode .. ")"

    for i, w in ipairs(sorted) do
        if i > MAX_TOTAL then break end
        addWordBtn(suggestionScroll, w, i)
    end
end

local function getPlayerAttributes()
    local inGame, isTurn = nil, nil
    pcall(function() inGame = player:GetAttribute("InGame") end)
    pcall(function() isTurn = player:GetAttribute("IsTurn") end)
    return inGame, isTurn
end

local function findMyTable(mesaNumero)
    if not mesaNumero then return nil, nil end
    local metaFolder = workspace:FindFirstChild("Meta")
    if not metaFolder then return nil, nil end
    local tables = metaFolder:FindFirstChild("Tables")
    if not tables then return nil, nil end
    for _, model in pairs(tables:GetChildren()) do
        if model:IsA("Model") and model.Name == tostring(mesaNumero) then
            local tableModel = model:FindFirstChild("Table")
            if tableModel then
                local matchDisplay = tableModel:FindFirstChild("MatchDisplay")
                if matchDisplay then return matchDisplay, model.Name end
            end
        end
    end
    return nil, nil
end

local function getPrefixo(matchDisplay)
    if not matchDisplay then return nil end
    local category = matchDisplay:FindFirstChild("Category")
    if category and category:IsA("TextLabel") then
        local texto = category.Text:upper():gsub("%s+", "")
        if texto ~= "" and #texto <= 10 then return texto end
    end
    return nil
end

local function getPalavraDoPet(matchDisplay, temHydra)
    if not matchDisplay then return "", 0 end
    local answerInput = matchDisplay:FindFirstChild("AnswerInput")
    if not answerInput then
        for _, child in pairs(matchDisplay:GetDescendants()) do
            if child.Name == "AnswerInput" then answerInput = child; break end
        end
    end
    if not answerInput then return "", 0 end
    local keys = answerInput:FindFirstChild("Keys")
    if not keys then return "", 0 end
    local count = 0; local letras = ""
    for _, key in pairs(keys:GetChildren()) do
        if key:IsA("TextButton") or key:IsA("ImageButton") or key:IsA("GuiButton") or key:IsA("Frame") then
            count = count + 1
            local keyText = key:FindFirstChildWhichIsA("TextLabel")
            if keyText and keyText.Text ~= "" then letras = letras .. keyText.Text end
        end
    end
    if count >= 1 and letras ~= "" then return letras:upper(), count end
    return "", 0
end

local function temPetHydraNaMesa(mesaNumero)
    if not mesaNumero then return false end
    local metaFolder = workspace:FindFirstChild("Meta")
    if not metaFolder then return false end
    local tables = metaFolder:FindFirstChild("Tables")
    if not tables then return false end
    for _, model in pairs(tables:GetChildren()) do
        if model:IsA("Model") and model.Name == tostring(mesaNumero) then
            local matchPets = model:FindFirstChild("MatchPets")
            if matchPets then
                for _, playerFolder in pairs(matchPets:GetChildren()) do
                    if playerFolder:IsA("Folder") or playerFolder:IsA("Model") then
                        local pet = playerFolder:FindFirstChild("Pet")
                        if pet and pet:IsA("Model") and pet:GetAttribute("Hydra") then return true end
                    end
                end
            end
            break
        end
    end
    return false
end

local function getStrikesErradas()
    local erros = 0
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return 0 end
    
    local screen = playerGui:FindFirstChild("ScreenGui") or playerGui:FindFirstChild("screenGui")
    if not screen then
        for _, child in pairs(playerGui:GetChildren()) do
            if child:IsA("ScreenGui") and (child:FindFirstChild("BottomBar") or child:FindFirstChild("CenterBar")) then
                screen = child
                break
            end
        end
    end
    
    if not screen then return 0 end
    
    local bottomBar = screen:FindFirstChild("BottomBar")
    if not bottomBar then return 0 end
    
    local centerBar = bottomBar:FindFirstChild("CenterBar")
    if not centerBar then return 0 end
    
    local strikes = centerBar:FindFirstChild("Strikes")
    if not strikes then return 0 end
    
    for i = 1, 5 do
        local strike = strikes:FindFirstChild(tostring(i))
        if strike and strike:IsA("ImageLabel") then
            local textLabel = strike:FindFirstChildWhichIsA("TextLabel")
            if textLabel then
                local color = textLabel.TextColor3
                if math.abs(color.R * 255 - 230) <= 10 and math.abs(color.G * 255 - 76) <= 10 and math.abs(color.B * 255 - 96) <= 10 then
                    erros = erros + 1
                end
            end
        end
    end
    
    return erros
end

local function getFastSpeedMultiplier()
    local speeds = {0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8}
    return speeds[math.random(1, #speeds)]
end

local function apagarLetras(qtd)
    if qtd <= 0 then return end
    
    local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0
    
    local delayBackspace = fastMode and (0.06 * speedMultiplier) or 0.04
    local delayBetween = fastMode and (0.04 * speedMultiplier) or 0.03
    local delayAfter = fastMode and (0.08 * speedMultiplier) or 0.1
    
    for i = 1, qtd do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backspace, false, nil)
        task.wait(delayBackspace)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backspace, false, nil)
        task.wait(delayBetween)
    end
    task.wait(delayAfter)
end

digitarResto = function(palavra, base)
    local resto = palavra:sub(#base + 1)
    
    local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0
    
    local delayEnterBefore = fastMode and (0.15 * speedMultiplier) or 0.25
    local delayEnterAfter = fastMode and (0.08 * speedMultiplier) or 0.10
    local delayKeyDown = fastMode and (0.08 * speedMultiplier) or 0.10
    local delayKeyUp = fastMode and (0.06 * speedMultiplier) or 0.08
    local delayRandomMin = fastMode and (0.04 * speedMultiplier) or 0.04
    local delayRandomMax = fastMode and (0.06 * speedMultiplier) or 0.06
    local delayAfterEnter = fastMode and (0.12 * speedMultiplier) or 0.25
    
    if resto == "" then
        task.wait(delayEnterBefore)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
        task.wait(delayEnterAfter)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
        return 0
    end
    for letra in resto:gmatch(".") do
        local keyCode = Enum.KeyCode[letra:upper()]
        if keyCode then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, nil)
            task.wait(delayKeyDown + math.random() * delayRandomMin)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, nil)
            task.wait(delayKeyUp + math.random() * delayRandomMax)
        end
    end
    task.wait(delayAfterEnter)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
    task.wait(delayEnterAfter)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
    return #resto
end

local verificando = false
local tempoEnvio = 0
local tentativas = 0
local MAX_TENTATIVAS = 5
local TEMPO_VERIFICACAO = 1.2
local TEMPO_TOTAL = 14
local inicioRodada = 0
local ultimaBase = ""
local qtdLetrasDigitadas = 0
local temHydra = false
local errosAnteriores = 0
local semPalavras = false
local escolhaJaFeita = false
local ultimoTempoChoice = 0

local palavrasTentadas = {}

local function registrarPalavraDoJogo(baseAnterior, baseAtual)
    if not baseAnterior or baseAnterior == "" or not baseAtual or baseAtual == "" then
        return
    end

    local anterior = tostring(baseAnterior):upper():gsub("%s+", "")
    local atual = tostring(baseAtual):upper():gsub("%s+", "")

    -- If the new turn/prefix extends the previous prefix (O -> OXYGEN),
    -- the longer value is the word the opponent just submitted.
    if #atual > #anterior and atual:sub(1, #anterior) == anterior
        and atual:match("^[A-Z]+$") then
        palavrasUsadasNoJogo[atual] = true
    end
end

local function atualizarInterface(statusMsg, idiomaStr, palavrasCount, mesaStr, baseStr)
    if not botAtivo then
        statusLabel.Text = "PAUSED - Click ON to resume"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        greenDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    statusLabel.Text = statusMsg
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    greenDot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    detIdioma.Text = idiomaStr
    detPalavras.Text = tostring(palavrasCount)
    detMesa.Text = mesaStr
    detPalavra.Text = baseStr
    
    local usadas = {}
    for word in pairs(palavrasTentadas) do usadas[word] = true end
    for word in pairs(palavrasUsadasNoJogo) do usadas[word] = true end

    local usadasCount = 0
    for _ in pairs(usadas) do
        usadasCount = usadasCount + 1
    end
    detUsadas.Text = tostring(usadasCount)
    detErros.Text = tostring(getStrikesErradas())
    prefixValue.Text = baseStr ~= "" and baseStr or "-"
    targetValue.Text = ultimaPalavraTentada and ultimaPalavraTentada:lower() or "Waiting..."
    local validN, invalidN = 0, 0
    for _ in pairs(palavrasValidas) do validN = validN + 1 end
    for _ in pairs(palavrasInvalidas) do invalidN = invalidN + 1 end
    knownCount.Text = tostring(validN)
    invalidCount.Text = tostring(invalidN)
    knownValidLabel.Text = "KNOWN VALID  " .. tostring(validN)
    knownInvalidLabel.Text = "INVALID  " .. tostring(invalidN)
    statCards["WORDS PLAYED"].Text = tostring(stats.played)
    statCards["ACCEPTED"].Text = tostring(stats.accepted)
    statCards["REJECTED"].Text = tostring(stats.rejected)
    statCards["RANDOM MISSES"].Text = tostring(stats.misses)
    suggestionsInfo.Text = "Valid unused words • rejected/used words hidden • " .. strategyMode .. " ranking • Look:" .. (lookAhead and "ON" or "OFF")
    updateSuggestions(baseStr, palavrasTentadas)
end

local function tentarPalavra(baseAgora, tempoRestante)
    local candidatas = encontrarPalavras(baseAgora, palavrasTentadas, false)
    
    if #candidatas > 0 then
        semPalavras = false

        -- Optional random miss: intentionally skip a small percentage of turns.
        if autoType and randomMisses and math.random() < RANDOM_MISS_CHANCE then
            stats.misses = stats.misses + 1
            atualizarInterface("Random miss...", idioma, #candidatas, detMesa.Text, baseAgora)
            local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0
            task.wait((fastMode and 0.06 or 0.08) * speedMultiplier)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
            task.wait((fastMode and 0.04 or 0.08) * speedMultiplier)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
            tempoEnvio = os.clock()
            qtdLetrasDigitadas = 0
            return true
        end

        local ranked = rankCandidates(candidatas, baseAgora)
        if #ranked == 0 then return false end

        -- Smart word selection: prefer words that are more likely to be valid
        -- Check if the word's 2-letter prefix exists in the GitHub dictionary
        local bestChoice = nil
        local bestScore = -math.huge
        
        for i, choice in ipairs(ranked) do
            local palavra = choice.word:upper()
            local prefix2 = palavra:sub(1, 2):upper()
            local prefix3 = palavra:sub(1, 3):upper()
            
            -- Check if this word's prefix has good coverage in GitHub dictionary
            local githubCoverage = 0
            if palavrasENExtra[prefix2] then
                githubCoverage = githubCoverage + #palavrasENExtra[prefix2]
            end
            if palavrasENExtra[prefix3] then
                githubCoverage = githubCoverage + #palavrasENExtra[prefix3]
            end
            
            -- Boost score for words with good GitHub coverage
            local adjustedScore = choice.score + (githubCoverage * 0.1)
            
            if adjustedScore > bestScore then
                bestScore = adjustedScore
                bestChoice = choice
            end
        end
        
        local choice = bestChoice or ranked[1]
        
        -- Tiny variation only when the top choices are effectively tied.
        if #ranked >= 2 and math.abs(bestScore - (ranked[2].score + (palavrasENExtra[ranked[2].word:sub(1, 2):upper()] and #palavrasENExtra[ranked[2].word:sub(1, 2):upper()] * 0.1 or 0))) < 3 then
            choice = ranked[math.random(1, 2)]
        end

        local palavra = choice.word
        ultimaPalavraTentada = palavra:upper()
        palavrasTentadas[palavra:upper()] = true
        palavrasUsadasNoJogo[palavra:upper()] = true
        stats.played = stats.played + 1
        
        atualizarInterface((autoType and "Trying: " or "Manual: ") .. palavra:upper() .. " (" .. string.format("%.1f", tempoRestante) .. "s)", idioma, #candidatas, detMesa.Text, baseAgora)

        if autoType then
            qtdLetrasDigitadas = digitarResto(palavra, baseAgora)
            tempoEnvio = os.clock()
        else
            qtdLetrasDigitadas = 0
            tempoEnvio = os.clock()
        end
        return true
    else
        if not semPalavras then
            semPalavras = true
            atualizarInterface("No words left! Skipping...", idioma, 0, detMesa.Text, baseAgora)
            
            if not autoType then
                return false
            end

            local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0
            local delayEnterBefore = fastMode and (0.06 * speedMultiplier) or 0.08
            local delayEnterAfter = fastMode and (0.04 * speedMultiplier) or 0.08
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
            task.wait(delayEnterBefore)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
            task.wait(delayEnterAfter)
            
            qtdLetrasDigitadas = 0
            tempoEnvio = os.clock()
        end
        return false
    end
end

spawn(function()
    while scriptAtivo do
        if botAtivo and autoType then
            local agora = os.clock()
            local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0
            local choiceDelay = fastMode and (1.5 * speedMultiplier) or 1.5
            
            if agora - ultimoTempoChoice > choiceDelay then
                ultimoTempoChoice = agora
                
                local fezEscolha = false
                pcall(function()
                    fezEscolha = autoEscolherLetraSmart(ultimaBase)
                end)
                
                if fezEscolha then
                    escolhaJaFeita = true
                    task.wait(fastMode and (0.4 * speedMultiplier) or 0.5)
                end
            end
        end
        task.wait(fastMode and 0.15 or 0.3)
    end
end)

local ultimoPrefixo = ""
local ultimaPalavraDigitada = ""

local function loopTick()
    local inGame, isTurn = getPlayerAttributes()

    if not botAtivo then
        atualizarInterface("PAUSED - Click ON to resume", idioma, 0, "-", "0")
        verificando = false
        tentativas = 0
        escolhaJaFeita = false
        return
    end

    if not inGame then
        atualizarInterface("Not in game", idioma, 0, "-", "0")
        verificando = false
        tentativas = 0
        palavrasTentadas = {}
        palavrasInvalidas = {}
        palavrasUsadasNoJogo = {}
        palavrasValidas = {}
        ultimaPalavraTentada = nil
        stats = {played = 0, accepted = 0, rejected = 0, misses = 0}
        semPalavras = false
        errosAnteriores = 0
        ultimaBase = ""
        ultimoPrefixo = ""
        ultimaPalavraDigitada = ""
        escolhaJaFeita = false
        return
    end

    if autoType and not escolhaJaFeita then
        local fezEscolha = false
        pcall(function()
            fezEscolha = autoEscolherLetraSmart(ultimaBase)
        end)
        if fezEscolha then
            escolhaJaFeita = true
            local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0
            task.wait(fastMode and (0.4 * speedMultiplier) or 0.5)
        end
    end

    local matchDisplay, mesaNumero = findMyTable(inGame)

    if matchDisplay then
        temHydra = temPetHydraNaMesa(inGame)
        local prefixo = getPrefixo(matchDisplay)
        local palavraPet = getPalavraDoPet(matchDisplay, temHydra)

        if prefixo then
            if prefixo ~= ultimoPrefixo then
                if ultimoPrefixo ~= "" and ultimaPalavraDigitada ~= "" and #ultimaPalavraDigitada > #ultimoPrefixo then
                    palavrasUsadasNoJogo[ultimaPalavraDigitada:upper()] = true
                end
                ultimoPrefixo = prefixo
                ultimaPalavraDigitada = ""
            end
            if palavraPet ~= "" and palavraPet:sub(1, #prefixo) == prefixo then
                ultimaPalavraDigitada = palavraPet
            end
        else
            ultimoPrefixo = ""
            ultimaPalavraDigitada = ""
        end

        local baseAgora = ""
        local speedMultiplier = fastMode and getFastSpeedMultiplier() or 1.0

        if palavraPet ~= "" then
            baseAgora = palavraPet
            TEMPO_VERIFICACAO = fastMode and (1.5 * speedMultiplier) or 1.5
        elseif prefixo then
            baseAgora = prefixo
            TEMPO_VERIFICACAO = fastMode and (1.2 * speedMultiplier) or 1.2
        end

        local palavrasCount = 0
        if baseAgora ~= "" then
            local candidatasTemp = encontrarPalavras(baseAgora, palavrasTentadas, false)
            palavrasCount = #candidatasTemp
        end

        if baseAgora ~= "" then
            if baseAgora ~= ultimaBase then
                ultimaBase = baseAgora
                tentativas = 0
                verificando = false
                semPalavras = false
                errosAnteriores = getStrikesErradas()
                inicioRodada = os.clock()
                escolhaJaFeita = false
            end

            local tempoRestante = TEMPO_TOTAL - (os.clock() - inicioRodada)
            if tempoRestante < 0 then tempoRestante = 0 end

            local errosAtuais = getStrikesErradas()

            if errosAtuais > errosAnteriores then
                errosAnteriores = errosAtuais
                if ultimaPalavraTentada then
                    palavrasInvalidas[ultimaPalavraTentada] = true
                    palavrasValidas[ultimaPalavraTentada] = nil
                    stats.rejected = stats.rejected + 1
                end
                if verificando then
                    apagarLetras(qtdLetrasDigitadas)
                    tentativas = tentativas + 1

                    if safeMode and errosAtuais >= 4 then
                        atualizarInterface("SAFE MODE: 4 errors! Waiting...", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                        verificando = false
                    elseif tentativas > MAX_TENTATIVAS or tempoRestante <= 0 or semPalavras then
                        atualizarInterface("Max attempts!", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                        verificando = false
                    else
                        tentarPalavra(baseAgora, tempoRestante)
                        verificando = true
                    end
                end
            end

            if safeMode and errosAtuais >= 4 then
                atualizarInterface("SAFE MODE: 4 errors! Waiting...", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                verificando = false
                return
            end

            MAX_TENTATIVAS = safeMode and (4 - errosAtuais) or 5
            if MAX_TENTATIVAS <= 0 then MAX_TENTATIVAS = 1 end

            if isTurn or verificando then
                if not autoType then
                    atualizarInterface("Manual mode - choose a suggestion", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                    verificando = false
                    tentativas = 0
                elseif verificando then
                    local tempoPassado = os.clock() - tempoEnvio

                    if tempoPassado > TEMPO_VERIFICACAO then
                        local _, aindaTurno = getPlayerAttributes()

                        if aindaTurno and not semPalavras then
                            apagarLetras(qtdLetrasDigitadas)
                            tentativas = tentativas + 1

                            errosAtuais = getStrikesErradas()
                            errosAnteriores = errosAtuais

                            if safeMode and errosAtuais >= 4 then
                                atualizarInterface("SAFE MODE: 4 errors! Waiting...", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                                verificando = false
                            elseif tentativas > MAX_TENTATIVAS or tempoRestante <= 0 or semPalavras then
                                atualizarInterface("Max attempts!", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                                verificando = false
                            else
                                tentarPalavra(baseAgora, tempoRestante)
                                verificando = true
                            end
                        elseif aindaTurno and semPalavras then
                            verificando = false
                        else
                            if ultimaPalavraTentada then
                                palavrasValidas[ultimaPalavraTentada] = true
                            end
                            stats.accepted = stats.accepted + 1
                            atualizarInterface("Accepted! ✓", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                            verificando = false
                            tentativas = 0
                            semPalavras = false
                            errosAnteriores = getStrikesErradas()
                        end
                    end
                else
                    tentativas = 1
                    inicioRodada = os.clock()
                    semPalavras = false
                    errosAnteriores = getStrikesErradas()

                    atualizarInterface("Thinking...", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                    local delayInicialMin = fastMode and (0.5 * speedMultiplier) or 0.5
                    local delayInicialMax = fastMode and (0.8 * speedMultiplier) or 0.8
                    local delayInicial = delayInicialMin + math.random() * delayInicialMax
                    task.wait(delayInicial)

                    if tentarPalavra(baseAgora, TEMPO_TOTAL) then
                        verificando = true
                    else
                        verificando = true
                    end
                end
            else
                atualizarInterface("Waiting for your turn...", idioma, palavrasCount, mesaNumero or "-", baseAgora)
                verificando = false
                tentativas = 0
                semPalavras = false
                errosAnteriores = getStrikesErradas()
            end
        else
            atualizarInterface("Waiting for letters...", idioma, 0, mesaNumero or "-", "0")
            verificando = false
        end
    else
        atualizarInterface("Searching table " .. tostring(inGame) .. "...", idioma, 0, "-", "0")
        verificando = false
    end
end

while scriptAtivo do
    pcall(loopTick)
    task.wait(fastMode and 0.1 or 0.1)
end
