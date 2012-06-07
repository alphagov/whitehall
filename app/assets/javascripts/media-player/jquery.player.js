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

// Bind function to resize event of the window/viewport
$(document).ready(function() {
	$(window).resize(function(){
        $('.player-container').each(function() {
            if($(this).width()>580) {
				$(this).addClass('player-wide');
			} else {
				$(this).removeClass('player-wide');
			}    
	    });
	});
});

/*
* Global object used for managing all the players on our page
* Use the getPlayer, addPlayer and removePlayer methods for 
* modifying the players within the PlayerManager
*---------------------------------------------------------*/
var PlayerManager = function(){
	//This is where we will store all of our player instances
	var players = {};	
	/*
	* Use this method for retrieving a player from the player list
	* @param playerID {string}: The id of the player object that we want to retrieve
	* @return {object}: Instance of a player if one with identical playerid exists, otherwise null
	*---------------------------------------------------------*/
	this.getPlayer = function(playerID){
		if(players[playerID] != undefined){
			return players[playerID];
		}
		return null;
	};
	/*
	* Use this method for adding a player to the player list
	* @param player {object}: The player object that we want to add to our PlayerManagers players list
	* @return {bool}: True if the player was added to the list, false if it already exists within the list
	*---------------------------------------------------------*/
	this.addPlayer = function(player){
		if(players[player.config.id] == undefined){
			players[player.config.id] = player;
			return true;
		}
		return false;
	};
	/*
	* Use this method for removing a player from the player list
	* @param playerID {string}: The id of the player object that we want to delete
	*---------------------------------------------------------*/
	this.removePlayer = function(playerID){
		if(players[playerID] != undefined){
			delete players[playerID];
		}
	};
};

/*
* Create a new instance of our PlayerManager object 
* See object above for info on how this works
*----------------------------------------------------*/
var PlayerDaemon = new PlayerManager();

/*
* Methods for and HTML5 video player.  These should be browser and implementation inspecific. 
* As such there should not be any need to change these controls on a per client basis
* 
* @note: all of the player controls should be included here.  The methods in this plugin 
* may be overridden by another config before we get to merging in HTML5 controls
* As such, any player interface control included in the plugin methods should also be included here
*
* @note: We will always assume that a players volume will be between 1 and 100.  The HTML5 spec uses
* decimal values between 0 and 1.  Therefore we get and set the volume ensuring that we multiply by or 
* divide by 100 to get a percentage value
*-----------------------------------------------------------------------------------------------------*/
var html5_methods = {
		play : function(){this.player.play();this.setSliderTimeout();if(this.config.captionsOn && this.captions){this.setCaptionTimeout();}},
		pause : function(){this.player.pause();this.clearSliderTimeout();if(this.config.captionsOn && this.captions){this.clearCaptionTimeout();}},
		ffwd : function(){var time = this.getCurrentTime() + this.config.player_skip;this.seek(time);},
		rewd : function(){var time = this.getCurrentTime() - this.config.player_skip;if(time < 0){time = 0;}this.seek(time);},
		mute : function(){var $button = this.$html.find('button.mute');if(this.player.muted){this.player.muted = false;if($button.hasClass('muted')){$button.removeClass('muted');}}else{this.player.muted = true;$button.addClass('muted');}},
		volup : function(){var vol = this.player.volume * 100;if(vol < (100 - this.config.volume_step)){vol += this.config.volume_step;}else{vol = 100;}this.player.volume = (vol/100);this.updateVolume(Math.round(vol));},
		voldwn : function(){var vol = this.player.volume * 100;if(vol > this.config.volume_step){vol -= this.config.volume_step;}else{vol = 0;}this.player.volume = (vol/100);this.updateVolume(Math.round(vol));},
		getDuration : function(){return this.player.duration;},
		getCurrentTime : function(){return this.player.currentTime;},
		getBytesLoaded : function(){return this.player.buffered.end(0);},
		getBytesTotal : function(){
			if(this.player.seekable != undefined){	
				return this.player.seekable.end();
			}else{
				// Some browsers (Firefox 4) will not always have the seekable property
				// If not, just return the duration 
				return this.player.duration;
			}
		},
		seek : function(time){this.player.currentTime = time;},
		cue : function(){return;}	// No queueing required for html5 video, just return
};

