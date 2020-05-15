# frozen_string_literal: true

class TableSync::Publisher::Job::Batch
  include Tainbox

  attribute :model
  attribute :original_attributes
  attribute :confirm
  attribute :event
  attribute :push_original_attributes

  # serialize for jobs?

  def enqueue
    job_class.perform_later(
      model: model,
      original_attributes: original_attributes,
      confirm: confirm,
      event: event, 
      push_original_attributes: push_original_attributes,
    )
  end

   def job_class
    return job_callable.call if job_callable
    raise "Can't publish, set TableSync.batch_publishing_job_class_callable"
  end

  def job_callable
    TableSync.batch_publishing_job_class_callable
  end
end
