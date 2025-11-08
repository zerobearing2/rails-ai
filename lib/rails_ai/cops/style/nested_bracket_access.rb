# frozen_string_literal: true

module RailsAi
  module Cops
    module Style
      # Detects nested hash bracket access and suggests using Hash#dig or Hash#fetch
      #
      # @example
      #   # bad - implicit NoMethodError if intermediate keys are nil
      #   user[:profile][:settings][:theme]
      #
      #   # good - explicit choice to raise or return nil
      #   user.dig(:profile, :settings, :theme)
      #   user.fetch(:profile).fetch(:settings).fetch(:theme)
      #
      class NestedBracketAccess < RuboCop::Cop::Base
        MSG = "Avoid nested bracket access `%<code>s`. " \
              "Use `dig` (safe) or chained `fetch` (raises) for explicit error handling."

        # Pattern: Detects when a [] call is made on the result of another [] call
        # (send (send _receiver :[] ...) :[] ...)
        def_node_matcher :nested_bracket_access?, <<~PATTERN
          (send (send $_ :[] $_) :[] $...)
        PATTERN

        def on_send(node)
          nested_bracket_access?(node) do |_receiver, _first_key, _second_keys|
            # Only flag if this is actually nested bracket access
            # (not array access, not method calls)
            next unless looks_like_hash_access?(node)

            add_offense(node, message: format(MSG, code: node.source))
          end
        end

        private

        def looks_like_hash_access?(node)
          inner_node = node.receiver
          return false unless inner_node&.send_type?

          # At least one access should use a symbol or string key (hash-like)
          # If both are integers, it's likely array access
          hash_like_key?(node) || hash_like_key?(inner_node)
        end

        def hash_like_key?(node)
          first_arg = node.first_argument
          return false unless first_arg

          first_arg.sym_type? || first_arg.str_type?
        end
      end
    end
  end
end
