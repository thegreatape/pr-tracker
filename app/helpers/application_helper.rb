module ApplicationHelper
  def date_frame_id(date)
    "workout-on-#{date.strftime('%Y-%m-%d')}"
  end
end
