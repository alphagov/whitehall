window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function AddAnother (module) {
    this.module = module
    this.template = module.querySelector('template')
    this.itemSection = module.querySelector('.app-c-add-another__items')
    this.emptyStateMessage = module.querySelector('.app-add-another__empty-state-message')
    this.addButton = module.querySelector('.js-app-c-add-another__add-button')
  }

  AddAnother.prototype.init = function () {
    this.initAddButton()
  }

  AddAnother.prototype.initAddButton = function () {
    this.addButton.addEventListener('click', function () {
      this.addAnotherItem()
    }.bind(this))
  }

  AddAnother.prototype.addAnotherItem = function () {
    var newIndex = this.itemSection.childElementCount + 1

    var newItem = this.template.content.cloneNode(true)
    newItem.firstElementChild.innerHTML = newItem.firstElementChild.innerHTML.replaceAll('{{ index }}', newIndex)

    this.hideEmptyStateMessage()
    this.itemSection.append(newItem)
  }

  AddAnother.prototype.hideEmptyStateMessage = function () {
    this.emptyStateMessage.classList.add('app-add-another__empty-state-message--hidden')
  }

  Modules.AddAnother = AddAnother
})(window.GOVUK.Modules)
