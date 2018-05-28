require "mnist/version"
require 'fileutils'
require 'zlib'
require 'net/http'
require 'ostruct'

module Mnist
  class Error < StandardError; end

  class LoadError < Error; end

  class InvalidMagic < LoadError; end

  class MnistReader
    def initialize(base_path, one_hot = false)
      @base_path = base_path
      @one_hot = one_hot
    end

    def train
      load_pair('train-images-idx3-ubyte', 'train-labels-idx1-ubyte')
    end

    def test
      load_pair('t10k-images-idx3-ubyte', 't10k-labels-idx1-ubyte')
    end

    private

    def load_pair(images, labels)
      Loader.new(File.join(@base_path, images), File.join(@base_path, labels), @one_hot)
    end
  end

  class Loader
    IMAGE_FILE_MAGIC = 2051
    LABEL_FILE_MAGIC = 2049

    def initialize(filename_image, filename_label, one_hot)
      @filename_image = filename_image
      @filename_label = filename_label
      @one_hot = one_hot
      @index = 0
    end

    attr_reader :filename_image, :filename_label

    def load_images
      check_magic(input_images, IMAGE_FILE_MAGIC)
      @total_count = read_total_count(input_images)
      nrows, ncols = read_image_size(input_images)
      images = @total_count.times.map do
        read_image(nrows, ncols)
      end
      [nrows, ncols, images]
    end

    def load_labels
      check_magic(input_labels, LABEL_FILE_MAGIC)
      @total_count = read_total_count(input_labels)
      read_labels(input_labels, @total_count)
    end

    def images
      @all_images ||= load_images[2]
    end

    def labels
      @all_labels ||= load_labels
    end
  
    def next_batch(batch_size)
      if @index == 0
          @rows, @columns, @images = load_images
          @labels = load_labels
      end
      images = []
      labels = []
      batch_size.times.each do
        next if @index >= @total_count
          image_data = @images[@index]
          label_data = @labels[@index]
          image_data.map! { |b| b.to_f / 255.0 }
          @index += 1
          images << image_data
          labels << (@one_hot ? one_hot_transform(label_data) : label_data.to_f)
      end
      [images, labels]
    end
  
    private

    def one_hot_transform(label)
      arr = Array.new(10) { 0.0 }
      arr[label] = 1.0
      arr
    end

    def check_magic(input_file, expected_magic)
      actual_magic = read_magic(input_file)
      unless actual_magic == expected_magic
        raise InvalidMagic, "Expected #{expected_magic}, but #{actual_magic} is given"
      end
    end

    def read_uint8(input_file, n=1)
      input_file.read(n).unpack('C*')
    end

    def read_uint32(input_file, n=1)
      input_file.read(4 * n).unpack('N*')
    end

    def read_magic(input_file)
      read_uint32(input_file).first
    end

    def read_total_count(input_file)
      read_uint32(input_file).first
    end

    def read_image_size(input_file)
      read_uint32(input_file, 2)
    end

    alias read_labels read_uint8

    def read_image(nrows, ncols)
      input_images.read(nrows * ncols).unpack("C*")
    end

    def input_images
      @input_images ||= File.open(filename_image)
    end

    def input_labels
      @input_labels ||= File.open(filename_label)
    end
  end

  def self.load_images(filename)
    Loader.new(filename).load_images
  end

  def self.load_labels(filename)
    Loader.new(filename).load_labels
  end

  def self.read_data_sets(path, one_hot: false)
    unless Dir.exist?(path)
      FileUtils.mkdir_p path
    end

    base_url = "yann.lecun.com"
    filenames = [
      "train-images-idx3-ubyte.gz",
      "train-labels-idx1-ubyte.gz",
      "t10k-images-idx3-ubyte.gz",
      "t10k-labels-idx1-ubyte.gz"
    ]
    Net::HTTP.start(base_url) do |http|
      filenames.each do |name|
        unless File.exists?(File.join(path, name))
          f = File.open(File.join(path, name), "w")
          begin
            http.request_get('/exdb/mnist/' + name) do |resp|
              resp.read_body do |segment|
                f.write(segment)
              end
            end
          ensure
            f.close
          end
        end
      end
    end

    filenames.each do |name|
      next if File.exists?(File.join(path, File.basename(name, '.gz')))
      puts "extracting #{name} ..."
      Zlib::GzipReader.open(File.join(path, name)) do |zipfile|
        outfile = File.open(File.join(path, File.basename(name, '.gz')), 'w')
        outfile.write(zipfile.read)
      end
    end
    MnistReader.new(path, one_hot)
  end
end
