defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """
  
  def main(input) do
    input
    |> hash_input()
    |> pick_colour()
  end

  def hash_input(input) do
    hex = 
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()
    
    %Identicon.Image{hex: hex}
  end
 
  def pick_colour(image) do
    %Identicon.Image{hex: [red, green, blue | _]}  = image
    
    %Identicon.Image{image | colour: {red, green, blue}}
  end
end