/*
* Main plugin function used to create media player HTML and 
* delegate controls to the correct player instance.
* @param options {object}: An object of config options for specific instance of the plugin
* @param functions {object}: A map of functions/methods that will be merged into the player
*   instance when it is created.  Methods/functions defined within this object will override methods
*   defined as part of the 'methods' objects defined below.
* @return {object}: The jQuery wrapped set on which the player method was initially called (allows for chaining).
*----------------------------------------------------*/
(function($) {
	
	// Add the player() method to the jQuery prototype chain
	$.fn.player = function(options, functions) {
		
		// Define the default config settings for the plugin
		var defaults = {
			id: 'media_player',	// The base string used for the player id.  Will end up with an integer appended to it e.g. 'ytplayer0', 'ytplayer1' etc
			url: 'http://www.youtube.com/apiplayer?enablejsapi=1&version=3&playerapiid=',
			media: '8LiQ-bLJaM4',
			repeat: false,	// loop the flash video true/false
            captions: null, // caption XML URL link for caption content 
            captionsOn : true, // Setting for turning the captions on/off by default
            flashWidth: '100%',
			flashHeight: '300px',
			playerStyles : {
					'height' : '100%',
					'width' : '100%'
				},
			sliderTimeout:350,
			flashContainer: 'span',
			playerContainer: 'span', // the container of the flash and controls
			image: '', //thumbnail image URL that appears before the media is played - This needs to be worked into the player
            playerSkip: 10, // amount in seconds the rewind and forward buttons skip
            volumeStep: 10,	// Amount by which to increase or decrease the volume at any given time
            buttons : {
				forward: true,	// Whether or not to show the fast-forward button
				rewind: true,	// Whether or not to show the rewind button
				toggle: true	// If this is set to false, both play and pause buttons will  be provided
			},
			logoURL : 'http://www.nomensa.com?ref=logo',	// A url or path to the logo to use within the player.  
			useHtml5 : true,	// Whether or not the player will make use of HTML5 video (if it is supported)
			swfCallback : null	// If we are using a swf, optionally provide a callback function, currently used with 
		};
		// Merge defaults and options with deep-merge set to true
		var config = $.extend(true, {}, defaults, options);

		/*
		* Method for detecting whether or not HTML5 video is supported
		* @param mimetype {string}: The mimetype for the video in use 
		* as expected in the 'type' attribute of the video element
		* @return {boolean}: True if the browser supports HTML5 video/audio
		* and the mimetype parameter is likely to play in this browser
		*---------------------------------------------------------*/
		var supports_media = function(mimetype, container) {
			var elem = document.createElement(container);
			if(elem.canPlayType != undefined){
				var playable = elem.canPlayType(mimetype);
				if((playable.toLowerCase() == 'maybe')||(playable.toLowerCase() == 'probably')){
					return true;
				}
			}
			return false;
		};
		/*
		* Method for retrieving the mime-type and codec string
		* for the HTML5 video element
		* @param filetype {string}: the file extension
		* @return {object}: (key:'mimetype') the mime-type and associated codecs for use with the html5 video element
		* (key:'container') The type of dom element to create for the type of media used
		* @return {null}: if the mime type is not recognised
		*---------------------------------------------------------*/
		var get_mime = function(filetype){
			var mimetype = '';
			var media_container = 'video';
			switch(filetype){
				case 'mp4':
					mimetype = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"';
				break;
				case 'm4v':
					mimetype = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"';
				break;
				case 'ogg':
					mimetype = 'video/ogg; codecs="theora, vorbis"';
				break;
				case 'ogv':
					mimetype = 'video/ogg; codecs="theora, vorbis"';
				break;
				case 'webm':
					mimetype = 'video/webm; codecs="vp8, vorbis"';
				break;
				case 'mp3':
					mimetype = 'audio/mpeg';
					media_container = 'audio';
				break;
			}
			return {'mimetype':mimetype,'container':media_container};
		};
		/*
		* Function for extracting the media file extension such as mp3, mp4, ogg etc
		* @param player {object}: A media player instance
		* @return {object}: Mime-type for the file and codecs or null if no file type found, also returns the type of media container
		*---------------------------------------------------------*/
		var get_media_type = function(player){
			var media = player.config.media;
			var strt = media.lastIndexOf('.');
			if(strt != -1 ){
				var ext = media.substring(strt+1);
				var mime = get_mime(ext);
				return mime;
			}
			return null;
		};
		/*
		* Method for checking to see if the browser is firefox four
		* We do this because ff4 has a nasty flash keyboard trap
		* If the function returns true, we add a tabindex of -1 to the object
		* tags.  This removes them from the tabbing order and thus removes the trap
		* @NOTE: This is also being used to detect firefox 5 now as flash is also broken for this release
		*----------------------------------------------*/
		var isFirefox = function(){
			if($.browser.mozilla){
				return ( parseInt($.browser.version, 10) >= 2) ? true : false;
			}
			return false;
		};
		
		// Let's just store all of our methods for the media player in an object.
		// These will be merged with the media player instance down the line
		var methods = {
			/*
			* Method for creating our reference to the player object and queueing a video
			* ready for playback.  This method is called by specific players callback function
			* via the player daemon
			* @param player {object}: The player manager through which we will execute our commands such as play, pause etc
			* @note: If the player does not need to cue the video, just override the cue method returning false or null 
			*-----------------------------------------------------------------------------------------------------------*/
			init : function(player){
				// Add the reference to the player manager to our media player instance
				this.player = player;
				// Cue the video
				this.cue();
				/* 
				* Add our player specific event listeners
				* This one listens for the onStateChange event and calls the 
				* playerState function at the bottom of this document
				*---------------------------------------------------------*/
				this.player.addEventListener("onStateChange", '(function(state) { return playerState(state, "' + this.config.id + '"); })');
			},
			/*
			* Method for creating a container that
			* holds the flash and the controls
			* @return {obj}: A jQuery wrapped set
			*---------------------------------------------------------*/
			generatePlayerContainer : function() {
				var $container = $('<'+this.config.playerContainer+' />').css(this.config.playerStyles).addClass('player-container');
				if($.browser.msie){
					$container.addClass('player-container-ie player-container-ie-'+$.browser.version.substring(0, 1));
				}
				return $container;
			},
			/*
			* Get an object containing some flashvars
			* @return {obj}: A map of flashvariables
			*---------------------------------------------------------*/
			getFlashVars : function(){
				var flashvars = {
					controlbar: 'none',
			        file: this.config.media
				};
				// Add extra properties to flashvars if they exist in the config
				if(this.config.image != '') { flashvars.image = this.config.image; }
				if(this.config.repeat) { flashvars.repeat = this.config.repeat; }
				return flashvars;
			},
			/*
			* Get an object containing some parameters for the flash movie
			* @return {obj}: A map of flash parameters
			*---------------------------------------------------------*/
			getFlashParams : function(){
				return {
					allowScriptAccess: "always",
					wmode: 'transparent'
				};
			},
			/*
			* Method for getting the url to embed the player
			* Youtube player allows you to pass an id in as part of a querystring
			* This will then be passed into the 'onYoutubePlayerReady' function
			* @return {string}: a url
			*---------------------------------------------------------*/
			getURL : function(){
				return [this.config.url, this.config.id].join('');
			},
			/*
			* Method for generating the flash component 
			* for the media player
			* @return {obj}: A jQuery wrapped set
			*---------------------------------------------------------*/
			generateFlashPlayer : function($playerContainer){
				var $self = this;
				/* Get our flash vars */
				var flashvars = this.getFlashVars();
				/* Create some parameters for the flash */
				var params = this.getFlashParams();
				/* Create some attributes for the flash */
				var atts = { 
						id: this.config.id, 
						name: this.config.id
					};
				
				/* Create our flash container with default content telling 
				* the user to download flash if it is not installed 
				*/
				var $container = $('<'+this.config.flashContainer+' />').attr('id', 'player-' + this.config.id).addClass('flashReplace').html('This content requires Macromedia Flash Player. You can <a href="http://get.adobe.com/flashplayer/">install or upgrade the Adobe Flash Player here</a>.');
				/* Create our video container */
				var $videoContainer = $('<span />').addClass('video');
				/* Get the url for the player */
				var url = this.getURL();
				/********************************************************************************************************
				 *  set a timeout of 0, which seems to be enough to give IE time to update its							*
				 *  DOM. Strangest manifested bug on the planet. Details on how it manifested itself					*
				 *  in a project are below:																				*
				 *  - IE breaks flash loading if the img src is external (ie, begins with http://+ any single character)*
				 *	AND																									*
				 *  - If the src is internal AND the content has an <li></li> in a <ul>									*
				 ********************************************************************************************************/
				// This is where we embed our swf using swfobject
				setTimeout(function() {
					swfobject.embedSWF(url, 
							$container.attr('id'), $self.config.flashWidth, 
							$self.config.flashHeight, "9.0.115", null, flashvars, params, atts, $self.config.swfCallback);
					// Dirty hack to remove element from tab index for versions of firefox that trap focus in flash
					if(isFirefox()){
							$self.$html.find('object').attr("tabindex", '-1');
						}
				}, 0);
				// Create our entire player container
				$playerContainer.append($videoContainer.append($container));
				return $playerContainer;
			},
			/*
			* Method for generating the HTML5 video  
			* component for the media player
			* @return {obj}: A jQuery wrapped set
			*---------------------------------------------------------*/
			generateHTML5Player : function($playerContainer, container_type, mime_type){
				var $videoContainer = $('<span />');
				$videoContainer[0].className = 'video';
				var $video = $('<'+container_type+' />').attr({'id':this.config.id, 'src':this.config.media, 'type':mime_type}).css({'width':'100%', 'height':'50%'});
				// If an image/thumbnail has been provided for the video
				if($.trim(this.config.image) != ''){
					$video.attr({'poster':$.trim(this.config.image)});
				}
				return $playerContainer.append($videoContainer.append($video));
			},
			/*
			* Method for adding a button to a container
			* @param name {string}: the name of the button
			* @param action {string}: the action that the button will 
			* trigger such as 'play', 'pause', 'ffwd' and 'rwd'.
			*---------------------------------------------------------*/
			createButton : function(action, name) {
				var $label = 0;
				var btnId = [action, this.config.id].join('-');
				
				var $btn = $('<button />')
							.append(name)
							.addClass(action)
							.attr({'title':action, 'id':btnId})
							.addClass('ui-corner-all ui-state-default')
							.hover(function() {
									$(this).addClass("ui-state-hover");
								},
								function() {
									$(this).removeClass("ui-state-hover"); 
								})
							.focus(function() {
									$(this).addClass("ui-state-focus");
								})
							.blur(function() {
									$(this).removeClass("ui-state-focus"); 
								})
							.click(function(e){
									e.preventDefault();
								});
				
				return $btn;
			},
			/*
			* Method for creating the functional controls such as
			* play, pause, rwd and ffwd buttons
			* @return {obj}: A jQuery wrapped set representing our 
			* controls and container
			*---------------------------------------------------------*/
			getFuncControls : function(){
				var self = this;
				var $cont = $('<div>');
				$cont[0].className = 'player-controls';
				var buttons = [];
				
				// Create play/pause buttons.  If toggle is enabled one button performs both
				// play and pause functions.  Otherwise one button is provided for each
				if(self.config.buttons.toggle){	// If the toggle button is enabled
					var $toggle = self.createButton('play', 'Play').attr({'aria-live':'assertive'}).click(function(){
						if($(this).hasClass('play')){
							$(this).removeClass('play').addClass('pause').attr({'title':'Pause', 'id':'pause-'+self.config.id}).text('Pause');
							self.play();
						}else{
							$(this).removeClass('pause').addClass('play').attr({'title':'Play', 'id':'play-'+self.config.id}).text('Play');
							self.pause();
						}
					});
					buttons.push($toggle);
				}else{	// The toggle button is not enabled, so add play and pause buttons if enabled
						var $play = self.createButton('play', 'Play').click(function(){self.play();});
						var $pause = self.createButton('pause', 'Pause').click(function(){self.pause();});
						buttons.push($play);
						buttons.push($pause);
				}

				// If the rewind button is enabled
				if(self.config.buttons.rewind){
					var $rwd = self.createButton('rewind', 'Rewind').click(function(){self.rewd();});
					buttons.push($rwd);
				}
				// If the ffwd button is enabled
				if(self.config.buttons.forward){
					var $ffwd = self.createButton('forward', 'Forward').click(function(){self.ffwd();});
					buttons.push($ffwd);
				}
				
				// If captions is enabled and we have a captions file
				if(self.config.captions){
					var $capt = self.createButton('captions', 'Captions').click(function(){self.toggleCaptions();});
					var myClass = (self.config.captionsOn == true) ? 'captions-on' : 'captions-off' ;
					$capt.addClass(myClass);
					buttons.push($capt);
				}
				var i;
				// Loop through our buttons adding each one to our container in turn
				for(i=0;i<buttons.length;i=i+1){
					$cont[0].appendChild(buttons[i][0]);
				}

				return $cont;
			},
			/*
			* Method for creating the volume controls such as
			* mute/unmute, Vol Up and Vol Down buttons
			* @return {obj}: A jQuery wrapped set representing our 
			* volume controls and container
			*---------------------------------------------------------*/
			getVolControls : function(){
				var self = this;
				var $cont = $('<div>').addClass('volume-controls');
				var $mute = self.createButton('mute', 'Mute').click(function(){self.mute();});
				var $up = self.createButton('vol-up', '+<span class="ui-helper-hidden-accessible"> Volume Up</span>').click(function(){self.volup();});
				var $dwn = self.createButton('vol-down','-<span class="ui-helper-hidden-accessible"> Volume Down</span>').click(function(){self.voldwn();});
				var $vol = $('<span />').attr({'id':'vol-'+self.config.id, 'class':'vol-display'}).text('100%');
				// Append all of our controls.  Doing it like this since 
				// ie6 dies if we append recursively using native jQuery
				// append method
				var controls = [$mute, $dwn, $up, $vol];
				var i;
				for(i=0;i<controls.length;i=i+1){
					$cont[0].appendChild(controls[i][0]);
				}
				return $cont;
			},
			/*
			* Method for getting the sliderbar for the media player
			* @return {obj}: A jQuery wrapped set, the sliderbar for 
			* the media player
			*---------------------------------------------------------*/
			getSliderBar : function(){
				var $info = $('<span />').addClass('ui-helper-hidden-accessible').html('<p>The timeline slider below uses WAI ARIA. Please use the documentation for your screen reader to find out more.</p>');
				var $curr_time = $('<span />').addClass('current-time').attr({'id':'current-'+this.config.id}).text('00:00:00');
				var $slider = this.getSlider();
				var $dur_time = $('<span />').addClass('duration-time').attr({'id':'duration-'+this.config.id}).text('00:00:00');
				var $bar = $('<div />').addClass('timer-bar').append($info);
				// Append all of our controls.  Doing it like this since 
				// ie6 dies if we append recursively using native jQuery
				// append method
				var bits = [$curr_time, $slider, $dur_time];
				var i;
				for(i=0;i<bits.length;i=i+1){
					$bar[0].appendChild(bits[i][0]);
				}
				return $bar;
			},
			/*
			* Method for creating the sliderbar for the media player
			* @return {obj}: A jQuery wrapped set, the sliderbar for 
			* the media player
			*---------------------------------------------------------*/
			getSlider : function(){
				var self = this;
				var $sliderBar = $('<span />')
					.attr('id', 'slider-'+this.config.id)
					.slider({orientation:'horizontal', change: function(event, ui) {
						// We're making use of the internal jQuery ui stuff here.
						// jQuery UI exposes a 'change' method of the slider widget
						// Allowing us to track state changes to the slider bar and respond
						// by queueing the video to the appropriate point
						var percentage = ui.value;
						var seconds = (percentage/100)*self.getDuration();
						self.seek(seconds);
						}
					});

				// Add our aria attributes to the sliderbar handle link
				$sliderBar.find('a.ui-slider-handle').attr({'role':'slider','aria-valuemin':'0','aria-valuemax':'100','aria-valuenow':'0', 'aria-valuetext':'0 percent', 'title':'Slider Control'});

				var $progressBar = $('<span />')
					.addClass('progress-bar')
					.attr({'id':'progress-bar-'+this.config.id, 'tabindex':'-1'})
					.addClass('ui-progressbar-value ui-widget-header ui-corner-left')
					.css({'width':'0%','height':'95%'});

				var $loadedBar = $('<span />')
					.attr({'id':'loaded-bar-'+this.config.id, 'tabindex':'-1'})
					.addClass('loaded-bar ui-progressbar-value ui-widget-header ui-corner-left')
					.css({'height':'95%', 'width':'0%'});

				return $sliderBar.append($progressBar, $loadedBar);
			},
			/*
			* Method for setting the timeout function for updating the 
			* position of the slider
			* @modifies {obj} this: Adds a reference to the timeout so that 
			* it can be cleared easily further down the line
			*---------------------------------------------------------*/
			setSliderTimeout : function(){
				var self = this;
				self.sliderInterval = setInterval(function() { 
					self.updateSlider();
				}, self.config.sliderTimeout);
			},
			/*
			* Method for clearing the timeout function for updating the 
			* position of the slider
			* @modifies {obj} this: Clears down the reference to the 
			* timeout function
			*---------------------------------------------------------*/
			clearSliderTimeout : function(){
				var self = this;
				if(self.sliderInterval != undefined){
					self.sliderInterval = clearInterval(self.sliderInterval);
				}
			},
			/*
			* Method for updating the position of the slider
			*---------------------------------------------------------*/
			updateSlider : function(){
				
				var duration = (typeof(this.duration) != 'undefined') ? this.duration : this.getDuration();
				var duration_found = (typeof(this.duration_found) == 'boolean') ? this.duration_found : false;
				var current_time = this.getCurrentTime();
				var markerPosition = 0;
				
				//get the correct value to set the marker to, converting time played to %
				if(duration > 0) {
					markerPosition = (current_time/duration)*100;
					markerPosition = parseInt(markerPosition,10);
				}else{	// Some players will return -1 for duration when the player is stopped.  
						// This is not great so set duration to 0
					duration = 0;
				}
				
				// If the duration has not been found yet
				if (!duration_found){
					$('#duration-'+this.config.id).html(this.formatTime(parseInt(duration, 10)));
					this.duration_found = true;
				}
				//Get a reference to the slider, find the slider handle and update the left value
				$('#slider-'+this.config.id)
					.find('a.ui-slider-handle')
					.attr({'aria-valuenow':markerPosition,'aria-valuetext':markerPosition.toString()+' percent'})
					.css('left', markerPosition.toString()+'%');
				
				//Get a reference to the progress bar and update accordingly
				$('#progress-bar-'+this.config.id)
					.attr({'aria-valuenow':markerPosition, 'aria-valuetext':markerPosition.toString()+' percent'})
					.css('width', markerPosition.toString()+'%');
				
				// Update the loader bar
				this.updateLoaderBar();
				// Update the current time as shown to either side of the slider bar
				this.updateTime(current_time);
			},
			/* 
			* Method for updating the loader bar 
			* This has it's own method since loading occurs in the background
			* and may need to update whilst the video is not playing
			*---------------------------------------------------------*/
			updateLoaderBar : function(){
				// Work out how much of the video has loaded
				var loaded = (this.getBytesLoaded()/this.getBytesTotal())*100;
				// Ensure that we have an integer
				loaded = parseInt(loaded, 10);
				// If the value of 'loaded' is not finite it is not a number 
				// so set the value of 'loaded' to 0
				if(!isFinite(loaded)) { loaded = 0; }
				//Get a reference to our loader bar and update accordingly
				$('#loaded-bar-'+this.config.id)
					.attr({'aria-valuetext':loaded.toString()+' percent','aria-valuenow':loaded})
					.css('width', loaded.toString()+'%');
			},
			/*
			* Generic method for rendering a time string in the format "hh:mm:ss"
			* @param time {int}: time in seconds
			* @return {string}: A formatted time
			*---------------------------------------------------------*/
			formatTime : function(time){
				var hours = 0;
				var minutes = 0;
				var seconds = 0; 
				
				if(time >= 60) {	// If we have more than 60 seconds
				    minutes = parseInt(time/60, 10);
				    seconds = time-(minutes*60);
				    if(minutes >= 60) {	// If we have more than 60 minutes
				        hours = parseInt(minutes/60, 10);
				        minutes -= parseInt(hours*60, 10);
				    }
				} else {	// The time is less than 60 seconds in length
				    seconds = time;
				}
				
				var tmp = [hours, minutes, seconds];
				var i;
				// Convert hours, minutes and seconds to strings
				for(i=0;i<tmp.length;i=i+1){
					tmp[i] = (tmp[i] < 10) ? '0'+tmp[i].toString() : tmp[i].toString();
				}
				return tmp.join(":");
			},
			/*
			* Method for updating the content of the current time label
			* @param time {int} the amount of time elapsed in seconds
			*---------------------------------------------------------*/
			updateTime : function(time) { 
				  var t = this.formatTime(parseInt(time, 10));
				  this.$html.find('#current-'+this.config.id).html(t);
			}, 
			/*
			* Method for getting the control bar for the media player
			* @return {obj}: A jQuery wrapped set, the control bar for the media player
			*---------------------------------------------------------*/
			getControls : function(){
				var $controls = $('<span />').addClass('ui-corner-bottom').addClass('control-bar');
				// Insert the Nomensa Logo
				var $logo = $('<a />').attr('href', 'http://www.nomensa.com?ref=logo').html('Accessible Media Player by Nomensa').addClass('logo');
				$controls.append($logo);
				var $func = this.getFuncControls();
				var $vol = this.getVolControls();
				var $slider = this.getSliderBar();
				// Append all of our controls.  Doing it like this since 
				// ie6 dies if we append recursively using native jQuery
				// append method
				var bits = [$func, $vol, $slider];
				var i;
				for(i=0;i<bits.length;i=i+1){
					$controls[0].appendChild(bits[i][0]);
				}
				return $controls;
			},
			/*
			* Method for assembling the HTML for the media player
			* This is just a wrapper for a number of other method calls
			* Help us to organise our methods better
			*---------------------------------------------------------*/
			assembleHTML : function(){
				var $playerContainer = this.generatePlayerContainer();
				var $flashContainer = this.generateFlashPlayer($playerContainer);
				var $container = $flashContainer.append(this.getControls());
				return $container;
			},
			/*
			* Method for assembling our HTML5 player
			* Only used if HTML5 video is supported by the browser 
			* and enabled in the player config
			*---------------------------------------------------------*/
			assembleHTML5 : function(container_type, mime_type){
				var $playerContainer = this.generatePlayerContainer();
				var $videoContainer = this.generateHTML5Player($playerContainer, container_type, mime_type);
				var $container = $videoContainer.append(this.getControls());
				return $container;
			},
			/*
			* Method for updating the visible volume labels 
			* and any aria attributes if required
			* @param volume {int}: The new volume of the player
			*---------------------------------------------------------*/
			updateVolume : function(volume){
				$('#vol-'+this.config.id).text(volume.toString()+'%');
				var $mute = this.$html.find('button.mute');
				if(volume == 0){
					$mute.addClass('muted');
				}else{
					if($mute.hasClass('muted')){
						$mute.removeClass('muted');
					}
				}
			},
			/*
			* CAPTIONING
			* All logic for captioning here.  This is a bit of a hack 
			* until such a time as captioning is better supported amongst
			* the main media players
			* @modifies {obj}: Adds a jQuery wrapped set of caption nodes to
			* the current object
			*------------------------------------------------------------*/
			getCaptions : function(){
				var self = this;
				if (self.config.captions){
					var $captions = [];
					$.ajax({ 
						url : self.config.captions,
						success : function(data){
							if($(data).find('p').length > 0){
								self.captions = $(data).find('p');
							}
						}
					});
				}
			},
			/*
			* Method for updating/inserting the caption into the media player
			* html.
			*-----------------------------------------------------------*/
			syncCaptions : function(){
				var caption;
				if(this.captions){
					var time = this.getCurrentTime();
					time = this.formatTime(parseInt(time, 10));
					caption = this.captions.filter('[begin="'+time+'"]');
					if(caption.length == 1){
						this.insertCaption(caption);
					}
				}
			},
			/*
			* Method for inserting the caption into the media player dom 
			* @param caption {obj}: A jQuery wrapped node from the captions file
			*---------------------------------------------------------*/
			insertCaption : function(caption){
				if(this.$html.find('.caption').length == 1){
					this.$html.find('.caption').text(caption.text());
				}else{
					var $c = $('<div>').text(caption.text());
					// We're only adding one class to the captions div
					// Use the native js version for speed
					$c[0].className = 'caption';
					this.$html.find('.video').prepend($c);
				}
			},
			/*
			* Method for obtaining the previous caption from the captions 
			* file.  This is used when captions are turned off
			* @param time {float}: The time representing the current time of the player
			* If this is null or undefined we will get the current time from the player instance
			*----------------------------------------------------------*/
			getPreviousCaption : function(time){
				var caption;
				if(time == undefined){
					time = this.getCurrentTime();
				}
				var formattedTime = this.formatTime(parseInt(time, 10));
				if (this.captions){
					caption = this.captions.filter('[begin="'+formattedTime+'"]');
					while((caption.length != 1) && (time > 0)){
						time--;
						formattedTime = this.formatTime(parseInt(time, 10));
						caption = this.captions.filter('[begin="'+formattedTime+'"]');
					}
					if(caption.length == 1){
						this.insertCaption(caption);
					}
				}
			},
			/*
			* Set the timeout for updating captions.  Set to half a second since
			* we get some annoying floating point issues.  This is related to
			* a degree of lag because of time taken for traversal.
			*---------------------------------------------------------*/
			setCaptionTimeout : function(){
				var self = this;
				if (self.captionInterval == undefined){ // We don't wanna set more than 1 timeout.  If we do, we cannot turn it off
					self.captionInterval = setInterval(function() { 
						self.syncCaptions();
					}, 500);
				}
			},
			/*
			* Clear the caption timeout
			*---------------------------------------------------------*/
			clearCaptionTimeout : function(){
				if (this.captionInterval != undefined){ // Make sure the timeout is not undefined before clearing it
					this.captionInterval = clearInterval(this.captionInterval);
				}
			},
			/*
			* CONTROLS FOR MAKING VIDEO PLAY, PAUSE, FAST FORWARD, REWIND ETC
			* These are generally specific to the Youtube API although we can
			* easily override these methods to work with different Players via
			* a config
			*---------------------------------------------------------*/
			play : function(){this.player.playVideo();this.setSliderTimeout();if(this.config.captionsOn && this.captions){this.setCaptionTimeout();}},
			pause : function(){this.player.pauseVideo();this.clearSliderTimeout();if(this.config.captionsOn && this.captions){this.clearCaptionTimeout();}},
			ffwd : function(){var time = this.getCurrentTime() + this.config.playerSkip;this.seek(time);},
			rewd : function(){var time = this.getCurrentTime() - this.config.playerSkip;if(time < 0){time = 0;}this.seek(time);},
			mute : function(){var $button = this.$html.find('button.mute');if(this.player.isMuted()){this.player.unMute();if($button.hasClass('muted')){$button.removeClass('muted');}}else{this.player.mute();$button.addClass('muted');}},
			volup : function(){var vol = this.player.getVolume();if(vol < (100 - this.config.volumeStep)){vol += this.config.volumeStep;}else{vol = 100;}this.player.setVolume(vol);this.updateVolume(vol);},
			voldwn : function(){var vol = this.player.getVolume();if(vol > this.config.volumeStep){vol -= this.config.volumeStep;}else{vol = 0;}this.player.setVolume(vol);this.updateVolume(vol);},
			getDuration : function(){return this.player.getDuration();},
			getCurrentTime : function(){return this.player.getCurrentTime();},
			getBytesLoaded : function(){return this.player.getVideoBytesLoaded();},
			getBytesTotal : function(){return this.player.getVideoBytesTotal();},
			seek : function(time){this.player.seekTo(time);if(this.config.captionsOn && this.captions){this.$html.find('.caption').remove();this.clearCaptionTimeout();this.setCaptionTimeout();this.getPreviousCaption();}},
			cue : function(){this.player.cueVideoById(this.config.media);},
			toggleCaptions : function(){var self = this;var $c = this.$html.find('.captions');if($c.hasClass('captions-off')){$c.removeClass('captions-off').addClass('captions-on');self.getPreviousCaption();self.setCaptionTimeout();self.config.captionsOn = true;}else{$c.removeClass('captions-on').addClass('captions-off');self.clearCaptionTimeout();self.$html.find('.caption').remove();self.config.captionsOn = false;}}
		};
		/* END METHODS */

		/*
		* Function for creating our media player instance
		* @param index {int}: The nth media player of this type on the page
		*---------------------------------------------------------*/
		function mediaplayer(index){
			// Merge our config into our object
			this.config = config;
			// Add our methods to the mediaplayer instance
			$.extend(true, this, methods, functions);
			// By default we will set is_html5 to false
			// This is a simple switch for merging the correct 
			// Player manager into the player object (in the main player function loop)
			this.is_html5 = false;
			// Get the media type (mime type and codecs)
			var media = get_media_type(this);
			// Check to see if the media type is supported by the browser
			if(media && supports_media(media.mimetype, media.container)  && this.config.useHtml5){	// HTML 5 video element is supported
				// Flag the object as using HTML5
				this.is_html5 = true;
				// Assemble the HTML5 controls
				this.$html = this.assembleHTML5(media.container, media.mimetype);
				// Merge in our HTML5 controller methods
				$.extend(this, html5_methods);
			}else{	// Fallback to use flash
				this.$html = this.assembleHTML();
			}
			// If we have a captions file, add it to the mp object
			if(this.config.captions){
				this.getCaptions();
			}
		}
		
		/* MAIN FUNCTION LOOP */
		return this.each(function(i) {
			
			var $self = $(this);
			// Create a new media player object
			var player = new mediaplayer(i);
			
			// Replace the HTML with that generated by this plugin 
			$self.html(player.$html);
			
			// If the player is wider than 580 add a class of player-wide to the container
			console.log(player.$html.width());
			if(player.$html.width()>580) {
				player.$html.addClass('player-wide');
			}
			// If the player is using HTML5 to play the media
			// Get a refernce to the video element and merge in the 
			// Player manager
			if(player.is_html5){
				player.player = document.getElementById(player.config.id);
			}
			
			// Add the player to the PlayerDaemon
			PlayerDaemon.addPlayer(player);
		});
		/* END MAIN FUNCTION LOOP */
	
	};

}(jQuery));


