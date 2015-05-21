function init() {
    window.addEventListener('scroll', function(e){
        var banner = $("#banner");
        var body = $("body");
        var distanceY = window.pageYOffset || document.documentElement.scrollTop,
        shrinkOn = 40;
        // header = document.querySelector("header");
        if (distanceY > 40) {
            banner.addClass("smaller");
            banner.css('top', '-120px');
            body.css("background", "white");
        } else {
            var alpha = 1 - (distanceY / 40);
            var gradient = "linear-gradient(209deg, rgba(217, 255, 255, "+alpha+"), rgba(252, 255, 246,  "+alpha+") 1300px, white 1900px)";
            banner.css("top", 0);
            if (banner.hasClass("smaller")){
                banner.removeClass("smaller");
            }
            body.css("background", gradient);
        }
    });
}
window.onload = init();
