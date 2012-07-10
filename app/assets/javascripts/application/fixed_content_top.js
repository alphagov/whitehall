$(document).ready(function () {  
  var contentContainer = $('.js-fixed-content-top')
  if (contentContainer.length > 0) {
    var top = $('.js-fixed-content-top').offset().top - parseFloat($('.js-fixed-content-top').css('marginTop').replace(/auto/, 0));
    $(window).scroll(function (event) {
      // what the y position of the scroll is
      var y = $(this).scrollTop();
    
      // whether that's below
      if (y >= top) {
        // if so, ad the fixed class
        $('.js-fixed-content-top').addClass('content-fixed');
      } else {
        // otherwise remove it
        $('.js-fixed-content-top').removeClass('content-fixed');
      }
    });
  };
});