(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var createNew = {
    init: function() {
      createNew.$el = $('.js-create-new');

      if(createNew.$el.length){
        createNew.$dropdown = createNew.$el.find('.dropdown-menu');
        createNew.$el.find('strong').on('click', createNew.toggle);

        // mouseUp rather than click because phantomJS was crashing
        $(root).on('mouseup', createNew.documentClick);
      }
    },
    documentClick: function(e){
      if($(e.target).closest(createNew.$el).length === 0 && createNew.$dropdown.is(':visible')){
        createNew.toggle();
      }
    },
    toggle: function() {
      if(createNew.$dropdown.is(':visible')){
        createNew.$dropdown.hide();
      } else {
        createNew.$dropdown.show();
      }
    }
  };

  root.GOVUK.createNew = createNew;
}).call(this);
