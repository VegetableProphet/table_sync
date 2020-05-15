# frozen_string_literal: true

module TableSync::Publisher::Data
  class Object
    include Memery
    include Tainbox

    attribute :object_class
    attribute :attrs
    attribute :destroy

    memoize def object
      TableSync.orm.find(object_class, needle)
    end

    # Attributes For Sync

    def attributes_for_sync
      destroy ? destroy_attributes : upsert_attributes
    end

    def upsert_attributes
      attributes_for_sync_defined? object.attributes_for_sync : TableSync.orm.attributes(object)
    end

    # Destroy Attributes (belongs to object class!)

    def destroy_attributes
      destroy_attributes_defined? ? object_class.table_sync_destroy_attributes(attrs) : needle
    end

    def destroy_attributes_defined?
      object_class.respond_to?(:table_sync_destroy_attributes)
    end

    # Attributes For Routing Key

    def attrs_for_routing_key
      attrs_for_routing_key_defined? ? object.attrs_for_routing_key : attrs
    end

    def attrs_for_routing_key_defined?
      object_class.method_defined?(:attributes_for_sync)
    end

    # Attributes For Metadata
  
    def attrs_for_metadata
      attrs_for_metadata_defined? ? object.attrs_for_metadata : attrs
    end

    def attrs_for_metadata_defined?
      object_class.method_defined?(:attributes_for_sync)
    end

    # Cache

    def cache_key
      "#{object_class}/#{hexdigest}_table_sync_time"
    end

    def hexdigest
      Digest::MD5.hexdigest(needle.values.sort.join)
    end

    # Misc

    def needle
      attributes.slice(*symbolized_pk)
    end

    def symbolized_pk
      Array(object_class.primary_key).map(&:to_sym)
    end

    def exists?
      object.present?
    end
  end
end