function init() {
    // Create the listener function
    var updateLayout = function(e) {
        var body = $("body");
        var distanceY = window.pageYOffset || document.documentElement.scrollTop;
        if (distanceY > 120) {
            body.css("background", "white");
        } else {
            var alpha = 1 - (distanceY / 120);
            var gradient = "linear-gradient(209deg, rgba(217, 255, 255, "+alpha+"), rgba(252, 255, 246,  "+alpha+") 1300px, white 1900px)";
            body.css("background", gradient);
        }
    };
    window.addEventListener('scroll', updateLayout, false);
}
window.onload = init();
