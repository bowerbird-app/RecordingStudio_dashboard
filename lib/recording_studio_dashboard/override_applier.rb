# frozen_string_literal: true

module RecordingStudioDashboard
  class OverrideApplier
    def self.call(definition, overrides, registry)
      new(definition, overrides, registry).call
    end

    def initialize(definition, overrides, registry)
      @definition = definition
      @overrides = overrides
      @registry = registry
      @policy = definition.policy
    end

    def call
      rows = @definition.rows.map { |row| apply_row(row) }
      rows = reorder(rows, @overrides.row_order) if @policy.reorder_rows
      append_added(rows)
    end

    private

    def apply_row(row)
      placements = row.placements
      placements = reorder(placements, order_for(row)) if @policy.reorder_widgets
      placements = placements.reject { |placement| hidden?(placement) } if @policy.hide
      placements = placements.map { |placement| resized(placement) } if @policy.resize
      row.with(placements: placements)
    end

    def order_for(row)
      @overrides.placement_order.fetch(row.id, [])
    end

    def hidden?(placement)
      @overrides.hidden_placements.include?(placement.id) && !placement.mandatory
    end

    def resized(placement)
      span = @overrides.spans[placement.id]
      return placement if span.nil?

      type = @registry.widget(placement.widget)
      raise ArgumentError, "span #{span} is not supported for #{type.id}" unless type.supports?(span)

      placement.with(span: span)
    end

    def append_added(rows)
      return rows unless @policy.add

      @overrides.added.reduce(rows) { |current, entry| append_one(current, entry) }
    end

    def append_one(rows, entry)
      index = row_index(rows, entry)
      placement = added_placement(rows, entry)
      row = rows[index]
      rows.dup.tap { |copy| copy[index] = row.with(placements: row.placements + [placement]) }
    end

    def row_index(rows, entry)
      index = rows.index { |row| row.id == entry.fetch(:row) }
      raise ArgumentError, "unknown row #{entry.fetch(:row)} for added widget #{entry.fetch(:id)}" if index.nil?

      index
    end

    def added_placement(rows, entry)
      draft = PlacementDraft.new(
        entry.fetch(:widget),
        id: entry.fetch(:id),
        span: entry[:span],
        config: entry[:config] || {}
      )
      draft.build(@registry, claim_against(rows))
    end

    def claim_against(rows)
      used = rows.flat_map { |row| row.placements.map(&:id) }
      lambda do |placement_id|
        raise ArgumentError, "placement #{placement_id} is already used" if used.include?(placement_id)

        used << placement_id
      end
    end

    def reorder(items, order)
      index = order.each_with_index.to_h
      items.sort_by.with_index { |item, position| [index.fetch(item.id, order.length), position] }
    end
  end
end
