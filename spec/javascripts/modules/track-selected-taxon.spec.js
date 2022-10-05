describe('GOVUK.Modules.TrackSelectedTaxons', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'track-selected-taxons')
    form.innerHTML = `
      <div class="app-c-miller-columns">
        <p id="navigation-instructions" class="govuk-body govuk-visually-hidden">
          Use the right arrow to explore sub-topics, use the up and down arrows to find other topics.
        </p>

        <miller-columns-selected id="selected-items" for="miller-columns-04c58f82" class="miller-columns-selected">
          <ol class="miller-columns-selected__list">
            <li class="miller-columns-selected__list-item">
              <div class="govuk-breadcrumbs">
                <ol class="govuk-breadcrumbs__list">
                  <li class="govuk-breadcrumbs__list-item">Parenting, childcare and children's services</li>
                  <li class="govuk-breadcrumbs__list-item">Divorce, separation and legal issues</li>
                </ol>
              </div>
              <button class="miller-columns-selected__remove-topic" type="button">Remove topic<span class="miller-columns-selected__remove-topic-name">: Divorce, separation and legal issues</span></button>
            </li>
            <li class="miller-columns-selected__list-item">
              <div class="govuk-breadcrumbs">
                <ol class="govuk-breadcrumbs__list">
                  <li class="govuk-breadcrumbs__list-item">Parenting, childcare and children's services</li>
                  <li class="govuk-breadcrumbs__list-item">Childcare and early years</li>
                </ol>
              </div>
              <button class="miller-columns-selected__remove-topic" type="button">Remove topic<span class="miller-columns-selected__remove-topic-name">: Childcare and early years</span></button>
            </li>
          </ol>
        </miller-columns-selected>

        <miller-columns class="miller-columns" for="miller-columns-04c58f82-list" selected="selected-items" id="miller-columns-04c58f82" aria-describedby="navigation-instructions" style="display: block;">
          <div class="miller-columns__column" data-root="true">
            <ul class="miller-columns__column-list">
              <li class="miller-columns__item govuk-checkboxes--small miller-columns__item--parent miller-columns__item--selected miller-columns__item--active" aria-describedby="navigation-instructions" tabindex="0">
                <div class="govuk-checkboxes__item">
                  <input class="govuk-checkboxes__input" type="checkbox" name="miller-columns-04c58f82[]" value="parenting-childcare-and-children-s-services" id="miller-columns-04c58f82-0" tabindex="-1">
                  <label class="govuk-label govuk-checkboxes__label" for="miller-columns-04c58f82-0">
                    Parenting, childcare and children's services
                  </label>
                </div>
              </li>
            </ul>
          </div>
          <div class="miller-columns__column">
            <button class="govuk-back-link" type="button">Back</button>
            <h3 class="miller-columns__column-heading">Parenting, childcare and children's services</h3>
            <ul class="miller-columns__column-list">
              <li class="miller-columns__item govuk-checkboxes--small miller-columns__item--selected" aria-describedby="navigation-instructions" tabindex="0">
                <div class="govuk-checkboxes__item">
                  <input class="govuk-checkboxes__input" type="checkbox" name="miller-columns-04c58f82[]" value="divorce-separation-and-legal-issues" id="miller-columns-04c58f82-0-0" tabindex="-1">
                  <label class="govuk-label govuk-checkboxes__label" for="miller-columns-04c58f82-0-0">
                    Divorce, separation and legal issues
                  </label>
                </div>
              </li>
              <li class="miller-columns__item govuk-checkboxes--small miller-columns__item--parent miller-columns__item--selected miller-columns__item--active" aria-describedby="navigation-instructions" tabindex="0">
                <div class="govuk-checkboxes__item">
                  <input class="govuk-checkboxes__input" type="checkbox" name="miller-columns-04c58f82[]" value="childcare-and-early-years" id="miller-columns-04c58f82-0-1" tabindex="-1">
                  <label class="govuk-label govuk-checkboxes__label" for="miller-columns-04c58f82-0-1">
                    Childcare and early years
                  </label>
                </div>
              </li>
            </ul>
          </div>
          <div class="miller-columns__column miller-columns__column--active">
            <button class="govuk-back-link" type="button">Back</button>
            <h3 class="miller-columns__column-heading">Childcare and early years</h3>
            <ul class="miller-columns__column-list">
              <li class="miller-columns__item govuk-checkboxes--small" aria-describedby="navigation-instructions" tabindex="0">
                <div class="govuk-checkboxes__item">
                  <input class="govuk-checkboxes__input" type="checkbox" name="miller-columns-04c58f82[]" value="childcare-vouchers" id="miller-columns-04c58f82-0-1-0" tabindex="-1">
                  <label class="govuk-label govuk-checkboxes__label" for="miller-columns-04c58f82-0-1-0">
                    Childcare vouchers
                  </label>
                </div>
              </li>
            </ul>
          </div>
        </miller-columns>
      </div>
      <div class="govuk-button-group govuk-!-margin-top-7">
        <button
          class="gem-c-button govuk-button" type="submit"
          name="save" value="save">
          Update tags
        </button>
        <button
          class="gem-c-button govuk-button govuk-button--secondary" type="submit"
          name="legacy_tags" value="legacy_tags">
          Update and review specialist topic tags
        </button>
      </div>
    `

    var trackSelectedTaxons = new GOVUK.Modules.TrackSelectedTaxons(form)
    trackSelectedTaxons.init()
  })

  it('should send tracking events for each selected taxon when form is submitted', function () {
    spyOn(GOVUK.analytics, 'trackEvent')
    spyOn(window.location, 'pathname').andReturn('/government/admin/editions/1/tags/edit')
    form.dispatchEvent(new Event('submit'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'taxonSelection',
      'Parenting, childcare and children\'s services > Divorce, separation and legal issues',
      { label: '/government/admin/editions/1/tags/edit' }
    )

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'taxonSelection',
      'Parenting, childcare and children\'s services > Childcare and early years',
      { label: '/government/admin/editions/1/tags/edit' }
    )
  })

  it('should send tracking event when you select and unselect a taxon', function () {
    spyOn(GOVUK.analytics, 'trackEvent')

    var checkbox = form.querySelector('#miller-columns-04c58f82-0-1')
    checkbox.checked = true
    checkbox.dispatchEvent(new Event('click'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'pageElementInteraction',
      'checkboxClickedOn',
      { label: 'Childcare and early years' }
    )

    checkbox.checked = false
    checkbox.dispatchEvent(new Event('click'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'pageElementInteraction',
      'checkboxClickedOff',
      { label: 'Childcare and early years' }
    )
  })
})
