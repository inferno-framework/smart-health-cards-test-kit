# frozen_string_literal: true

module SmartHealthCardsTestKit
  module Utils
    # Logic for verifying a Payload JWS
    module Verification
      # Verify Health Card with given KeySet
      #
      # @param verifiable [SmartHealthCardsTestKit::Utils::JWS, String] the health card to verify
      # @param key_set [SmartHealthCardsTestKit::Utils::KeySet, nil] the KeySet from which keys should be taken or added
      # @param resolve_keys [Boolean] if keys should be resolved
      # @return [Boolean]
      def verify_using_key_set(verifiable, key_set = nil, resolve_keys: true)
        jws = JWS.from_jws(verifiable)
        key_set ||= SmartHealthCardsTestKit::Utils::KeySet.new
        key_set.add_keys(resolve_key(jws)) if resolve_keys && key_set.find_key(jws.kid).nil?

        key = key_set.find_key(jws.kid)
        unless key
          raise MissingPublicKeyError,
                'Verifier does not contain public key that is able to verify this signature'
        end

        jws.public_key = key
        jws.verify
      end

      # Resolve a key
      # @param jws [SmartHealthCardsTestKit::Utils::JWS, String] The JWS for which to resolve keys
      # @return [SmartHealthCardsTestKit::Utils::KeySet]
      def resolve_key(jws)
        jwks_uri = URI("#{HealthCard.new(jws.to_s).issuer}/.well-known/jwks.json")
        res = Net::HTTP.get(jwks_uri)
        SmartHealthCardsTestKit::Utils::KeySet.from_jwks(res)
      # Handle response if key is malformed or unreachable
      rescue StandardError => e
        raise ArgumentError, "Unable resolve a valid key from uri #{jwks_uri}: #{e.message}"
      end
    end
  end
end