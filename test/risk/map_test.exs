defmodule Risk.BoardTest do
  use ExUnit.Case
  alias Risk.Board

  test "get tile from map" do
    tile = Map.get_tile("Ontario")

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
