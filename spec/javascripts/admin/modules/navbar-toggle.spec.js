describe('GOVUK.Modules.NavbarToggle', function () {
  let navbarItem

  beforeEach(function () {
    navbarItem = document.createElement('li')
    navbarItem.setAttribute('data-module', 'navbar-toggle')

    // add toggle link
    const toggler = document.createElement('a')
    toggler.classList.add('js-navbar-toggle__toggler')
    toggler.setAttribute('href', '#more-options')
    toggler.innerText = 'More options'
    navbarItem.appendChild(toggler)

    // add sub menu
    const menu = document.createElement('ul')
    menu.classList.add('js-navbar-toggle__menu')
    menu.appendChild(document.createElement('li'))
    menu.appendChild(document.createElement('li'))
    menu.appendChild(document.createElement('li'))
    navbarItem.appendChild(menu)

    const navbarToggle = new GOVUK.Modules.NavbarToggle(navbarItem)
    navbarToggle.init()
  })

  it('should initialise correctly', function () {
    expect(navbarItem.querySelector('.js-navbar-toggle__toggler').getAttribute('tabindex')).toEqual('0')
    expect(navbarItem.querySelector('.js-navbar-toggle__menu')).toHaveClass('govuk-visually-hidden')
  })

  it('should show menu when toggler is clicked', function () {
    const toggler = navbarItem.querySelector('.js-navbar-toggle__toggler')
    const menu = navbarItem.querySelector('.js-navbar-toggle__menu')

    expect(navbarItem).not.toHaveClass('open')
    expect(menu).toHaveClass('govuk-visually-hidden')

    toggler.dispatchEvent(new Event('click'))

    expect(navbarItem).toHaveClass('open')
    expect(menu).not.toHaveClass('govuk-visually-hidden')
  })

  it('should close menu when toggled', function () {
    const toggler = navbarItem.querySelector('.js-navbar-toggle__toggler')
    const menu = navbarItem.querySelector('.js-navbar-toggle__menu')

    expect(navbarItem).not.toHaveClass('open')
    expect(menu).toHaveClass('govuk-visually-hidden')

    toggler.dispatchEvent(new Event('click'))

    expect(navbarItem).toHaveClass('open')
    expect(menu).not.toHaveClass('govuk-visually-hidden')

    toggler.dispatchEvent(new Event('click'))

    expect(navbarItem).not.toHaveClass('open')
    expect(menu).toHaveClass('govuk-visually-hidden')
  })
})
