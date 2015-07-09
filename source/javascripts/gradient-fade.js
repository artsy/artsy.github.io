$(function() {
    var $window = $(window);
    var $header = $('#banner');
    var updateBackgroundPosition = function(e) {
        scrollPosition = $window.scrollTop();
        console.log(scrollPosition);
        $header.css({'background-position': "0px -" + scrollPosition + "px"});
    };
    $window.scroll(updateBackgroundPosition);
});
