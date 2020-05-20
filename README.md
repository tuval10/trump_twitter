# Trump Twitter

This project is a Ruby on Rails server and with Next.js client

It gets data from http://trumptwitterarchive.com and shows it on graphs.

Graphs:
1. word occurrences in links: conspiracy, russia, scandal, outrage, china (WIP)
1. Tweets overtime / # of retweets
1. Tweets by the time of day

[see it in action!](https://tuval-trump-twitter-client.herokuapp.com/)

## Requirements
This project require [mongodb](https://docs.mongodb.com/manual/administration/install-community) and redis
update .env file

### Tests
Test runs with RSpec:
```rake spec```

### Rollbar
to initiate rollbar - add ROLLBAR_ACCESS_TOKEN env param.
test rollbar config ```rake rollbar::test```

### Jobs and DB initialization
This app runs job with sidekiq active jobs integration, 
using clockwork for scheduling 

run jobs locally with
``` bundle exec sidekiq ```

you can monitor them on localhost:3000/sidekiq

then run from rails console this jobs to get the data from the remote API run:
```
Tweets::ImportJob.perform_later
```

and when it finish (check sidekiq GUI):
```
Links::CountMentionsManagerJob.perform_later
```

To clean sidekiq queues: ```rake sidekiq:clean```

## Client
Check client library in order to run Next.js client

## Deployment
### server
deployment from heroku: hosted on [https://tuval-trump-twitter.herokuapp.com/trump_twitter_api](https://tuval-trump-twitter.herokuapp.com/trump_twitter_api)

### client
1. add remote: 
```
git remote add client https://git.heroku.com/tuval-trump-twitter-client.git
```
1. push master: 
```
git push client master:master
```



### TODO not must
1. only 1 env file for client and server
1. add date selector to the UI
1. add linter
1. add dead man snitch
1. switch "group by minute" selector to bar instead of buttons
1. move some logic from word count to model
1. split word count logic to fetch, then count