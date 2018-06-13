(function (Modules) {
    "use strict";

    Modules.DeselectTaxonClick = function () {
        var helper = window.GOVUK.taxonomyTreeHelper;
        this.start = function (container) {
            var deselectTaxonClick = function () {
                var taxon_name = $(container).closest('.taxon-breadcrumb').find('li:last').text() ;
                $("input[data-taxon-name=\"" + taxon_name + "\"]").each(function(idx, el){
                    $(el).prop('checked', false)
                    if (!helper.hasCheckedSiblings(el)){
                        helper.uncheckAncestors(el);
                    }
                });
                $('.topic-tree').trigger('change');
                return false;
            };

            container.on("click", deselectTaxonClick);
        };
    };

})(window.GOVUKAdmin.Modules);
