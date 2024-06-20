# Dynamic Vehicle Wear and Tear System for FiveM

Enhance the realism and immersion of your FiveM roleplay server with this comprehensive vehicle wear and tear system.  This resource introduces a dynamic mechanic where vehicle condition degrades over time and through usage, requiring players to actively maintain their vehicles.

## Features

https://gist.github.com/iboss21/73acafe25a87764a3e3b0f21c64e0b00?permalink_comment_id=5094492#gistcomment-5094492

* **Visual Degradation:**  Vehicles gradually accumulate scratches, dents, dirt, and even rust, reflecting their usage and age.
* **Performance Impact:**  As wear and tear increases, vehicle performance degrades, affecting top speed, acceleration, and handling.
* **Maintenance Gameplay:**  Players must visit designated repair locations to restore their vehicles' condition, adding a new layer of roleplay and interaction.
* **Configurable:**  Fine-tune wear rates, repair costs, visual effects, and more to tailor the system to your server's needs.
* **Framework Support:**  Seamless integration with both QBCore and ESX frameworks, ensuring compatibility with a wide range of servers.
* **Mechanic Integration:**  Easily tie into your existing mechanic jobs, allowing players to earn money by repairing other players' vehicles.
* **Future Expansion:** The system is designed to be easily expandable with features like random breakdowns, part-specific damage, and more.

## Installation

1. **Download:** Download the latest version of the resource from this GitHub repository.
2. **Extract:** Extract the contents of the downloaded zip file into your FiveM server's `resources` folder.
3. **Configuration:** Open the `config.lua` file and adjust the settings to your liking.
4. **Start:** Add `start theluxempire-vehiclewear` to your `server.cfg` file and restart your server.

## Configuration

Refer to the `config.lua` file for a detailed explanation of all available configuration options. You can customize:

*   **Framework:** Choose between `QBCore` and `ESX`.
*   **WearAndTear:** Adjust wear rate, maximum wear level, repair costs, and visual impact.
*   **Maintenance:** Configure mechanic job, repair locations, and repair distance.
*   **Notifications:** Enable/disable and customize notification messages.
*   **Commands:** Change the command for repairing vehicles.

## Usage

*   **Drive:** As players drive their vehicles, they will gradually accumulate wear and tear.
*   **Repair:** Players can use the `/repairvehicle` command to fix their vehicles at designated repair locations (if they meet the job requirements).

## Dependencies

*   This resource requires either **QBCore** or **ESX** framework to function.

## Contributing

We welcome contributions! Feel free to open a pull request or submit an issue if you have any suggestions, bug fixes, or improvements.

## Support & Feedback

For support or feedback, please join our Discord community: [https://discord.gg/theluxempire](https://discord.gg/theluxempire)

**Enjoy the enhanced realism and roleplay possibilities that this Dynamic Vehicle Wear and Tear System brings to your FiveM server!**
