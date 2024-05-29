-- OBS Lua Script
-- This script displays a stopwatch on a specified text source in OBS.
-- The stopwatch starts from 00:00:00.00 and increments every centisecond when started.

local ffi = require("ffi")

if ffi.os == "Windows" then
    ffi.cdef[[
        typedef struct {
            unsigned long dwLowDateTime;
            unsigned long dwHighDateTime;
        } FILETIME;

        void GetSystemTimeAsFileTime(FILETIME* lpSystemTimeAsFileTime);
    ]]

    function get_time_in_ms()
        local ft = ffi.new("FILETIME")
        ffi.C.GetSystemTimeAsFileTime(ft)
        local t = ft.dwHighDateTime * 2^32 + ft.dwLowDateTime
        return t / 10000
    end
else
    ffi.cdef[[
        typedef long time_t;
        typedef struct timeval {
            time_t tv_sec;
            time_t tv_usec;
        } timeval;

        int gettimeofday(struct timeval* tv, struct timezone* tz);
    ]]

    function get_time_in_ms()
        local tv = ffi.new("timeval")
        ffi.C.gettimeofday(tv, nil)
        return tonumber(tv.tv_sec) * 1000 + tonumber(tv.tv_usec) / 1000
    end
end

obs = obslua

-- Variables to store the name of the text source and stopwatch state
source_name = ""
stopwatch_running = false
start_time = 0
elapsed_time = 0

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

-- Function to calculate and update the elapsed time on the text source
function update_text()
    script_log(LOG_DEBUG, "Updating text...")
    local current_time = elapsed_time
    if stopwatch_running then
        current_time = current_time + (get_time_in_ms() - start_time)
    end

    local hours = math.floor(current_time / 3600000)
    local minutes = math.floor((current_time % 3600000) / 60000)
    local seconds = math.floor((current_time % 60000) / 1000)
    local centiseconds = math.floor((current_time % 1000) / 10)
    local text = string.format("%02d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
    script_log(LOG_INFO, "Elapsed time: " .. text)
    
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

-- Function to start, stop, or reset the stopwatch
function toggle_stopwatch(pressed)
    if pressed then
        if stopwatch_running then
            -- Stop the stopwatch
            elapsed_time = elapsed_time + (get_time_in_ms() - start_time)
            stopwatch_running = false
            obs.timer_remove(timer_callback)
            script_log(LOG_INFO, "Stopwatch stopped")
        elseif elapsed_time > 0 then
            -- Reset the stopwatch
            elapsed_time = 0
            start_time = get_time_in_ms()
            update_text()
            script_log(LOG_INFO, "Stopwatch reset")
        else
            -- Start the stopwatch
            start_time = get_time_in_ms()
            obs.timer_add(timer_callback, 10)
            stopwatch_running = true
            script_log(LOG_INFO, "Stopwatch started")
        end
    end
end

-- Timer callback function executed every 100 milliseconds
function timer_callback()
    update_text()
end

-- Function to define script properties
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source", "Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_button(props, "toggle_button", "Start / Stop / Reset", toggle_stopwatch)
    return props
end

-- Function called when script settings are updated
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    script_log(LOG_INFO, "Script update called. Source name: " .. source_name)
    update_text()
end

-- Function to define default script settings
function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "source", "Stopwatch")
end

-- Function called when the script is loaded
function script_load(settings)
    script_log(LOG_INFO, "Script loaded")
    stopwatch_running = false
    start_time = get_time_in_ms()
    script_update(settings)
end

-- Function to return script description
function script_description()
    return "This script displays a stopwatch on a specified text source in OBS.\n" ..
           "The stopwatch starts from 00:00:00.00 and increments every centisecond when started.\n" ..
           "Use the Start/Stop/Reset button to control the stopwatch."
end
