window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
    function Parts (module) {
        this.module = module
    }

    Parts.prototype.init = function () {
        this.initAddNewPartBtn()
    }

    Parts.prototype.initAddNewPartBtn = function () {
        var btn = this.module.querySelector('.js-add-new-part')

        btn.addEventListener('click', function (e) {
            e.preventDefault()

            var template = this.module.querySelector('#new-part-template')
            template = template.content.cloneNode(true)
            template = this.initialiseTemplate(template)

            this.module.querySelector('.govuk-accordion__wrapper').append(template)
        }.bind(this))
    }

    Parts.prototype.initialiseTemplate = function (template) {
        return template
    }

    Modules.Parts = Parts
})(window.GOVUK.Modules)
