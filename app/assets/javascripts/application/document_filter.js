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
    formType: '',

    renderTable: function(data) {
      $('.js-filter-results').mustache('documents-_filter_table', data);
    },
    updateAtomFeed: function(data) {
      if (data.atom_feed_url) {
        $(".feeds .feed").attr("href", data.atom_feed_url);
        $(".feed-panel input").val(data.atom_feed_url);
      }
    },
    updateEmailSignup: function(data) {
      if (data.email_signup_url) {
        $(".feeds .govdelivery").attr("href", data.email_signup_url);
      }
    },
    updateFeeds: function(data) {
      $(".feeds").removeClass('js-hidden');
      documentFilter.updateAtomFeed(data);
      documentFilter.updateEmailSignup(data);
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
      $(".feeds").addClass('js-hidden');
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
          documentFilter.updateFeeds(data);
          if (data.results) {
            documentFilter.renderTable(data);
            documentFilter.liveResultSummary(data);
          }

          var newUrl = url + "?" + $form.serialize();
          history.pushState(documentFilter.currentPageState(), null, newUrl);
          window._gaq && _gaq.push(['_trackPageview', newUrl]);
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
          $title = $('.headings-block h1'),
          summary = '',
          formStatus = documentFilter.currentPageState(),
          context = {},
          i, _i, j, _j, field;

      $selections.html('');
      $title.find('span').remove();

      if (!data.result_type) {
        data.result_type = "result";
      }

      context.result_count = documentFilter._numberWithDelimiter(data.total_count);
      context.pluralized_result_type = documentFilter._pluralize(data.result_type, data.total_count);

      if(formStatus.selected) {
        for(i=0,_i=formStatus.selected.length; i<_i; i++) {
          field = formStatus.selected[i];

          if (field.title.length > 0) {
            if (field.id == "publication_filter_option" || field.id == "announcement_type_option") {
              if (field.value != "all") {
                $title.html($title.text().trim() + '<span>: '+field.title[0]+'</span>');
              }
            } else if (field.id === 'world_locations'){
              context.world_locations = [];
              for(j=0, _j=field.title.length; j<_j; j++){
                if(field.value[j] !== 'all'){
                  context['world_locations'].push({
                    name: field.title[j],
                    url: documentFilter.urlWithout(field.id, field.value[j]),
                    value: field.value[j],
                    joining: (j < _j-1 ? 'and' : '')
                  });
                }
              }
              if (context.world_locations.length > 0) {
                context['world_locations_any?'] = true;
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
            } else if (field.id === 'from_date'){
              context['date_from'] = field.value
            } else if (field.id === 'to_date'){
              context['date_to'] = field.value
            }
          }
        }
      }

      if (formStatus.checked) {
        for (i=0, _i=formStatus.checked.length; i<_i; i++) {
          field = formStatus.checked[i];
          if (field.id === 'relevant_to_local_government' && field.value === '1') {
            context.relevant_to_local_government = true;
          } else if (field.id === 'include_world_location_news' && field.value === '1') {
            context.include_world_location_news = true;
          }
        }
      }

      $selections.mustache('documents/_filter_selections', context);
    },
    removeFilters: function(field, removed){
      var selects = ['topics', 'departments', 'world_locations'],
          inputs = ['keywords', 'from_date', 'to_date'],
          checkboxes = ['relevant_to_local_government'];

      if($.inArray(field, selects) > -1){
        var $options = $("select option[value='"+removed+"']");
        if($options.length){
          $options.removeAttr("selected");
          var $select = $options.closest("select");
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
        html: $('.js-filter-results').html(),
        selected: $.map(documentFilter.$form.find('select'), function(n) {
          var $n = $(n),
              id = $n.attr('id'),
              titles = [],
              values = [];
          $("#" + id  + " option:selected").each(function(){
            titles.push($(this).text());
            values.push($(this).attr('value'));
          });
          return {id: id, value: values, title: titles};
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
        $('.js-filter-results').html(event.state.html);
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
    _numberWithDelimiter: function(x) {
      var parts = x.toString().split(".");
      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      return parts.join(".");
    },
    _pluralize: function(word, count) {
      if (count === 1) {
        return word;
      }
      else {
        if (word.slice(-1) === 'y') {
          return word.slice(0, -1) + 'ies';
        }
        else {
          return word + 's';
        }
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
        documentFilter.formType = $form.attr('action').split('/').pop();

        history.replaceState(documentFilter.currentPageState(), null);

        $form.submit(documentFilter.submitFilters);

        var delay = (function(){
          var timer = 0;
          return function(callback, ms){
            clearTimeout (timer);
            timer = setTimeout(callback, ms);
          }
        })();

        $form.find('select, input[type=checkbox]').change(function() {
          $form.submit();
        });

        $('#keyword-filter').add('#date-range-filter').find('input[type=text]').keyup(function () {
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
    });
    return this;
  }

  $.fn.extend({
    enableDocumentFilter: enableDocumentFilter
  });
})(jQuery);
