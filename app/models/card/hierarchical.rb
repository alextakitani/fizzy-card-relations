module Card::Hierarchical
  extend ActiveSupport::Concern

  MAX_ANCESTOR_DEPTH = 100

  included do
    # touch the parent: parent_id lives on the child, so gaining or losing a
    # child leaves the parent's own timestamp untouched and its cached JSON
    # keeps serving a stale children_count. CardDependency touches for the same
    # reason.
    belongs_to :parent, class_name: "Card", optional: true, touch: true
    has_many :children, class_name: "Card", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify

    scope :roots, -> { where(parent_id: nil) }

    validate :parent_must_differ_from_card
    validate :parent_must_belong_to_same_account
    validate :parent_must_not_create_cycle

    # `touch: true` above only reaches the parent a card moves *to*. The one it
    # left keeps its old timestamp, and therefore its old children_count.
    after_update_commit :touch_former_parent, if: :saved_change_to_parent_id?
  end

  private
    def touch_former_parent
      former_parent_id, _ = saved_change_to_parent_id
      return if former_parent_id.nil?

      Card.where(id: former_parent_id).touch_all
    end

    def parent_must_differ_from_card
      errors.add(:parent, :invalid, message: "can't be itself") if parent_id.present? && parent_id == id
    end

    def parent_must_belong_to_same_account
      return if parent.nil?

      errors.add(:parent, :invalid, message: "must belong to the same account") if parent.account_id != account_id
    end

    def parent_must_not_create_cycle
      return if parent.nil?

      visited = { id => true }
      ancestor = parent

      MAX_ANCESTOR_DEPTH.times do
        return if ancestor.nil?

        if visited[ancestor.id]
          errors.add(:parent, :invalid, message: "would create a cycle")
          return
        end

        visited[ancestor.id] = true
        ancestor = ancestor.parent
      end

      errors.add(:parent, :invalid, message: "ancestor chain is too deep")
    end
end
