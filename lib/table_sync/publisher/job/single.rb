# frozen_string_literal: true

class TableSync::Publisher::Job::Single
  include Tainbox
  include Memery

  DEFAULT_JOB = ::TableSync::Publisher::Job::Default::Single

  attribute :model
  attribute :original_attributes
  attribute :confirm
  attribute :event
  attribute :debounce_time

  def enqueue
    enqueue_job unless time.before_sync_time?
  end

  private

  def enqueue_job
    job_class.set(wait_until: time.perform_at).perform_later(job_params)
    time.cache_perform_at_time
  end

  def job_params
    {
      model: model.name,
      original_attributes: safe_attributes,
      event: event,
      confirm: confirm,
    }
  end

  memoize def time
    ::TableSync::Publisher::Job::Time.new(
      model: model,
      original_attributes: original_attributes,
      event: event,
      debounce_time: debounce_time,
    )
  end

  def safe_attributes
    ::TableSync::Publisher::Job::Filter.strip_of_unserializable_values(original_attributes)
  end

  def job_class
    ::TableSync.publishing_job_class || DEFAULT_JOB
  end
end
