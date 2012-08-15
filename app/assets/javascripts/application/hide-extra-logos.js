(function($) {
  if($('.js-hide-extra-logos').length > 0){
    var $organisations = $('.js-hide-extra-logos .organisations-icon-list'),
        $organisation = $organisations.find('.organisation'),
        organisationHeight = $organisation.outerHeight(true),
        all = $organisation.length,
        hidden = 0,
        $toggle;

    function numberOfLines(){
      var lines = $organisations.height() / organisationHeight;
      return Math.round(lines);
    }

    if(numberOfLines() > 1){
      $toggle = $('<li class="show-other-content"><a href="#" title="Show additional links"><span class="plus">+&nbsp;</span>others</a></li>');
      $organisations.append($toggle);
      while((numberOfLines() > 1) && (all - hidden > 1)){
        hidden = hidden + 1;
        $($organisation.get(all-hidden)).hide();
      }
      $organisations.addClass('extra-icons');

      $toggle.on('click', function(e) {
        e.preventDefault();
        $toggle.remove();
        $organisations.removeClass('extra-icons');
        $organisation.filter(':hidden').show().focus();
      });
      $organisations.attr('aria-live', 'polite');
    }
  }
}(jQuery));
