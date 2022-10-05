defmodule DFM do
  @moduledoc """
  API module for Direct Followers Matrix library.
  """
  alias DFM.{CSVImporter, Matrix}

  @example_path Path.join(:code.priv_dir(:dfm), "IncidentExample.csv")

  @typedoc """
  Possible options for the building of the Direct Follower Matrix:
  * :print - print the DFM to the output. Default is true.
  * :from and :to - filter the result based on data range.
  * :add_null_values - populate the missing combinations of the events in the DFM with 0. Default is false.
  * :parallel - import data from CSV in parallel. Default is false.
  """
  @type option ::
          {:print, boolean()}
          | {:from, NaiveDateTime.t()}
          | {:to, NaiveDateTime.t()}
          | {:add_null_values, boolean()}
          | {:parallel, boolean()}
  @type opts :: Keyword.t(option())

  @doc """
  Builds a Direct Follower Matrix from a CSV file.
  """
  @spec build_dfm!() :: Matrix.t()
  def build_dfm!(), do: build_dfm!(@example_path)

  @spec build_dfm!(Path.t(), opts()) :: Matrix.t()
  def build_dfm!(path, opts \\ []) do
    matrix =
      path
      |> CSVImporter.import_from_csv!(Keyword.take(opts, [:parallel]))
      |> Enum.filter(&DFM.Trace.in_time_range?(&1, Keyword.take(opts, [:from, :to])))
      |> Matrix.new()
      |> maybe_add_null_values(Keyword.get(opts, :add_null_values, false))

    if Keyword.get(opts, :print, true) do
      IO.inspect(matrix.direct_followers, label: "Direct Follower Matrix")
    end

    matrix
  end

  # Adding null values is an optional step because a matrix with all possible combinations
  # of activities will have N^2 elements, where N is a number of different activities.
  defp maybe_add_null_values(matrix, false), do: matrix
  defp maybe_add_null_values(matrix, true), do: Matrix.add_null_values(matrix)
end
