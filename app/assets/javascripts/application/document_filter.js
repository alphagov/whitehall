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
    importantAttributes: ["id", "title", "url", "type", "public_timestamp"],
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
          var newUrl = url + "?" + $form.serialize();
          history.pushState(documentFilter.currentPageState(), null, newUrl);
          window._gaq && _gaq.push(['_trackPageview', newUrl]);
          // undo double-click protection
          //$submitButton.removeAttr('disabled').removeClass('disabled');

          if (data.results) {
            documentFilter.drawTable(data);
            documentFilter.liveResultSummary(data);
          }
        },
        error: function() {
          $submitButton.removeAttr('disabled');
        }
      });
    },
    urlWithout: function(object, value){
      var url = window.location.search,
          reg = new RegExp('&?'+object+'%5B%5D='+value+'&?');

      return url.replace(reg, '&')
    },
    urlWithoutKeyword: function(words, index){
      var url = window.location.search,
          reg = new RegExp('keywords=[^&]+'),
          newKeywords = [],
          i, _i;

      for(i=0,_i=words.length; i<_i; i++){
        if(i !== index){
          newKeywords.push(words[i]);
        }
      }
      return url.replace(reg, 'keywords='+ newKeywords.join('+'));
    },
    liveResultSummary: function(data){
      var $selections = $('.selections'),
          $title = $('.page_title'),
          summary = '',
          formStatus = documentFilter.currentPageState(),
          context = {},
          i, _i, j, _j, field;


      $selections.html('');
      $title.find('span').remove();

      if (data.total_count > 0) {
        context.result_count = 'Showing ' + data.total_count +' result' + ( data.total_count != 1 ? 's' : '');
      } else {
        context.result_count = 'No results ';
      }

      if(formStatus.selected) {
        for(i=0,_i=formStatus.selected.length; i<_i; i++) {
          field = formStatus.selected[i];

          if (field.title.length > 0) {
            if (field.id == "publication_filter_option" || field.id == "announcement_type_option") {
              if (field.value != "all") {
                $title.html($title.text().trim() + '<span>: '+field.title[0]+'</span>');
              }
            } else if (field.id != 'sub_orgs' && field.id != 'date') {
              context[field.id] = [];

              for(j=0, _j=field.title.length; j<_j; j++){
                if(field.value[j] !== 'all'){
                  context[field.id].push({
                    name: field.title[j],
                    url: documentFilter.urlWithout(field.id, field.value[j]),
                    value: field.value[j],
                    joining: (j < _j-1 ? 'and' : '')
                  });
                }
              }
            } else if (field.id === 'date'){
              context[field.id] = {
                date: field.title[0],
                direction: formStatus.checked[0].value
              }
            }
          }
        }
      }
      if(formStatus.text) {
        for(i=0,_i=formStatus.text.length; i<_i; i++) {
          field = formStatus.text[i];

          if(field.value.length){
            if(field.id === 'keywords'){
              context['keywords_any?'] = true;
              context.keywords = [];

              var words = field.value.trim().split(/\s+/);
              for(j=0, _j=words.length; j<_j; j++){
                context.keywords.push({
                  name: words[j],
                  url: documentFilter.urlWithoutKeyword(words, j-1),
                  joining: (j < _j-1 ? 'or' : '')
                });
              }
            }
          }
        }
      }

      if (formStatus.checked) {
        for (i=0, _i=formStatus.checked.length; i<_i; i++) {
          field = formStatus.checked[i];
          if (field.id === 'relevant_to_local_government' && field.value === '1') {
            context.relevant_to_local_government = true;
          }
        }
      }

      $selections.mustache('documents/_filter_selections', context);
    },
    removeFilters: function(field, removed){
      var selects = ['topics', 'departments'],
          inputs = ['keywords'],
          checkboxes = ['relevant_to_local_government'];

      if($.inArray(field, selects) > -1){
        var $options = $("select option[value='"+removed+"']");
        if($options.length){
          $options.removeAttr("selected");
          var $select = $options.parent("select");
          if($select.find(':selected').length === 0){
            $select.find(">:first-child").prop("selected", true);
          };
          $select.change();
        }
      } else if ($.inArray(field, inputs) > -1){
        var $input = $("input#"+field);
        if($input.length){
          var value = $input.val(),
              reg = new RegExp(removed);
          $input.val(value.replace(reg, '').trim())
        }
        $input.parents('form').submit();
      } else if ($.inArray(field, checkboxes)) {
        var $checkbox = $('input#' + field);
        if ($checkbox.length) {
          $checkbox.attr('checked', false);
        }
        $checkbox.parents('form').submit();
      }
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
        checked: $.map(documentFilter.$form.find('input[type=radio]:checked, input[type=checkbox]:checked'), function(n) {
          var $n = $(n);
          return {id: $n.attr('id'), value: $n.val()};
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
          $("#" + checked.id).attr('checked', true);
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
        $form.find('select, input[name=direction]:radio, input:checkbox').change(function(e){
          $form.submit();
        });

        var delay = (function(){
          var timer = 0;
          return function(callback, ms){
            clearTimeout (timer);
            timer = setTimeout(callback, ms);
          }
        })();

        $('#keyword-filter').find('input[name=keywords]').keyup(function () {
          delay(function () {
            $form.submit();
          }, 600);
        });

        $('.filter-results-summary').delegate('a', 'click', function(e){
          e.preventDefault();
          documentFilter.removeFilters($(this).data('field'), $(this).data("val"));
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
