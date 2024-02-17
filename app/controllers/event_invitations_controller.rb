class EventInvitationsController < ApplicationController
  include EventScoped

  before_action :authorize_event, only: %i[bulk_add bulk_create]
  before_action :check_if_event_archived, only: %i[bulk_add bulk_create]

  helper_method :event_invitations

  def bulk_add; end

  def bulk_create
    result = EventInvitationsManager.new(event, params[:user_ids] || []).call

    if result.success?
      event.invite_users! if event.details_specified?

      redirect_to event_path(event)
    else
      flash.now[:alert] = result.error.message
      render :bulk_add, status: :unprocessable_entity
    end
  end

  def accept
    event_invitation.accept!

    redirect_to event_path(event), notice: t('.success')
  end

  def decline
    event_invitation.decline!

    redirect_to events_path, notice: t('.success')
  end

  private

  def authorize_event
    authorize event, :manage?
  end

  def check_if_event_archived
    redirect_to event_path(event) if event.archived?
  end

  def event_invitations
    @event_invitations ||= event.event_invitations
  end

  def event_invitation
    @event_invitation ||= event.event_invitations.find_by(user: current_user)
  end
end
