module("Enhance youbute videos test", {
  setup: function(){
    this.container = $('<div id="wrap"><p><a></a></p></div>');
    $('#qunit-fixture').append(this.container);
  }
});

test("should replace tiny youtube links", sinon.test(function() {
  var stub = this.stub($.fn, "player");
  stub.returns(true);

  this.container.find('a').attr('href', 'http://youtu.be/tinyVideo');

  $('#wrap').enhanceYoutubeVideoLinks();

  var playerArgs = stub.getCall(0).args[0];
  equal('tinyVideo', playerArgs.media);
}));

test("should replace short youtube links", sinon.test(function() {
  var stub = this.stub($.fn, "player");
  stub.returns(true);

  this.container.find('a').attr('href', 'http://youtube.com/watch?v=shortVideo');

  $('#wrap').enhanceYoutubeVideoLinks();

  var playerArgs = stub.getCall(0).args[0];
  equal('shortVideo', playerArgs.media);
}));

test("should replace medium youtube links", sinon.test(function() {
  var stub = this.stub($.fn, "player");
  stub.returns(true);

  this.container.find('a').attr('href', 'http://youtube.com/watch?v=mediumVideo&source=twitter');

  $('#wrap').enhanceYoutubeVideoLinks();

  var playerArgs = stub.getCall(0).args[0];
  equal('mediumVideo', playerArgs.media);
}));

test("should do nothing if no video id found", sinon.test(function() {
  var stub = this.stub($.fn, "player");
  stub.returns(true);

  this.container.find('a').attr('href', 'http://youtube.com/watch?wrong=parameter');
  $('#wrap').enhanceYoutubeVideoLinks();

  this.container.find('a').attr('href', 'http://youtube.com/channel_name');
  $('#wrap').enhanceYoutubeVideoLinks();

  equal(0, stub.callCount);
}));
