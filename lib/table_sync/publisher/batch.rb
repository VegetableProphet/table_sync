# frozen_string_literal: true

class TableSync::Publisher::Batch < TableSync::Publisher::Base
  attribute :push_original_attributes

  def symbolized_original_attributes
    original_attributes.map(&:deep_symbolize_keys)
  end

  def notify_params
    super.merge(count: original_attributes.size)
  end

  def valid_data?
    (push_original_attributes? && original_attributes.present?) || super
  end
end
