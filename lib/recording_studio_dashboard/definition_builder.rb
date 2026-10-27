# frozen_string_literal: true

module RecordingStudioDashboard
  class DefinitionBuilder
    def self.build(id, policy:, registry:, &block)
      builder = new(id, policy, registry)
      builder.instance_eval(&block) if block
      builder.definition
    end

    def self.from_layout(id, layout, policy:, header:, registry:)
      builder = new(id, policy, registry)
      builder.header(component: header) if header
      rows_from(layout).each { |row| builder.add_row_hash(row) }
      builder.definition
    end

    def self.rows_from(layout)
      data = layout.to_h
      data["rows"] || data[:rows] || []
    end
    private_class_method :rows_from

    def initialize(id, policy, registry)
      @id = id.to_sym
      @policy = Policy.resolve(policy)
      @registry = registry
      @header = nil
      @rows = []
      @placement_ids = []
      @rows_factory = RowFactory.new(registry, method(:claim!))
    end

    def header(component:)
      @header = Header.new(component: component)
    end

    def row(id, **options, &block)
      drafts = []
      RowBuilder.new(drafts).instance_eval(&block) if block
      add_row(@rows_factory.from_options(id, drafts, options))
    end

    def add_row_hash(raw)
      add_row(@rows_factory.from_hash(raw))
    end

    def definition
      Definition.new(id: @id, header: @header, rows: @rows, policy: @policy)
    end

    private

    def add_row(row)
      raise ArgumentError, "row #{row.id} is already used on #{@id}" if @rows.any? { |existing| existing.id == row.id }

      @rows << row
    end

    def claim!(placement_id)
      if @placement_ids.include?(placement_id)
        raise ArgumentError, "placement #{placement_id} is already used on #{@id}"
      end

      @placement_ids << placement_id
    end
  end

  class RowFactory
    COLLAPSES = %i[expand preserve].freeze
    SPACINGS = %i[sm md lg].freeze

    def initialize(registry, claim)
      @registry = registry
      @claim = claim
    end

    def from_hash(raw)
      data = raw.to_h.transform_keys(&:to_s)
      drafts = Array(data["placements"]).map { |entry| draft_from(entry) }
      from_options(data.fetch("id"), drafts, row_options(data))
    end

    def from_options(id, drafts, options)
      Row.new(id: id.to_sym, placements: built_placements(drafts), **attributes(options))
    end

    private

    def attributes(options)
      {
        title: options[:title],
        description: options[:description],
        action: HeadingAction.coerce(options[:action]),
        spacing: checked(SPACINGS, options.fetch(:spacing, :lg), "spacing"),
        collapse: checked(COLLAPSES, options.fetch(:collapse, :expand), "collapse"),
        visible_if: options[:visible_if],
        empty_state: EmptyState.coerce(options.fetch(:empty, :hide))
      }
    end

    def row_options(data)
      {
        title: data["title"],
        description: data["description"],
        action: data["action"],
        spacing: data["spacing"] || :lg,
        collapse: data["collapse"] || :expand,
        visible_if: data["visible_if"]&.to_sym,
        empty: data["empty"] || :hide
      }
    end

    def draft_from(entry)
      data = entry.to_h.transform_keys(&:to_s)
      PlacementDraft.new(data.fetch("widget"), **draft_options(data))
    end

    def draft_options(data)
      {
        id: data["id"],
        span: data["span"],
        config: data["config"] || {},
        visible_if: data["visible_if"]&.to_sym,
        mandatory: data["mandatory"] == true,
        empty: data["empty"]
      }
    end

    def built_placements(drafts)
      Array(drafts).map { |draft| draft.build(@registry, @claim) }
    end

    def checked(allowed, value, label)
      symbol = value.to_sym
      raise ArgumentError, "unknown #{label} #{value.inspect}" unless allowed.include?(symbol)

      symbol
    end
  end

  class RowBuilder
    def initialize(drafts)
      @drafts = drafts
    end

    def widget(type, **, &block)
      draft = PlacementDraft.new(type, **)
      draft.instance_eval(&block) if block
      @drafts << draft
    end
  end
end
