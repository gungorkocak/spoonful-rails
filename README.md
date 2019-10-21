# Spoonful

👋 Hello!

Welcome to Spoonful, a delicate take home challenge done in Rails.


### Getting Started

Project is developed using `ruby v2.5.1` and `rails v6.0.0`.
In order not to have problems on the way, please make sure you are on the correct versions as well.


First but not least, install bundler deps first:
```sh
$ bundle install
```

We are going to need some config variables set in runtime, so don't forget to copy `.env.example` as `.env`, and make sure you are providing correct credentials there.

Example `.env.example` file is as follows:
```sh
CONTENTFUL_SPACE_ID=YOUR_SPACE_ID
CONTENTFUL_ENVIRONMENT_ID=YOUR_ENV_ID
CONTENTFUL_ACCESS_TOKEN=YOUR_SECRET
```


Although project actually does not use any database (contentful api is the source of truth), we still need to bootstrap our database with rails.

Now, let’s bootstrap postgresql db and migrate to be able to start and test our app.

```sh
$ rails db:create --all
$ rails db:migrate
```

Before seeing it in action, let's run our tests and make sure everything is intact:

```sh
$ rails test
```

In case something goes wrong, let's remember that some tests are based on snapshots from actual Contentful Api, (using `vcr` gem), so either you should have relevant cassettes under `tests/cassettes` directory or you'll need to have access to actual Contentful Api.


If all tests are passing, then yey!.


Let's start our application with the usual stuff:
```sh
$ rails s
```


### Important Files

Let's try to visualize important files in the project directory for a second:
```
.
├── Gemfile
├── app
│   ├── lib
│   │   ├── contentful
│   │   │   ├── entry.rb
│   │   │   └── entry_serializer.rb
│   │   └── contentful.rb
│   ├── models
│   │   ├── chef.rb
│   │   ├── concerns
│   │   ├── photo.rb
│   │   ├── photo_file.rb
│   │   ├── recipe.rb
│   │   └── tag.rb
│   └── views
│       ├── recipes
│       └── shared
├── config
│   ├── initializers
│   │   ├── contentful.rb
│   │   ├── vcr.rb
├── test
│   ├── cassettes
│   ├── lib
│   │   ├── configuration_test.rb
│   │   └── contentful
│   │       └── entry_test.rb
```

So, a good start would be checking `test/lib` and `app/lib` directories.
Inside you are going to see the base core application and its logic.

Basically `contentful` module, serves as a wrapper to access Contentful Delivery Api, and its relevant entries.

It exposes two main functions as:

* `all!`: to get relevant collection for given entry name.
* `one!`: to get relevant resource for given entry id.

It expects `name:` and `model:` parameters on object initialization. `name:` maps to directly `content_type` for Contentful API, whereas `model:` params is used to serialize Api responses into `ActiveModel` (tableless) model objects.

Each given model should implement `class#to_model(params = {})` method, otherwise `Contentful::Entry` object initialization fails.

HTTP Requests are performed using `faraday` gem, and caching is only performed at that level using `faraday-http-cache`.

If you want to test if cache hits or misses on development environment, you can enable caching with:
```sh
$ rails dev:cache
```

Then you can see `cache hit, store` logs after you do `rails s`.

### Have more questions?

Great! I have more as well. Let's discuss this on a call :)

You can reach me through [email](mailto:self@gungor.dev)
