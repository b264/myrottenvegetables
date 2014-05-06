module ApplicationHelper
  # returns the full title or a specific one
  def full_title(page_title)
    base_title= 'My Rotten Vegetables'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
