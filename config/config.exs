import Config

config :tzdata, :autoupdate, :disabled

import_config "#{Mix.env()}.exs"
