module("BreadcrumbPreview", function(){
  var subject = new GOVUKAdmin.Modules.BreadcrumbPreview();

  test(".filterBreadcrumbs returns an empty array", function() {
    deepEqual(
      this.subject.filterBreadcrumbs([]),
      []
    )
  });

  test(".filterBreadcrumbs filters out breadcrumbs that are prefixes of other breadcrumbs", function() {
    deepEqual(
      this.subject.filterBreadcrumbs([
        ["foo", "bar"],
        ["foo"],
        ["foo", "bar", "baz"]
      ]),
      [
        ["foo", "bar", "baz"]
      ]
    )
  });
});
