# Ralphql

Ralphql is a DSL language written in ruby to aid in the creation fo GraphQL queries. 
It provides convenient methods to create and update queries as needed. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ralphql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ralphql

## Usage

```ruby
node = Ralphql::Node.new(:query_name, atts: %i[id name])
node.add Ralphql::Node.new(:items, atts: %i[title body], args: { first: 3 })

node.query 
  #=> "{queryName{id name items(first:3){title body}}}"  
```

###Atts
Attributes are string, they represent attribute names of a query, they dont contain options. Ralphql camelizes for you. 
```ruby
Ralphql::Node.new(:query_name, atts: :id).query 
  #=> "{queryName{id}}" 
Ralphql::Node.new(:query_name, atts: %i[name simple_body]).query 
  #=> "{queryName{name simpleBody}}" 
```

###Args
Arguments affect the nodes query, you can write them snake cased and Ralphql camelizes for you. For example
```ruby
 Ralphql::Node.new(:query_name, args: { first: 3, order: 'id' }, atts: :id).query 
  #=> "{queryName(first:3,order:'id'){id}}" 
```

###Pagination
Ralphql can take care of pagination for you. As of this version pagination includes all 
attributes and updates the body accordingly. So for example:
```ruby
Ralphql::Node.new(:query_name, atts: :id).query 
  #=> "{queryName{id}}" 
Ralphql::Node.new(:query_name, atts: :id, paginated: true).query 
  #=> "{queryName{pageInfo{endCursor startCursor hasPreviousPage hasNextPage}edges{cursor node{id}}}}"
```

###Nodes
Every node can have many child nodes and almost every node has a parent node. Ralphql takes care of this for you.
It allows to build complex queries where attributes are queries themselves with arguments, pagination...etc etc
```ruby
node = Ralphql::Node.new(:query_name, atts: %i[name])
node.add Ralphql::Node.new(:items, atts: %i[id name], args: { exclude: :unpublished })
node.add Ralphql::Node.new(:comments, atts: %i[title body], args: { first: 3, order: :popular }, paginated: true)

node.query 
  #=> "{queryName{name items(exclude:'unpublished'){id name} comments(first:3,order:'popular'){pageInfo{endCursor startCursor hasPreviousPage hasNextPage}edges{cursor node{title body}}}}}"   
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wolas/ralphql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ralphql project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/wolas/ralphql/blob/master/CODE_OF_CONDUCT.md).
