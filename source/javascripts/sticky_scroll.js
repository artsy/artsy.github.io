function init() {
    window.addEventListener('scroll', function(e){
        var banner = $("#banner");
        var body = $("body");
        if ($("#page-sidebar").length) {
            var sidebar = $("#page-sidebar");
        }
        var distanceY = window.pageYOffset || document.documentElement.scrollTop,
        shrinkOn = 40;
        if (distanceY > shrinkOn) {
            banner.addClass("smaller");
            banner.css('top', '-120px');
            body.css("background", "white");
            if (sidebar.length) {
                sidebar.css('top', '140px');
            }
        } else {
            banner.css("top", 0);
            if (banner.hasClass("smaller")){
                banner.removeClass("smaller");
            }
            var alpha = 1 - (distanceY / shrinkOn);
            var gradient = "linear-gradient(209deg, rgba(217, 255, 255, "+alpha+"), rgba(252, 255, 246,  "+alpha+") 1300px, white 1900px)";
            body.css("background", gradient);
            if (sidebar.length) {
                sidebar.css("top", '260px');
            }
        }
    });
}
window.onload = init();
