# frozen_string_literal: true

module TableSync::Publisher::Data
  class Batch < Base
    attribute :push_original_attributes
    attribute :headers
    attribute :routing_key

    private

    def objects
      original_attributes.map do |attrs|
        ::TableSync::Publisher::Data::Object.new(model: model, attrs: attrs, event: event)
      end
    end

    def publishing_data
      super.merge(metadata: {})
    end

    def attrs_for_routing_key
      {}
    end

    def attrs_for_metadata
      {}
    end

    def attributes_for_sync
      push_original_attributes ? original_attributes : objects.map(&:attributes_for_sync)
    end

    # all objects must exist if insert or update event
    def valid?
      objects.all?(&:exists?) || event.destroy?
    end
  end
end
