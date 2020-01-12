
-- Create a TCP server
srv_sv = net.createServer(net.TCP, 30)

-- Configure the server to print the data it gets and respond
-- with a greeting message
if srv_sv then
    srv_sv:listen(80, function(conn)
        conn:on('receive', srv_receiver)
    end)
end

function render_file_list()
    local ret = '<ul>'

    allFiles = file.list('samples/')
    for k,v in pairs(allFiles) do
        ret = ret .. '<li><a href="/play?file='..k..'">'..k..'</a></li>'
    end

    return ret .. '</ul>'
end

function send_file(sck, filename, cb)
    local src = file.open(filename, "r")
    if not src then
        sck:close()
        return
    end
    local function send_chunk()
        local line = src:read(512)
        if line then 
            sck:send(line, send_chunk) 
        else
            src:close()
            collectgarbage()
            if cb then
                cb()
            else
                sck:close()
            end
        end
    end
    send_chunk()
end

function srv_to_JSON(data)
    if data == nil then
        return 'null'
    elseif data == true then
        return 'true'
    elseif data == false then
        return 'false'
    else
        return '"' .. data .. '"'
    end
end

function srv_get_param(urlstring, param_name)
    url = string.sub(firstLine, string.find(firstLine, ' ') + 1)
    url = string.sub(url, 0, string.find(url, ' ') - 1)
    return string.sub(url, string.find(url, param_name .. '=') + param_name:len() + 1)
end

function srv_status()
    local message = '{"house":' ..
        srv_to_JSON(ai_get_next_outcome()) .. ',"speech":' ..
        srv_to_JSON(ai_get_next_speech()) .. ',"detector":' ..
        srv_to_JSON(ai_get_detector_enabled()) .. ',"animation":' ..
        srv_to_JSON(ai_get_animation_enabled()) .. '}'
    return 'application/json', message
end

function srv_receiver(sck, data)
    firstLine = string.sub(data, 0, string.find(data, '\n'))
    local content_type = "text/plain";
    local message = ''

    if string.match(firstLine, 'GET /on ') then
        play_file('wisley.u8')
    elseif string.match(firstLine, 'GET /speeches') then
        content_type = 'application/json'
        message = '['
        local allFiles = file.list('samples/')
        for k,v in pairs(allFiles) do
            if string.match(k, 'speech_') then
                message = message .. '"' .. k .. '"' .. ','
            end
        end
        message = message .. 'null]'
    elseif string.match(firstLine, 'POST /speech') then
        local speech = srv_get_param(firstLine, 's')
        print('Selecting speech: ' .. speech)
        if speech == 'random' then
            ai_set_random_speech()
        else
            ai_set_next_speech(speech)
        end
        content_type, message = srv_status()
    elseif string.match(firstLine, 'POST /animation/on') then
        ai_enable_animation()
        content_type, message = srv_status()
    elseif string.match(firstLine, 'POST /animation/off') then
        ai_disable_animation()
        content_type, message = srv_status()
    elseif string.match(firstLine, 'POST /detector/on') then
        ai_enable_detector()
        content_type, message = srv_status()
    elseif string.match(firstLine, 'POST /detector/off') then
        ai_disable_detector()
        content_type, message = srv_status()
    elseif string.match(firstLine, 'GET /status') then
        content_type, message = srv_status()
    elseif string.match(firstLine, 'POST /house') then
        local house = srv_get_param(firstLine, 'h')
        print('Selecting house: ' .. house)
        if house == 'random' then
            ai_set_random_outcome()
        else
            ai_set_next_outcome(house)
        end
        content_type, message = srv_status()
    elseif string.match(firstLine, 'POST /play') then
        url = string.sub(firstLine, string.find(firstLine, ' ') + 1)
        url = string.sub(url, 0, string.find(url, ' ') - 1)
        filename = string.sub(url, string.find(url, 'file=') + 5)
        print('Server requested to play ' .. filename)
        play_file(filename)
    elseif string.match(firstLine, 'POST /next') then
        url = string.sub(firstLine, string.find(firstLine, ' ') + 1)
        url = string.sub(url, 0, string.find(url, ' ') - 1)
        file_pos = string.find(url, 'file=')
        if file_pos > 0 then
            filename = string.sub(url, file_pos + 5)
            next_sound = filename
        else
            next_sound = nil
        end
    elseif string.match(firstLine, 'POST /trigger') then
        content_type, message = srv_status()
        ai_manual_trigger()
    elseif string.match(firstLine, 'GET /main.js') then
        sck:send('HTTP/1.1 200 OK\r\nContent-Type: text/javascript\r\n\r\n',
            function()
                send_file(sck, "www/main.js")
            end)
        return;
    elseif string.match(firstLine, 'GET /') then
        sck:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n',
            function()
                send_file(sck, "www/index.html")
            end)
        return
    end

    sck:send('HTTP/1.1 200 OK\r\nContent-Type: ' .. content_type .. '\r\n\r\n' .. message, function()
        sck:close()
        collectgarbage()
    end)
end
