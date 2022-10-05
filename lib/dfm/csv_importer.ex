defmodule DFM.CSVImporter do
  @moduledoc """
  Functionality for importing traces from a CSV file.
  """

  alias NimbleCSV.RFC4180, as: CSV
  alias DFM.{Event, Trace, Util}

  @doc """
  Performs import of traces from the CSV file. The import can be performed sequentially or
  in parallel depending on the options.
  """
  @spec import_from_csv!(Path.t(), Keyword.t()) :: [Trace.t()]
  def import_from_csv!(path, opts \\ []) do
    if Keyword.get(opts, :parallel, false) do
      import_from_csv_parallel!(path)
    else
      import_from_csv_sequential!(path)
    end
  end

  defp import_from_csv_sequential!(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&parse_row_stream!/1)
    |> Enum.reduce(%{}, &build_traces/2)
    |> Enum.map(fn {_id, trace} -> Trace.sort_events(trace) end)
  end

  defp import_from_csv_parallel!(path) do
    path
    |> File.stream!()
    |> Flow.from_enumerable()
    |> Flow.map(fn row -> parse_row!(row) end)
    |> Flow.partition(key: {:key, :case_id})
    |> Flow.reduce(fn -> %{} end, &build_traces/2)
    |> Enum.map(fn {_id, trace} -> Trace.sort_events(trace) end)
  end

  defp parse_row_stream!(row) do
    %{
      case_id: :binary.copy(Enum.at(row, 0)),
      activity: :binary.copy(Enum.at(row, 1)),
      start: :binary.copy(Enum.at(row, 2)) |> Util.string_to_datetime!(),
      complete: :binary.copy(Enum.at(row, 3)) |> Util.string_to_datetime!()
    }
  end

  # HACK: the header line needs to be skipped.
  @header_line "Case ID,Activity,Start,Complete,Classification\n"
  defp parse_row!(@header_line), do: %{:case_id => :skip}

  defp parse_row!(row) do
    [row] = CSV.parse_string(row, skip_headers: false)

    %{
      case_id: Enum.at(row, 0),
      activity: Enum.at(row, 1),
      start: Enum.at(row, 2) |> Util.string_to_datetime!(),
      complete: Enum.at(row, 3) |> Util.string_to_datetime!()
    }
  end

  defp build_traces(%{case_id: id, activity: activity, start: start, complete: complete}, acc) do
    event = Event.new(activity, start, complete)

    trace =
      case Map.fetch(acc, id) do
        {:ok, trace} -> Trace.add_event(trace, event)
        :error -> Trace.new(id, [event])
      end

    Map.put(acc, id, trace)
  end

  defp build_traces(_, acc), do: acc
end
