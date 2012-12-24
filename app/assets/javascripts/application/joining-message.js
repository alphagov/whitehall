(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var joining = {
    cookieName: 'inside-gov-joining',

    init: function(){
      joining.$progressBar = $('.js-progress-bar');

      if(joining.$progressBar.length === 1){
        var joiningCookie = root.GOVUK.cookie(joining.cookieName);

        if(""+ joining.$progressBar.data('join-count') !== joiningCookie){
          joining.showBar();
        }

        joining.addCloseButton();
      }
    },
    showBar: function(){
      joining.$progressBar.removeClass('js-hidden');
    },
    hideBar: function(){
      joining.$progressBar.addClass('js-hidden');
    },
    closeBar: function(){
      root.GOVUK.cookie(joining.cookieName, joining.$progressBar.data('join-count'), 30);
      joining.hideBar();
    },
    addCloseButton: function(){
      var closeButton = $('<span class="close-button"><em>close</em>x</span>');
      joining.$progressBar.prepend(closeButton);
      closeButton.click(joining.closeBar);
    }
  };
  root.GOVUK.joiningMessage = joining;
}).call(this);
