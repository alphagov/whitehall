(function($) {
	/* options:
		{source: "data source", drop: "true", frequency: "6000"}
		additional placement = this
		drop equal number = this - items
		*/
  $.fn.news_ticker = function (options) {

  	// setup options
  	var options = options || {};
    var _this = $(this);
    var _source = options.source || "local";
    var _drop = options.drop || false;
    var _frequency = options.frequency || 5000;
 


    var _getNewItem = function () {
  			/*$.ajax({
    			url:  _source,
    			dataType: 'json',
    			success: function(data) {
    				console.log('success')
      			callback(data.responseData.feed);
    			}
  			});*/
        // poll every X seconds
        // check if new items?
      
      // this is just fake until we have real data to be adding
      var items = $(_this).children("li");

      
      _updateTicker(items);
      
      
    }

    var _updateTicker = function(items){
      
        // again, just temporary for fake fill in effect
        var i = 3,
          delay = 4000;
        
        while(i--){
          delay = delay + 2000 + Math.floor(Math.random()*6000);
          var item = $(items[i]);
          $(items[i]).remove();
          $(item).hide().prependTo(_this).delay(delay).slideDown("slow");
        }
        
    	if(_drop){
    		var i = newitems.length;
    		while(i--){
    			_removeItems();
    		}
    	}
    }

    var _removeItems = function(){
    	$(_this).children("li:last").remove();
    }

 		_getNewItem()

    return $(this);
  }
})(jQuery);
