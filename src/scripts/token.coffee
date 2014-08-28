# Description
#   Enable deployments from chat that correctly attribute you as the creator - https://github.com/atmos/hubot-deploy
#
# Commands:
#   hubot deploy-token:set <token> - Sets your user's deployment token. Requires repo_deployment scope.
#   hubot deploy-token:reset - Resets your user's deployment token. Requires repo_deployment scope.
#
supported_tasks = [ "#{DeployPrefix}-token" ]

Path           = require("path")
Patterns       = require(Path.join(__dirname, "..", "patterns"))
Deployment     = require(Path.join(__dirname, "..", "deployment")).Deployment
DeployPrefix   = Patterns.DeployPrefix
DeployPattern  = Patterns.DeployPattern
DeploysPattern = Patterns.DeploysPattern

TokenVerifier  = require(Path.join(__dirname, "..", "token_verifier")).TokenVerifier
###########################################################################
module.exports = (robot) ->
  robot.respond ///#{DeployPrefix}-token:set (.*)///i, (msg) ->
    return unless robot.auth.hasRole(msg.envelope.user, "deployer")
    token = msg.match[1]

    verifier = new TokenVerifier(token)
    verifier.valid (result) ->
      if result
        msg.reply "Your token is valid. I stored it for future use."
        msg.envelope.user.githubDeployToken = verifier.token
      else
        msg.reply "Your token is invalid, verify that it has 'repo_deployment' scope."

  robot.respond ///#{DeployPrefix}-token:reset///i, (msg) ->
    return unless robot.auth.hasRole(msg.envelope.user, "deployer")
    delete(msg.envelope.user.githubDeployToken)
    msg.reply "I nuked your deployment token. I'll use my default token until you configure another."
