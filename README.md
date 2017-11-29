# ResqueDuplicateless

Resque is awesome. It's great at queuing up lots of jobs and processing them offline. It works making use of Redis, which is extraordinarily fast.

However, Resque makes use of Redis's lists, which means that the entries are not unique. There can exist duplicate entries in the queue. And this is usually what we want. But sometimes it's not. 

resque-duplicateless gives us the option of uniquely adding a job to a queue. This will ensure that the job will only be added to the queue if no other job matching its class and arguments already exists on the queue.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque-duplicateless'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-duplicateless

## Usage

Making a job unique is super easy.

In a normal Resque environment, we would enqueue a job by using the following method

    Resque.enqueue FooClass, argument_1, argument_2, ...

In order to uniquely enqueue that class, we do the following.

    Resque.enqueue_uniquely FooClass, argument_1, argument_2, ...

Also, a correlated method to `enqueue_to` exists in `enqueue_uniquely_to`


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Please make sure to run `bundle exec rspec` if you make any changes to make sure they are not breaking. Rspec expects that there is a Redis process set up on the machine and makes use of the keys `ruj:rspec:queue_1` and `ruj:rspec:queue_1`

*WARNING* - The Rspec will delete everything on the `ruj:rspec:queue_1` and `ruj:rspec:queue_2` queues. Please make sure you don't need them for anything before testing or change the redis database in the `spec/helpers/spec_init.rb` file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/glossandglam/resque-duplicateless. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ResqueUniqueJob project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/glossandglam/resque-duplicateless/blob/master/CODE_OF_CONDUCT.md).


### Authors

This gem was authored by the following:

Jeremy Linder (deathbyjer)
