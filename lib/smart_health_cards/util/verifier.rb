# frozen_string_literal: true

require 'net/http'
require_relative 'verification'

module SmartHealthCards
  # Verifiers can validate HealthCards using public keys
  class Verifier
    attr_reader :keys
    attr_accessor :resolve_keys

    include SmartHealthCards::Verification
    extend SmartHealthCards::Verification

    # Verify a Payload
    #
    # This method _always_ uses key resolution and does not depend on any cached keys
    #
    # @param verifiable [SmartHealthCards::JWS, String] the health card to verify
    # @return [Boolean]
    def self.verify(verifiable)
      verify_using_key_set(verifiable)
    end

    # Create a new Verifier
    #
    # @param keys [SmartHealthCards::KeySet, SmartHealthCards::Key, nil] keys to use when verifying Health Cards
    # @param resolve_keys [Boolean] Enables or disables key resolution
    def initialize(keys: nil, resolve_keys: true)
      @keys = case keys
              when KeySet
                keys
              when Key
                KeySet.new(keys)
              else
                KeySet.new
              end

      self.resolve_keys = resolve_keys
    end

    # # Add a key to use when verifying
    # #
    # # @param key [SmartHealthCards::Key, SmartHealthCards::KeySet] the key to add
    # def add_keys(key)
    #   @keys.add_keys(key)
    # end

    # # Remove a key to use when verifying
    # #
    # # @param key [SmartHealthCards::Key] the key to remove
    # def remove_keys(key)
    #   @keys.remove_keys(key)
    # end

    # Verify a Payload
    #
    # @param verifiable [SmartHealthCards::JWS, String] the health card to verify
    # @return [Boolean]
    def verify(verifiable)
      verify_using_key_set(verifiable, keys, resolve_keys: resolve_keys?)
    end

    def resolve_keys?
      resolve_keys
    end
  end
end
