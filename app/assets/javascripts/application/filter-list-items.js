(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var filter = {
    _terms: false,
    _regexCache: {},

    init: function(){
      var $filterList = $('.js-filter-list');

      if($filterList.length === 1){
        filter.$form = $('<form><label for="who-are-you-looking-for">Which organisation are you looking for?</label> <input name="who-are-you-looking-for"></form>');
        filter.$filterItems = $('.js-filter-item');
        filter.$filterBlock = $('.js-filter-block');

        $filterList.append(filter.$form);
        filter.$form.submit(filter.updateResults);
        filter.$form.find('input').keyup(filter.updateResults);
      }
    },
    updateResults: function(){
      var search = filter.$form.find('input').val(),
          itemsToShow = filter.getItems(search);

      $(document).trigger('govuk.hideDepartmentChildren.hideAll');
      filter.$filterItems.hide();
      $(itemsToShow).show();
      filter.hideEmptyBlocks(itemsToShow);
    },
    hideEmptyBlocks: function(itemsToShow){
      if(itemsToShow.length === 0){
        $('.js-filter-no-results').addClass('reveal');
        filter.$filterBlock.hide();
      } else {
        $('.js-filter-no-results').removeClass('reveal');

        filter.$filterBlock.each(function(i, el){
          var $el = $(el);

          $el.show();
          if($el.find('.js-filter-item:visible').length === 0){
            $el.hide();
          }
        });
      }
    },
    getItems: function(search){
      var regex = filter.getRegex(search),
          terms = filter.getFilterTerms(),
          items = [],
          key;

      for(key in terms) {
        if(key.match(regex)){
          items.push(terms[key]);
        }
      }
      return items;
    },
    getRegex: function(search){
      if(typeof filter._regexCache[search] === 'undefined'){
        filter._regexCache[search] = new RegExp(search.replace(/\W/, ".*"), 'i');
      }
      return filter._regexCache[search];
    },
    getFilterTerms: function(){
      if(filter._terms === false){
        filter._terms = {};
        filter.$filterItems.each(function(i, el){
          filter._terms[$(el).data('filter-terms')] = el;
        });
      }

      return filter._terms
    }
  };

  root.GOVUK.filterListItems = filter;
}).call(this);
