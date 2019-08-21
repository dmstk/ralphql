# frozen_string_literal: true

require 'ralphql/version'
require 'ralphql/node'
require 'ralphql/inflections'

module Ralphql
  class AttributeNotSupportedError < StandardError; end
  class EmptyNodeError < StandardError; end
end
