-- Copyright 2023 Przemyslaw Kacprowicz
-- For SmartThings ecosystem & based on SmartThings's work
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- SmartThings capabilities references
local capabilities = require "st.capabilities"
local signalStrength = capabilities.signalStrength

local common = {}

common.extract_signal_strength_from_raw_message = function(message)
  return {
    lqi = message.lqi.value,
    rssi = message.rssi.value,
  }
end

common.send_signal_strength_event = function(device, message)
  local signal_strength = common.extract_signal_strength_from_raw_message(message)
  device:emit_event(signalStrength.lqi(signal_strength.lqi))
  device:emit_event(signalStrength.rssi({ value = signal_strength.rssi, unit = 'dBm' }))
end

return common