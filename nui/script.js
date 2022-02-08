const Bodycam = new Vue({
    el: "#Bodycam_Body",

    data: {
        showBody: false,

        gameTime: 0,
        clockTime: {},
        videoNumber: 0
    },

    methods: {

        EnableBodycam() {
            this.showBody = true;
        },

        DisableBodycam() {
            this.showBody = false;
        },

        UpdateBodycam(data) {
            this.gameTime = data.gameTime;
            this.clockTime = data.clockTime;
            this.videoNumber = data.videoNumber;
        },

    }
});

document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function(event) {
            if (event.data.type == "enablebody") {
                
                Bodycam.EnableBodycam();

            } else if (event.data.type == "disablebody") {

                Bodycam.DisableBodycam();

            } else if (event.data.type == "updatebody") {

                Bodycam.UpdateBodycam(event.data.info);

            }

        });
    };
};