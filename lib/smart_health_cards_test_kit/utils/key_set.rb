# frozen_string_literal: true

require 'forwardable'

module SmartHealthCardsTestKit
  module Utils
    # A set of keys used for signing or verifying HealthCards
    class KeySet
      extend Forwardable

      def_delegator :keys, :empty?

      # Create a KeySet from a JWKS
      #
      # @param jwks [String] the JWKS as a string
      # @return [SmartHealthCardsTestKit::Utils::KeySet]
      def self.from_jwks(jwks)
        jwks = JSON.parse(jwks)
        keys = jwks['keys'].map { |jwk| SmartHealthCardsTestKit::Utils::Key.from_jwk(jwk) }
        KeySet.new(keys)
      end

      # Create a new KeySet
      #
      # @param keys [SmartHealthCardsTestKit::Utils::Key, Array<SmartHealthCardsTestKit::Utils::Key>, nil] the initial keys
      def initialize(keys = nil)
        @key_map = {}
        add_keys(keys) unless keys.nil?
      end

      # The contained keys
      #
      # @return [Array]
      def keys
        @key_map.values
      end

      # Returns the keys as a JWK
      #
      # @return JSON string in JWK format
      def to_jwk
        { keys: keys.map(&:to_jwk) }.to_json
      end

      # Retrieves a key from the keyset with a kid
      # that matches the parameter
      # @param kid [String] a Base64 encoded kid from a JWS or Key
      # @return [Payload::Key] a key with a matching kid or nil if not found
      def find_key(kid)
        @key_map[kid]
      end

      # Add keys to KeySet
      #
      # Keys are added based on the key kid
      #
      # @param new_keys [SmartHealthCardsTestKit::Utils::Key, Array<SmartHealthCardsTestKit::Utils::Key>, SmartHealthCardsTestKit::Utils::KeySet] the initial keys
      def add_keys(new_keys)
        if new_keys.is_a? KeySet
          add_keys(new_keys.keys)
        else
          [*new_keys].each { |new_key| @key_map[new_key.kid] = new_key }
        end
      end

      # Remove keys from KeySet
      #
      # Keys are remove based on the key kid
      #
      # @param new_keys [SmartHealthCardsTestKit::Utils::Key, Array<SmartHealthCardsTestKit::Utils::Key>, SmartHealthCardsTestKit::Utils::KeySet] the initial keys
      def remove_keys(removed_keys)
        if removed_keys.is_a? KeySet
          remove_keys(removed_keys.keys)
        else
          [*removed_keys].each { |removed_key| @key_map.delete(removed_key.kid) }
        end
      end

      # Check if key is included in the KeySet
      #
      # @param key [SmartHealthCardsTestKit::Utils::Key]
      # @return [Boolean]
      def include?(key)
        !@key_map[key.kid].nil?
      end
    end
  end
end