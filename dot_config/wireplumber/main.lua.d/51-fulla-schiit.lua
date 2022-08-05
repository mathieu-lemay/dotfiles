table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.*Fulla_Schiit*" },
    },
  },
  apply_properties = {
    ["audio.format"]         = "S24LE",
    ["audio.rate"]           = 96000,
    ["api.alsa.headroom"]    = 1024,
    ["node.pause-on-idle"]   = false,
  },
})

-- FIXME: This is not applied as it should
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "device.name", "matches", "alsa_card.*Fulla_Schiit*" },
    },
  },
  apply_properties = {
    ["device.profile"] = "output:iec958-stereo+input:iec958-stereo",
  },
})
