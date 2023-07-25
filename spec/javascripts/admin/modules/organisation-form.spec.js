describe('GOVUK.Modules.OrganisationForm', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'OrganisationForm')
    form.innerHTML = `
      <form>
        <div>
          <select id='organisation_organisation_logo_type_id'>
            <option value='1'>Cabinet office logo</option>
            <option value='14'>Custom logo</option>
          </select>
        </div>

        <div class='js-view-organisation__form__custom_logo app-view-organisation__form__custom_logo--hidden'>
        </div>

        <div>
          <select id='organisation_organisation_type_key'>
            <option value='executive_office'>Executive office</option>
            <option value='advisory_ndpb'>Advisory org</option>
            <option value='executive_ndpb'>Executive ndpb</option>
            <option value='tribunal'>Tribunal</option>
          </select>
        </div>

        <div class='js-view-organisation__form__non-departmental-public-body-fields app-view-organisation__form__non-departmental-public-body-fields--hidden'>
        </div>
      </form>
    `

    var organisationForm = new GOVUK.Modules.OrganisationForm(form)
    organisationForm.init()
  })

  it('#setupCustomLogoVisibilityEventListener should hide the custom logo div when custom logo is not selected and hide it when custom logo is selected', function () {
    var select = form.querySelector('#organisation_organisation_logo_type_id')
    var customLogoDiv = form.querySelector('.js-view-organisation__form__custom_logo')

    select.value = '14'
    select.dispatchEvent(new Event('change'))

    expect(customLogoDiv.classList).not.toContain('app-view-organisation__form__custom_logo--hidden')

    select.value = '1'
    select.dispatchEvent(new Event('change'))

    expect(customLogoDiv.classList).toContain('app-view-organisation__form__custom_logo--hidden')
  })

  it('#setupNotDepartmentalPublicBodyFieldsEventListener should hide the non-departmental div when a non-departmental public body is not selected and show it when one is', function () {
    var select = form.querySelector('#organisation_organisation_type_key')
    var nonDepartmentalDiv = form.querySelector('.js-view-organisation__form__non-departmental-public-body-fields')

    select.value = 'advisory_ndpb'
    select.dispatchEvent(new Event('change'))

    expect(nonDepartmentalDiv.classList).not.toContain('app-view-organisation__form__non-departmental-public-body-fields--hidden')

    select.value = 'executive_ndpb'
    select.dispatchEvent(new Event('change'))

    expect(nonDepartmentalDiv.classList).not.toContain('app-view-organisation__form__non-departmental-public-body-fields--hidden')

    select.value = 'tribunal'
    select.dispatchEvent(new Event('change'))

    expect(nonDepartmentalDiv.classList).not.toContain('app-view-organisation__form__non-departmental-public-body-fields--hidden')

    select.value = 'executive_office'
    select.dispatchEvent(new Event('change'))

    expect(nonDepartmentalDiv.classList).toContain('app-view-organisation__form__non-departmental-public-body-fields--hidden')
  })
})
