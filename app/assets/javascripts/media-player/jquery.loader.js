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
    var $vimeo_links = $("a[href*='http://vimeo.com/']");
    var $media_links = $("a[href$='flv'], a[href$='mp4'], a[href$='ogv']");
    var $audio_links = $("a[href$='mp3']");
    
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

	// Iterate through the links to vimeo 
	// instantiating a player instance for each
	$.each($vimeo_links, function(i) {
    	var $holder = $('<span />');
        $(this).parent().replaceWith($holder);
        // Find the captions file if it exists
        var $mycaptions = $(this).siblings('.captions');
        // Work out if we have captions or not
        var captionsf = $($mycaptions).length > 0 ? $($mycaptions).attr('href') : null;
        // Ensure that we extract the last part of the vimeo link (the video id)
        // and pass it to the player() method
        var link = $(this).attr('href').split("/")[3];
        // Initialise the player
        $holder.player({
            id:'vimeo'+i,
            url: 'http://vimeo.com/moogaloop.swf?clip_id=',
            media:link,
			captions:captionsf
        }, vimeoconfig);
    });

    // Create players for our audio links
    $.each($audio_links, function(i) {
        var $holder = $('<span />');
        $(this).parent().replaceWith($holder);
        // Get the path/url tpo the audio file
        var link = $(this).attr('href');
        // Create an instance of the player 
        $holder.player({
            id:'audio'+i,
            media:link,
        	flashHeight: 50,
        	url: '../custom/javascript/config/jwplayer-5/core/player.swf',
            playerWidth: '270px',
            swfCallback : jwPlayerReady
        }, jwconfig);
    });

    // Create players for our media links
    $.each($media_links, function(i) {
        var $holder = $('<span />');
        // Extract the url/path from the links href attribute
        var link = $(this).attr('href');
        // Grab the captions if they exist
		var $captions = $(this).siblings('.captions');
		// Work out if the video has captions
		var captionsFile = $($captions).length > 0 ? $($captions).attr('href') : '';
		$(this).parent().replaceWith($holder);
		// Instantiate the jwplayer
        $holder.player({
            id:'jw'+i,
            media:link,
			captions:captionsFile,
        	flashHeight: 300,
        	url: '../custom/javascript/config/jwplayer-5/core/player.swf',
        	swfCallback : jwPlayerReady
        }, jwconfig);
    });

});