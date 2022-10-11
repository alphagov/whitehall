describe('GOVUKAdmin.Modules.BreadcrumbPreview', function () {
  var preview

  beforeEach(function () {
    preview = new GOVUKAdmin.Modules.BreadcrumbPreview()
  })

  describe('filterBreadcrumbs', function () {
    it('returns an empty array when given an empty array', function () {
      expect(preview.filterBreadcrumbs([])).toEqual([])
    })

    it('filters out breadcrumbs that are prefixes of other breadcrumbs', function () {
      var collection = [
        {
          ancestors: ['foo', 'bar']
        },
        {
          ancestors: ['foo']
        },
        {
          ancestors: ['foo', 'bar', 'baz']
        }
      ]

      expect(preview.filterBreadcrumbs(collection)).toEqual([{ ancestors: ['foo', 'bar', 'baz'] }])
    })
  })
})
