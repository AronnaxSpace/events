class EventsController < ApplicationController
  before_action :authorize_event, only: %i[edit update destroy]

  helper_method :event, :event_invitation

  def index
    @events = Event.for(current_user).order(created_at: :desc)
  end

  def show
    redirect_to event_bulk_add_invitations_path(event) if event.details_specified?

    @event_invitations = event.event_invitations
  end

  def new
    @event = Event.new
  end

  def edit; end

  def create
    @event = current_user.owned_events.new(event_params)

    if @event.save
      redirect_to event_bulk_add_invitations_path(event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if event.update(event_params)
      redirect_to event, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    event.destroy

    redirect_to events_url, notice: t('.success')
  end

  def publish
    if event.valid?
      event.publish!
      redirect_to event, notice: t('.success')
    else
      redirect_to edit_event_path, alert: event.errors.full_messages.join(', ')
    end
  end

  private

  def event
    @event ||= Event.for(current_user).find_by!(uuid: params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title, :place, :start_at, :end_at, :conditions, :time_format
    )
  end

  def authorize_event
    authorize event
  end

  def event_invitation
    @event_invitation ||= event.event_invitations.find_by(user: current_user)
  end
end
