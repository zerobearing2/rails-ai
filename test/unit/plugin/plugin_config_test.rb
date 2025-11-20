# frozen_string_literal: true

require_relative "../../test_helper"
require "json"

class PluginConfigTest < Minitest::Test
  def setup
    @marketplace_json = JSON.parse(File.read(".claude-plugin/marketplace.json"))
    @plugin_json = JSON.parse(File.read(".claude-plugin/plugin.json"))
    @plugin_info = @marketplace_json["plugins"].first
  end

  def test_marketplace_json_exists
    assert_path_exists ".claude-plugin/marketplace.json",
                       "marketplace.json should exist in .claude-plugin folder"
  end

  def test_plugin_json_exists
    assert_path_exists ".claude-plugin/plugin.json",
                       "plugin.json should exist in .claude-plugin folder"
  end

  def test_versions_are_in_sync
    marketplace_version = @plugin_info["version"]
    plugin_version = @plugin_json["version"]

    assert_equal marketplace_version, plugin_version,
                 "Version in marketplace.json (#{marketplace_version}) must match plugin.json (#{plugin_version})"
  end

  def test_names_are_consistent
    marketplace_name = @plugin_info["name"]
    plugin_name = @plugin_json["name"]

    assert_equal "rails-ai", marketplace_name,
                 "Plugin name in marketplace.json should be 'rails-ai'"
    assert_equal marketplace_name, plugin_name,
                 "Plugin name must be consistent across both files"
  end

  def test_descriptions_are_consistent
    marketplace_desc = @plugin_info["description"]
    plugin_desc = @plugin_json["description"]

    assert_equal marketplace_desc, plugin_desc,
                 "Description must be consistent across marketplace.json and plugin.json"
  end

  def test_authors_are_consistent
    marketplace_author = @plugin_info["author"]
    plugin_author = @plugin_json["author"]

    assert_equal marketplace_author["name"], plugin_author["name"],
                 "Author name must be consistent across both files"

    # marketplace.json uses 'url', plugin.json uses 'url'
    assert_equal marketplace_author["url"], plugin_author["url"],
                 "Author URL must be consistent across both files"
  end

  def test_version_format
    version = @plugin_json["version"]

    assert_match(/^\d+\.\d+\.\d+$/, version,
                 "Version must be in semver format (X.Y.Z)")
  end

  def test_plugin_json_has_required_fields
    required_fields = %w[name description version author homepage repository license keywords]

    required_fields.each do |field|
      assert @plugin_json.key?(field),
             "plugin.json must have '#{field}' field"
      refute_nil @plugin_json[field],
                 "plugin.json '#{field}' field must not be nil"
    end
  end

  def test_marketplace_json_has_required_structure
    assert @marketplace_json.key?("name"),
           "marketplace.json must have 'name' field"
    assert @marketplace_json.key?("owner"),
           "marketplace.json must have 'owner' field"
    assert @marketplace_json.key?("plugins"),
           "marketplace.json must have 'plugins' array"
    assert_kind_of Array, @marketplace_json["plugins"],
                   "plugins must be an array"
    refute_empty @marketplace_json["plugins"],
                 "plugins array must not be empty"
  end

  def test_keywords_include_required_terms
    keywords = @plugin_json["keywords"]

    assert_kind_of Array, keywords,
                   "keywords must be an array"

    # Should include key terms
    assert_includes keywords, "rails",
                    "keywords should include 'rails'"
    assert_includes keywords, "superpowers",
                    "keywords should include 'superpowers' (dependency)"
  end

  def test_license_is_mit
    assert_equal "MIT", @plugin_json["license"],
                 "License should be MIT"
  end

  def test_repository_urls_are_consistent
    plugin_repo = @plugin_json["repository"]
    plugin_homepage = @plugin_json["homepage"]

    expected_repo = "https://github.com/zerobearing2/rails-ai"

    assert_equal expected_repo, plugin_repo,
                 "Repository URL should point to GitHub repo"
    assert_equal expected_repo, plugin_homepage,
                 "Homepage should match repository URL"
  end
end
