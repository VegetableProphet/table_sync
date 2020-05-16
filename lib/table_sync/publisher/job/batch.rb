# frozen_string_literal: true

class TableSync::Publisher::Job::Batch
  include Tainbox

  DEFAULT_JOB = ::TableSync::Publisher::Job::Default::Batch

  attribute :model
  attribute :original_attributes
  attribute :confirm
  attribute :event
  attribute :push_original_attributes
  # attribute :raise_for_unserializable ?

  def enqueue
    job_class.perform_later(
      model: model,
      original_attributes: safe_attributes,
      confirm: confirm,
      event: event, 
      push_original_attributes: push_original_attributes,
    )
  end

  def safe_attributes
    original_attributes.map do |attrs|
      ::TableSync::Publisher::Job::Filter.strip_of_unserializable_values(attrs)
    end
  end

  def job_class
    ::TableSync.batch_publishing_job_class || DEFAULT_JOB
  end
end
