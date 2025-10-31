# frozen_string_literal: true

require "rake/testtask"

# Default task
task default: %w[lint test:skills:unit test:agents:unit]

namespace :test do
  namespace :agents do
    desc "Run all agent unit tests (fast, structural validation)"
    Rake::TestTask.new(:unit) do |t|
      t.libs << "test"
      t.test_files = FileList["test/agents/unit/**/*_test.rb"]
      t.verbose = true
      t.warning = false
    end

    desc "Run all agent integration tests (slow, uses LLMs)"
    task :integration do
      puts "Agent integration tests not yet implemented (deferred post-MVP)"
      puts "Agent unit tests provide structural validation for MVP"
    end

    desc "Run all agent tests (unit + integration)"
    task all: %i[unit integration]

    desc "Agent test coverage report"
    task :report do
      puts "\n=== Agent Test Coverage Report ==="
      puts ""

      # Count agents
      total_agents = Dir.glob("agents/*.md").count
      puts "Total Agents: #{total_agents}"

      # Count unit tests
      unit_tests = Dir.glob("test/agents/unit/**/*_test.rb").count
      puts "Unit Tests: #{unit_tests}"

      # Count test assertions (approximate)
      test_count = 0
      Dir.glob("test/agents/unit/**/*_test.rb").each do |file|
        test_count += File.read(file).scan("def test_").count
      end
      puts "Test Methods: #{test_count}"

      puts ""
      puts "Run tests:"
      puts "  rake test:agents:unit          # Fast structural tests"
      puts "  rake test:agents:all           # All tests"
      puts ""
    end
  end

  namespace :skills do
    desc "Run all skill unit tests (fast, no LLM calls)"
    Rake::TestTask.new(:unit) do |t|
      t.libs << "test"
      t.test_files = FileList["test/skills/unit/**/*_test.rb"]
      t.verbose = true
      t.warning = false
    end

    desc "Run all skill integration tests (slow, uses LLMs)"
    task :integration do
      ENV["INTEGRATION"] = "1"
      Rake::TestTask.new(:integration_runner) do |t|
        t.libs << "test"
        t.test_files = FileList["test/skills/integration/**/*_test.rb"]
        t.verbose = true
        t.warning = false
      end
      Rake::Task[:integration_runner].invoke
    end

    desc "Run all skill tests (unit + integration)"
    task all: %i[unit integration]

    desc "Run skill tests with coverage report"
    task :report do
      puts "\n=== Skill Test Coverage Report ==="
      puts ""

      # Count skills
      total_skills = Dir.glob("skills/**/*.md").reject { |f| f.include?("README") }.count
      puts "Total Skills: #{total_skills}"

      # Count unit tests
      unit_tests = Dir.glob("test/skills/unit/**/*_test.rb").count
      puts "Unit Tests: #{unit_tests}"

      # Count integration tests
      integration_tests = Dir.glob("test/skills/integration/**/*_test.rb").count
      puts "Integration Tests: #{integration_tests}"

      # Coverage
      coverage = ((unit_tests.to_f / total_skills) * 100).round(1)
      puts "Coverage: #{coverage}%"

      puts ""
      puts "Run tests:"
      puts "  rake test:skills:unit          # Fast unit tests"
      puts "  rake test:skills:integration   # Slow integration tests"
      puts "  rake test:skills:all           # All tests"
      puts ""
    end

    desc "Run tests for a specific skill"
    task :skill, [:skill_name] do |_t, args|
      skill_name = args[:skill_name]
      raise "Usage: rake test:skills:skill[skill-name]" unless skill_name

      # Convert skill-name to SkillName for test file
      skill_name.split("-").map(&:capitalize).join

      unit_test = "test/skills/unit/#{skill_name}_test.rb"
      integration_test = "test/skills/integration/#{skill_name}_integration_test.rb"

      if File.exist?(unit_test)
        puts "Running unit test: #{unit_test}"
        system("ruby -Itest #{unit_test}")
      else
        puts "Warning: Unit test not found: #{unit_test}"
      end

      if File.exist?(integration_test) && ENV["INTEGRATION"]
        puts "Running integration test: #{integration_test}"
        system("INTEGRATION=1 ruby -Itest #{integration_test}")
      elsif File.exist?(integration_test)
        puts "Skipping integration test (set INTEGRATION=1 to run)"
      end
    end

    desc "Create a new skill test template"
    task :new, [:skill_name, :domain] do |_t, args|
      skill_name = args[:skill_name]
      domain = args[:domain] || "frontend"

      raise "Usage: rake test:skills:new[skill-name,domain]" unless skill_name

      test_class = "#{skill_name.split('-').map(&:capitalize).join}Test"
      unit_test_file = "test/skills/unit/#{skill_name}_test.rb"

      # Create unit test template
      File.write(unit_test_file, <<~RUBY)
        # frozen_string_literal: true

        require_relative "../skill_test_case"

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
      puts "Run with: ruby -Itest #{unit_test_file}"
    end
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
    # Lint skills and root markdown files (exclude docs/maintenance/ archive)
    system("bundle exec mdl skills/ *.md --style .mdl_style.rb")
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
