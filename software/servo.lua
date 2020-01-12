spi.setup(1, spi.MASTER, spi.CPOL_HIGH, spi.CPHA_HIGH, 24, 2048)
-- we won't be using the HSPI /CS line, so disable it again
gpio.mode(8, gpio.INPUT, gpio.PULLUP)

write_servos = function(val1, val2)
    print('sending: ' .. val1 .. ' ; ' .. val2)
    spi.send(1, 0xff * 65536 + val1 * 256 + val2) -- Set servo 1 to 32, servo 2 to 5
end

stop_animating = false

stop_animation = function()
    stop_animating = true
end

dumb_animation = function()
    stop_animating = false
    write_servos(34, 34)
    if stop_animating ~= true then
        tmr.create():alarm(200, tmr.ALARM_SINGLE, function()
            write_servos(20, 20)
            if stop_animating ~= true then
                tmr.create():alarm(250, tmr.ALARM_SINGLE, function()
                    write_servos(40, 40)
                    if stop_animating ~= true then
                        tmr.create():alarm(150, tmr.ALARM_SINGLE, function()
                            write_servos(70, 70)
                            if stop_animating ~= true then
                                tmr.create():alarm(150, tmr.ALARM_SINGLE, function()
                                    if stop_animating ~= true then
                                        dumb_animation()
                                    end
                                end)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end