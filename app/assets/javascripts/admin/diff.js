(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var dmp = new diff_match_patch();
  dmp.Diff_EditCost = 6;

  root.GOVUK.diff = function(section) {
    var $section = $('#'+section);

    var $a = $section.find('.previous-version');
    var $b = $section.find('.current-version');

    var rawDiff = dmp.diff_main($a.text(), $b.text());
    dmp.diff_cleanupEfficiency(rawDiff);

    var htmlDiff = dmp.diff_prettyHtml(rawDiff);

    $a.remove();
    $b.html(htmlDiff);
  };
}).call(this);
