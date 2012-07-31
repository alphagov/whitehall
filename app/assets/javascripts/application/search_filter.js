(function($){

  var $navigation = $('.js-search-filter'),
      $results;

  if($navigation.length){
    $results = $('.js-search-result');

    $navigation.find('a').click(function(e){
      var $link = $(e.target),
          filter = $link.parent().data('filter'),
          $shownResults;

      e.preventDefault();

      // Update the active link
      $navigation.find('.active').removeClass('active');
      $link.addClass('active')

      if(filter === '*'){
        $results.removeClass('hidden');
      } else {
        $shownResults = $results.filter('.'+filter).removeClass('hidden');
        $results.not($shownResults).addClass('hidden');
      }
    });
  }

}(jQuery));
