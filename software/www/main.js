
function request(verb, target, cb) {
    var xhr = new XMLHttpRequest();
    xhr.open(verb, target);
    xhr.onload = function() {
        if (cb)
            cb(xhr.responseText);
    }
    xhr.send();
}

function onSoundBtnClick(target) {
    return function() {
        request('POST', '/next/?file=' + target);
    }
}

function filename(path) {
    const split = path.split('/');
    return split[split.length - 1].split('.')[0];
}

function renderButton(name, cb) {
    var el = document.createElement('div');
    var link = document.createElement('a');
    el.appendChild(link);
    el.className = 'btn';
    link.innerText = filename(name);
    link.onclick = cb ? cb : onSoundBtnClick(name);

    return el;
}

function main() {
    const state = {
        house: 'random',
        speech: 'random',
        animation: true,
        detector: true
    };

    const speechesAnchor = document.getElementById('speeches');
    const speechBtns = {};

    const animationButton = document.getElementById('toggle_animation');
    const detectorButton = document.getElementById('toggle_detector');

    function onSelectHouse(house) {
        return () => {
            request('POST', '/house?h=' + house, onRefresh);
        }
    }

    const house_btns = ['griffondor_1', 'serpentar_1', 'pouffsoufle_1', 'serdaigle_1', 'rick', 'random']
        .map(house => {
            const el = document.getElementById(`house_${house}`);
            el.addEventListener('click', onSelectHouse(house))
            return [house, el]
        })
        .reduce((acc, el) => {acc[el[0]] = el[1]; return acc}, {});

    function refreshHouseBtns() {
        for (let i of Object.keys(house_btns)) {
            house_btns[i].classList.remove('active');
        }
        house_btns[state.house].classList.add('active');
    }
    
    function refreshSpeechBtns() {
        for (let i of Object.keys(speechBtns)) {
            speechBtns[i].classList.remove('active');
        }
        speechBtns[state.speech].classList.add('active');
    }

    function refreshControls() {
        animationButton.classList.remove('active');
        detectorButton.classList.remove('active');
        if (state.animation) {
            animationButton.classList.add('active');
        }
        if (state.detector) {
            detectorButton.classList.add('active');
        }
    }

    animationButton.addEventListener('click', () => {
        request('POST', `/animation/${state.animation ? 'off' : 'on'}`, onRefresh);
    });
    detectorButton.addEventListener('click', () => {
        request('POST', `/detector/${state.detector ? 'off' : 'on'}`, onRefresh);
    });

    function onSelectSpeech(name) {
        return () => {
            request('POST', '/speech?s=' + name, onRefresh);
        };
    }

    function renderSpeechBtn(name) {
        const el = document.createElement('div');
        el.classList.add('btn');
        el.innerText = filename(name).replace('speech_', '');
        el.addEventListener('click', onSelectSpeech(name));
        speechBtns[name] = el;
        return el;
    }

    function refresh() {
        request('GET', '/status', onRefresh);
    }

    function onRefresh(raw) {
        const result = JSON.parse(raw);
        state.house = result.house == null ? 'random' : result.house;
        state.speech = result.speech == null ? 'random' : result.speech;
        state.animation = result.animation || false;
        state.detector = result.detector || false;
        refreshHouseBtns();
        refreshSpeechBtns();
        refreshControls();
    }

    document.getElementById('trigger_choice').addEventListener('click', () => {
        request('POST', '/trigger');
    });

    request('GET', '/speeches', function(raw) {
        speechesAnchor.innerHTML = '';
        JSON.parse(raw).sort()
            .map(name => renderSpeechBtn(name || 'random'))
            .forEach(el => {
                speechesAnchor.appendChild(el);
            });
        refresh();
    });

}
