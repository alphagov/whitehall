$(document).ready(function () {  
  var contentContainer = $('.js-fixed-content-top')
  if (contentContainer.length > 0) {
    var top = $('.js-fixed-content-top').offset().top - parseFloat($('.js-fixed-content-top').css('marginTop').replace(/auto/, 0));
    $(window).scroll(function (event) {
      var y = $(this).scrollTop();
      if (y >= top) {
        $('.js-fixed-content-top').addClass('content-fixed');
      } else {
        $('.js-fixed-content-top').removeClass('content-fixed');
      }
    });
  };
});