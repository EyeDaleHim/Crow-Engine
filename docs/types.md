# Logic Action Types

This document provides a reference for the various action types that can be executed by the `LogicEvaluator`. These actions are defined in JSON and are used to control game logic and entity behavior.

## `play_animation`

Plays an animation on a target entity.

-   **values**:
    1.  `animName` (String): The name of the animation to play.
    2.  `force` (Bool, optional, default: `false`): Whether to force the animation to restart if it's already playing.
    3.  `updateHitbox` (Bool, optional, default: `true`): Whether to update the entity's hitbox to match the animation frame.

## `state_change`

Changes the state of a variable in a `LogicState`.

-   **values**:
    1.  `stateChange` (ActionMetadata): The state change to apply.

## `set_text` | `add_text` | `clear_text`

Manipulates the text of an `AnimatedText` entity.

-   **`set_text`**: Sets the text to the provided value.
-   **`add_text`**: Appends the provided value to the existing text.
-   **`clear_text`**: Clears the text.
-   **values**:
    1.  `text` (String): The text to set or add.

## `set_visible`

Sets the visibility of a target entity.

-   **values**:
    1.  `visible` (Bool): Whether the entity should be visible.

## `set_alpha`

Sets the alpha (transparency) of a target entity.

-   **values**:
    1.  `alpha` (Float): The alpha value to set (0.0 to 1.0).

## `play_sound`

Plays a sound effect.

-   **values**:
    1.  `soundId` (String): The ID of the sound to play.
    2.  `volume` (Float, optional, default: `1.0`): The volume to play the sound at.

## `camera_effect`

Applies an effect to the camera.

-   **values**:
    1.  `effectType` (String): The type of effect to apply. Can be one of the following:
        -   `flash`: Flashes the camera with a color.
            -   **values**:
                1.  `color` (Color, optional, default: `FlxColor.WHITE`): The color to flash.
                2.  `duration` (Float, optional, default: `1.0`): The duration of the flash.
        -   `fade`: Fades the camera to a color.
            -   **values**:
                1.  `color` (Color, optional, default: `FlxColor.BLACK`): The color to fade to.
                2.  `duration` (Float, optional, default: `1.0`): The duration of the fade.
                3.  `reverse` (Bool, optional, default: `false`): Whether to fade in instead of out.
        -   `shake`: Shakes the camera.
            -   **values**:
                1.  `intensity` (Float, optional, default: `0.05`): The intensity of the shake.
                2.  `duration` (Float, optional, default: `0.15`): The duration of the shake.
                3.  `force` (Bool, optional, default: `true`): Whether to force the shake to occur.

## `dispatch_event`

Dispatches an event to the `IEventExecutor`.

-   **values**:
    1.  `name` (String): The name of the event to dispatch.
    2.  `actions` (LogicState, optional): The arguments to pass with the event.

## `create_tween`

Creates a tween on a target entity.

-   **values**:
    1.  `tweenName` (String): The name of the tween.
    2.  `tweenProps` (Dynamic): The properties to tween.
    3.  `duration` (Float): The duration of the tween.
    4.  `tweenOptions` (Dynamic, optional): The options for the tween.

## `complete_tween`

Forces complete a tween, if it exists.

-   **values**:
    1.  `tweenName` (String): The name of the tween to complete.

## `cancel_tween`

Cancels a tween.

-   **values**:
    1.  `tweenName` (String): The name of the tween to cancel.

## `create_timer`

Creates a timer.

-   **values**:
    1.  `timerName` (String): The name of the timer.
    2.  `time` (Float): The duration of the timer.

## `complete_timer`

Forces complete a timer, if it exists.

-   **values**:
    1.  `timerName` (String): The name of the timer to complete.

## `cancel_timer`

Cancels a timer.

-   **values**:
    1.  `timerName` (String): The name of the timer to cancel.

## `open_url`

Opens a URL in the default web browser.

-   **values**:
    1.  `url` (String): The URL to open.

## `exit_game`

-   **values**:
    1. `code` (Int, optional, default: `0`): The exit code.

Exits the game.

## `destroy_entity`

Destroys a target entity. The entity to destroy depends on the entity filter.

## `music_load` | `music_play` | `music_pause` | `music_stop` | `music_fade_in` | `music_fade_out`

Controls the music.

-   **`music_load`**: Loads a music track.
    -   **values**:
        1.  `soundId` (String): The ID of the music to load.
-   **`music_play`**: Plays the currently loaded music.
-   **`music_pause`**: Pauses the currently playing music.
-   **`music_stop`**: Stops the currently playing music.
-   **`music_fade_in`**: Fades the music in.
    -   **values**:
        1.  `duration` (Float, optional, default: `1.0`): The duration of the fade.
        2.  `from` (Float, optional): The starting volume. If not provided, the current volume will be used.
        3.  `to` (Float, optional): The ending volume. If not provided, 1.0 will be used.
-   **`music_fade_out`**: Fades the music out.
    -   **values**:
        1.  `duration` (Float, optional, default: `1.0`): The duration of the fade.
        2.  `to` (Float, optional): The ending volume.

## `remove_listeners_by_tag`

Removes event listeners by tag.

-   **values**:
    1.  `tagToRemove` (String): The tag of the listeners to remove.

## `switch_scene`

Switches to a new scene.

-   **values**:
    1.  `sceneName` (String): The name of the scene to switch to.