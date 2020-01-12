
wifi.setmode(wifi.SOFTAP)
cfg={}
cfg.ssid="myssid"
cfg.pwd="mypassword"
wifi.ap.config(cfg)

wifi.setmaxtxpower(60)

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
    print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
end)

dofile('audio.lc')
dofile('server.lc')
dofile('servo.lc')
dofile('ai.lc')

head_pin = 4

gpio.mode(head_pin, gpio.INT)
gpio.trig(head_pin, "down", ai_head_detected)
