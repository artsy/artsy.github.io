function init() {
    var $window = $("window");
    var $header = $('#banner');
    var updateLayout = function(e) {
        scrollPosition = $window.scrollTop();
        $header.css({'background-position': "0px -" + scrollPosition + "px"});
    };
    window.addEventListener('scroll', updateLayout, false);
}
window.onload = init();
