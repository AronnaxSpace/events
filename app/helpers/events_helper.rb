module EventsHelper
  def event_time_for(event)
    "#{event.start_at} - #{event.end_at}"
  end

  def event_state_tag_classes_for(event)
    return 'tag-warning' if event.draft?
    return 'tag-secondary' if event.archived?

    'tag-success'
  end
end
