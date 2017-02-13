defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """
  
  def main(input) do
    input
    |> hash_input()
    |> pick_colour()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end

  defp hash_input(input) do
    hex = 
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()
    
    %Identicon.Image{hex: hex}
  end
 
  defp pick_colour(%Identicon.Image{hex: [red, green, blue | _]} = image) do
    %Identicon.Image{image | colour: {red, green, blue}}
  end

  defp build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  defp mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = 
      Enum.map grid, fn({_code, index}) ->
        horizontal_distance = rem(index, 5) * 50
        vertical_distance = div(index, 5) * 50

        top_left = {horizontal_distance, vertical_distance}
        bottom_right = {horizontal_distance + 50, vertical_distance + 50}

        {top_left, bottom_right}
      end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Identicon.Image{colour: colour, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(colour)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  defp save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
