# frozen_string_literal: true

require "rake/testtask"

# Default task
task default: %w[lint test:unit]

namespace :test do
  # Unit tests (fast) - organized by category
  desc "Run all unit tests (fast, no external deps)"
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.test_files = FileList["test/unit/**/*_test.rb"]
    t.verbose = true
    t.warning = false
  end

  # Integration tests (slow) - organized by category
  desc "Run all integration tests (slow, uses LLMs/Claude CLI)"
  task :integration do
    ENV["INTEGRATION"] = "1"
    Rake::TestTask.new(:integration_runner) do |t|
      t.libs << "test"
      t.test_files = FileList["test/integration/**/*_test.rb"]
      t.verbose = true
      t.warning = false
    end
    Rake::Task[:integration_runner].invoke
  end

  # Run all tests
  desc "Run all tests (unit + integration)"
  task all: %i[unit integration]

  # Category-specific tasks for backward compatibility and granular control
  namespace :unit do
    desc "Run skill unit tests only"
    Rake::TestTask.new(:skills) do |t|
      t.libs << "test"
      t.test_files = FileList["test/unit/skills/**/*_test.rb"]
      t.verbose = true
      t.warning = false
    end

    desc "Run agent unit tests only"
    Rake::TestTask.new(:agents) do |t|
      t.libs << "test"
      t.test_files = FileList["test/unit/agents/**/*_test.rb"]
      t.verbose = true
      t.warning = false
    end
  end

  namespace :integration do
    desc "Run skill integration tests only"
    task :skills do
      ENV["INTEGRATION"] = "1"
      Rake::TestTask.new(:skills_runner) do |t|
        t.libs << "test"
        t.test_files = FileList["test/integration/skills/**/*_test.rb"]
        t.verbose = true
        t.warning = false
      end
      Rake::Task[:skills_runner].invoke
    end

    desc "Run agent integration tests only"
    Rake::TestTask.new(:agents) do |t|
      t.libs << "test"
      t.test_files = FileList["test/integration/agents/**/*_test.rb"]
      t.verbose = true
      t.warning = false
    end

    desc "Run a specific agent integration scenario"
    task :scenario, [:scenario_name] do |_t, args|
      scenario_name = args[:scenario_name]
      raise "Usage: rake test:integration:scenario[scenario_name]" unless scenario_name

      test_file = "test/integration/agents/#{scenario_name}_test.rb"

      if File.exist?(test_file)
        puts "Running integration test: #{test_file}"
        system("ruby -Itest #{test_file}")
      else
        puts "Error: Integration test not found: #{test_file}"
        puts ""
        puts "Available scenarios:"
        Dir.glob("test/integration/agents/*_test.rb").each do |file|
          name = File.basename(file, "_test.rb")
          puts "  - #{name}"
        end
        exit 1
      end
    end
  end

  # Test coverage reports
  desc "Show test coverage report"
  task :report do
    puts "\n=== Test Coverage Report ==="
    puts ""

    # Skills
    total_skills = Dir.glob("skills/**/*.md").reject { |f| f.include?("README") }.count
    skill_unit_tests = Dir.glob("test/unit/skills/**/*_test.rb").count
    skill_integration_tests = Dir.glob("test/integration/skills/**/*_test.rb").count
    skill_coverage = ((skill_unit_tests.to_f / total_skills) * 100).round(1)

    puts "Skills:"
    puts "  Total: #{total_skills}"
    puts "  Unit Tests: #{skill_unit_tests} (#{skill_coverage}% coverage)"
    puts "  Integration Tests: #{skill_integration_tests}"
    puts ""

    # Agents
    total_agents = Dir.glob("agents/*.md").count
    agent_unit_tests = Dir.glob("test/unit/agents/**/*_test.rb").count
    agent_integration_tests = Dir.glob("test/integration/agents/**/*_test.rb").count

    puts "Agents:"
    puts "  Total: #{total_agents}"
    puts "  Unit Tests: #{agent_unit_tests}"
    puts "  Integration Tests: #{agent_integration_tests}"
    puts ""

    # Overall
    total_unit = skill_unit_tests + agent_unit_tests
    total_integration = skill_integration_tests + agent_integration_tests

    puts "Overall:"
    puts "  Unit Tests: #{total_unit}"
    puts "  Integration Tests: #{total_integration}"
    puts "  Total Tests: #{total_unit + total_integration}"
    puts ""
    puts "Run tests:"
    puts "  rake test:unit                    # Fast unit tests"
    puts "  rake test:integration             # Slow integration tests"
    puts "  rake test:unit:skills             # Skills unit tests only"
    puts "  rake test:unit:agents             # Agents unit tests only"
    puts "  rake test:integration:scenario[X] # Specific agent scenario"
    puts ""
  end

  # Helper task for running a specific test file
  desc "Run a specific test file"
  task :file, [:file_path] do |_t, args|
    file_path = args[:file_path]
    raise "Usage: rake test:file[path/to/test.rb]" unless file_path

    if File.exist?(file_path)
      puts "Running test: #{file_path}"
      system("ruby -Itest #{file_path}")
    else
      puts "Error: Test file not found: #{file_path}"
      exit 1
    end
  end

  # Template generator for new skill tests
  desc "Create a new skill test template"
  task :new_skill, [:skill_name, :domain] do |_t, args|
    skill_name = args[:skill_name]
    domain = args[:domain] || "frontend"

    raise "Usage: rake test:new_skill[skill-name,domain]" unless skill_name

    test_class = "#{skill_name.split('-').map(&:capitalize).join}Test"
    unit_test_file = "test/unit/skills/#{skill_name}_test.rb"

    # Create unit test template
    File.write(unit_test_file, <<~RUBY)
      # frozen_string_literal: true

      require_relative "../../support/skill_test_case"

      class #{test_class} < SkillTestCase
        self.skill_domain = "#{domain}"
        self.skill_name = "#{skill_name}"

        def test_skill_file_exists
          assert skill_file_exists?("#{domain}", "#{skill_name}"),
                 "#{skill_name}.md should exist in skills/#{domain}/"
        end

        def test_has_yaml_front_matter
          assert_skill_has_yaml_front_matter
        end

        def test_has_required_metadata
          assert_skill_has_required_metadata
          assert_equal "#{skill_name}", skill_metadata["name"]
          assert_equal "#{domain}", skill_metadata["domain"]
        end

        def test_has_required_sections
          assert_skill_has_section("when-to-use")
          assert_skill_has_section("benefits")
          assert_skill_has_section("standards")
        end

        def test_has_code_examples
          assert_code_examples_are_valid
        end

        # Add more specific tests for this skill...
      end
    RUBY

    puts "Created unit test: #{unit_test_file}"
    puts "Run with: rake test:file[#{unit_test_file}]"
  end
