local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("enUS", {

    ["Sharing"]                                         = true,
    ["Enable sharing (send & receive)"]                 = true,
    ["Accept shares from"]                              = true,
    ["anyone"]                                          = true,
    ["guild"]                                           = true,
    ["friends"]                                         = true,
    ["nobody"]                                          = true,
    ["Auto-open import preview on receive"]             = true,
    ["Announce in chat when sharing"]                   = true,
    ["New entries shareable by default"]                = true,
    ["Export only shareable entries"]                   = true,
    ["Debug (verbose send/receive log)"]                = true,
    ["Share with"]                                      = true,
    ["name[-realm]"]                                    = true,
    ["Whisper"]                                         = true,
    ["Guild"]                                           = true,

    ["%d shareable entries exported."]                  = true,
    ["%d private entries held back."]                   = true,
    ["Shared %d entries with %s."]                      = true,
    ["Skipped %d oversized entries."]                   = true,
    ["%s shared %d blacklist entries."]                 = true,
    ["%s sent an empty share."]                         = true,
    ["Use /nbk share show to review."]                  = true,
    ["from %s"]                                         = true,

    ["share via whisper"]                               = true,
    ["broadcast to guild"]                              = true,

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."] = true,

    ["Auto-Sync blacklist push"]                        = true,
    ["%s wants to share an entry:"]                     = true,
    ["%s auto-shared %s-%s."]                           = true,
    ["Reason: %s"]                                      = true,
    ["no reason logged"]                                = true,
    ["Add to blacklist"]                                = true,
    ["Decline"]                                         = true,
    ["From"]                                            = true,
    ["Reason"]                                          = true,
    ["Note"]                                            = true,
    ["%s shared %d entries (%s)."]                      = true,
}, true)
