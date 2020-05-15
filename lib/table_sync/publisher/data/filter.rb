# frozen_string_literal: true

module TableSync::Publisher::Data::Filter
  module_function

  SAFE_JSON_TYPES = [
    NilClass,
    String,
    TrueClass,
    FalseClass,
    Numeric,
    Symbol,
    Date,
    Time,
  ].freeze

  UNSERIALIZABLE = Object.new

  # raise if pk columns are trown out?
  def strip_of_unserializable_values(attributes)
    filter(attributes)
  end

  private

  # substitues simple type values with UNSERIALIZABLE if type is not safe for serialization
  # if arrays or hashes have nested structure, called recursively until reaches simple types
  def filter(value)
    return filter_array(value) if value.is_a?(Array)
    return filter_hash(value)  if value.is_a?(Hash)
    return UNSERIALIZABLE      if value.is_a?(Float::INFINITY)  # It's Numeric
    return value               if safe_type?(value)             # Must be after Infinity check

    UNSERIALIZABLE
  end

  def safe_type?(value)
    BASE_SAFE_JSON_TYPES.any? { |type| value.is_a?(type) }
  end

  # calls #filter for all array elements and excludes UNSERIALIZABLE
  def filter_array(value)
    value.map(&method(:filter)).select(&method(:serializable?))
  end

  # calls #filter for all hash keys and values and excludes UNSERIALIZABLE key/value pairs
  def filter_hash(value)
    value.transform_keys(&method(:filter))
         .transform_values(&method(:filter))
         .select { |key, val| serializable?(key) && serializable?(val)) }
  end

  def serializable?(value)
    value != UNSERIALIZABLE
  end
end