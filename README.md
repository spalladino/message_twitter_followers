# message_twitter_followers

Crystal tool for downloading the list of Twitter followers and DM'ing them.

See [balajis/twitter-export](https://github.com/balajis/twitter-export) for context.

## Status

This project is under development. Classes for storing data in a local SQLite DB and querying Twitter are set up. Main logic is in progress in `src/executor`, with tests still pending and logic for sending DMs (at a 1000 per day limit).

## Environment

While there is no environment set up, the idea was to use Github Actions as an environment. This requires setting actions on a scheduled basis (eg every few hours) to check for the current status and run as much as they can (in retrieving follower ids, follower data, or sending DMs) depending on Twitter aggressive rate limits.

Whoever wants to run this, can just fork the repo, populate their API keys as a github secret, and have github actions on their repo take care of running. The running action can persist the sqlite DB in a new commit in the repo itself, since we are not storing much data.

## Development

[Install Crystal](https://crystal-lang.org/install/), and test running `crystal spec`.

## Contributing

1. Fork it (<https://github.com/your-github-user/message_twitter_followers/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Santiago Palladino](https://github.com/spalladino) - creator and maintainer
