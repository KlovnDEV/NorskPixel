config = {}

-- How much ofter the player position is updated ?
config.RefreshTime = 100

-- default sound format for interact
config.interact_sound_file = "ogg"

-- is emulator enabled ?
config.interact_sound_enable = false

-- how much close player has to be to the sound before starting updating position ?
config.distanceBeforeUpdatingPos = 40

-- Message list
config.Messages = {
    ["streamer_on"]  = "Streamer mode er skrudd på. Du vil ikke kunne høre musikken.",
    ["streamer_off"] = "Streamer mode er skrudd av. Du vil nå kunne høre andres musikk.",

    ["no_permission"] = "Du kan ikke bruke denne kommandoen, du har ikke permission til det!",
}

-- Addon list
-- True/False enabled/disabled
config.AddonList = {
    crewPhone = false,
}