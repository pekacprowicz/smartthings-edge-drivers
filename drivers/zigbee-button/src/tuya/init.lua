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

-- Zigbee cluster(s)
local OnOff = (require "st.zigbee.zcl.clusters").OnOff
local PowerConfiguration = (require "st.zigbee.zcl.clusters").PowerConfiguration

-- Zigbee commands
local device_management = require "st.zigbee.device_management"

-- SmartThings capabilities references
local capabilities = require "st.capabilities"
local button = capabilities.button.button

-- st.lua utils
local log = require "log"
local utils = require "st.utils"

-- local utils
local multi_utils = require "lib.multi"
local common_handlers = require "lib.common"

-- Tuya's custom definitions
local MFR_SPECIFIC_ON_OFF_COMMAND = {
  ID = 0xFD,
  NAME = "TuyaSpecificOnOffCmd"
}

local TUYA_BUTTONS_FINGERPRINTS = {
  { mfr = "_TZ3000_w8jwkczz", model = "TS0043" }
}

local function can_handle_tuya_button(opts, self, device, ...)
  for _, fingerprint in ipairs(TUYA_BUTTONS_FINGERPRINTS) do
    if device:get_manufacturer() == fingerprint.mfr and device:get_model() == fingerprint.model then
      return true
    end
  end
  return false
end

local endpoint_to_component = multi_utils.get_endpoint_to_component_func("button")

local function do_refresh(self, device)
  device:send(PowerConfiguration.attributes.BatteryPercentageRemaining:read(device))
  device:send(PowerConfiguration.attributes.BatteryVoltage:read(device))
end

local function do_configure(self, device)
  do_refresh(self, device)
  device:send(device_management.build_bind_request(device, OnOff.ID, self.environment_info.hub_zigbee_eui))
  device:send(device_management.build_bind_request(device, PowerConfiguration.ID, self.environment_info.hub_zigbee_eui))
  device:send(PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device, 30, 21600, 1))
  device:send(PowerConfiguration.attributes.BatteryVoltage:configure_reporting(device, 30, 21600, 1))
end

local function extract_body_from_raw_message(message)
  return message.body.zcl_body.body_bytes:byte(1)
end

local function extract_signal_strength_from_raw_message(message)
  return {
    lqi = message.lqi.value,
    rssi = message.rssi.value,
  }
end

local function extract_endpoint_from_raw_message(message)
  return message.address_header.src_endpoint.value
end

local function get_button_event(value)
  local event = button.pushed({ state_change = true })
  if value == 1 then
    event = button.double({ state_change = true })
  elseif value == 2 then
    event = button.held({ state_change = true })
  end
  return event
end

local function button_handler(self, device, value)
  local button_event = get_button_event(extract_body_from_raw_message(value))
  device:emit_event(button_event)
  local endpoint = extract_endpoint_from_raw_message(value)
  device:emit_component_event(endpoint_to_component(device, endpoint), button_event)
  common_handlers.send_signal_strength_event(device, value)
end

local tuya_button = {
  NAME = "Tuya Button",
  lifecycle_handlers = {
    doConfigure = do_configure
  },
  zigbee_handlers = {
    cluster = {
      [OnOff.ID] = {
        [MFR_SPECIFIC_ON_OFF_COMMAND.ID] = button_handler,
      }
    }
  },
  can_handle = can_handle_tuya_button
}

return tuya_button