module("Hide department children", {
  setup: function() {
    this.$departments = $(
      '<div class="js-hide-department-children">'
    +   '<div class="department">'
    +     '<div class="child-organisations">'
    +       '<p>child content</p>'
    +     '</div>'
    +   '</div>'
    + '</div>');

    $('#qunit-fixture').append(this.$departments);
  }
});

test("should create toggle link before department list", function() {
  GOVUK.hideDepartmentChildren.init();
  equals(this.$departments.find('.view-all').length, 1);
  console.log(this.$departments.html());
});

test("should toggle class when clicking view all link", function() {
  GOVUK.hideDepartmentChildren.init();

  ok(this.$departments.find('.department').hasClass('js-hiding-children'));
  this.$departments.find('.view-all').click();
  ok(!this.$departments.find('.department').hasClass('js-hiding-children'));
});

