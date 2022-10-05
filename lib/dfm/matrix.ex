defmodule DFM.Matrix do
  @moduledoc """
  Functionality for building and working with a Direct Follower Matrix.
  """

  defstruct activities: MapSet.new(), direct_followers: Map.new()

  @typedoc """
  A data structure representing a Direct Follower Matrix. :activities field stores all
  activities which occurred at least once. :direct_followers field stores the Direct
  Follower Matrix itself in a format %{{Event,DirectFollower} => Count}.
  """
  @type t :: %__MODULE__{
          activities: MapSet.t(String.t()),
          direct_followers: %{{String.t(), String.t()} => non_neg_integer()}
        }

  @doc """
  Creates a new DFM.Matrix struct from a list of DFM.Trace.
  """
  @spec new(list(DFM.Trace)) :: __MODULE__.t()
  def new(traces) do
    Enum.reduce(traces, %__MODULE__{}, &add_events/2)
  end

  @doc """
  Gets count of activity1 followed by activity2 from the DFM. Returns error if
  the activity is not present in the DFM.
  """
  @spec get_count(__MODULE__.t(), String.t(), String.t()) ::
          non_neg_integer() | {:error, :no_such_activity}
  def get_count(matrix, activity1, activity2) do
    Map.get_lazy(matrix.direct_followers, {activity1, activity2}, fn ->
      if MapSet.member?(matrix.activities, activity1) and
           MapSet.member?(matrix.activities, activity2) do
        0
      else
        {:error, :no_such_activity}
      end
    end)
  end

  @doc """
  Adds all missing combinations of events with a 0 value to DFM.Matrix.direct_followers.
  """
  @spec add_null_values(__MODULE__.t()) :: __MODULE__.t()
  def add_null_values(matrix) do
    all_pairs = for i <- matrix.activities, j <- matrix.activities, do: {i, j}

    full_direct_followers =
      Enum.reduce(all_pairs, matrix.direct_followers, fn pair, acc ->
        Map.put_new(acc, pair, 0)
      end)

    %__MODULE__{matrix | :direct_followers => full_direct_followers}
  end

  defp add_events(%DFM.Trace{events: events}, matrix) do
    add_direct_followers(events, matrix)
  end

  defp add_direct_followers([], matrix), do: matrix

  defp add_direct_followers([event], matrix) do
    add_activity(matrix, event.activity)
  end

  defp add_direct_followers([event1, event2 | rest], matrix) do
    matrix =
      matrix
      |> add_activity(event1.activity)
      |> add_direct_follower({event1.activity, event2.activity})

    add_direct_followers([event2 | rest], matrix)
  end

  defp add_activity(matrix = %__MODULE__{activities: activities}, activity) do
    %__MODULE__{matrix | :activities => MapSet.put(activities, activity)}
  end

  defp add_direct_follower(matrix = %__MODULE__{direct_followers: direct_followers}, pair) do
    direct_followers = Map.update(direct_followers, pair, 1, &(&1 + 1))
    %__MODULE__{matrix | :direct_followers => direct_followers}
  end
end
