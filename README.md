# Mnist

Utility ruby gem for easily loading and parsing the MNIST Database of handwritten digits for machine learning purposes.

Based on work by kenta murata.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mnist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mnist

## Usage

Load test and training data easily.

```ruby
minst = Mnist.read_data_sets('data') # auto download test and training archives and store them in /data
images = minst.train.images
labels = minst.train.labels

#you can also iterate in batches

train_images, train_labels = minst.train.next_batch(100)
test_images, test_labels = minst.test.next_batch(100)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mnist/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
