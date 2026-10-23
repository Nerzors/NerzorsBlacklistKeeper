local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ptBR", {

    ["Enable sharing (send & receive)"]      = "Ativar compartilhamento (enviar e receber)",
    ["Accept shares from"]                   = "Aceitar compartilhamentos de",
    ["anyone"]                               = "qualquer um",
    ["guild"]                                = "guilda",
    ["friends"]                              = "amigos",
    ["nobody"]                               = "ninguém",
    ["Auto-open import preview on receive"]  = "Abrir a prévia automaticamente ao receber",
    ["Announce in chat when sharing"]        = "Anunciar no bate-papo ao compartilhar",
    ["New entries shareable by default"]     = "Novas entradas compartilháveis por padrão",
    ["Export only shareable entries"]        = "Exportar somente entradas compartilháveis",
    ["Debug (verbose send/receive log)"]     = "Depuração (registro detalhado de envio/recebimento)",
    ["Share with"]                           = "Compartilhar com",
    ["name[-realm]"]                         = "nome[-reino]",
    ["Whisper"]                              = "Sussurrar",
    ["Guild"]                                = "Guilda",

    ["%d shareable entries exported."]       = "Entradas compartilháveis exportadas: %d.",
    ["%d private entries held back."]        = "Entradas privadas retidas: %d.",
    ["Shared %d entries with %s."]           = "%d entradas compartilhadas com %s.",
    ["Skipped %d oversized entries."]        = "Entradas grandes demais ignoradas: %d.",
    ["%s shared %d blacklist entries."]      = "%s compartilhou %d entradas da lista negra.",
    ["%s sent an empty share."]              = "%s enviou um compartilhamento vazio.",
    ["Use /nbk share show to review."]       = "Use /nbk share show para revisar.",
    ["from %s"]                              = "de %s",

    ["share via whisper"]                    = "compartilhar por sussurro",
    ["broadcast to guild"]                   = "enviar para a guilda",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Dica: sussurros de AddOn exigem que o destinatário esteja online e que haja um contato recente (amigo / membro da guilda / grupo / sussurro recente). Se nada chegar, envie primeiro um sussurro normal ou use o canal da guilda.",

    ["Auto-Sync"]                            = "Auto-Sync",
    ["Auto-Sync new blacklist entries"]      = "Compartilhar automaticamente novas entradas da lista negra",
    ["Send to"]                              = "Enviar para",
    ["Friends"]                              = "Amigos",
    ["Specific characters"]                  = "Personagens específicos",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Marque os personagens que devem receber as novas entradas automaticamente (Nome-Reino).",
    ["Name-Realm"]                           = "Nome-Reino",

    ["Auto-Sync blacklist push"]             = "Auto-Sync: entrada da lista negra",
    ["%s wants to share an entry:"]          = "%s quer compartilhar uma entrada:",
    ["%s auto-shared %s-%s."]                = "%s compartilhou %s-%s automaticamente.",
    ["Reason: %s"]                           = "Motivo: %s",
    ["Decline"]                              = "Recusar",
    ["From"]                                 = "De",
    ["%s shared %d entries (%s)."]           = "%s compartilhou %d entradas (%s).",

    ["missing target"]                       = "destinatário ausente",
    ["not in a guild"]                       = "você não está em uma guilda",
    ["not in a group"]                       = "você não está em um grupo",
    ["sync disabled"]                        = "compartilhamento desativado",
    ["no shareable entries (all marked private)"] = "nenhuma entrada compartilhável (todas privadas)",
    ["list is empty"]                        = "a lista está vazia",
    ["no pending share"]                     = "nenhum compartilhamento pendente",
})
