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

-- This file is solely based on/copied from
-- https://github.com/SmartThingsCommunity/SmartThingsEdgeDrivers/blob/main/drivers/SmartThings/zigbee-button/src/zigbee-multi-button/supported_values.lua

local devices = {
  BUTTON_PUSH_HELD_DOUBLE_3 = {
    MATCHING_MATRIX = {
      { mfr = "_TZ3000_w8jwkczz", model = "TS0043" }
    },
    SUPPORTED_BUTTON_VALUES = { "pushed", "held", "double" },
    NUMBER_OF_BUTTONS = 3
  }
}

local configs = {}

configs.get_device_parameters = function(zb_device)
  for _, device in pairs(devices) do
    for _, fingerprint in pairs(device.MATCHING_MATRIX) do
      if zb_device:get_manufacturer() == fingerprint.mfr and zb_device:get_model() == fingerprint.model then
        return device
      end
    end
  end
  return nil
end

return configs