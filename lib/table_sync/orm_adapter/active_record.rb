# frozen_string_literal: true

module TableSync::ORMAdapter
  module ActiveRecord
    module_function

    def model
      ::TableSync::Model::ActiveRecord
    end

    def model_naming(object)
      ::TableSync::NamingResolver::ActiveRecord.new(table_name: object.table_name)
    end

    def find(dataset, conditions)
      dataset.find_by(conditions)
    end

    def attributes(object)
      object.attributes
    end

    def setup_sync(klass, **opts)
      debounce_time = opts.delete(:debounce_time)

      klass.instance_exec do
        [:create, :update, :destroy].each do |event, state|
          after_commit(on: event, **opts) do
            ::TableSync::Publisher::Job::Single.new(
              model: self.class.name,
              original_attributes: attributes,
              event: event,
              debounce_time: debounce_time,
            ).enqueue
          end
        end
      end
    end
  end
end
