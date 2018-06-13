(function (Modules) {
    "use strict";

    Modules.TrackSelectedTaxons = function () {
        var extractBreadcrumb = function (element) {
            return element.find('li').map(function () {
                return $(this).text();
            }).get().join(' > ');
        };
        this.start = function (container) {
            var trackSelectedTaxons = function () {
                var category = container.data("track-category"),
                    label = container.data("track-label");

                $('.taxon-breadcrumb').each(function (idx, element) {
                    var action = extractBreadcrumb($(element));
                    GOVUKAdmin.trackEvent(category, action, {label: label});
                });
            };

            container.on("click", trackSelectedTaxons);
        };
    };

})(window.GOVUKAdmin.Modules);
