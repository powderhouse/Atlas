const scopes = [
  'https://www.googleapis.com/auth/drive'
]

const {OAuth2Client} = require('google-auth-library');
const http = require('http');
const url = require('url');
const opn = require('opn');
const fs = require("fs");
const destroyer = require('server-destroy');

const keys = require('./oauth2.keys.json');
const tokensFile = "tokens.json"

module.exports = {

  getOAuth2Client: async function(dataDirectory) {
    var tokens;
    try {
      tokens = require(dataDirectory + "/" + tokensFile)
    } catch (e) {
      tokens = {}
    }

    const oAuth2Client = new OAuth2Client(
      keys.web.client_id,
      keys.web.client_secret,
      keys.web.redirect_uris[0]
    );

    var scopeTokens = tokens[scopes.join("-")]
    if (!scopeTokens) {
      scopeTokens = await getTokens(oAuth2Client);
      tokens[scopes.join("-")] = scopeTokens

      fs.writeFile(dataDirectory + "/" + tokensFile, JSON.stringify(tokens), 'utf8', function() {
        console.log("Token saved")
      });
    }

    oAuth2Client.setCredentials(scopeTokens);
    return oAuth2Client;
  }

}


function getTokens(oAuth2Client) {
  return new Promise((resolve, reject) => {
    const authorizeUrl = oAuth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
    });

    const server = http
      .createServer(async (req, res) => {
        try {
          if (req.url.indexOf('www.googleapis.com') > -1) {
            const qs = new url.URL(req.url, 'http://localhost:3000')
              .searchParams;
            const code = qs.get('code');
            res.end('Authentication successful! You can close this window.');
            server.destroy();

            const r = await oAuth2Client.getToken(code);
            resolve(r.tokens);
          }
        } catch (e) {
          reject(e);
        }
      })
      .listen(3000, () => {
        opn(authorizeUrl, {wait: false}).then(cp => cp.unref());
      });
    destroyer(server);
  });
}
