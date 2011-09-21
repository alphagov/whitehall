(function ($) {
  /*
  *
  * Fades flash notices out after they are shown
  *
  */
  $.fn.flashNotice = function (static) {
  	$(this).hide();
  	$(this).fadeIn();

  	if (!static) {
  	  var element = $(this);
    	var timeout = setTimeout(function () { element.fadeOut(); }, 3000);
  	}

  	$(this).click(function () {
  	  if (timeout) {
  	    clearTimeout(timeout);
  	  }

  	  $(this).fadeOut();
  	});
  }

  $.fn.showNotice = function (message) {
  	$(this).html("<p class='flash notice'>"+message+"</p>")
  	$(".notice", this).flashNotice();
  }

  $.fn.showError = function (message) {
  	$(this).html("<p class='flash error'>"+message+"</p>")
  	$(".error", this).flashNotice();
  }

})(jQuery);