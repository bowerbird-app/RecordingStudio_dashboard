# frozen_string_literal: true

# Recording Studio v4.7.0 and Root Switchable v0.9.0 still call Flatpack
# with the Card and PageNav keywords removed in Flatpack 0.1.315.
module FlatPackCardStyleCompat
  STYLES = {
    default: {},
    outlined: {border: :strong, shadow: :none},
    elevated: {shadow: :md}
  }.freeze

  def initialize(*args, **kwargs, &block)
    style = kwargs.delete(:style)
    if style
      STYLES.fetch(style.to_sym).each do |key, value|
        kwargs[key] = value unless kwargs.key?(key)
      end
    end
    super(*args, **kwargs, &block)
  end
end

module FlatPackPageNavCompat
  LEGACY_KEYS = %i[
    show_back right_slot back_href back_icon back_tooltip back_label back_style back_size
    anchor_href anchor_url anchor_icon anchor_tooltip anchor_label anchor_style anchor_size
  ].freeze

  def initialize(*args, **kwargs, &block)
    @legacy_page_nav = LEGACY_KEYS.each_with_object({}) do |key, legacy|
      legacy[key] = kwargs.delete(key) if kwargs.key?(key)
    end
    super(*args, **kwargs, &block)
  end

  def right_slot(&block)
    with_item(&block)
  end

  def before_render
    apply_legacy_page_nav!
    super
  end

  private

  def apply_legacy_page_nav!
    return if @legacy_page_nav_applied

    @legacy_page_nav_applied = true
    legacy = @legacy_page_nav || {}
    anchor_href = legacy[:anchor_href].presence || legacy[:anchor_url].presence
    if legacy[:back_href] || legacy[:back_icon] || legacy[:back_label] || legacy[:back_tooltip]
      with_back(
        href: legacy[:back_href],
        icon: legacy[:back_icon],
        tooltip: legacy[:back_tooltip].presence || legacy[:back_label],
        fallback_url: anchor_href,
        style: legacy[:back_style],
        size: legacy[:back_size]
      )
    end
    return if anchor_href.blank?

    with_close(
      href: anchor_href,
      icon: legacy[:anchor_icon],
      tooltip: legacy[:anchor_tooltip].presence || legacy[:anchor_label],
      style: legacy[:anchor_style],
      size: legacy[:anchor_size]
    )
  end
end

Rails.application.config.to_prepare do
  FlatPack::Card::Component.prepend(FlatPackCardStyleCompat) unless FlatPack::Card::Component < FlatPackCardStyleCompat
  FlatPack::PageNav::Component.prepend(FlatPackPageNavCompat) unless FlatPack::PageNav::Component < FlatPackPageNavCompat
end
