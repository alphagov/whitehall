/*jslint
 browser: true,
 white: true,
 plusplus: true,
 vars: true */
/*global jQuery */

(function($) {
    "use strict";
    function progressSpan(current, total) {
        var span = $("<span />");
        span.text(current + " of " + total);
        return span;
    }
    function drawPagination(data, after) {
      var existingNav = $('#show-more-documents');
       if (existingNav.length > 0) {
         existingNav.remove();
       }
      if (data.next_page_url || data.prev_page_url) {
        var nav = $('<nav id="show-more-documents" role="navigation" />'),
            ul = $('<ul class="previous-next-navigation" />'),
            li, a;
        nav.append(ul);
        if (data.prev_page_url) {
          li = $('<li class="previous" />');
          a = $('<a>Previous page</a>');
          a.attr('href', data.prev_page_url);
          ul.append(li);
          li.append(a);
          a.append(" ");
          a.append(progressSpan(data.prev_page, data.total_pages));
        }
        if (data.next_page_url) {
          li = $('<li class="next" />');
          a = $('<a>Next page</a>');
          a.attr('href', data.next_page_url);
          ul.append(li);
          li.append(a);
          a.append(" ");
          a.append(progressSpan(data.next_page, data.total_pages));
        }

        $(after).after(nav);
      }
    }
    function importantAttribute(attribute) {
      return ($.inArray(attribute, ["id", "title", "url", "type"]) < 0);
    }
    function capitalize(attribute) {
      return attribute.replace(/_/, " ").replace(/(^|\s)([a-z])/g, function(_,a,b){ return a+b.toUpperCase(); });
    }
    function drawTable(data) {
        var container = $('.filter-results');
        if (data.results.length > 0) {
            var tBody, i, l;
            if (!document.getElementById('document-list')) {
                var table = $('<table id="document-list" class="document-list" />'),
                    tHead = $('<thead class="visuallyhidden" />'),
                    tr = $('<tr />');
                for(var attribute in data.results[0]) {
                  if (importantAttribute(attribute)) {
                    tr.append($('<tr scope="col">' + capitalize(attribute) + '</tr>'))
                  }
                }

                tHead.append(tr);
                table.append(tHead);
                table.append('<tbody />');
                container.empty().append(table);
            }

            tBody = $('<tbody />');

            for (i=0, l=data.results.length; i<l; i++) {
                var row = data.results[i],
                    tableRow = $('<tr />'),
                    th = $('<th />'),
                    a = $('<a />');
                tableRow.attr('id', row.type + '_' + row.id).addClass('document-row').addClass((i < 3 ? 'recent' : ''));
                th.attr('scope', 'row').addClass('title attribute');
                a.attr('href', row.url).attr('title', "View " + row.title).text(row.title);
                th.append(a);
                tableRow.append(th);
                for(var attribute in row) {
                  if (importantAttribute(attribute)) {
                    tableRow.append($('<td class="' + attribute + ' attribute">' + row[attribute] + '</td>'));
                  }
                }
                tBody.append(tableRow);
            }

            $('.filter-results .document-list tbody').replaceWith(tBody);

            drawPagination(data, tBody.parent());

        }
        else {
            container.empty();
            container.append('<div class="no-results"><h2>There are no matching documents.</h2>' +
                             '<p>Try making your search broader and try again.</p></div>');
        }
    }
    function updateAtomFeed(data) {
      if (data.atom_feed_url) {
        $(".subscribe a.feed").attr("href", data.atom_feed_url);
      }
    }

    var _enableDocumentFilter = function() {
      if (!History.enabled) {
        return false;
      }
      var $form = $(this);
      $form.submit(function(e) {
          e.preventDefault();
          var $submitButton = $form.find('input[type=submit]'),
              url = $form.attr('action'),
              params = $form.serializeArray();

          $submitButton.addClass('disabled');
          // TODO: make a spinny updating thing
          $.ajax(url, {
              cache: false,
              dataType:'json',
              data: params,
              success: function(data) {
                updateAtomFeed(data);
                if (data.results) {
                  drawTable(data);
                }
                History.pushState(null, null, url + "?" + $form.serialize());
                // undo double-click protection
                $submitButton.removeAttr('disabled').removeClass('disabled');
              },
              error: function() {
                $submitButton.removeAttr('disabled');
              }
          });

      });
      $form.find('select').change(function(e){
        $form.submit();
      });
    }

    $.fn.extend({
      enableDocumentFilter: _enableDocumentFilter
    });
})(jQuery);

jQuery(function($) {
  $("form#document-filter").enableDocumentFilter();
})
