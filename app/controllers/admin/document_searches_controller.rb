class Admin::DocumentSearchesController < Admin::BaseController
  def show
    @editions = Filterer.new(params).editions
  end

  class Filterer
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def editions
      filters_for(params).inject(edition_scope) do |editions, filter|
        filter.call(editions)
      end
    end

    def edition_scope
      Edition
        .with_translations(I18n.locale)
        .limit(10)
    end

  private

    def filters_for(params)
      filters = []

      if params[:title]
        filters << ->(editions) { editions.with_title_containing(params[:title]) }
      end

      type = find_type(params[:type])
      if type
        filters << ->(editions) { editions.by_type(type) }

        if params[:subtypes]
          filters << ->(editions) { editions.by_subtypes(type, params[:subtypes]) }
        end
      end

      filters << ->(editions) { editions.in_state(params[:state] || 'active') }

      filters
    end

    def find_type(type_name)
      if type_name
        Whitehall.edition_classes.find do |klass|
          klass.to_s == type_name.classify
        end
      end
    end
  end
end
