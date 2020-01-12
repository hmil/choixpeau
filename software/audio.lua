audio_finished = function() end

function audio_cb_drained(d)
    print("drained "..node.heap())
    file.close()
    audio_finished()
end

function audio_cb_stopped(d)
    print("playback stopped")
    file.seek("set", 0)
end

function audio_cb_paused(d)
    print("playback paused")
end


audio_drv = pcm.new(pcm.SD, 1)

-- fetch data in chunks of FILE_READ_CHUNK (1024) from file
audio_drv:on("data", function(drv) return file.read() end)

-- get called back when all samples were read from the file
audio_drv:on("drained", audio_cb_drained)

audio_drv:on("stopped", audio_cb_stopped)
audio_drv:on("paused", audio_cb_paused)

function audio_play(audiofile, finished_cb)
    print('playing: ' .. audiofile)
    audio_finished = finished_cb
    file.open(audiofile, "r")
    audio_drv:play(pcm.RATE_16K)
end

