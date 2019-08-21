# frozen_string_literal: true

module Ralphql
  # A Node represents a query type object in GraphQL.
  # It has name, attributes, arguments and other associated nodes.
  # It can be paginated, which includes rails GraphQL default
  # pagination attributes and the edges, nodes schema
  #
  class Node
    attr_accessor :parent_node

    PAGINATION_ATTS = %i[endCursor startCursor hasPreviousPage hasNextPage].freeze

    def initialize(name, opts = {})
      @name = name
      @args = opts[:args] || {}
      @atts = [opts[:atts]].flatten.compact
      @nodes = [opts[:nodes]].flatten.compact
      @parent_node = opts[:parent_node]
      @paginated = opts[:paginated] || false

      @nodes.each { |node| node.parent_node = self }
    end

    def query
      raise EmptyNodeError if empty_body? && @args.empty?

      args = resolve_args
      body = resolve_body

      result = camelize(@name) + args + body
      result = "{#{result}}" if @parent_node.nil?
      result
    end

    def replace(opts)
      @name = opts[:name] if opts[:name]
      @args = opts[:args] if opts[:args]
      @atts = [opts[:atts]].flatten if opts[:atts]
      @nodes = [opts[:nodes]].flatten if opts[:nodes]
      @parent_node = opts[:parent_node] if opts[:parent_node]
      @paginated = opts[:paginated] if opts[:paginated]
    end

    def add(obj)
      case obj
      when Symbol then @atts << obj.to_s
      when String then @atts << obj
      when Array then @atts += obj.map(&:to_s)
      when Node then obj.parent_node = self && @nodes << obj
      else raise AttributeNotSupportedError
      end
      self
    end

    def add_node(name, args: {}, atts: [], nodes: [], paginated: false)
      node = self.class.new(name, args: args, atts: atts, nodes: nodes, paginated: paginated)
      add(node)
      node
    end

    def empty_body?
      @nodes.empty? && @atts.empty?
    end

    private

    def resolve_args
      args = @args.map { |arg, value| "#{camelize(arg)}:#{value.to_ralphql}" }
      args = args.to_a.join(',')
      args = "(#{args})" if args.size > 1
      args
    end

    def resolve_body
      body = @atts.map { |att| camelize(att) }.join(' ')
      body += ' ' if @atts.any? && @nodes.any?
      body += @nodes.map(&:query).join(' ')
      body = resolve_pagination(body)

      empty_body? ? body : "{#{body}}"
    end

    def resolve_pagination(body)
      return body unless @paginated

      "pageInfo{#{PAGINATION_ATTS.join(' ')}}edges{cursor node{#{body}}}"
    end

    def camelize(term)
      term.to_s.gsub(%r{(?:_|(/))([a-z\d]*)}i) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
    end
  end
end
