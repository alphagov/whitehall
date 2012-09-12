class Publicationesque < Edition
  include Edition::RelatedPolicies
  include ::Attachable

  attachable :edition
end
