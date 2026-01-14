class EventsController < ApplicationController
  def index
    @events = Event.upcoming

    if params[:city].present?
      @events = @events.in_city(params[:city])
    end

    if params[:type].present? && Event.event_types.key?(params[:type])
      @events = @events.where(event_type: params[:type])
    end

    @grouped_events = @events.group_by { |e| e.starts_at.to_date }
    @cities = Event.upcoming.distinct.pluck(:location).compact.sort
  end

  def show
    @event = Event.find(params[:id])
  end
end
