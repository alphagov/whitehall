(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.hideDepartmentChildren = {
    init: function(){
      var $departments = $('.js-hide-department-children .department');

      $departments.each(function(i, el){
        var $department = $(el),
            $viewAll = $('<a href="#" class="view-all">view all</a>');

        $department.toggleClass('js-hiding-children');
        $viewAll.click(function(e){
          e.preventDefault();
          $department.toggleClass('js-hiding-children');
        });
        $viewAll.insertBefore($department.find('.child-organisations'))
      });
    }
  };
}).call(this);
