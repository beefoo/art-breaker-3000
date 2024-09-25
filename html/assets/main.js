let started = false;
const body = document.body;
const startButton = document.getElementById('start');
const loading = document.getElementById('loading');
const canvas = document.getElementById('canvas');

window._gdExchange = {};
window._gdExchange.quit = function() {
    body.classList.remove('active');
    engine.requestQuit();
    document.exitFullscreen()
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
    body.classList.add('active');
    startButton.disabled = true;
    started = true;
};