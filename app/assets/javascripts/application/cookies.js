// Cookies
//
// Get or set cookie values
//
// Usage:
//
//    GOVUK.cookie('myCookie');
//
//      returns the value of 'myCookie';
//
//    GOVUK.cookie('myCookie', 'hobnob', 30);
//
//      sets the cookie 'myCookie' to 'hobnob' for 30 days.
//


(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.cookie = function(name, value, days){
    if(typeof value !== 'undefined'){
      return root.GOVUK.setCookie(name, value, days);
    } else {
      return root.GOVUK.getCookie(name);
    }
  };

  root.GOVUK.setCookie = function(name, value, days){
    var cookieString = name + "=" + value + "; path=/";
    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      cookieString = cookieString + "; expires=" + date.toGMTString();
    }
    if (document.location.protocol == 'https:'){
      cookieString = cookieString + "; Secure";
    }
    root.document.cookie = cookieString;
  };

  root.GOVUK.getCookie = function(name){
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i = 0, len = ca.length; i < len; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1, c.length);
      }
      if (c.indexOf(nameEQ) === 0) {
        return c.substring(nameEQ.length, c.length);
      }
    }
    return null;
  };
}).call(this);
