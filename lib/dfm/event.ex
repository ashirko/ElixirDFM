defmodule DFM.Event do
  @moduledoc """
  An atomic data point in process mining domain.

  It represents the digital footprint of one unit of work, also called *activity*
  (e.g. "receive user application", "send invoice", "process order", "ship parcel" etc.),
  that was done and logged in a given process.

  It contains at least one timestamp, and the name of the *activity* which produced the *event*.

  Events usually also contain relevant *attributes* which can be either numeric or nominal,
  and contain any additional information needed.
  """

  defstruct [:activity, :start, :complete]

  #  The type of :start and :complete fields was changed to NaiveDateTime because
  #  timestamps in the example file don't have time zone.
  @type t :: %__MODULE__{
          activity: String.t(),
          start: NaiveDateTime.t(),
          complete: NaiveDateTime.t()
        }

  @doc """
   Creates a new DFM.Event struct.
  """
  @spec new(String.t(), NaiveDateTime.t(), NaiveDateTime.t()) :: __MODULE__.t()
  def new(activity, start, complete) do
    %__MODULE__{
      activity: activity,
      start: start,
      complete: complete
    }
  end

  @doc """
  Returns true if event2 is a follower of event1. Otherwise returns false.
  """
  @spec follower?(__MODULE__.t(), __MODULE__.t()) :: boolean()
  def follower?(event1, event2) do
    case NaiveDateTime.compare(event2.start, event1.start) do
      :gt -> true
      _ -> false
    end
  end

  @doc """
  Returns true if the event was started after or at the specified timestamp. Otherwise returns false.
  """
  @spec started_after?(__MODULE__.t(), NaiveDateTime.t() | nil) :: boolean()
  def started_after?(_event, nil), do: true

  def started_after?(event, timestamp) do
    case NaiveDateTime.compare(event.start, timestamp) do
      :lt -> false
      _ -> true
    end
  end

  @doc """
  Returns true if the event was completed before or at the specified timestamp. Otherwise returns false.
  """
  @spec finished_before?(__MODULE__.t(), NaiveDateTime.t() | nil) :: boolean()
  def finished_before?(_event, nil), do: true

  def finished_before?(event, timestamp) do
    case NaiveDateTime.compare(event.complete, timestamp) do
      :gt -> false
      _ -> true
    end
  end
end
