# frozen_string_literal: true

require "librest"

module GnomeMaps
  # Builds the OpenStreetMap OAuth2 sign-in URL for editing map data.
  # Upstream's src/osmConnection.js builds this with Rest.OAuth2Proxy and
  # Rest.PkceCodeChallenge; this port calls the same two types through the
  # librest GI binding instead of reimplementing PKCE or the authorization
  # URL assembly by hand.
  #
  # AUTH_URL/ACCESS_TOKEN_URL/REDIRECT_URL and the OAuth2 client key are
  # upstream's own public-client constants (src/osmConnection.js) — a
  # desktop-app OAuth2 client id is not a secret the way a server-side one
  # is, and upstream ships it in its public git history under the same
  # GPL-2.0-or-later license as this port.
  class OsmConnection
    AUTH_URL = "https://www.openstreetmap.org/oauth2/authorize"
    ACCESS_TOKEN_URL = "https://www.openstreetmap.org/oauth2/token"
    REDIRECT_URL = "urn:ietf:wg:oauth:2.0:oob"
    BASE_URL = "https://api.openstreetmap.org/api/0.6"
    CLIENT_KEY = "ATOMKAKOXQuAJXpFxkm__nDVRlJLYYmP-0P54UfDnZI"
    CLIENT_SECRET = "9vda-8M_lt0cLJMLJlbTfJVRDGiS2-pPbeSNMRqBQ0k"

    def proxy
      @proxy ||= Rest::OAuth2Proxy.new(AUTH_URL, ACCESS_TOKEN_URL, REDIRECT_URL, CLIENT_KEY, CLIENT_SECRET, BASE_URL)
    end

    # A fresh PKCE verifier/challenge pair for one sign-in attempt, as
    # Rest::PkceCodeChallenge.new generates (the gem's binding has no
    # `new_random` class method; the plain constructor already randomizes).
    def pkce_challenge = Rest::PkceCodeChallenge.new

    # Returns [authorization_url, state], exactly what
    # Rest::OAuth2Proxy#build_authorization_url returns: the URL to open in
    # a browser, and the per-attempt state token to verify the callback
    # against.
    def authorization_url
      proxy.build_authorization_url(pkce_challenge.challenge)
    end
  end
end
