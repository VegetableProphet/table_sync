# frozen_string_literal: true

module TableSync::Publisher::Data
  class Event
    include Tainbox

    VALID_TYPES = [:create, :update, :destroy].freeze

    attribute :type, Symbol

    def valid?
      raise "Unknown state: #{type}" unless VALID_TYPES.include?(type)
    end

    def create?
      type == :create
    end

    def destroy?
      type == :destroy
    end
  end
end