/*
* Global function called by YouTube when player is ready
* We use this to get a reference to the player manager.  We can retrieve 
* The player instance from the PlayerDaemon using the playerId
* 
* @param playerId {string}: The id of the player object.  This is used to
* retrieve the correct player instance from the PlayerDaemon  
*---------------------------------------------------------------------------*/
function onYouTubePlayerReady(playerId) {
	var player = PlayerDaemon.getPlayer(playerId);	// This is our initial object created by the mediaplayer plugin
	var myplayer = document.getElementById(player.config.id);	// This is a reference to the DOM element that we use as an interface through which to execute player commands
	player.init(myplayer);	// Pass the controller to our generated player object
}

/*
* Global function that is called on Youtube player state change
* This is registered in the init call for the media player object (when we have a player 
* manager instance to inject into the player object).  We use this to listen for any 
* play commands that have not been initialised using the media player control panel
* (e.g. if the play button within the actual flash element is activated).
* 
* @param state {int}: The state code for the player when this function is fired
*   This code is set by the youtube api.  Can be one of:
*     -> -1: Unstarted
*     -> 0 : Ended
*     -> 1 : Playing
*     -> 2 : Paused
*     -> 3 : Buffering
*     -> 5 : Video Cued
* 
* @param playerId {string}: The id of the player.  We use this to access the 
* correct player instance from the PlayerDaemon
* 
*---------------------------------------------------------------------------*/ 
function playerState(state, playerId){
	var player = PlayerDaemon.getPlayer(playerId);
	if(state == 1){
		player.play();
		if(player.config.buttons.toggle){	// This seems pretty bad.  Can we not abstract this sort of logic further?
			player.$html.find('.play').removeClass('play').addClass('pause').text('Pause');
		}
	}else if(player.config.repeat && (state == 0)){	// The movie has ended and the config requires the video to repeat
		// Let's just start the movie again 
		player.play();
	}
}