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

multi_components_libs = {}

multi_components_libs.get_component_name_to_endpoint_func = function(sub_component_name)
  return function(device, component_id)
    local match_string = string.format("%s(%%d)", sub_component_name)
    local endpoint_number = component_id:match(match_string)
    return endpoint_number and tonumber(endpoint_number) or 1
  end
end

multi_components_libs.get_endpoint_to_component_name_func = function(sub_component_name)
  return function(device, endpoint)
    local component = string.format("%s%d", sub_component_name, endpoint)
    if device.profile.components[component] ~= nil then
      return component
    else
      return "main"
    end
  end
end

multi_components_libs.get_endpoint_to_component_func = function(sub_component_name)
  return function(device, endpoint)
    local component = string.format("%s%d", sub_component_name, endpoint)
    if device.profile.components[component] ~= nil then
      return device.profile.components[component]
    else
      return "main"
    end
  end
end

return multi_components_libs