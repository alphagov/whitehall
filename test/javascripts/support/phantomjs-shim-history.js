
if (navigator.userAgent.toLowerCase().indexOf('phantom') > -1) {
  // slimmest possible history-api shim for phantomjs
  // it's not clear if phantomjs actually supports the history-api or not
  // but if it does it doesn't allow it to be stubbed by sinon as it doesn't
  // think the pushState and replaceState functions are actually functions,
  // nor does it allow them to be assigned to new functions, so we have to
  // shim out the entire history object.

  var oldHistory = window.history;
  window.history = {}

  history.pushState = function(state, title, url) {
    history.state = state;
    return history.state;
  };
  history.replaceState = function(state, title, url) {
    history.state = state;
    return history.state;
  };
  history.go = oldHistory.go;
  history.length = 1;
}
