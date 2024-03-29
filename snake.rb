#importera ruby2d biblioteket
require 'ruby2d'

#Inställningar för spelfönstret
set background: 'black'
set fps_cap: 20
SQUARE_SIZE = 20
GRID_WIDTH = Window.width / SQUARE_SIZE
GRID_HEIGHT = Window.height / SQUARE_SIZE

#Snake klassen hanterar hur ormen fungerar och rör sig
class Snake
  attr_writer :direction #gör så att extern kod kan se ormens riktning

  #initialize bestämmer startposition och rikting för ormen
  def initialize
    @positions = [[5, 0], [5, 1], [5, 2], [5 ,3]]
    @direction = 'down'
    @growing = false
  end

  #ritar ormen på i spelfönstret
  def draw
    @positions.each do |position|
      Square.new(x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE, size: SQUARE_SIZE - 1, color: 'green')
    end
  end

  #grow signalerar att ormen ska växa
  def grow
    @growing = true
  end

  #move flyttar ormen beroende på rikting och om den ska växa eller inte
  def move
    #.shift flyttar alla element neråt
    if !@growing
      @positions.shift
    end
    
    @positions.push(next_position)
    @growing = false
  end
#can_change_direction_to? hindrar ormen för att åka in i sig själv genom olika cases
  def can_change_direction_to?(new_direction)

    case @direction
    when 'up' then new_direction != 'down'
    when 'down' then new_direction != 'up'
    when 'left' then new_direction != 'right'
    when 'right' then new_direction != 'left'
    end
  end

  #hittar x koordinaten av ormens huvud
  def x
    head[0]
  end
  #hittar y koordinaten av ormens huvud
  def y
    head[1]
  end

  #next_position räknar ut nästa position för ormen. If-satser används för att kolla riktning
  def next_position
    if @direction == 'down'
      new_coords(head[0], head[1] + 1)
    elsif @direction == 'up'
      new_coords(head[0], head[1] - 1)
    elsif @direction == 'left'
      new_coords(head[0] - 1, head[1])
    elsif @direction == 'right'
      new_coords(head[0] + 1, head[1])
    end
  end

  #hit_itself? kollar om ormen har åkt in i sig själv. När det händer ska man förlora.
  def hit_itself?
    #.uniq tar bort positioner som är likadana, vilket kommer vara fallet om ormen kolliderar med sig själv
    @positions.uniq.length != @positions.length
  end

  private
  #
  def new_coords(x, y)
    [x % GRID_WIDTH, y % GRID_HEIGHT]
  end
#head returnar sista elementet av sig själv genom .last, alltså huvudet
  def head
    @positions.last
  end
end

#game klassen hanterar spelet
class Game
  #initialisera spelet med position på bollen/frukten som ormen äter för att växa och poäng
  def initialize
    @ball_x = 10
    @ball_y = 10
    @score = 0
    @finished = false
  end

  #ritar bollen/frukten och visar poängen
  def draw
    Square.new(x: @ball_x * SQUARE_SIZE, y: @ball_y * SQUARE_SIZE, size: SQUARE_SIZE, color: 'red')
    Text.new(text_message, color: 'white', x: 10, y: 10, size: 25, z: 1)
  end

  #snake_hit_ball? kollar om ormen har åkt på bollen genom att kolla ifall bollen har samma position som ormens huvud
  def snake_hit_ball?(x, y)
    @ball_x == x && @ball_y == y
  end

  #record_hit uppdaterar poängen och skapar en ny boll på random koordinater
  def record_hit
    @score += 1
    @ball_x = rand(Window.width / SQUARE_SIZE)
    @ball_y = rand(Window.height / SQUARE_SIZE)
  end

  #finish signalerar att spelet ska avsluta
  def finish
    @finished = true
  end

  #finished? kollar om spelet är avslutat
  def finished?
    @finished
  end

  private

  #text_message generar rätt text för spelets status
  def text_message
    if finished?
      #genererar denna text om spelet är avslutat
      "Game over. Din poäng var #{@score}. Tryc på 'R' för att spela igen. "
    else
      #genererar denna text om spelt är igång
      "Score: #{@score}"
    end
  end
end

#starta spelet och ormen
snake = Snake.new
game = Game.new

#Game loop logik
update do
  clear

  unless game.finished?
    snake.move
  end

  snake.draw
  game.draw

  if game.snake_hit_ball?(snake.x, snake.y)
    game.record_hit
    snake.grow
  end

  if snake.hit_itself?
    game.finish
  end
end
#event handling för input
on :key_down do |event|
  if ['up', 'down', 'left', 'right'].include?(event.key)
    if snake.can_change_direction_to?(event.key)
      snake.direction = event.key
    end
  end

  if game.finished? && event.key == 'r'
    snake = Snake.new
    game = Game.new
  end
end

show