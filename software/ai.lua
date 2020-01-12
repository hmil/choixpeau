

ai_houses = { 'griffondor_1', 'serpentar_1', 'serdaigle_1', 'pouffsoufle_1' }

ai_speech_count = 6
ai_speech_counter = 1

ai_next_outcome = nil
ai_next_speech = nil
ai_detector_enabled = true
ai_animation_enabled = true

ai_step = 0
ai_is_running = false

ai_last_trigger_time = 0

-- Throtle between end of one choice and beginning of next choice
AI_TRIGGER_THROTTLE = 3000000

-- Sets the next choice to a predetermined outcome
ai_set_next_outcome = function(house)
    ai_next_outcome = house
end

ai_get_next_outcome = function()
    return ai_next_outcome
end

-- Sets the next choice to a random outcome
ai_set_random_outcome = function()
    ai_next_outcome = nil
end

ai_set_next_speech = function(speech)
    ai_next_speech = speech
end

ai_get_next_speech = function()
    return ai_next_speech
end

ai_set_random_speech = function()
    ai_next_speech = nil
end

-- Called when a head has been detected
ai_head_detected = function()
    if ai_detector_enabled then
        now = tmr.now()
        if now - ai_last_trigger_time > AI_TRIGGER_THROTTLE then
            _ai_start()
        end
    else
        print('detector is disabled')
    end
end

ai_enable_detector = function()
    ai_detector_enabled = true
end

ai_disable_detector = function()
    ai_detector_enabled = false
end

ai_get_detector_enabled = function()
    return ai_detector_enabled
end

ai_enable_animation = function()
    ai_animation_enabled = true
end

ai_disable_animation = function()
    ai_animation_enabled = false
end

ai_get_animation_enabled = function()
    return ai_animation_enabled
end

-- Manually trigger a choice cycle (when the head detector is not working)
ai_manual_trigger = function()
    _ai_start(true)
end

_ai_start = function(skip_delay)
    if ai_is_running then
        print("choice already started")
        return
    end
    ai_is_running = true
    node.setcpufreq(node.CPU160MHZ)
    ai_step = 1
    if skip_delay == true then
        _ai_do_step()
    else
        tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
            if gpio.read(4) then
                _ai_do_step()
            else
                _ai_stop()
                print('head was removed')
            end
        end)
    end
end

_ai_stop = function()
    ai_is_running = false
    node.setcpufreq(node.CPU80MHZ)
    ai_step = 0
    ai_last_trigger_time = tmr.now()
end

_ai_do_step = function()
    if ai_step == 0 then
        ai_stop()
        return
    end

    if ai_step == 1 then
        if ai_animation_enabled then
            dumb_animation()
        end
        local speech = ai_next_speech
        if speech == nil then
            speech = 'samples/speech_' .. ai_speech_counter .. '.u8'
            ai_speech_counter = ai_speech_counter + 1
            if ai_speech_counter > ai_speech_count then
                ai_speech_counter = 1
            end
        end
        audio_play(speech, function()
            _ai_do_step()
        end)
    elseif ai_step == 2 then
        local outcome = ai_next_outcome
        if outcome == nil then
            outcome = ai_houses[node.random(4)]
        end
        audio_play('samples/' .. outcome .. '.u8', function()
            _ai_do_step()
        end)
    else
        stop_animation()
        _ai_stop()
        return
    end

    ai_step = ai_step + 1
end