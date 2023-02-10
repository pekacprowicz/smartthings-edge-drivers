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

-- Basic driver dependencies
local ZigbeeDriver = require "st.zigbee"
local defaults = require "st.zigbee.defaults"

-- Zigbee cluster(s)
local PowerConfiguration = (require "st.zigbee.zcl.clusters").PowerConfiguration

-- SmartThings capabilities references
local capabilities = require "st.capabilities"
local voltageMeasurement = capabilities.voltageMeasurement

-- st.lua utils
local log = require "log"
local utils = require "st.utils"

-- Zigbee cluster(s)
local OnOff = (require "st.zigbee.zcl.clusters").OnOff

-- local utils
local supported_values = require "configs.supported_values"
local common_handlers = require "lib.common"

local function added_handler(self, device)
  local config = supported_values.get_device_parameters(device)
  for _, component in pairs(device.profile.components) do
    local number_of_buttons = component.id == "main" and config.NUMBER_OF_BUTTONS or 1
    if config ~= nil then
      device:emit_component_event(component, capabilities.button.supportedButtonValues(config.SUPPORTED_BUTTON_VALUES, {visibility = { displayed = false }}))
    else
      device:emit_component_event(component, capabilities.button.supportedButtonValues({"pushed", "held"}, {visibility = { displayed = false }}))
    end
    device:emit_component_event(component, capabilities.button.numberOfButtons({value = number_of_buttons}, {visibility = { displayed = false }}))
  end
  -- device:emit_event(capabilities.button.button.pushed({state_change = false}))
end

local function battery_voltage_handler(self, device, value, zb_rx)
  log.debug(utils.stringify_table(zb_rx))
  log.debug(utils.stringify_table(value))
  local voltage = value.value / 10
  device:emit_event(voltageMeasurement.voltage({value = voltage, unit = 'V'}))
  common_handlers.send_signal_strength_event(device, zb_rx)
end

local zigbee_button_template = {
  lifecycle_handlers = {
    added = added_handler
  },
  supported_capabilities = {
    capabilities.button,
    capabilities.battery,
    capabilities.signalStrength,
    capabilities.voltageMeasurement
  },
  zigbee_handlers = {
    attr = {
      [PowerConfiguration.ID] = {
        [PowerConfiguration.attributes.BatteryVoltage.ID] = battery_voltage_handler
      }
    }
  },
  sub_drivers = {
    require("tuya")
  },
}

defaults.register_for_default_handlers(zigbee_button_template, zigbee_button_template.supported_capabilities)
local zigbee_button = ZigbeeDriver("zigbee-button", zigbee_button_template)
zigbee_button:run()