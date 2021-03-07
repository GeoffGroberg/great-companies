module ApplicationHelper
  def date(datetime)
    datetime.strftime("%b %-d, %Y")
  end
end
