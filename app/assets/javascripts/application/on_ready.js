jQuery(function($) {
  $("#notes_to_editors").addToggleLink(".notes_to_editors");
  $("abbr.time_ago").timeago();
  $('section.featured_items').equalHeightHelper({selectorsToResize: ['h2 a', 'p.summary', 'div.image_summary']});
  $('section.article_group').equalHeightHelper({selectorsToResize: ['article']});
  $('#featured-news-articles').equalHeightHelper({selectorsToResize: ['.img img']});
  $('.change_notes').policyUpdateNotes({link:'.link-to-change-notes'});
  $('#global-nav').each(function () {
    $(this).find('.inner ul').append($.li('', '.st'));
  }).navHelper({
    breakpoints: [
      { width: 540, label: 'All sections', exclude: '.home, .current' },
      { width: 850, label: 'More sections', exclude: '.home, .current, .primary' }
    ],
    appendTo: '#global-nav .inner li.st'
  });

  var betaInfo = function(){
    $("#toggle-section").live("click", function(e){
      if($(".show-beta").length != 0){
        $(".icon-key").removeClass("offset");
        $(".beta-info").removeClass("offset");
        $(this).removeClass("show-beta");
      }
      else{
        $(this).addClass("show-beta");
        $(".icon-key").addClass("offset")
        $(".beta-info").addClass("offset")
      }
      e.preventDefault();
    })
  }


  var inside_gov = $(".inside_gov_home");
  if(inside_gov.length != 0){
    $(".recently_updated").news_ticker();
    betaInfo();
  }
  $('section.featured_carousel').each(function () {
    $(this).addClass('slider');
    $(this).find('article').addClass('slide');
    $(this).wrap($.div('', '.slider_wrap'));
    $('.slider_wrap').carousel({
      slider: '.slider',
      slide: '.slide',
      addNav: true,
      addPagination: false,
      namespace: 'carousel',
      speed: 300 // ms.
    });
  });

  $('.filter-controls .toggle').click(function() {
    var is_visible = $('.filter-controls li:not(.top,.selected)').first().is(':visible');
    $('.filter-controls li:not(.top,.selected)').toggle(!is_visible);
    $(this).hide();
  });

});