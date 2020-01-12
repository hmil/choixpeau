const fs = require('fs');
const path = require('path');

// Filtre le bruit de fond du fichier audio

if (process.argv.length != 3) {
    console.log("Usage: node filter.js <input>");
}

const inputFile = process.argv[2];

const lebuff = fs.readFileSync(inputFile);

const outBuff = Buffer.alloc(lebuff.length);

const history = [0, 0];

for (let i = 0 ; i < lebuff.length ; i++) {
    const byte = lebuff.readUInt8(i);
    history.splice(0, 1);
    history.push(byte);
    outBuff.writeUInt8(filter(history), i);
}

fs.writeFileSync(path.join(path.dirname(inputFile), path.basename(inputFile, '.raw.u8') + '.u8'), outBuff);

// function filter(values) {
//     const fade = 3;
//     const coeff = Math.min(1, values.reduce((acc, v) => acc + (normalize(v) / fade / values.length)));

//     return Math.round(values[0] * coeff + 0x80 * (1 - coeff));
// }

// function normalize(value) {
//     return Math.abs((value - 0x80));
// }

function filter(values) {
    if (belowThreshold(values[0]) && belowThreshold(values[1])) {
        return 0x80;
    }
    return values[0];
}

function belowThreshold(v) {
    return v >= 0x7e && v <= 0x82;
}