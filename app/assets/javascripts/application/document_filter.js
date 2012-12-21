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
            $li, $a, $link;

        $nav = $('<nav id="show-more-documents" role="navigation" />').append($ul);
        if (data.next_page_url) {
          $li = $('<li class="next" />');
          $a = $('<a>Next page '+ documentFilter.progressSpan(data.next_page, data.total_pages) +'</a>').attr('href', data.next_page_url);
          $link = $('link[rel=next][type=application/json]');
          if ($link.length) {
            $link.attr("href", data.next_page_url);
          }
          else {
            $ul.append($('<link rel="next" type="application/json" href="' + data.next_page_url + '">'));
          }
          $ul.append($li);
          $li.append($a);
        } else {
          $('link[rel=next][type=application/json]').remove();
        }
      }
      return $nav;
    },
    progressSpan: function(current, total) {
      return '<span>' + current + " of " + total + '</span>';
    },
    importantAttributes: ["id", "title", "url", "type", "updated_at"],
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
            $a = $('<a href="'+ row.url +'" />'),
            attribute;

        $a.text(row.title);
        $a.attr('href', row.url);

        $tableRow.attr('id', row.type + '_' + row.id).addClass((i < 3 ? ' recent' : ''));
        $th.append($a);
        $tableRow.append($th);
        for(attribute in row) {
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
          jsonUrl = url + ".json",
          params = $form.serializeArray();

      $submitButton.addClass('disabled');
      $(".filter-results-summary").find('.selections').text("Loading results…");
      documentFilter.loading = true;
      // TODO: make a spinny updating thing
      $.ajax(jsonUrl, {
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
            documentFilter.liveResultSummary(data, documentFilter.currentPageState());
          }
          var newUrl = url + "?" + $form.serialize();
          history.pushState(documentFilter.currentPageState(), null, newUrl);
          window._gaq && _gaq.push(['_trackPageview', newUrl]);
          // undo double-click protection
          //$submitButton.removeAttr('disabled').removeClass('disabled');

        },
        error: function() {
          $submitButton.removeAttr('disabled');
        }
      });
    },
    liveResultSummary: function(data, formStatus){
      var $selections = $('.selections'),
          $title = $('.page_title'),
          summary = '';

      $selections.html('');
      $title.find('span').remove();

      if (data.total_count > 0) {
        summary = 'Showing <span class="count">' + data.total_count +' result';
        if (data.total_count != 1) summary += 's';
        summary += '</span> ';
      } else {
        summary = 'No results ';
      }

      if(formStatus.selected) {
        var i = formStatus.selected.length;

        while(i--) {
          var j = formStatus.selected[i].title.length;

          if (j > 0) {
            if (formStatus.selected[i].id == "publication_filter_option") {
              if (formStatus.selected[i].value != "all") {
                $title.append('<span>: '+formStatus.selected[i].title[0]+'</span>');
              }
            } else if (formStatus.selected[i].id != 'sub_orgs' && formStatus.selected[i].id != 'date') {
              if (formStatus.selected[i].id == 'topics') {
                summary += 'about ';
              } else if (formStatus.selected[i].id == 'departments') {
                summary += 'published by ';
              }

              summary += '<span class="'+formStatus.selected[i].id+'-selections chosen"> ';

              while(j--) {
                var selection = "<span>"+formStatus.selected[i].title[j]+" <a href='' data-val='"+formStatus.selected[i].value[j]+"' title='Remove this filter'>&times;</a></span> ";
                if (j > 1) {
                  selection += ", ";
                } else if (j == 1 && formStatus.selected[i].title.length > 1) {
                  selection += " and ";
                }

                summary += selection;
              }

              summary += '</span> ';
            }


          }
        }

      }

      $selections.html(summary);

      documentFilter.filterEvents();
    },
    filterEvents: function(){
      $(".selections .chosen span a").on("click", function(){
        documentFilter.removeFilters($(this).attr("data-val"));
        $(this).parent().remove();
        return false;
      });
    },
    removeFilters: function(removed){
      var options = $("select option");
      $(options).each(function(){
        if($(this).attr("value") == removed){
          $(this).removeAttr("selected");
          var $select = $(this).parent("select");
          if($select.children("option:selected").length == 0){
            $select.find(">:first-child").prop("selected", true);
          };
          $(this).parent("select").change();
        }
      });
    },
    currentPageState: function() {
      return {
        html: $('.filter-results').html(),
        selected: $.map(documentFilter.$form.find('select'), function(n) {
          var $n = $(n);
          var id = $n.attr('id');
          var titles = [];
          $("#" + id  + " option:selected").each(function(){
            titles.push($(this).text());
          });
          return {id: id, value: $n.val(), title: titles};
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
      var $url = $('link[rel=next][type=application/json]').attr('href')

      if(!documentFilter.loading && $url){
        documentFilter.loading = true;
        $.ajax($url, {
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
    if (window.ieVersion && ieVersion === 6) {
      return this;
    }
    this.each(function(){
      if (window.GOVUK.support.history()) {
        var $form = $(this);
        $(window).on('popstate', function(evet) {
          documentFilter.onPopState(event);
        });
        documentFilter.$form = $form;

        history.replaceState(documentFilter.currentPageState(), null);
        $form.submit(documentFilter.submitFilters);
        $form.find('select, input[name=direction]:radio').change(function(e){
          $form.submit();
        });

        var delay = (function(){
          var timer = 0;
          return function(callback, ms){
            clearTimeout (timer);
            timer = setTimeout(callback, ms);
          }
        })();

        $('#keyword-filter')
        .find('input[name=keywords]').keyup(function () {
          delay(function () {
            $form.submit();
          }, 600);
        });

        $(".submit").addClass("js-hidden");

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
