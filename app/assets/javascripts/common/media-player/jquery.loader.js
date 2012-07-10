/**
*    The Nomensa accessible media player is a flexible multimedia solution for websites and intranets.  
*    The core player consists of JavaScript wrapper responsible for generating an accessible HTML toolbar 
*    for interacting with a media player of your choice. We currently provide support for YouTube (default),
*    Vimeo and JWPlayer although it should be possible to integrate the player with almost any media player on
*    the web (provided a JavaScript api for the player in question is available).
*    
*    Copyright (C) 2012  Nomensa Ltd
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/


$(document).ready(function() {
/*
 * There are many ways in which you can load the Accessible Media Player. The best method 
 * will vary depending on any implementation and/or CMS restrictions you might have.
 */

  /*
   * OR you could do a jQuery lookup for specific links/file types
   * (simple but potentially less flexible and extra load on the browser)
   */
  var $yt_links = $("a[href*='http://www.youtube.com/watch']");

  // Create players for our youtube links
  $.each($yt_links, function(i) {
    var $holder = $('<span />');
    $(this).parent().replaceWith($holder);
    // Find the captions file if it exists
    var $mycaptions = $(this).siblings('.captions');
    // Work out if we have captions or not
    var captionsf = $($mycaptions).length > 0 ? $($mycaptions).attr('href') : null;
    // Ensure that we extract the last part of the youtube link (the video id)
    // and pass it to the player() method
    var link = $(this).attr('href').split("=")[1];
    // Initialise the player
    $holder.player({
      id:'yt'+i,
      media:link,
      captions:captionsf
    });
  });
});