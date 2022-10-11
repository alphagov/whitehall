(function ($) {
  function parseYoutubeVideoId (string) {
    var parts
    var params = {}

    if (string.indexOf('youtube.com') > -1) {
      parts = string.split('?')
      if (parts.length === 1) {
        return
      }
      parts = parts[1].split('&')
      for (var i = 0, _i = parts.length; i < _i; i++) {
        var part = parts[i].split('=')
        params[part[0]] = part[1]
      }
      return params.v
    }
    if (string.indexOf('youtu.be') > -1) {
      parts = string.split('/')
      return parts.pop()
    }
  }

  var enhanceYoutubeVideoLinks = function () {
    this.find("a[href*='youtube.com'], a[href*='youtu.be']").each(function (i) {
      var $link = $(this)
      var videoId = parseYoutubeVideoId($link.attr('href'))
      var $holder = $('<span />')
      var $captions = $link.siblings('.captions')

      if (typeof videoId !== 'undefined') {
        $link.parent().replaceWith($holder)

        $holder.player({
          id: 'youtube-' + i,
          media: videoId,
          captions: $captions.length > 0 ? $captions.attr('href') : null,
          url: (document.location.protocol + '//www.youtube.com/apiplayer?enablejsapi=1&version=3&playerapiid=')
        })
      }
    })
  }

  $.fn.extend({
    enhanceYoutubeVideoLinks: enhanceYoutubeVideoLinks
  })
})(jQuery)
