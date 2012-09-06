/*jslint
 browser: true,
 white: true,
 plusplus: true,
 vars: true,
 nomen: true */
/*global jQuery */


if(typeof window.GOVUK === 'undefined'){ window.GOVUK = {}; }
(function($) {
  "use strict";

  var documentFilter = {
    loading: false,
    $form: null,

    drawPagination: function (data) {
      var $existingNav = $('#show-more-documents'),
          $nav = $('');
      if ($existingNav.length > 0) {
        $existingNav.remove();
      }
      if (data.next_page_url) {
        var $ul = $('<ul class="previous-next-navigation infinite" />'),
            $li, $a;

        $nav = $('<nav id="show-more-documents" role="navigation" />').append($ul);
        if (data.next_page_url) {
          $li = $('<li class="next" />');
          $a = $('<a>Next page '+ documentFilter.progressSpan(data.next_page, data.total_pages) +'</a>').attr('href', data.next_page_url);
          $ul.append($li);
          $li.append($a);
        }
      }
      return $nav;
    },
    progressSpan: function(current, total) {
      return '<span>' + current + " of " + total + '</span>';
    },
    importantAttributes: ["id", "title", "url", "type"],
    importantAttribute: function(attribute) {
      return ($.inArray(attribute, documentFilter.importantAttributes) < 0);
    },
    capitalize: function(attribute) {
      return attribute.replace(/_/, " ").replace(/(^|\s)([a-z])/g, function(_,a,b){ return a+b.toUpperCase(); });
    },
    drawTableCell: function(attributeName, attributeValue) {
      var inner = attributeValue;
      return '<td class="' + attributeName + ' attribute">' + inner + '</td>';
    },
    drawTableRows: function(results) {
      var $tBody = $('<tbody />'), i,l;

      for (i=0, l=results.length; i<l; i++) {
        var row = results[i],
            $tableRow = $('<tr class="document-row" />'),
            $th = $('<th scope="row" class="title attribute"/>'),
            $a = $('<a href="'+ row.url +'" title="View '+ row.title +'">'+ row.title +'</a>');

        $tableRow.attr('id', row.type + '_' + row.id).addClass((i < 3 ? ' recent' : ''));
        $th.append($a);
        $tableRow.append($th);
        for(var attribute in row) {
          if (documentFilter.importantAttribute(attribute)) {
            $tableRow.append($(documentFilter.drawTableCell(attribute, row[attribute])));
          }
        }
        $tBody.append($tableRow);
      }
      return $tBody;
    },
    drawTable: function(data) {
      var $container = $('.filter-results');
      if (data.results.length > 0) {
        var $tBody;
        if ($('#document-list').length < 1) {
          var $table = $('<table id="document-list" class="document-list" />'),
              $tHead = $('<thead class="visuallyhidden" />'),
              $tr = $('<tr />').append('<th scope="col">Title</th>');

          for(var attribute in data.results[0]) {
            if (documentFilter.importantAttribute(attribute)) {
              $tr.append($('<th scope="col">' + documentFilter.capitalize(attribute) + '</th>'))
            }
          }
          $tHead.append($tr);
          $table.append($tHead);
          $table.append('<tbody />');
          $container.empty().append($table);
        }
        $tBody = documentFilter.drawTableRows(data.results);
        $container.find('.document-list tbody').replaceWith($tBody);
        $container.append(documentFilter.drawPagination(data));
      } else {
        $container.empty();
        $container.append('<div class="no-results"><h2>There are no matching documents.</h2>' +
                        '<p>Try making your search broader and try again.</p></div>');
      }
    },
    extendTable: function(data){
      var $container = $('.filter-results');
      if (data.results.length > 0) {
        var $tBody = $container.find('tbody'),
            $rows = documentFilter.drawTableRows(data.results);

        $tBody.append($rows.contents());

        $container.find('nav').remove();
        $container.append(documentFilter.drawPagination(data));
      }
    },
    updateAtomFeed: function(data) {
      if (data.atom_feed_url) {
        $(".subscribe a.feed").attr("href", data.atom_feed_url);
      }
    },
    submitFilters: function(e){
      e.preventDefault();
      var $form = documentFilter.$form,
          $submitButton = $form.find('input[type=submit]'),
          url = $form.attr('action'),
          params = $form.serializeArray();

      $submitButton.addClass('disabled');
      documentFilter.loading = true;
      // TODO: make a spinny updating thing
      $.ajax(url, {
        cache: false,
        dataType:'json',
        data: params,
        complete: function(){
          documentFilter.loading = false;
        },
        success: function(data) {
          documentFilter.updateAtomFeed(data);
          if (data.results) {
            documentFilter.drawTable(data);
          }
          var newUrl = url + "?" + $form.serialize();
          history.pushState(documentFilter.currentPageState(), null, newUrl);
          window._gaq && _gaq.push(['_trackPageview', newUrl]);
          // undo double-click protection
          $submitButton.removeAttr('disabled').removeClass('disabled');
        },
        error: function() {
          $submitButton.removeAttr('disabled');
        }
      });
    },
    currentPageState: function() {
      return {
        html: $('.filter-results').html(),
        selected: $.map(documentFilter.$form.find('select'), function(n) {
          var $n = $(n);
          return {id: $n.attr('id'), value: $n.val()};
        }),
        text: $.map(documentFilter.$form.find('input[type=text]'), function(n) {
          var $n = $(n);
          return {id: $n.attr('id'), value: $n.val()};
        }),
        checked: $.map(documentFilter.$form.find('input[type=radio]:checked'), function(n) {
          return $(n).attr('id');
        })
      };
    },
    onPopState: function(event) {
      if (event.state && event.state.html) {
        $('.filter-results').html(event.state.html);
        $.each(event.state.selected, function(i, selected) {
          $("#" + selected.id).val(selected.value);
        });
        $.each(event.state.text, function(i, text) {
          $("#" + text.id).val(text.value);
        });
        $.each(event.state.checked, function(i, checked) {
          $("#" + checked).attr('checked', true);
        });
      }
    },
    loadMoreInline: function(){
      var $next = $('#show-more-documents .next a'),
          url;

      if(!documentFilter.loading && $next.length > 0){
        url = $next.attr('href');
        documentFilter.loading = true;
        $.ajax(url, {
          cache: false,
          dataType:'json',
          complete: function(){
            documentFilter.loading = false;
            $('.infinite.loading').removeClass('loading');
          },
          success: function(data) {
            if (data.results) {
              documentFilter.extendTable(data)
            }
          }
        });
      }
    },
    initScroll: function(){
      documentFilter.scrolled = false;
      $('#show-more-documents .previous-next-navigation').addClass('infinite');

      $(window).scroll(function(){
        documentFilter.scrolled = true;
      });

      var scrollInterval = window.setInterval(documentFilter.onScroll, 250);
    },
    onScroll: function(){
      if(documentFilter.scrolled){
        documentFilter.scrolled = false;
        var $window = $(window),
            $nav = $('.previous-next-navigation'),
            bottomOfWindow = $window.scrollTop() + $window.height(),
            navOffset = $nav.offset();

        documentFilter.hideFooter();
        $nav.addClass('loading').find('.next a').text('Loading more...');
        if(navOffset && (bottomOfWindow + 100 > navOffset.top)){
          documentFilter.loadMoreInline();
        } else {
          documentFilter.showFooter();
        }
      }
    },
    hideFooter: function(){
      if(documentFilter.footerHidden !== true){
        $('#footer').addClass('visuallyhidden');
        documentFilter.footerHidden = false;
      }
    },
    showFooter: function(){
      var $next = $('#show-more-documents .next a');

      if($next.length === 0){
        $('#footer').removeClass('visuallyhidden');
      }
    }
  };
  window.GOVUK.documentFilter = documentFilter;

  var enableDocumentFilter = function() {
    this.each(function(){
      if (window.GOVUK.support.history()) {
        var $form = $(this);
        $(window).on('popstate', function(evet) {
          documentFilter.onPopState(event);
        });
        documentFilter.$form = $form;

        history.replaceState(documentFilter.currentPageState(), null);
        $form.submit(documentFilter.submitFilters);
        $form.find('select').change(function(e){
          $form.submit();
        });
      }
      if($('#show-more-documents .previous').length === 0){
        documentFilter.initScroll();
      }
    });
    return this;
  }

  $.fn.extend({
    enableDocumentFilter: enableDocumentFilter
  });
})(jQuery);
