window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function AddAnother (module) {
    this.module = module
    this.template = module.querySelector('template')
    this.itemSection = module.querySelector('.app-c-add-another__items')
    this.emptyStateMessage = module.querySelector('.app-add-another__empty-state-message')
    this.addButton = module.querySelector('.js-app-c-add-another__add-button')
    this.deleteMode = module.getAttribute('data-delete-mode')
  }

  AddAnother.prototype.init = function () {
    this.initAddButton()
    this.initDeleteButtons()
  }

  AddAnother.prototype.initAddButton = function () {
    this.addButton.addEventListener('click', function () {
      this.addAnotherItem()
    }.bind(this))
  }

  AddAnother.prototype.initDeleteButtons = function () {
    var initialItems = this.module.querySelectorAll('.app-c-add-another__item')

    initialItems.forEach(function (item) {
      this.initItemDeleteButton(item)
    }.bind(this))
  }

  AddAnother.prototype.addAnotherItem = function () {
    var newIndex = this.itemSection.childElementCount + 1

    var newItem = this.template.content.cloneNode(true)
    newItem = this.replaceNewItemVariables(newItem, newIndex)

    this.initItemDeleteButton(newItem)
    this.hideEmptyStateMessage()
    this.itemSection.append(newItem)
  }

  AddAnother.prototype.replaceNewItemVariables = function (newItem, index) {
    newItem.firstElementChild.innerHTML = newItem.firstElementChild.innerHTML.replaceAll('{{ index }}', index)
    newItem.firstElementChild.innerHTML = newItem.firstElementChild.innerHTML.replaceAll(/{{(.*?)}}/g, '')

    return newItem
  }

  AddAnother.prototype.showEmptyStateMessage = function () {
    this.emptyStateMessage.classList.remove('app-add-another__empty-state-message--hidden')
  }

  AddAnother.prototype.hideEmptyStateMessage = function () {
    this.emptyStateMessage.classList.add('app-add-another__empty-state-message--hidden')
  }

  AddAnother.prototype.initItemDeleteButton = function (item) {
    item
      .querySelector('.js-app-c-add-another__delete-button')
      .addEventListener('click', function (e) {
        var target = e.currentTarget
        var itemElement = target.parentElement

        if (this.deleteMode === 'hide') {
          itemElement.classList.add('app-c-add-another--hidden')
          this.updateDestroyInputValue(itemElement)
        } else {
          itemElement.remove()
        }

        var numberOfVisibleItems = this.itemSection.querySelectorAll('.app-c-add-another__item:not(.app-c-add-another--hidden)').length
        if (numberOfVisibleItems === 0) {
          this.showEmptyStateMessage()
        }
      }.bind(this))
  }

  AddAnother.prototype.updateDestroyInputValue = function (itemElement) {
    var regex = /\[_destroy\]$/g
    var inputs = itemElement.querySelectorAll('input')

    inputs.forEach(function (input) {
      if (regex.exec(input.getAttribute('name'))) {
        input.value = 1
      }
    })
  }

  Modules.AddAnother = AddAnother
})(window.GOVUK.Modules)
