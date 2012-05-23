module FactoryGirlInterceptor

  include Factory::Syntax::Methods

  def attributes_for(name, overrides = {}, &block)
    super(*adapt(name, overrides), &block)
  end

  def build(name, overrides = {}, &block)
    super(*adapt(name, overrides), &block)
  end

  def create(name, overrides = {}, &block)
    super(*adapt(name, overrides), &block)
  end

  def adapt(name, overrides = {})
    new_name, new_overrides = name, overrides.dup
    if [
         :fact_check_request,
         :document_relation,
         :document_organisation,
         :document_attachment
        ].include?(name) && new_overrides.has_key?(:document)
      new_overrides[:edition] = new_overrides.delete(:document)
    end
    [new_name, new_overrides]
  end
end
