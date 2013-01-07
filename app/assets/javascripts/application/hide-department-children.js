(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var hideDepartmentChildren = {
    init: function(){
      var $departments = $('.js-hide-department-children .department'),
          windowHash = root.location.hash;

      $departments.each(function(i, el){
        var $department = $(el),
            $childOrganisations = $department.find('.organisations-box'),
            $viewAll = $('<a href="#" class="view-all">view all</a>');

        if($department.find(windowHash).length === 0){
          // only hide if its not the department we should be showing
          $department.toggleClass('js-hiding-children');
        }
        $childOrganisations.removeClass('js-hidden');

        $viewAll.click(function(e){
          e.preventDefault();
          $department.toggleClass('js-hiding-children');
        });
        $viewAll.insertBefore($childOrganisations)
      });

      $(document).on('govuk.hideDepartmentChildren.hideAll', hideDepartmentChildren.hideAllChildren);
    },
    hideAllChildren: function(){
      $('.js-hide-department-children .department').addClass('js-hiding-children');
    }
  };
  root.GOVUK.hideDepartmentChildren = hideDepartmentChildren;
}).call(this);
