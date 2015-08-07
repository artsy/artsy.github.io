$(function() {
    var $window = $(window);
    var $header = $('#banner');
    var updateBackgroundPosition = function(e) {
        scrollPosition = $window.scrollTop();
        $header.css({'background-position': "0px -" + (scrollPosition - 100) + "px"});
    };
    $window.scroll(updateBackgroundPosition);
});
