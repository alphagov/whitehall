(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var dmp = new diff_match_patch();

  var diff = function(text1, text2, output) {
    var text1 = text1.text();
    var text2 = text2.text();

    var d = dmp.diff_main(text1, text2);
    dmp.diff_cleanupEfficiency(d);

    var ds = dmp.diff_prettyHtml(d);
    output.html(ds);
  };
  root.GOVUK.diff = diff;
}).call(this);
