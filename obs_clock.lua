-- OBS Lua Script
-- This script displays the current time on a specified text source in OBS.
-- The text source is updated every second.

obs = obslua

-- Variable to store the name of the text source
source_name = ""

-- Log levels
LOG_DEBUG = 0
LOG_INFO = 1
LOG_WARNING = 2
LOG_ERROR = 3

-- Current log level
current_log_level = LOG_ERROR

-- Function for logging messages with a specified log level
function script_log(level, message)
    if level >= current_log_level then
        obs.script_log(level, message)
    end
end

-- Function to set the current time on the text source
function update_text()
    script_log(LOG_DEBUG, "Updating text...")
    local hour = os.date("%H")
    local minute = os.date("%M")
    local second = os.date("%S")
    local text = hour .. ":" .. minute .. ":" .. second
    script_log(LOG_INFO, "Current time: " .. text)
    
    -- Get the source with the specified name
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        script_log(LOG_DEBUG, "Source found: " .. source_name)
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", text)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
        script_log(LOG_INFO, "Text updated")
    else
        script_log(LOG_WARNING, "Source not found: " .. source_name)
    end
end

-- Callback function executed every second
function timer_callback()
    update_text()
end

-- Function to define script properties
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source", "Source", obs.OBS_TEXT_DEFAULT)

    -- local log_level_list = obs.obs_properties_add_list(props, "log_level", "Log Level", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)
    -- obs.obs_property_list_add_int(log_level_list, "Debug", LOG_DEBUG)
    -- obs.obs_property_list_add_int(log_level_list, "Info", LOG_INFO)
    -- obs.obs_property_list_add_int(log_level_list, "Warning", LOG_WARNING)
    -- obs.obs_property_list_add_int(log_level_list, "Error", LOG_ERROR)
    
    return props
end

-- Function called when script settings are updated
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    -- current_log_level = obs.obs_data_get_int(settings, "log_level")
    script_log(LOG_INFO, "Script update called. Source name: " .. source_name .. ", Log level: " .. current_log_level)
    update_text()
end

-- Function to define default script settings
function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source", "Clock")
    -- obs.obs_data_set_default_int(settings, "log_level", LOG_ERROR)
end

-- Function called when the script is loaded
function script_load(settings)
    script_log(LOG_INFO, "Script loaded")
    script_update(settings)
    obs.timer_add(timer_callback, 1000)
end

-- Function to return script description
function script_description()
    return "This script displays the current time on a specified text source in OBS.\n" ..
           "The text source is updated every second. Please set the source name to use."
end