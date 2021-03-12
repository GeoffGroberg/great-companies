module ApplicationHelper

  def date(datetime)
    datetime.strftime("%b %-d, %Y")
  end

  def date_and_time(datetime)
    datetime.strftime("%b %-d, %Y, %l:%M %P")
  end

end
