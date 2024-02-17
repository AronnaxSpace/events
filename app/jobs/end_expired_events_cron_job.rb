class EndExpiredEventsCronJob < ApplicationJob
  queue_as :default

  def perform
    Event.expired.find_each(&:archive_without_validation!)
  end
end
