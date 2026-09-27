# frozen_string_literal: true

class Gman
  # Second level .us domains for states and locality
  # See http://en.wikipedia.org/wiki/.us
  #
  # Examples:
  #  * foo.state.il.us
  #  * ci.foo.il.us
  #
  # Not:
  #  * state.foo.il.us
  #  * foo.ci.il.us
  #  * k12.il.us
  #  * ci.foo.zx.us
  class Locality
    AFFINITY_NAMESPACES = %w[state dst cog].freeze

    STATES = %w[
      ak al ar az ca co ct dc de fl ga hi ia id il in ks ky
      la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh
      ok or pa ri sc sd tn tx um ut va vt wa wi wv wy
    ].freeze

    LOCALITY_DOMAINS = %w[
      ci co borough boro city county
      parish town twp vi vil village
    ].freeze

    REGEX = /
      (
        (#{Regexp.union(AFFINITY_NAMESPACES)})
      |
        (#{Regexp.union(LOCALITY_DOMAINS)})\.[a-z-]+
      )\.(#{Regexp.union(STATES)})\.us
    /x

    def self.valid?(domain)
      !domain.to_s.match(Locality::REGEX).nil?
    end
  end
end
