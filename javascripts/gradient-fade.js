$(function() {
    var $window = $(window);
    var $header = $('#banner');

    var isWhite = true
    var updateBackgroundPosition = function(e) {
        scrollPosition = $window.scrollTop();
        $header.css({'background-position': "0px -" + (scrollPosition - 100) + "px"});
        
        // Lets us have a nice bounce colour - see #265 / #120
        var shouldBeWhite = scrollPosition >= 0
        if (shouldBeWhite && !isWhite) {
          $("body").css( "background-color", "white" )
          isWhite = true
        } else if (!shouldBeWhite && isWhite) {
          $("body").css( "background-color", "#dafffd" )
          isWhite = false
        }
    };
    $window.scroll(updateBackgroundPosition);
});
