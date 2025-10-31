# frozen_string_literal: true

require_relative "../../test_helper"
require "yaml"

class AgentContentTest < Minitest::Test
  def setup
    @agent_files = Dir.glob("agents/*.md")
    @registry = YAML.load_file("skills/SKILLS_REGISTRY.yml")
    @all_skills = @registry["skills"].keys
  end

  # Test that agents have required markdown sections
  def test_specialized_agents_have_required_sections
    # Exclude coordinator (architect) and strategic agent (plan)
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") || f.include?("plan.md") }

    required_sections = [
      /##\s+Role/i,
      /##\s+Expertise\s+Areas/i,
      /##\s+Skills\s+Preset/i,
      /##\s+Integration\s+with\s+Other\s+Agents/i,
      /##\s+Deliverables/i
    ]

    specialized_agents.each do |file|
      content = File.read(file)

      required_sections.each do |section_regex|
        assert_match section_regex, content,
                     "#{file}: missing required section matching #{section_regex.inspect}"
      end
    end
  end

  # Test that coordinator has appropriate sections
  def test_coordinator_has_required_sections
    coordinator = @agent_files.find { |f| f.include?("architect.md") }
    content = File.read(coordinator)

    required_sections = [
      /##\s+Role/i,
      /##\s+Skills\s+Registry/i
    ]

    required_sections.each do |section_regex|
      assert_match section_regex, content,
                   "Coordinator: missing required section matching #{section_regex.inspect}"
    end
  end

  # Test that architect has critical delegation enforcement sections
  def test_architect_has_delegation_enforcement
    coordinator = @agent_files.find { |f| f.include?("architect.md") }
    content = File.read(coordinator)

    # Should have delegation-protocol section with critical priority
    assert_match(/<delegation-protocol\s+priority="critical">/i, content,
                 "Architect: missing <delegation-protocol priority=\"critical\"> section")

    # Should have ABSOLUTE RULES section
    assert_match(/ABSOLUTE RULES.*NO EXCEPTIONS/im, content,
                 "Architect: missing 'ABSOLUTE RULES (NO EXCEPTIONS)' in delegation protocol")

    # Should explicitly forbid Write/Edit/NotebookEdit tools
    assert_match(/NEVER.*Write.*Edit.*NotebookEdit/im, content,
                 "Architect: should explicitly forbid Write/Edit/NotebookEdit tools")

    # Should have ONLY use Task tool instruction
    assert_match(/ONLY use Task tool/i, content,
                 "Architect: should have 'ONLY use Task tool' instruction")

    # Should have critical anti-pattern section for direct implementation
    assert_match(/CRITICAL ANTI-PATTERN.*Architect Doing Implementation/im, content,
                 "Architect: missing critical anti-pattern section for direct implementation")

    # Should have examples of forbidden vs correct behavior
    assert_match(/FORBIDDEN.*behavior/i, content,
                 "Architect: should have examples of FORBIDDEN behavior")
    assert_match(/CORRECT.*behavior/i, content,
                 "Architect: should have examples of CORRECT behavior")

    # Should have critical-reminder section
    assert_match(/<critical-reminder>/i, content,
                 "Architect: should have <critical-reminder> section")
  end

  # Test that skill names mentioned in preset sections exist in registry
  def test_skill_presets_reference_valid_skills
    # Exclude coordinator (architect) and strategic agent (plan)
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") || f.include?("plan.md") }

    specialized_agents.each do |file|
      content = File.read(file)

      # Find Skills Preset section
      next unless content =~ /##\s+Skills\s+Preset.*?\n(.*?)(?=\n##|\z)/im

      preset_section = Regexp.last_match(1)

      # Extract skill references from Location: patterns
      # Looking for: Location: `skills/domain/skill-name.md`
      skill_refs = preset_section.scan(%r{Location:\s+`skills/\w+/([\w-]+)\.md`})

      skill_refs.flatten.uniq.each do |skill_name|
        assert_includes @all_skills, skill_name,
                        "#{file}: Skills Preset references '#{skill_name}' which doesn't exist in SKILLS_REGISTRY.yml"
      end
    end
  end

  # Test that agents have valid YAML metadata fields
  def test_agents_have_complete_metadata
    # Exclude coordinator (architect) and strategic agent (plan)
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") || f.include?("plan.md") }

    specialized_agents.each do |file|
      yaml = extract_yaml_front_matter(file)

      # All specialized agents should have these fields
      assert yaml["role"], "#{file}: missing 'role' field"
      assert yaml["triggers"], "#{file}: missing 'triggers' field"
      assert yaml["capabilities"], "#{file}: missing 'capabilities' field"
      assert yaml["coordinates_with"], "#{file}: missing 'coordinates_with' field"

      # Triggers should have keywords and file_patterns
      if yaml["triggers"]
        assert yaml["triggers"]["keywords"], "#{file}: triggers missing 'keywords'"
        assert_kind_of Array, yaml["triggers"]["keywords"],
                       "#{file}: triggers.keywords should be an array"
        assert yaml["triggers"]["file_patterns"], "#{file}: triggers missing 'file_patterns'"
        assert_kind_of Array, yaml["triggers"]["file_patterns"],
                       "#{file}: triggers.file_patterns should be an array"
      end

      # Capabilities should be an array
      assert_kind_of Array, yaml["capabilities"],
                     "#{file}: capabilities should be an array"
      refute_empty yaml["capabilities"], "#{file}: capabilities should not be empty"
    end
  end

  # Test that model field is valid
  def test_agents_have_valid_model_field
    valid_models = %w[inherit sonnet opus haiku]

    @agent_files.each do |file|
      yaml = extract_yaml_front_matter(file)

      if yaml["model"]
        assert_includes valid_models, yaml["model"],
                        "#{file}: model '#{yaml['model']}' is not valid (must be: #{valid_models.join(', ')})"
      end
    end
  end

  # Test that security agent has critical priority
  def test_security_agent_has_critical_priority
    security_agent = @agent_files.find { |f| f.include?("security.md") }
    yaml = extract_yaml_front_matter(security_agent)

    assert_equal "critical", yaml["priority"],
                 "Security agent should have 'critical' priority"
  end

  # Test that Integration sections mention valid agents
  def test_integration_sections_reference_valid_agents
    existing_agents = @agent_files.map { |f| File.basename(f, ".md") }

    @agent_files.each do |file|
      content = File.read(file)

      # Find Integration with Other Agents section
      next unless content =~ /##\s+Integration\s+with\s+Other\s+Agents.*?\n(.*?)(?=\n##|\z)/im

      integration_section = Regexp.last_match(1)

      # Extract @agent references like @backend, @frontend, @architect, @plan
      agent_refs = integration_section.scan(/@(architect|plan|backend|frontend|tests|security|debug)/)

      agent_refs.flatten.uniq.each do |agent_name|
        assert_includes existing_agents, agent_name,
                        "#{file}: Integration section mentions non-existent agent '@#{agent_name}'"
      end
    end
  end

  # Test that agents don't reference themselves in coordinates_with
  def test_agents_dont_coordinate_with_themselves
    @agent_files.each do |file|
      yaml = extract_yaml_front_matter(file)
      next unless yaml && yaml["coordinates_with"]

      agent_name = File.basename(file, ".md")

      refute_includes yaml["coordinates_with"], agent_name,
                      "#{file}: should not coordinate with itself"
    end
  end

  # Test that critical rules exist where appropriate
  def test_security_agent_has_critical_rules
    security_agent = @agent_files.find { |f| f.include?("security.md") }
    yaml = extract_yaml_front_matter(security_agent)
    content = File.read(security_agent)

    assert yaml["critical_rules"], "Security agent should have 'critical_rules' field"
    assert_kind_of Array, yaml["critical_rules"],
                   "Security agent critical_rules should be an array"
    refute_empty yaml["critical_rules"], "Security agent critical_rules should not be empty"

    # Should have <critical> tags in content
    assert_match(%r{<critical.*?>.*?</critical>}im, content,
                 "Security agent should have <critical> tags in content")
  end

  # Test that workflows are specified
  def test_specialized_agents_have_workflow
    # Exclude coordinator (architect) and strategic agent (plan)
    specialized_agents = @agent_files.reject { |f| f.include?("architect.md") || f.include?("plan.md") }

    specialized_agents.each do |file|
      yaml = extract_yaml_front_matter(file)

      # Not all agents have workflow yet, but if present it should be a string
      next unless yaml["workflow"]

      assert_kind_of String, yaml["workflow"],
                     "#{file}: workflow should be a string"
      refute_empty yaml["workflow"], "#{file}: workflow should not be empty"
    end
  end

  private

  def extract_yaml_front_matter(file)
    content = File.read(file)
    match = content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    return nil unless match

    YAML.safe_load(match[1], permitted_classes: [Symbol], aliases: true)
  rescue Psych::SyntaxError
    {}
  end
end
