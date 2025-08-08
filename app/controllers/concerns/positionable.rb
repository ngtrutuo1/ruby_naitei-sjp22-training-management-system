# app/models/concerns/positionable.rb
module Positionable
  extend ActiveSupport::Concern

  included do
    before_validation :validate_and_normalize_positions
  end

  private

  def association_records_for association_name
    send(association_name).reject(&:marked_for_destruction?)
  end

  def validate_unique_positions positions
    present_positions = positions.compact
    duplicates = present_positions.select do |v|
      present_positions.count(v) > 1
    end.uniq
    errors.add(:base, :must_be_unique_positions) if duplicates.any?
  end

  def normalize_positions_for association_name
    records = association_records_for(association_name)

    with_pos, without_pos = records.partition {|r| r.position.present?}

    ordered = with_pos.sort_by {|r| r.position.to_i} + without_pos

    ordered.each_with_index do |record, index|
      record.position = index + Settings.digits.digit_one
    end
  end

  def validate_and_normalize_positions
    return unless respond_to?(:positionable_association_name, true)

    assoc_name = positionable_association_name
    positions = association_records_for(assoc_name).map(&:position)

    validate_unique_positions(positions)
    return if errors.any?

    normalize_positions_for(assoc_name)
  end
end
