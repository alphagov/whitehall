(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var duplicateFields = {
    init: function(){
      duplicateFields.$sets = $('.js-duplicate-fields');

      duplicateFields.addButton();
    },
    addButton: function(){
      duplicateFields.$sets.each(function(){
        var $set = $(this),
            $button = $('<a href="#">Add another</a>');

        $set.append($button);
        $button.on('click', duplicateFields.addFields);
      });
    },
    addFields: function(e){
      e.preventDefault();
      var $button = $(e.target),
          $set = $button.closest('.js-duplicate-fields'),
          $fields = $set.find('.js-duplicate-fields-set').last(),
          $newFields = $fields.clone();

      $newFields.find('input[type=text], textarea').val('');
      duplicateFields.incrementIndexes($newFields);
      $button.before($newFields);
    },
    incrementIndexes: function(fields){
      fields.find('label,input,textarea,select').each(function(i, el){
        var $el = $(el),
            currentName = $el.attr('name'),
            currentId = $el.attr('id'),
            currentFor = $el.attr('for'),
            index = false;

        if(currentName && currentName.match(/\[([0-9]+)\]/)){
          index = parseInt(currentName.match(/\[([0-9]+)\]/)[1], 10);
          $el.attr('name', currentName.replace('['+ index +']', '['+ (index+1) +']'));
        }
        if(currentId && currentId.match(/_([0-9]+)_/)){
          if(index === false){
            index = parseInt(currentId.match(/_([0-9]+)_/)[1], 10);
          }
          $el.attr('id', currentId.replace('_'+ index +'_', '_'+ (index+1) +'_'));
        }
        if(currentFor && currentFor.match(/_([0-9]+)_/)){
          if(index === false){
            index = parseInt(currentFor.match(/_([0-9]+)_/)[1], 10);
          }
          $el.attr('for', currentFor.replace('_'+ index +'_', '_'+ (index+1) +'_'));
        }
      });
    }
  };
  root.GOVUK.duplicateFields = duplicateFields;
}).call(this);
