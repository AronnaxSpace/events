module EventScoped
  extend ActiveSupport::Concern

  included do
    helper_method :event
  end

  private

  def event
    @event ||= Event.for(current_user).find_by!(uuid: params[:event_id])
  end
end
