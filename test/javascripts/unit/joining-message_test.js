module("display joining message", {
  setup: function() {
    this.$message = $('<div class="js-progress-bar" data-join-count="2"></div>');
    $('#qunit-fixture').append(this.$message);

    this.cookieStub = sinon.stub(GOVUK, "cookie").returns('cookie value');
  },
  teardown: function() {
    this.cookieStub.restore();
  }
});

test('hides progress bar', function(){
  GOVUK.joiningMessage.init();

  ok(this.$message.is(':visible'));
  GOVUK.joiningMessage.hideBar();
  ok(!this.$message.is(':visible'));
});

test('closes bar and sets a cookie' , function(){
  GOVUK.joiningMessage.init();

  ok(this.$message.is(':visible'));
  GOVUK.joiningMessage.closeBar();
  ok(!this.$message.is(':visible'));

  var cookieCallArgs = this.cookieStub.getCall(this.cookieStub.callCount-1).args
  var expectedArgs = ["inside-gov-joining", 2, 30]
  deepEqual(cookieCallArgs, expectedArgs);
});

test('adds close button', function(){
  GOVUK.joiningMessage.init();
  equal(this.$message.find('.close-button').length, 1);
});

test('closes bar when clicking close', function(){
  GOVUK.joiningMessage.init();
  var closeStub = sinon.stub(GOVUK.joiningMessage, "hideBar");

  this.$message.find('.close-button').trigger('click');

  equal(closeStub.callCount, 1);
  closeStub.restore();
});

test('hides bar if cookie matches data value', function(){
  this.$message.data('join-count', 'cookie value');

  ok(this.$message.is(':visible'));
  GOVUK.joiningMessage.init();
  ok(!this.$message.is(':visible'));
});
