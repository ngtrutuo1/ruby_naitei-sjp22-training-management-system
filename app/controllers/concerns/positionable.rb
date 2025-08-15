# app/models/concerns/positionable.rb
module Positionable
  extend ActiveSupport::Concern

  included do
    before_validation :validate_and_normalize_positions
  end

  private

  def positions_for association_name
    send(association_name).reject(&:marked_for_destruction?).map(&:position)
  end

  def validate_unique_positions positions
    duplicates = positions.select {|v| positions.count(v) > 1}.uniq
    errors.add(:base, :must_be_unique_positions) if duplicates.any?
  end

  def normalize_positions_for association_name
    send(association_name).reject(&:marked_for_destruction?)
                          .sort_by(&:position)
                          .each_with_index do |record, index|
      record.position = index + Settings.digits.digit_one
    end
  end

  def validate_and_normalize_positions
    return unless respond_to?(:positionable_association_name, true)

    assoc_name = positionable_association_name
    positions = positions_for assoc_name

    return if positions.any?(&:blank?)

    validate_unique_positions positions
    return if errors.any?

    normalize_positions_for assoc_name
  end
end
