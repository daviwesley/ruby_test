# frozen_string_literal: true

class Player
  attr_accessor :name

  def initialize(name)
    self.name = name
  end
end

class Game
  attr_accessor :player1, :player2, :player1_jumps, :player2_jumps, :home

  def initialize(player1, player2, player1_jumps = 0, player2_jumps = 0)
    self.player1 = player1
    self.player2 = player2
    self.player1_jumps = player1_jumps
    self.player2_jumps = player2_jumps
    self.home = player1
    calculate_points
  end

  def calculate_points
    player1_jumps.map! { |e| e > 10 ? e += 2 : e }
    player2_jumps.map! { |e| e > 10 ? e += 2 : e }
  end
end

class Match
  attr_accessor :games, :home_player, :player1, :player2, :winner, :player1_total_points, :player2_total_points, :p1_total_jumps, :p2_total_jumps, :p1_extra_points, :p2_extra_points

  def initialize(game1, game2, game3, player1_total_points = 0, player2_total_points = 0, p1_total_jumps = 0, p2_total_jumps = 0, p1_extra_points = 0, p2_extra_points = 0)
    self.games = [game1, game2, game3]
    self.player1 = games[0].player1
    self.player2 = games[0].player2
    self.home_player = games[0].home
    self.player1_total_points = player1_total_points
    self.player2_total_points = player2_total_points
    self.p1_total_jumps = p1_total_jumps
    self.p2_total_jumps = p2_total_jumps
    self.p1_extra_points = p1_extra_points
    self.p2_extra_points = p2_extra_points
    calculate
    calculate_points
  end

  def calculate_points
    p1_jumps = p1_extra_points + p1_total_jumps
    p2_jumps = p2_extra_points + p2_total_jumps
    # puts "player1, player2", p1_jumps, p2_jumps
    if p1_jumps < 3
      self.player1_total_points = -1
    elsif p2_jumps < 3
      self.player2_total_points = -1
    end
    if p1_jumps > p2_jumps
      self.player1_total_points = 3
      self.winner = player1
    elsif p2_jumps > p1_jumps
      self.player2_total_points = 3
      self.winner = player2
    elsif p1_jumps == p2_jumps
      if home_player == player1
        self.player2_total_points = 2
        self.winner = player2
      else
        self.player1_total_points = 2
        self.winner = player1
      end
    end
  end

  def calculate
    tries_p1 = [games[0].player1_jumps, games[1].player1_jumps, games[2].player1_jumps]
    tries_p2 = [games[0].player2_jumps, games[1].player2_jumps, games[2].player2_jumps]

    if tries_p1.uniq.size.eql?(1)
      bonus = (tries_p1.flatten.reduce(:+) * 0.10).round
      self.p1_extra_points += bonus
      self.p1_total_jumps += tries_p1.flatten.reduce(:+)
      # puts 'p1 repetido', self.p1_total_jumps, bonus
    else
      # puts 'p1 tries', tries_p1
      self.p1_total_jumps += tries_p1.flatten.reduce(:+)
    end

    if tries_p2.uniq.size.eql?(1)
      # puts 'p2 tries', tries_p1
      bonus = (tries_p2.flatten.reduce(:+) * 0.10).round
      self.p2_extra_points += bonus
      self.p2_total_jumps += tries_p2.flatten.reduce(:+)
      # puts 'p2 repetido', self.p2_total_jumps, bonus
      # else
      #   # puts 'p2 diferente', self.p2_total_jumps
    end
    self.p2_total_jumps += tries_p2.flatten.reduce(:+)
  end
end

class Championship
  attr_accessor :matches, :players, :partial_points

  def initialize(matches = nil, players = [], partial_points = {})
    self.matches = matches
    self.players = players
    self.partial_points = partial_points
    add_players
    calculate
    set_winner
  end

  def set_winner
    puts 'before', partial_points
    # clean the data
    partial_points.transform_values!(&:sum)
    self.partial_points = partial_points.sort_by(&:last).reverse
    # TODO: Draw criterion
  end

  def calculate
    matches.map do |el|
      if el.winner.eql?(el.player1)
        partial_points[el.winner.name].push(el.player1_total_points)
      else
        partial_points[el.winner.name].push(el.player2_total_points)
      end
    end
  end

  def add_players
    matches.map do |el|
      unless players.include?(el.player1.name)
        players.push(el.player1.name)
        partial_points[el.player1.name] = []
      end
    end
  end
end

# generate match, games and tournament with this data
# probabily I'll need use regex
# dict = [["egio", 'jaco', [0,1,2], [1,2,3]], ]
def open_file(file)
  dict = []
  x = -1
  list = []
  File.open(file) do |file|
    file.each do |line|
      pattern = line.match(/([\w]+)[\s]+[\w][\s]+([\w]+)[\s]+(\d+)[\s]+x[\s]+(\d+)/)
      if x >= 0
        list.push([pattern.captures[0], pattern.captures[1], pattern.captures[2], pattern.captures[3]])
      end
      x += 1
      next unless x == 3

      dict.push([list[0][0], list[0][1], [list[0][2], list[1][2], list[2][2]], [list[0][3], list[1][3], list[2][3]]])
      x = 0
      list = []
    end
  end
  dict
end

player1 = Player.new('Davi')
player2 = Player.new('Daniel')

# #g1 = Game.new(player1, player2, [1,2,3], [2,2,12])
# #g2 = Game.new(player1, player2, [4,5,6], [1,1,1])
# #g3 = Game.new(player1, player2, [7,8,9], [1,1,1])

g1 = Game.new(player1, player2, [1, 1, 1], [1, 1, 1])
g2 = Game.new(player1, player2, [1, 1, 1], [1, 1, 1])
g3 = Game.new(player1, player2, [1, 1, 1], [1, 1, 1])
m = Match.new(g1, g2, g3)

g1 = Game.new(player2, player1, [1, 2, 3], [2, 2, 12])
g2 = Game.new(player2, player1, [4, 5, 6], [1, 1, 1])
g3 = Game.new(player2, player1, [7, 8, 9], [1, 1, 1])
m2 = Match.new(g1, g2, g3)

g1 = Game.new(player2, player1, [1, 1, 3], [2, 2, 12])
g2 = Game.new(player2, player1, [1, 1, 1], [1, 1, 1])
g3 = Game.new(player2, player1, [1, 1, 1], [1, 1, 1])
m3 = Match.new(g1, g2, g3)
matches = [m, m2, m3]
t = Championship.new(matches)

dict = open_file('jogadas.txt')
# require 'pry'; binding.pry
# puts dict
