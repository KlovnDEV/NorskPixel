
Config = {}

Config.RestrictedChannels = {
  [482] = {
    police = true
  },
  [470] = {
    ambulance = true
  },
  [858] = {
    police = true,
    ambulance = true
  }
} 

Config.MaxFrequency = 500

Config.messages = {
  ['not_on_radio'] = 'Du er ikke koblet til en kanal',
  ['on_radio'] = 'Du er allerede koblet til kanalen',
  ['joined_to_radio'] = 'Du er koblet til: ',
  ['restricted_channel_error'] = 'Du kan ikke kobles til frekvensen!',
  ['invalid_radio'] = 'Denne frekvens er ikke ledig',
  ['you_on_radio'] = 'Du er allerede koblet til kanalen',
  ['you_leave'] = 'Du forlod kanalen.',
  ['volume_radio'] = 'Ny lydstyrke ',
  ['decrease_radio_volume'] = 'Radio lydstyrken er allerede satt på maks',
  ['increase_radio_volume'] = 'Radio lydstyrken kan ikke være lavere',
  ['increase_decrease_radio_channel'] = 'Ny kanal ',
}
