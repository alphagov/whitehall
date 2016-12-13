(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var tour = {
    tours: [],

    addTourPlayerWrapper: function(){
      tour.$player = $('<div id="tour-player"></div>');
      tour.$tour.prepend(tour.$player);
    },
    findTours: function(){
      tour.$tour.find('.tour-info').each(function(i, el){
        var $el = $(el);
        tour.tours.push({
          $el: $el,
          id: $el.attr('id'),
          title: $el.find('h3'),
          xml: $el.data('tour-xml')
        });
      });
    },
    findTour: function(id){
      var i, _i;
      for(i=0, _i=tour.tours.length; i<_i; i++){
        if(tour.tours[i].id === id){
          return tour.tours[i];
        }
      }
      return false;
    },
    switchTour: function(e){
      var newTourId = $(e.target).attr('href').substr(1),
          newTour = tour.findTour(newTourId);

      e.preventDefault();
      tour.loadTour(newTour);
    },
    loadTour: function(newTour){
      tour.$player.html('');
      embedpano({swf:"/government/assets/tour/tour_pano.swf", xml: "/government/assets/tour/"+newTour.xml, target: "tour-player"});

      tour.$tour.find('.js-visible').not(newTour.$el).removeClass('js-visible');
      newTour.$el.addClass('js-visible');
      tour.$nav.find('a').removeClass('active-tour');
      tour.$nav.find("a[href$='#"+newTour.$el.attr('id')+"']").addClass('active-tour');
    },
    init: function (){
      tour.$tour = $('.js-virtual-tour');
      if(tour.$tour.length === 1){
        tour.findTours();
        tour.addTourPlayerWrapper();
        tour.$nav = tour.$tour.find('.tour-nav');
        tour.$nav.on('click', 'a', tour.switchTour);
        tour.loadTour(tour.tours[0]);
      }
    }
  };

  root.GOVUK.virtualTour = tour;
}).call(this);
