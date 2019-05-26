require 'matrix'
require 'distribution'

class NeuralNetwork
  attr_reader :neurons, :weights, :biases, :names

  @@rng = Distribution::Normal.rng

  def initialize(sizes = nil)
    @weights = [[]]
    @biases = [[]]
    @neurons = [[], []]
    @names = {}

    unless sizes.nil?
      sizes.first.times{ @neurons.first << 0.0 }
      sizes[1..-2].each do |size|
        puts size
        add_hidden_layer(size)
      end
      sizes.last.times{ add_output }
    end
  end

  def outputs
    @neurons.length > 0 ? @neurons[-1] : []
  end

  def inputs
    @neurons.length > 0 ? @neurons[0] : []
  end

  def sizes
    @neurons.map(&:size)
  end

  def add_input(name = nil)
    @neurons.first << 0.0
    @weights.first.each do |weight_arr|
      weight_arr << @@rng.call
    end
    name_neuron(0, @neurons.first.length - 1, name) unless name.nil?
  end

  def add_output(name = nil)
    @neurons.last << 0.0
    @biases.last << @@rng.call
    @weights.last << []
    @weights[-2].size.times do |i|
      @weights.last.last << @@rng.call
    end
    name_neuron(@neurons.size - 1, @neurons.last.length - 1, name) unless name.nil?
  end

  def add_hidden_layer(size, position = :last)
    puts 'here'
    prev_index = position == :last ? -2 : 0
    insert_index = position == :last ? -2 : 1
    next_index = position == :last ? -1 : 1
    layer = Array.new(size, 0.0)
    layer_biases = size.times.map{ @@rng.call }
    layer_weights = size.times.map{ @neurons[prev_index].size.times.map{ @@rng.call }}
    @neurons.insert(insert_index, layer)
    @biases.insert(insert_index, layer_biases)
    @weights.insert(insert_index, layer_weights)
    @weights[next_index] = @weights[next_index].size.times.map{ size.times.map{ @@rng.call }}
    pp [prev_index, next_index, insert_index]
    pp to_hash
  end

  def name_neuron(i, j, name)
    raise TypeError.new('Integer not allowed as neuron name') if name.is_a?(Integer)
    @names[name] = [i, j]
  end

  def [](name)
    return @neurons[name] if name.is_a?(i)
    raise KeyError("No such neuron name #{name}") unless @names.has_key?(name)
    indices = @names[name]
    @neurons[indices.first][indices.last]
  end

  def []=(name, value)
    raise KeyError("No such neuron name #{name}") unless @names.has_key?(name)
    indices = @names[name]
    @neurons[indices.first][indices.last] = value
  end

  def think
    feed_forward
  end

  def feed_forward(values = nil)
    feed(values) unless values.nil?
    (1..@neurons.length - 1).each do |i|
      a = Matrix.rows(@weights[i - 1], false)
      b = Matrix.columns([@neurons[i - 1]])
      c = Matrix.columns([@biases[i - 1]])
      outputs = a * b + c
      @neurons[i].length.times do |j|
        @neurons[i][j] = sigmoid(outputs[j, 0])
      end
    end
  end

  def feed(values)
    values.each do |name, value|
      if name.is_a?(Array)
        self[name.first][name.last] = value
      else
        self[name] = value
      end
    end
  end

  def to_hash
    {
      neurons: Marshal.load(Marshal.dump(@neurons)),
      names: Marshal.load(Marshal.dump(@names)),
      weights: Marshal.load(Marshal.dump(@weights)),
      biases: Marshal.load(Marshal.dump(@biases))
    }
  end

  def self.from_hash(hash)
    hash = Marshal.load(Marshal.dump(hash))

    neurons = hash.has_key?(:neurons) ? hash[:neurons] : hash['neurons']
    names = hash.has_key?(:names) ? hash[:names] : hash['names']
    weights = hash.has_key?(:weights) ? hash[:weights] : hash['weights']
    biases = hash.has_key?(:biases) ? hash[:biases] : hash['biases']

    nn = NeuralNetwork.new(neurons.map(&:size))

    neurons.each.with_index{ |layer, i| nn.neurons[i] = layer }
    names.each{ |name, indices| nn.names[name] = indices }
    weights.each.with_index{ |layer, i| nn.weights[i] = layer }
    biases.each.with_index{ |layer, i| nn.biases[i] = layer }

    nn
  end

  def to_json
    if defined?(JSON).nil?
      raise NoMethodError.new('JSON undefined')
    else
      to_hash.to_json
    end
  end

  def self.from_json(json)
    if defined?(JSON).nil?
      raise NoMethodError.new('JSON undefined')
    else
      from_hash(JSON.load(json))
    end
  end

  def to_yaml
    if defined?(YAML).nil?
      raise NoMethodError.new('YAML undefined')
    else
      to_hash.to_yaml
    end
  end

  def self.from_yaml(json)
    if defined?(YAML).nil?
      raise NoMethodError.new('JSON undefined')
    else
      from_hash(YAML.load(json))
    end
  end

  private

  def sigmoid(x)
    1.0 / (1.0 + Math::E ** (-x.to_f))
  end
end
