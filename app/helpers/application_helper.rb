module ApplicationHelper
  include Pagy::Frontend

  def full_title page_title = ""
    base_title = Settings.app.name || t("base_title")
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def page_class
    controller.instance_variable_get(:@page_class)
  end
end
