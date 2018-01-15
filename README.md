<p align="center">
  <img height="200" src="design/logo.png" />
</p>

# Aeryn

[![CircleCI](https://circleci.com/gh/Moya/Aeryn.svg?style=svg)](https://circleci.com/gh/Moya/Aeryn)

Aeryn is a server app, written in Sinatra, used to invite new contributors to a GitHub organization team once they have a pull request merged. 

## State

This project works for production. However, by this point all of the Aeryn servers ran by the maintainers of this repo have moved to [danger/peril](https://github.com/danger/peril) with an [`aeryn.ts`](https://github.com/RxSwiftCommunity/peril/blob/master/org/aeryn.ts) file.

## Motivation

Moya's [contributor guidelines](https://github.com/Moya/contributors) explain in detail what we'll summarize here: we believe in giving push access to contributors after they have a pull request merged. On Moya's [main repo](https://github.com/Moya/Moya), we've been practicing this since June 2015; the practice has led to an engaged, respectful community helping to improve the project.

But remembering to check every pull request, actually inviting new contributors, leaving them a comment – it's work that adds up. This project automates that process using GitHub WebHooks and the GitHub API.

## Setup

There are a few prerequisites:

- A GitHub personal access token.
- The team ID of the GitHub org team to invite contributors to.

### Personal Access Token

You'll need to [create a new personal access token](https://github.com/settings/tokens/new) on whatever account will be inviting new contributors (this means the account needs admin writes). The access token needs the `admin:org` and `public_repo` scopes.

### Team ID

The organization's Team ID is also required. This is a number that's not easily retrieved from GitHub's user interface. You can retrieve it by using `curl` and your personal access token from the previous step.

```sh
> curl -H "Authorization: token PUT_YOUR_ACCESS_TOKEN_HERE" https://api.github.com/orgs/PUT_YOUR_ORG_NAME_HERE/teams
```

That will return a JSON list of teams on the org. Pick the one you want to invite contributors to (here's an abridged sample of what that might look like).

```json
[
  {
    "name": "Contributors",
    "id": 1234567
  }
]
```

### Deploy

The easiest way to deploy the app is to use Heroku. Click the following to get set up and provide necessary config values.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

If you don't want to use Heroku, you can copy `.env.sample` to `.env` to set environment variables for your server. The variables themselves are described in the [app.json](app.json) file.

### Configuring the WebHook

Once deployed, we need to point your GitHub repo(s) at the server. Go to your repository's settings page and WebHook tab, and create a new WebHook. 

You'll need the server's address, as well as the `WEBHOOK_ENDPOINT` environment variable you set up earlier. So if your server is at `https://example.com` and the endpoint is `/payload`, then the Payload URL for the WebHook is `https://example.com/payload`.

You'll also need to specify a secret. This is a random string that GitHub will use to sign the requests sent to Aeryn, to make sure no one else can control the server but GitHub.

![New WebHook interface](web/new_web_hook.png)

Only certain events need to trigger the WebHook, specifically the "Pull Request" event.

![New WebHook interface](web/trigger_events.png)

Once you've saved the WebHook, GitHub will send a ping to your server to see if everything is working. Aeryn should respond that everything is fine, and you'll see a nice green check under the WebHook settings:

![New WebHook interface](web/green_check.png)

If you don't see a green checkmark, it means that GitHub wasn't able to reach Aeryn. Double-check your environment variables and server config, and please feel free to [open an issue](https://github.com/Moya/Aeryn/issues/new).

## Contributing

> If you have trouble installing `ffi` when running `bundle install`, try running `brew install coreutils` first.

This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs.

This project subscribes to the [Moya Contributors Guidelines](https://github.com/Moya/contributors) which TLDR: means we give out push access easily and often. That's actually the whole point of this repo.

This repo subscribes to the [Contributor Code of Conduct](http://contributor-covenant.org/version/1/4/), based on the [Contributor Covenant](http://contributor-covenant.org) version 1.4.0. The maintainers take the code of conduct seriously. 

### Organizations using Aeryn

Check out this list of [known organizations using Aeryn](https://github.com/Moya/Aeryn/blob/master/Orgs%20Using%20Aeryn.md).
Submit a [pull request](https://github.com/Moya/Aeryn/compare) if you'd like to be added to the list!
