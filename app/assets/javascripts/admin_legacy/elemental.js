jQuery.elemental = function (element, content, options) {
  var attributes = []

  if (typeof (options) === 'string') {
    var m
    var o

    if (m = options.match(/(\.)([-\w]+)/)) { // eslint-disable-line
      o = { class: m[2] }
    } else if (m = options.match(/(\#)([-\w]+)/)) { //eslint-disable-line
      o = { id: m[2] }
    };

    options = o
  }

  for (var key in options) {
    attributes.push(key + '="' + options[key] + '"')
  }

  var el = $('<' + element + ' ' + attributes.join(' ') + ' />')

  if (typeof (content) === 'string') {
    el.text(content)
  } else if (content != null) {
    el.append(content)
  }

  return el
}

jQuery(['div', 'span', 'ul', 'ol', 'li', 'a', 'p']).each(function () {
  var element = this
  $[element] = function () {
    return $.elemental(element, arguments[0], arguments[1])
  }
})
