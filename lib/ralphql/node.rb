# frozen_string_literal: true

module Ralphql
  # A Node represents a query type object in GraphQL.
  # It has name, attributes, arguments and other associated nodes
  class Node
    attr_accessor :parent_node, :atts, :args

    def initialize(name, args: {}, atts: [], nodes: [], parent_node: nil)
      @name = name
      @args = args
      @atts = [atts].flatten
      @nodes = [nodes].flatten
      @parent_node = parent_node

      @nodes.each { |node| node.parent_node = self }
    end

    def query
      raise EmptyBodyError if @nodes.empty? && @atts.empty?

      args = resolve_args
      body = resolve_body

      result = "#{camelize(@name)}#{args}{#{body}}"
      result = "{#{result}}" if @parent_node.nil?
      result
    end

    def update(name: nil, args: nil, atts: nil, nodes: nil, parent_node: nil)
      @name = name if name
      @args = args if args
      @atts = [atts].flatten if atts
      @nodes = [nodes].flatten if nodes
      @parent_node = parent_node if parent_node
    end

    def add(obj)
      case obj
      when Symbol then @atts << obj.to_s
      when String then @atts << obj
      when Array then @atts += obj.map(&:to_s)
      when Node then
        obj.parent_node = self
        @nodes << obj
      else raise AttributeNotSupportedError
      end
      self
    end

    def add_node(name, atts: [], nodes: [], args: {})
      node = self.class.new(name, args: args, atts: atts, nodes: nodes)
      add(node)
      node
    end

    private

    def resolve_args
      args = @args.map do |arg, value|
        value = "'#{value}'" if value.is_a?(String) || value.is_a?(Symbol)
        "#{camelize(arg)}:#{value}"
      end

      args = args.to_a.join(',')
      args = "(#{args})" if args.size > 1
      args
    end

    def resolve_body
      body = @atts.map { |att| camelize(att) }.join(' ')
      body += ' ' if @atts.any? && @nodes.any?
      body + @nodes.map(&:query).join(' ')
    end

    def camelize(term)
      term.to_s.gsub(%r{(?:_|(/))([a-z\d]*)}i) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
    end
  end
end
