require 'chunky_png'


# http://rdoc.info/gems/chunky_png/frames
module ChunkyPNG::Color
  def self.block_intensity(pixel_block) #returns a number between 0 and 256 that represents the value of the block passed to it
    avg_red   = pixel_block.map{|p| r(p)}.inject(&:+) / pixel_block.size
    avg_green = pixel_block.map{|p| g(p)}.inject(&:+) / pixel_block.size
    avg_blue  = pixel_block.map{|p| r(p)}.inject(&:+) / pixel_block.size
    gray = 256 - (0.299 * avg_red + 0.587 * avg_green + 0.114 * avg_blue).ceil
  end

  def self.pixel_intensity(pixel) #returns a number between 0 and 256 that represents the value of the pixel passed to it
    gray = 256 - (0.299 * r(pixel) + 0.587 * g(pixel) + 0.114 * b(pixel)).ceil
  end

end

class HalfToneImage < ChunkyPNG::Image
  attr_reader :halftone_coords

  def halftone_data_by_resize(block_percent)
    halftone_coords = []

    @dot_spacing = block_percent
    new_width = width/@dot_spacing.floor
    new_height = height/@dot_spacing.floor
    self.resample_bilinear!(new_width, new_height)

    pixel_locations = (0...new_width).to_a.product((0...new_height).to_a)

    pixels = pixel_locations.map {|x,y| [x , y, get_pixel(x,y)] }

    pixels.each do |pixel|
      # puts pixel.inspect
      # puts ChunkyPNG::Color.pixel_intensity(pixel[2])
      halftone_coords << [pixel[0]* @dot_spacing, pixel[1] * @dot_spacing, ChunkyPNG::Color.pixel_intensity(pixel[2])]
    end

    @halftone_coords = halftone_coords

  end

  def halftone_data_by_block(block_percent)
  halftone_coords = []
  dot_spacing = (width/100*block_percent).floor
  columns1 = width/dot_spacing
  columns2 = columns1 - 2
  rows1 = height/dot_spacing
  rows2 = rows1 - 2

  normal_blocks_positions = (0...columns1).map{|x| x * dot_spacing}.product((0...rows1).map{|y| y * dot_spacing})

    normal_blocks_positions.each do |x,y|
      halftone_coords << [x, y, ChunkyPNG::Color.block_intensity(pixel_block(x,y,dot_spacing))]
    end
  # puts halftone_coords.inspect
  @halftone_coords = halftone_coords
  end

  def pixel_block(x, y, dot_spacing)
    pixels = pixel_coords(x,y, dot_spacing)
    # pixels.each do |p|
      # puts p.inspect
    # end
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
    svg_contents = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <!-- Generator: Adobe Illustrator 14.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 43363)  -->
    <!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">
    <svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
       width=\"#{width * @dot_spacing}px\" height=\"#{height * @dot_spacing}px\" viewBox=\"0 0 #{width * @dot_spacing} #{height * @dot_spacing}\" enable-background=\"new 0 0 1280 720\" xml:space=\"preserve\">\""
    puts @halftone_coords.length
    # @dot_spacing
    @halftone_coords.each do |coord|
      #<circle cx="150" cy="100" r="80" fill="green" />
      if coord[2]/150.floor != 0
        svg_contents << "<circle cx=\"#{coord[0]}\" cy=\"#{coord[1]}\" r=\"#{[(coord[2]/150).floor,@dot_spacing/1.5].min}\" fill=\"black\" /> \n"
      end
    end

    svg_contents << "</svg>"

    file = File.open(file_name, 'w')
    file.write(svg_contents)
    file.close
  end

  def save

  end

end

image = HalfToneImage.from_file('che.png')
# image.resample_bilinear!(180, 240)
# file = File.open('resampled.png', "w")
# image.write(file)
# file.close

image.halftone_data_by_resize(1)
image.export('che.svg')
