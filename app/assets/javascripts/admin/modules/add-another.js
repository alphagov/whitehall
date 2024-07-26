'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function AddAnother(module) {
    this.module = module
    this.addText = this.module.dataset.addText || 'Add another'
  }

  AddAnother.prototype.init = function () {
    this.addButton()
    this.removeButton()
  }

  AddAnother.prototype.addButton = function () {
    const buttonAdd = document.createElement('button')

    buttonAdd.classList.add(
      'govuk-button',
      'govuk-!-margin-bottom-0',
      'govuk-button--secondary',
      'add-another__add-button'
    )
    buttonAdd.setAttribute('type', 'submit')
    buttonAdd.textContent = this.addText

    this.module.append(buttonAdd)

    // Add event listeners for "add" and "remove" buttons
    this.module.addEventListener(
      'click',
      function (e) {
        if (e.target.classList.contains('add-another__remove-button')) {
          this.removeFields(e.target)
        } else if (e.target.classList.contains('add-another__add-button')) {
          e.preventDefault()
          this.addFields(e.target)
        }
      }.bind(this)
    )
  }

  AddAnother.prototype.addFields = function (button) {
    const allFields = button.parentNode.querySelectorAll(
      '.js-duplicate-fields-set'
    )
    const fields = allFields[allFields.length - 1]

    // Show hidden "Remove" button
    if (fields.querySelector('.add-another__remove-button')) {
      fields.querySelector('.add-another__remove-button').style.display =
        'inline-block'
    }

    // Clone the markup of the previous set of fields
    const newFields = fields.cloneNode(true)

    // Reset values of cloned fields
    newFields
      .querySelectorAll('input, textarea, select')
      .forEach(function (element) {
        element.value = ''
      })

    // Increment values for id, for and name of cloned fields
    this.setValues(newFields, null)

    // Add cloned fields to the DOM
    button.before(newFields)

    // Add remove button to all fields
    this.removeButton()

    // Move focus to first visible field in new set
    newFields
      .querySelectorAll('input:not([type="hidden"]), select, textarea')[0]
      .focus()
  }

  AddAnother.prototype.removeButton = function () {
    const fields = this.module.querySelectorAll('.js-duplicate-fields-set')
    let buttonRemove

    if (fields.length > 1) {
      fields.forEach(function (field) {
        if (!field.querySelector('.add-another__remove-button')) {
          buttonRemove = document.createElement('button')
          buttonRemove.classList.add(
            'govuk-button',
            'govuk-button--warning',
            'govuk-!-margin-bottom-6',
            'add-another__remove-button'
          )
          buttonRemove.setAttribute('type', 'button')
          buttonRemove.textContent = 'Delete'

          field.append(buttonRemove)
        }
      })
    }
  }

  AddAnother.prototype.removeFields = function (button) {
    const set = button.parentNode
    const input = set.querySelectorAll(
      'input:not([type="hidden"]), select, textarea'
    )[0]
    const baseId = input.id
    const baseName = input.name

    set.remove()

    const sets = this.module.querySelectorAll('.js-duplicate-fields-set')

    // Add hidden field for removed set
    const hiddenField = document.createElement('input')
    hiddenField.type = 'hidden'
    hiddenField.classList.add('js-hidden-destroy')
    hiddenField.id = baseId.replace(/_[a-zA-Z]+$/, '__destroy')
    hiddenField.name = baseName.replace(/\[[_a-zA-Z]+\]$/, '[_destroy]')
    hiddenField.setAttribute('value', 'true')
    this.module.append(hiddenField)

    // Hide "Remove" button if only first set displayed
    if (sets.length === 1) {
      sets[0].querySelector('.add-another__remove-button').style.display =
        'none'
    }

    // Move focus to first visible field
    sets[0]
      .querySelectorAll('input:not([type="hidden"]), select, textarea')[0]
      .focus()
  }

  // Set values for index, for and name of supplied fields
  AddAnother.prototype.setValues = function (set, index) {
    let num = 0

    set
      .querySelectorAll('label, input, select, textarea')
      .forEach(function (element) {
        const currentName = element.getAttribute('name') || null
        const currentId = element.getAttribute('id') || null
        const currentFor = element.getAttribute('for') || null
        const arrayMatcher = /(.*)\[([0-9]+)\](.*?)$/
        const underscoreMatcher = /(.*)_([0-9]+)_(.*?)$/
        let matched

        if (currentName && arrayMatcher.exec(currentName)) {
          matched = arrayMatcher.exec(currentName)

          if (index === null) {
            num = parseInt(matched[2], 10) + 1
          } else {
            num = index
          }

          element.setAttribute(
            'name',
            matched[1] + '[' + num + ']' + matched[3]
          )
        }

        if (currentId && underscoreMatcher.exec(currentId)) {
          matched = underscoreMatcher.exec(currentId)

          if (index === null) {
            num = parseInt(matched[2], 10) + 1
          } else {
            num = index
          }

          element.setAttribute('id', matched[1] + '_' + num + '_' + matched[3])
        }

        if (currentFor && underscoreMatcher.exec(currentFor)) {
          matched = underscoreMatcher.exec(currentFor)

          if (index === null) {
            num = parseInt(matched[2], 10) + 1
          } else {
            num = index
          }

          element.setAttribute('for', matched[1] + '_' + num + '_' + matched[3])
        }
      })
  }

  Modules.AddAnother = AddAnother
})(window.GOVUK.Modules)
