defmodule DFM.CSVImporterTest do
  use ExUnit.Case
  alias DFM.{CSVImporter, Event, Trace}

  @test_file_path Path.join(:code.priv_dir(:dfm), "IncidentExampleTest.csv")

  setup_all do
    data = CSVImporter.import_from_csv!(@test_file_path)
    {:ok, data: data}
  end

  test "CSV file doesn't exist" do
    assert_raise File.Error, fn ->
      CSVImporter.import_from_csv!("missing_file.csv")
    end
  end

  test "Data is imported", state do
    assert is_list(state.data)
  end

  test "Data structure is correct", state do
    assert Enum.all?(state.data, fn trace ->
             is_struct(trace, Trace)
           end)
  end

  test "Events are sorted", state do
    assert Enum.all?(state.data, fn trace ->
             events_sorted?(trace.events)
           end)
  end

  test "Parallel and sequential produce the same result", state do
    parallel_data = CSVImporter.import_from_csv!(@test_file_path, parallel: true)
    assert Enum.sort(state.data) == Enum.sort(parallel_data)
  end

  defp events_sorted?([]), do: true

  defp events_sorted?([_]), do: true

  defp events_sorted?([event1, event2 | rest]) do
    if Event.follower?(event1, event2) do
      events_sorted?([event2 | rest])
    else
      false
    end
  end
end
