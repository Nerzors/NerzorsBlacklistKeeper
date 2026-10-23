local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ptBR", {

    ["Remembered"]                   = "Favorito",

    ["Add to Remember Me"]           = "Adicionar aos Favoritos",
    ["Edit Remember Me entry"]       = "Editar favorito",
    ["Remove from Remember Me"]      = "Remover dos Favoritos",
    ["Remove %s-%s from Remember Me?"] = "Remover %s-%s dos Favoritos?",

    ["Rating"]                       = "Avaliação",
    ["Default rating"]               = "Avaliação padrão",
    ["%d ★"]                         = "%d ★",

    ["Show in unit tooltips"]        = "Mostrar nas dicas",
    ["Prompt after Mythic+ runs"]    = "Perguntar após masmorras Míticas+",
    ["Clear Remember Me..."]         = "Limpar Favoritos...",
    ["Clear all %d Remember Me entries?"] = "Apagar todos os %d favoritos?",
    ["Cleared %d Remember Me entries."]   = "Favoritos apagados: %d.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Ainda não há entradas: conclua uma masmorra Mítica+ para lembrar dos seus colegas de grupo.",

    ["Mythic+ run finished"]         = "Masmorra Mítica+ concluída",
    ["%s +%d - %s"]                  = "%s +%d - %s",
    ["timed"]                        = "no tempo",
    ["depleted"]                     = "fora do tempo",
    ["Rate your party-mates"]        = "Avalie seus colegas de grupo",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]   = "%s-%s está na lista negra. Remover da lista negra?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]   = "%s-%s está nos Favoritos. Remover dos Favoritos?",

    ["Added %s-%s to Remember Me."]  = "%s-%s adicionado aos Favoritos.",
    ["Removed %s-%s from Remember Me."] = "%s-%s removido dos Favoritos.",

    ["invalid name/realm"]           = "nome/reino inválido",
})
