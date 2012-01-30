jQuery(document).ready(function($) {
  if (document.URL.match('whitehall.dev')) {
    // This is useful for toggling CSS helpers
    // whilst developing.. alt+G
    var altKey = '18'
    var altDown = false;
    var gKey = '71';
    var gId = 'grid-helper';
    var devClass = 'dev';

    var grid = function () {
      return $('#' + gId);
    }

    var showGrid = function () {
      var gh = grid();
      if (gh.length == 0) {
        gh = $.div('', {'class': 'group', 'id': gId});
        gh.css('height', 0);
        var g3 = $.div('', '.g3');
        g3.css({"height": $('body').height()});
        g3.append($.div('', '.g1'), $.div('', '.g1'), $.div('', '.g1'));
        gh.append(g3);
        $('#wrapper').append(gh);
        sizeGrid();
      }
    }

    var hideGrid = function () {
      $('#grid-helper').remove();
    }

    var sizeGrid = function () {
      var offset = 24; // Unsure why I need this :(
      grid().find('.g3').css({"margin-top": "-" + (grid().offset().top + offset) + "px"});
    }

    $(window).resize(function () {
      if ($('body').hasClass(devClass)) {
        hideGrid();
        showGrid();
      };
    });

    $('body').keydown(function(event) {
      if (event.keyCode == altKey) {
        altDown = true;
      }
      if (altDown && event.keyCode == gKey) {
        event.preventDefault();
        $(this).toggleClass(devClass);
        if ($(this).hasClass(devClass)) {
          showGrid();
        } else {
          hideGrid();
        }
      }
    }).keyup(function(event) {
      if (event.keyCode == altKey) {
        altDown = false;
      }
    });
  }
});