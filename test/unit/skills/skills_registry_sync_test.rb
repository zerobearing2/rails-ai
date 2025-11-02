# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"
require "date"

class SkillsRegistrySyncTest < Minitest::Test
  def setup
    @registry = YAML.load_file("skills/SKILLS_REGISTRY.yml")
  end

  def test_total_skill_count_matches_registry_metadata
    actual_skill_files = Dir.glob("skills/*/*.md").count
    registry_total = @registry["metadata"]["total_skills"]

    assert_equal registry_total, actual_skill_files,
                 "SKILLS_REGISTRY.yml metadata lists #{registry_total} skills, but found #{actual_skill_files} .md files. " \
                 "Please update metadata.total_skills in SKILLS_REGISTRY.yml to match actual skill count."
  end

  def test_domain_counts_match_actual_files
    domains = @registry["metadata"]["domains"]

    domains.each do |domain, expected_count|
      actual_count = Dir.glob("skills/#{domain}/*.md").count

      assert_equal expected_count, actual_count,
                   "SKILLS_REGISTRY.yml metadata lists #{expected_count} #{domain} skills, " \
                   "but found #{actual_count} .md files in skills/#{domain}/. " \
                   "Please update metadata.domains.#{domain} in SKILLS_REGISTRY.yml."
    end
  end

  def test_domain_breakdown_matches_metadata
    domains_section = @registry["domains"]
    metadata_domains = @registry["metadata"]["domains"]

    metadata_domains.each_key do |domain|
      assert domains_section.key?(domain),
             "Domain '#{domain}' exists in metadata.domains but not in domains section"

      domain_data = domains_section[domain]

      assert_equal metadata_domains[domain], domain_data["count"],
                   "Domain '#{domain}' count mismatch: metadata says #{metadata_domains[domain]}, " \
                   "domains section says #{domain_data['count']}"
    end
  end

  def test_all_skill_files_listed_in_domains_section
    domains = @registry["domains"]
    listed_skills = domains.values.flat_map { |d| d["skills"] }
    actual_skills = Dir.glob("skills/*/*.md").map { |f| File.basename(f, ".md") }

    missing_from_registry = actual_skills - listed_skills
    extra_in_registry = listed_skills - actual_skills

    assert_empty missing_from_registry,
                 "Skills exist but not listed in SKILLS_REGISTRY.yml domains section: #{missing_from_registry.join(', ')}"

    assert_empty extra_in_registry,
                 "Skills listed in SKILLS_REGISTRY.yml but files don't exist: #{extra_in_registry.join(', ')}"
  end

  def test_all_listed_skills_have_definitions
    domains = @registry["domains"]
    listed_skills = domains.values.flat_map { |d| d["skills"] }
    defined_skills = @registry["skills"].keys

    missing_definitions = listed_skills - defined_skills

    assert_empty missing_definitions,
                 "Skills listed in domains section but missing skill definitions: #{missing_definitions.join(', ')}"
  end

  def test_all_skill_definitions_are_listed_in_domains
    defined_skills = @registry["skills"].keys
    domains = @registry["domains"]
    listed_skills = domains.values.flat_map { |d| d["skills"] }

    orphaned_definitions = defined_skills - listed_skills

    assert_empty orphaned_definitions,
                 "Skills have definitions but not listed in any domain: #{orphaned_definitions.join(', ')}"
  end

  def test_skill_domain_matches_directory_location
    @registry["skills"].each do |skill_name, skill_data|
      declared_domain = skill_data["domain"]

      # Find the actual file
      matching_files = Dir.glob("skills/#{declared_domain}/#{skill_name}.md")

      assert_equal 1, matching_files.count,
                   "Skill '#{skill_name}' declares domain '#{declared_domain}' but file not found at skills/#{declared_domain}/#{skill_name}.md"
    end
  end

  def test_documentation_references_match_registry
    # Test AGENTS.md
    agents_doc = File.read("AGENTS.md")
    registry_total = @registry["metadata"]["total_skills"]

    skill_count_pattern = /(\d+)\s+skills?/i
    matches = agents_doc.scan(skill_count_pattern).flatten.map(&:to_i)

    # All skill count references should match registry
    incorrect_counts = matches.reject { |count| count == registry_total }

    assert_empty incorrect_counts,
                 "AGENTS.md contains incorrect skill counts: #{incorrect_counts.uniq.join(', ')}. " \
                 "Should be #{registry_total} skills per SKILLS_REGISTRY.yml. " \
                 "Please update AGENTS.md to match."

    # Test README.md
    readme_doc = File.read("README.md")
    readme_matches = readme_doc.scan(skill_count_pattern).flatten.map(&:to_i)
    readme_incorrect = readme_matches.reject { |count| count == registry_total }

    assert_empty readme_incorrect,
                 "README.md contains incorrect skill counts: #{readme_incorrect.uniq.join(', ')}. " \
                 "Should be #{registry_total} skills per SKILLS_REGISTRY.yml. " \
                 "Please update README.md to match."
  end

  def test_registry_last_updated_date_is_recent
    registry_content = File.read("skills/SKILLS_REGISTRY.yml")
    match = registry_content.match(/Last updated: (\d{4}-\d{2}-\d{2})/)

    assert match, "SKILLS_REGISTRY.yml should have '# Last updated: YYYY-MM-DD' in header comments"

    last_updated = match[1]
    last_updated_date = Date.parse(last_updated)
    days_old = (Date.today - last_updated_date).to_i

    assert_operator days_old, :<=, 30, "SKILLS_REGISTRY.yml last_updated date is #{days_old} days old (#{last_updated}). " \
                                       "Consider updating if skills have been modified recently."
  end
end
