# frozen_string_literal: true

module TableSync::Publisher::Data
  class Single < Base
    private

    delegate :attrs_for_routing_key,
             :attrs_for_metadata,
             :attributes_for_sync,
             :cache_key,
             to: :object

    memoize def object
      ::TableSync::Publisher::Data::Object.new(
        model: model, attrs: original_attributes, event: event
      )
    end

    def publishing_data
      super.merge(metadata: { created: event.created? })
    end

    # object must exist if insert or update event
    def valid?
      object.exists? || event.destroy?
    end
  end
end
