# frozen_string_literal: true

class TableSync::Publisher::Single < TableSync::Publisher::Base
  def symbolized_original_attributes
    original_attributes.deep_symbolize_keys
  end
end
