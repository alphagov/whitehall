module("Hide department children", {
  setup: function() {
    this.$departments = $(
      '<div class="js-hide-department-children">'
    +   '<div class="department">'
    +     '<div class="organisations-box">'
    +       '<p>child content</p>'
    +     '</div>'
    +   '</div>'
    + '</div>');

    $('#qunit-fixture').append(this.$departments);
    this.oldWindowHash = window.location.hash;
    window.location.hash = '#department-name';
  },
  teardown: function(){
    window.location.hash = this.oldWindowHash;
  }
});

test("should create toggle link before department list", function() {
  GOVUK.hideDepartmentChildren.init();
  equal(this.$departments.find('.view-all').length, 1);
});

test("should toggle class when clicking view all link", function() {
  GOVUK.hideDepartmentChildren.init();

  ok(this.$departments.find('.department').hasClass('js-hiding-children'));
  this.$departments.find('.view-all').click();
  ok(!this.$departments.find('.department').hasClass('js-hiding-children'));
});

test("should not toggle class of department with id in window hash", function(){
  this.$departments.find('.organisations-box').append('<span id="department-name"></span>');

  GOVUK.hideDepartmentChildren.init();

  ok(!this.$departments.find('.department').hasClass('js-hiding-children'));
});
