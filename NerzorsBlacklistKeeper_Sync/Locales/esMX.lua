local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("esMX", {

    ["Enable sharing (send & receive)"]      = "Activar compartir (enviar y recibir)",
    ["Accept shares from"]                   = "Aceptar listas de",
    ["anyone"]                               = "cualquiera",
    ["guild"]                                = "hermandad",
    ["friends"]                              = "amigos",
    ["nobody"]                               = "nadie",
    ["Auto-open import preview on receive"]  = "Abrir la vista previa automáticamente al recibir",
    ["Announce in chat when sharing"]        = "Anunciar en el chat al compartir",
    ["New entries shareable by default"]     = "Entradas nuevas compartibles por defecto",
    ["Export only shareable entries"]        = "Exportar solo entradas compartibles",
    ["Debug (verbose send/receive log)"]     = "Depuración (registro detallado de envío/recepción)",
    ["Share with"]                           = "Compartir con",
    ["name[-realm]"]                         = "nombre[-reino]",
    ["Whisper"]                              = "Susurrar",
    ["Guild"]                                = "Hermandad",

    ["%d shareable entries exported."]       = "Entradas compartibles exportadas: %d.",
    ["%d private entries held back."]        = "Entradas privadas retenidas: %d.",
    ["Shared %d entries with %s."]           = "%d entradas compartidas con %s.",
    ["Skipped %d oversized entries."]        = "Entradas demasiado grandes omitidas: %d.",
    ["%s shared %d blacklist entries."]      = "%s compartió %d entradas de la lista negra.",
    ["%s sent an empty share."]              = "%s envió una lista vacía.",
    ["Use /nbk share show to review."]       = "Usa /nbk share show para revisarla.",
    ["from %s"]                              = "de %s",

    ["share via whisper"]                    = "compartir por susurro",
    ["broadcast to guild"]                   = "enviar a la hermandad",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Consejo: los susurros entre accesorios requieren que el destinatario esté conectado y que haya un contacto reciente (amigo / miembro de la hermandad / grupo / susurro reciente). Si no le llega nada, envíale primero un susurro normal o usa el canal de hermandad.",

    ["Auto-Sync"]                            = "Auto-Sync",
    ["Auto-Sync new blacklist entries"]      = "Compartir automáticamente las entradas nuevas",
    ["Send to"]                              = "Enviar a",
    ["Friends"]                              = "Amigos",
    ["Specific characters"]                  = "Personajes concretos",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Marca los personajes que deben recibir automáticamente las entradas nuevas (Nombre-Reino).",
    ["Name-Realm"]                           = "Nombre-Reino",

    ["Auto-Sync blacklist push"]             = "Auto-Sync: entrada de la lista negra",
    ["%s wants to share an entry:"]          = "%s quiere compartir una entrada:",
    ["%s auto-shared %s-%s."]                = "%s compartió automáticamente a %s-%s.",
    ["Reason: %s"]                           = "Motivo: %s",
    ["Decline"]                              = "Rechazar",
    ["From"]                                 = "De",
    ["%s shared %d entries (%s)."]           = "%s compartió %d entradas (%s).",

    ["missing target"]                       = "falta el destinatario",
    ["not in a guild"]                       = "no estás en una hermandad",
    ["not in a group"]                       = "no estás en un grupo",
    ["sync disabled"]                        = "compartir está desactivado",
    ["no shareable entries (all marked private)"] = "no hay entradas compartibles (todas privadas)",
    ["list is empty"]                        = "la lista está vacía",
    ["no pending share"]                     = "no hay ninguna lista pendiente",
})