end

namespace :lint do
  desc "Run all linters (Ruby, Markdown, YAML)"
  task all: %i[ruby markdown yaml]

  desc "Lint Ruby files with Rubocop"
  task :ruby do
    puts "Running Rubocop..."
    system("bundle exec rubocop")
  end

  desc "Lint Markdown skill files"
  task :markdown do
    puts "Linting Markdown files..."
    # Lint all markdown files except docs/maintenance/ and docs/optimization/ (internal documentation)
    md_files = Dir.glob("skills/**/*.md") +
               Dir.glob("rules/**/*.md") +
               Dir.glob("docs/**/*.md").reject { |f| f.start_with?("docs/maintenance/", "docs/optimization/") } +
               Dir.glob("*.md")
    system("bundle exec mdl #{md_files.join(' ')} --style .mdl_style.rb")
  end

  desc "Validate YAML front matter in skill files"
  task :yaml do
    puts "Validating YAML front matter..."
    require "yaml"
    errors = []

    Dir.glob("skills/**/*.md").each do |file|
      content = File.read(file)
      if content =~ /\A---\n(.*?)\n---\n/m
        begin
          YAML.safe_load(Regexp.last_match(1), permitted_classes: [Symbol])
        rescue Psych::SyntaxError => e
          errors << "#{file}: #{e.message}"
        end
      else
        errors << "#{file}: Missing YAML front matter"
      end
    end

    if errors.any?
      puts "❌ YAML validation errors:"
      errors.each { |err| puts "  #{err}" }
      exit 1
    else
      puts "✅ All YAML front matter valid"
    end
  end

  desc "Auto-fix Ruby style issues"
  task :fix do
    puts "Auto-fixing Ruby style issues..."
    system("bundle exec rubocop -a")
  end
end

# Alias for convenience
desc "Run all linters (alias for lint:all)"
task lint: "lint:all"

desc "Show available tasks"
task :help do
  system("rake -T")
end
