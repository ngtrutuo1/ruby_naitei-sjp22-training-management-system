module Supervisor
  module SubjectsHelper
    def subjects_with_ordered_categories
      subjects = Subject.includes(:categories, :subject_categories)
                        .map do |s|
                          {
                            id: s.id,
                            name: s.name,
                            categories: s.subject_categories
                                         .sort_by {|sc| sc.position || Float::INFINITY}
                                         .map do |sc|
                                          {
                                            id: sc.category_id,
                                            position: sc.position
                                          }
                                        end
                          }
                        end
      subjects.to_json
    end
  end
end
