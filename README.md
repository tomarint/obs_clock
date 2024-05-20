# obs_clock

This script displays the current time on a specified text source in OBS.

![](sample.jpg)

## Usage

1. Download obs_clock.lua.

    - Save the script file to a location on your computer.

2. Open OBS.

    - Launch the OBS application.

3. Create a Text Source.

    - In the main OBS window, locate the “Sources” panel.
    - Click the “+” button at the bottom of the “Sources” panel.
    - Select “Text (GDI+)” or “Text (FreeType 2)” from the list of options, depending on your version of OBS.
    - Name your text source (e.g., “CurrentTime”) and click “OK”.
    - In the text properties window, leave the text field blank since the script will update it automatically.
    - Click “OK” to create the text source.

4. Add the Script to OBS.

    - Go to the menu bar and select “Tools” > “Scripts”.
    - In the “Scripts” window, click the “+” button to add a new script.
    - Locate and select the obs_clock.lua file you downloaded earlier.

5. Configure the Script.

    - In the “Source” field of the obs_clock.lua script settings, enter the exact name of the text source you created (e.g., “CurrentTime”).
    - Close the “Scripts” window.

6. This script will now display the current time on the specified text source in OBS, updating every second.
