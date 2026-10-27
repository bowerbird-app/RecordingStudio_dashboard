# frozen_string_literal: true

require "test_helper"

class RenameGemIdentityTest < Minitest::Test
  def test_rename_script_rewrites_homepages_from_the_detected_name
    script = File.read(File.expand_path("../bin/rename_gem", __dir__))

    assert_includes script, "rewrite_leftover_homepages!"
    assert_includes script, "LEFTOVER_HOMEPAGES = [].freeze"
    assert_includes script, "leftover_template_identity?"
    refute_includes script, %w[gem template].join("_")
  end
end
