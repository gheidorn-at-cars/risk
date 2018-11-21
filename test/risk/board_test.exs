defmodule Risk.BoardTest do
  use ExUnit.Case
  alias Risk.Board

  test "get territory from board" do
    board = Board.new()
    tile = Board.get_territory(board, "Ontario")

    assert tile == %Risk.Board.Territory{
             adjacent: [
               "Alberta",
               "Northwest Territory",
               "Western United States",
               "Eastern Canada",
               "Eastern United States",
               "Ontario",
               "Greenland"
             ],
             armies: nil,
             continent: "North America",
             name: "Ontario",
             owner: nil
           }
  end
end
