class Gman
  LOCALITY_REGEX = /
    (
      (state|dst|cog)
    |
      (ci|co|borough|boro|city|county|parish|town|twp|vi|vil|village)\.[a-z-]+
    )
    \.(ak|al|ar|az|ca|co|ct|dc|de|fl|ga|hi|ia|id|il|in|ks|ky|la|ma|md|me|mi|mn|mo|ms|mt|nc|nd|ne|nh|nj|nm|nv|ny|oh|ok|or|pa|ri|sc|sd|tn|tx|um|ut|va|vt|wa|wi|wv|wy)
    \.us
     /x

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
  def locality?
    !!(domain.to_s =~ LOCALITY_REGEX)
  end
end
