let audioContext;

const generator = `
  function genVariation() {
    const timestamp = Date.now();
    const angle = (timestamp % 20000) / 20000 * (2 * Math.PI);
    return Math.sin(angle);
  }

  class RainSoundProcessor extends AudioWorkletProcessor {
    constructor(params) {
      super();

      this.amplitude = (params.processorOptions.rainIntensity || 400) / 10000.0;
      this.rainDistance = params.processorOptions.rainDistance || 8000;
      this.sampleRate = 48000;
      this.bufferSize = 256;
      this.time = 0;
      this.rainLeft = this.generateRain();
      this.rainRight = this.generateRain();

      this.lpFilter = this.createLowPassFilter(this.rainDistance);
      this.lpFilterBufferLeft = new Float32Array(this.bufferSize);
      this.lpFilterBufferRight = new Float32Array(this.bufferSize);
    }

    process(inputs, outputs, parameters) {
      const output = outputs[0];
      const outputChannelLeft = output[0];
      const outputChannelRight = output[1];

      for (let i = 0; i < this.bufferSize; ++i) {
        const rainSampleLeft = this.rainLeft();
        const rainSampleRight = this.rainRight();
        this.lpFilterBufferLeft[i] = this.lpFilter(rainSampleLeft);
        this.lpFilterBufferRight[i] = this.lpFilter(rainSampleRight);
      }

      for (let i = 0; i < outputChannelLeft.length; ++i) {
        outputChannelLeft[i] = this.lpFilterBufferLeft[i % this.bufferSize];
        outputChannelRight[i] = this.lpFilterBufferRight[i % this.bufferSize];
      }
 
      return true;
    }

    generateRain() {
      let b0, b1, b2, b3, b4, b5, b6;
      b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;

      return () => {
        let white = Math.random() * 2 - 1;

        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.89332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;

        let output = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
        b6 = white * 0.115926;

        return (output * this.amplitude) * (1 + genVariation() * 0.1);
      };
    }

    createLowPassFilter(cutoffFrequency) {
      const RC = 1.0 / (cutoffFrequency * 2 * Math.PI);
      const dt = 1.0 / this.sampleRate;
      const alpha = dt / (RC + dt);

      let y = 0;

      return (input) => {
        y = y + alpha * (input - y);
        return y;
      };
    }
  }

  registerProcessor('rain-processor', RainSoundProcessor);
`;

async function initAudio() {  
  const moduleUrl = 'data:application/javascript;base64,' + btoa(generator);
  audioContext = new (window.AudioContext || window.webkitAudioContext)()
  await audioContext.audioWorklet.addModule(moduleUrl);
  const rainNode = new AudioWorkletNode(audioContext, 'rain-processor', {
    outputChannelCount: [2],
    processorOptions: {
      ...weather
    }
  });

  rainNode.connect(audioContext.destination);
}

function rotateGroups() {
  const rainCanvas = document.querySelector('#rain-canvas');
  const groups = rainCanvas.querySelectorAll('g');
  const copies = Array.from(groups).map(group => group.cloneNode(true));
  groups.forEach((group, index) => {
    const sourceOpacity = group.getAttribute('opacity');
    const sourceFilterClass = group.querySelector('use').getAttribute('class').split(' ').filter(x => x.startsWith('f')).join(' ');
    const sourceTextTransform = group.querySelector('use').getAttribute('transform');

    const targetIndex = (index + 1) % copies.length;
    const copy = copies[targetIndex];
    const targetClasses = copy.querySelector('use').getAttribute('class').split(' ').filter(x => !x.startsWith('f')).join(' ');
    copy.setAttribute('opacity', sourceOpacity);
    copy.querySelector('use').setAttribute('class', `${sourceFilterClass} ${targetClasses}`);
    copy.querySelector('use').setAttribute('transform', sourceTextTransform);
  })

  groups.forEach((group, index) => {
    const targetIndex = (index + 1) % copies.length;
    group.remove();
    rainCanvas.appendChild(copies[targetIndex]);
  });
}

let playing = false;
let intervalCallback = undefined;

document.onclick = async function() {
  document.getElementById('controls').style.visibility = 'hidden';

  if(!audioContext) {
    await initAudio();
  }

  if(!playing) {
    audioContext.resume().then(() => {
      intervalCallback = setInterval(() => {
        rotateGroups();
      }, 10);
    });
  } else {
    audioContext.suspend().then(() => {
      clearInterval(intervalCallback);
    });
  }
  playing = !playing;
};

function toggleFullScreen() {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen();
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    }
  }
}

document.addEventListener('keydown', function (event) {
  if (event.key.toLowerCase() === 'f') {
    toggleFullScreen();
  }
});

document.addEventListener("DOMContentLoaded", function() {
  const controls = document.getElementById('controls');
  
  setTimeout(function() {
    controls.style.opacity = 1;
    setTimeout(function() {
      controls.style.opacity = 0;
    }, 4000);
  }, 1000);
});
