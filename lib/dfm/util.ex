defmodule DFM.Util do
  @moduledoc """
  Different utility functions.
  """

  @doc """
  Converts string in the specified format into NaiveDateTime.
  """
  @spec string_to_datetime!(String.t()) :: NaiveDateTime.t()
  def string_to_datetime!(string) do
    string
    |> Timex.parse!("{YYYY}/{M}/{D} {h24}:{m}:{s}{ss}")
  end
end
