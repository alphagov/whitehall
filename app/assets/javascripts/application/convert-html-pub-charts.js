$(function() {
    $('.js-barchart-table').each(function() {
        $.magnaCharta($(this), {
            toggleText: "Change between chart and table"
        });
    })
});
