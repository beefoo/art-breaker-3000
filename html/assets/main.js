let started = false;
const startButton = document.getElementById('start');
const startButtonText = startButton.innerText;
const canvas = document.getElementById('canvas');

window._gdExchange = {};
window._gdExchange.quit = function() {
    startButton.classList.remove('loading');
    startButton.innerText = startButtonText;
    engine.requestQuit();
    document.exitFullscreen()
    canvas.classList.remove('active');
    startButton.disabled = false;
};
window._gdExchange.upload = function(gd_callback) {
    const input = document.getElementById('file-picker');
    input.click();
    this.cancelled = false;
    input.addEventListener('change', (event) => {
        if (event.target.files.length <= 0) {
            this.cancelled = true;
            return;
        }
        const file = event.target.files[0];
        const reader = new FileReader();
        this.fileType = file.type;
        // var fileName = file.name;
        reader.readAsArrayBuffer(file);
        reader.onloadend = (evt) => {
            if (evt.target.readyState === FileReader.DONE) {
                this.result = evt.target.result;
                gd_callback();
            }
        }
    });
}

startButton.onclick = (event) => {
    engine.startGame();
    canvas.classList.add('active');
    startButton.classList.add('loading');
    startButton.innerText = 'Loading...';
    startButton.disabled = true;
    started = true;
};