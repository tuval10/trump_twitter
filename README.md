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
done via 2 different heroku - for client and server

client: https://tuval-trump-twitter-client.herokuapp.com/

server: https://tuval-trump-twitter.herokuapp.com/trump_twitter_api/1.0.0/tweets_by_minute


### TODO not must
1. add words occurrences in links reports
1. add procfile and deploy to heroku  
1. only 1 env file for client and server
1. add date selector to the UI
1. add group by selector to the UI