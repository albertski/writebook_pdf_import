module Positionable
  extend ActiveSupport::Concern

  REBALANCE_THRESHOLD = 1e-10
  ELEMENT_GAP         = 1

  included do
    scope :positioned, -> { order(:position_score, :id) }
    scope :before, ->(other) { positioned.where("position_score < ?", other.position_score) }
    scope :after,  ->(other) { positioned.where("position_score > ?", other.position_score) }
    around_create :insert_at_default_position
    after_save_commit :rebalance_positions, if: :rebalance_required?
  end

  class_methods do
    def positioned_within(parent, association:, filter:)
      define_method(:positioning_parent) { send(parent) }
      define_method(:all_positioned_siblings) { positioning_parent.send(association).send(filter).positioned }
      define_method(:other_positioned_siblings) { all_positioned_siblings.excluding(self) }
      private :positioning_parent, :all_positioned_siblings, :other_positioned_siblings
    end
  end

  private
    def insert_at_default_position
      with_positioning_lock do
        position_at_end
        yield
      end
    end

    def position_at_end
      self.position_score = (all_positioned_siblings.maximum(:position_score) || 0) + ELEMENT_GAP
    end

    def rebalance_required? = @rebalance_required
    def rebalance_positions = @rebalance_required = false
    def remember_to_rebalance_positions = @rebalance_required = true

    def with_positioning_lock(&block)
      positioning_parent.with_lock(&block)
    end
end
