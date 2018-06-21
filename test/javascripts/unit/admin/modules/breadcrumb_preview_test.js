module("BreadcrumbPreview", {
  setup: function() {
    this.subject = new GOVUKAdmin.Modules.BreadcrumbPreview();
  }
});

test(".filterBreadcrumbs returns an empty array", function() {
  deepEqual(
    this.subject.filterBreadcrumbs([]),
    []
  )
});

test(".filterBreadcrumbs filters out breadcrumbs that are prefixes of other breadcrumbs", function() {
  deepEqual(
    this.subject.filterBreadcrumbs([
      {
        ancestors: ["foo", "bar"]
      },
      {
        ancestors: ["foo"]
      },
      {
        ancestors: ["foo", "bar", "baz"]
      }
    ]),
    [
      {
        ancestors: ["foo", "bar", "baz"]
      }
    ]
  )
});
