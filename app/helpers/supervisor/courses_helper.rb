module Supervisor
  module CoursesHelper
    def build_statuses
      Course.statuses.map do |key, value|
        [t("courses.statuses.#{key}"), value]
      end
    end

    def search_type_options
      [
        [t(".courses"), :courses],
        [t(".creators"), :creators]
      ]
    end

    def status_filter_options
      [[t(".all_statuses").to_s, ""]] + build_statuses
    end
  end
end
