jQuery(document).ready(function($) {
  $(".flash.notice, .flash.alert").flashNotice();

  // This is useful for toggling CSS helpers
  // whilst developing.. cmd+G
  var showGrid = function () {
    var gId = 'grid-helper';
    var gh = $('#' + gId);
    if (gh.length == 0) {
      gh = $.div('', {class: 'group', id: gId});
      gh.css({height: $('body').height()});

      var g3 = $.div('', '.g3');

      g3.css({"margin-top": -$('body').height()});

      g3.append($.div('', '.g1'), $.div('', '.g1'), $.div('', '.g1'));

      gh.append(g3);

      $('#wrapper').append(gh);
    }
  }

  var hideGrid = function () {
    $('#grid-helper').remove();
  }

  var altKey = '18'
  var altDown = false;
  var gKey = '71';
  $('body').keydown(function(event) {
    if (event.keyCode == altKey) {
      altDown = true;
    }
    if (altDown && event.keyCode == gKey) {
      event.preventDefault();
      $(this).toggleClass('dev');
      if ($(this).hasClass('dev')) {
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
});
