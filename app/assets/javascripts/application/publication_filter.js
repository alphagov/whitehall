/*jslint
 browser: true,
 white: true,
 plusplus: true,
 vars: true */
/*global jQuery */

(function($) {
    "use strict";
    function drawTable(data) {
        var container = $('#publications-container');
        if (data.length > 0) {
            var tBody, i, l;
            if (!document.getElementById('publications-list')) {
                var table = $('<table id="publications-list" class="document-list" />'),
                    tHead = $('<thead class="visuallyhidden" />'),
                    tr = $('<tr />');
                $(["Title", "Publicatoon Date", "Publication Type"]).each(function(title) {
                    tr.append($('<tr scope="col">' + title + '</tr>'));
                });
                tHead.append(tr);
                table.append(tHead);
                table.append('<tbody />');
                container.empty().append(table);
            }

            tBody = $('<tbody />');

            for (i=0, l=data.length; i<l; i++) {
                var row = data[i],
                    tableRow = $('<tr />'),
                    th = $('<th />'),
                    a = $('<a />');
                tableRow.attr('id', 'publication_' + row.id).addClass('document-row').addClass((i < 3 ? 'recent' : ''));
                th.attr('scope', 'row').addClass('title attribute');
                a.attr('href', row.url).attr('title', "View " + row.title).text(row.title);
                th.append(a);
                th.append(' ');
                th.append($('<em class="meta organisations">'+row.organisations+'</em>'));
                tableRow.append(th);
                tableRow.append($('<td class="data attribute">' + row.published + '</td>'));
                tableRow.append($('<td class="type attribute">' + row.publication_type + '</td>'));
                tBody.append(tableRow);
            }

            $('#publications-list tbody').replaceWith(tBody);
        }
        else {
            container.empty();
            container.append('<div class="no-results"><h2>There are no matching publications.</h2>' +
                             '<p>Try making your search broader and try again.</p></div>');
        }
    }

    $('form#publications-filter').submit(function(e) {
        e.preventDefault();
        $('#publications-filter input[type=submit]').addClass('disabled');
        var $form = $(this),
            url = $(this).attr('action'),
            params = $(this).serializeArray();
        // TODO: make a spinny updating thing
        $.ajax(url, {
            cache: false,
            dataType:'json',
            data: params,
            success: function(data) {
              if (data.results) {
                drawTable(data.results);
              }
              // undo double-click protection
              $('#publications-filter input[type=submit]').removeAttr('disabled').removeClass('disabled');
            },
            error: function() {
                $('#publications-filter input[type=submit]').removeAttr('disabled');
            }
        });

    });
})(jQuery);
