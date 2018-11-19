defmodule Risk.BoardTest do
  use ExUnit.Case
  alias Risk.Board

  test "get territory from board" do
    board = Board.new()
    tile = Board.get_territory(board, "Ontario")

    assert tile == %{
             "adjacent_tiles" => [
               "Alberta",
               "Northwest Territory",
               "Western United States",
               "Eastern Canada",
               "Eastern United States",
               "Ontario",
               "Greenland"
             ],
             "continent" => "North America",
             "name" => "Ontario"
           }
  end
end