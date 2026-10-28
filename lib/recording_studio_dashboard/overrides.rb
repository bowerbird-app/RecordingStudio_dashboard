# frozen_string_literal: true

module RecordingStudioDashboard
  class Overrides < Data.define(:row_order, :placement_order, :hidden_placements, :spans, :added)
    KEYS = %w[row_order placement_order hidden_placements spans added].freeze

    def self.none
      new(row_order: [], placement_order: {}, hidden_placements: [], spans: {}, added: [])
    end

    def self.parse(hash)
      data = hash.to_h.transform_keys(&:to_s)
      unknown = data.keys - KEYS
      raise ArgumentError, "unknown override keys: #{unknown.join(', ')}" if unknown.any?

      new(**fields(data))
    end

    def self.fields(data)
      {
        row_order: Array(data["row_order"]).map(&:to_sym),
        placement_order: order_map(data["placement_order"]),
        hidden_placements: Array(data["hidden_placements"]).map(&:to_sym),
        spans: span_map(data["spans"]),
        added: Array(data["added"]).map { |entry| added_entry(entry) }
      }
    end

    def to_h
      order_fields.merge(layout_fields).compact
    end

    def order_fields
      {
        "row_order" => listed(row_order) { row_order.map(&:to_s) },
        "placement_order" => listed(placement_order) { string_order },
        "hidden_placements" => listed(hidden_placements) { hidden_placements.map(&:to_s) }
      }
    end

    def layout_fields
      {
        "spans" => listed(spans) { spans.transform_keys(&:to_s) },
        "added" => listed(added) { added.map { |entry| stringify_added(entry) } }
      }
    end

    def listed(collection)
      yield unless collection.empty?
    end

    def self.order_map(value)
      Array(value).to_h.transform_keys(&:to_sym).transform_values { |ids| Array(ids).map(&:to_sym) }
    end

    def self.span_map(value)
      return {} if value.nil?

      value.to_h.transform_keys(&:to_sym).transform_values { |span| Integer(span) }
    end

    def self.added_entry(entry)
      data = entry.to_h.transform_keys(&:to_s)
      {
        id: data.fetch("id").to_sym,
        widget: data.fetch("widget").to_sym,
        row: data.fetch("row").to_sym,
        span: data["span"]&.then { |span| Integer(span) },
        config: data["config"] || {}
      }
    end

    def string_order
      placement_order.transform_keys(&:to_s).transform_values { |ids| ids.map(&:to_s) }
    end

    def stringify_added(entry)
      {
        "id" => entry.fetch(:id).to_s,
        "widget" => entry.fetch(:widget).to_s,
        "row" => entry.fetch(:row).to_s,
        "span" => entry[:span],
        "config" => entry[:config] || {}
      }
    end

    private_class_method :fields, :order_map, :span_map, :added_entry
  end
end
