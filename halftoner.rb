require 'chunky_png'
# require 'fastimage_resize'

# http://rdoc.info/gems/chunky_png/frames
module ChunkyPNG::Color
  def self.find_intensity(pixel_block) #returns a number between 0 and 256 that represents the value of the block passed to it
    avg_red   = pixel_block.map{|p| r(p)}.inject(&:+) / pixel_block.size
    avg_green = pixel_block.map{|p| g(p)}.inject(&:+) / pixel_block.size
    avg_blue  = pixel_block.map{|p| r(p)}.inject(&:+) / pixel_block.size
    # puts "#{avg_red} #{avg_green} #{avg_blue}"
    gray = 256 - (0.299 * avg_red + 0.587 * avg_green + 0.114 * avg_blue).ceil
  end
end

class HalfToneImage < ChunkyPNG::Image
  attr_reader :halftone_coords

  def halftone_data(block_percent)
  halftone_coords = []
  dot_spacing = width/100*block_percent
  columns1 = width/dot_spacing
  columns2 = columns1 - 2
  rows1 = height/dot_spacing
  rows2 = rows1 - 2

  normal_blocks_positions = (0...columns1).map{|x| x * dot_spacing}.product((0...rows1).map{|y| y * dot_spacing})

    normal_blocks_positions.each do |x,y|
      halftone_coords << [x, y, ChunkyPNG::Color.find_intensity(pixel_block(x,y,dot_spacing))]
    end
  # puts halftone_coords.inspect
  @halftone_coords = halftone_coords
  end

  def pixel_block(x, y, dot_spacing)
    pixels = pixel_coords(x,y, dot_spacing)
    pixels.each do |p|
      # puts p.inspect
    end
    bob = pixels.map {|x,y| get_pixel(x,y)}
    # bob.each do |p|
    #   puts p.inspect
    # end
    bob
  end

  def pixel_coords(x, y, dot_spacing)
    x_pixel_columns = [width, x + dot_spacing].min
    y_pixel_rows = [height, y + dot_spacing].min
    (x...x_pixel_columns).to_a.product((y...y_pixel_rows).to_a)
  end

  def export(file_name)
    svg_contents = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\"
       width=\"#{width}px\" height=\"#{height}px\" viewBox=\"0 0 #{width} #{height}\" enable-background=\"new 0 0 1280 720\" xml:space=\"preserve\">\"\n"

    @halftone_coords.each do |coord|
      #<circle cx="150" cy="100" r="80" fill="green" />
      svg_contents << "<circle cx=\"#{coord[0]}\" cy=\"#{coord[1]}\" r=\"#{(coord[2]/50).floor}\" fill=\"black\" /> \n"
    end

    svg_contents << "</svg>"

    file = File.open(file_name, 'w')
    file.write(svg_contents)
    file.close
  end


end

image = HalfToneImage.from_file('che.png')
image.halftone_data(2)
image.export('che2.svg')
