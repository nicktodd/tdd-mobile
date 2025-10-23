# Lab: Effective Mocking

## Objective
The goal of this lab is to practice using mocking frameworks to test complex interactions between components. You will implement and test two scenarios:
1. A mocked version of the full speaking clock.
2. A music player that interacts with a playlist, a song retriever, and a player.

## Part 1: Mocking the Full Speaking Clock

### Scenario
Using the existing iOS and Android demo projects, implement and test a mocked version of the full speaking clock. The speaking clock should:
- Retrieve the current time from a clock.
- Convert the time to text using a time-to-text converter.
- Speak the text using a speech synthesizer.

### Instructions
1. **Set Up Your Test Environment**:
   - Ensure you have a mocking framework installed (e.g., Cuckoo for Swift, MockKo for Kotlin).

2. **Write Tests**:
   - Mock the dependencies (clock, time-to-text converter, speech synthesizer).
   - Write tests to verify that the speaking clock:
     - Retrieves the current time.
     - Converts the time to text.
     - Speaks the text.
   - Ensure the tests verify the correct invocation order of these steps.

3. **Implement the Speaking Clock**:
   - Use the TDD process to implement the speaking clock.
   - Refactor as needed while ensuring all tests pass.



## Part 2: Music Player Challenge

### Scenario
Implement a music player that interacts with the following components:
- **Playlist**: Provides a list of songs.
- **Song Retriever**: Retrieves the stream URL for a given song.
- **Player**: Plays the song using the stream URL.

The music player should:
- Retrieve the list of songs from the playlist.
- Retrieve the stream URL for a selected song.
- Play the song using the player.

### Instructions
1. **Set Up Your Test Environment**:
   - Ensure you have a mocking framework installed (e.g., Cuckoo for Swift, Mockito for Kotlin).

2. **Write Tests**:
   - Mock the dependencies (playlist, song retriever, player).
   - Write tests to verify that the music player:
     - Retrieves the list of songs.
     - Retrieves the stream URL for a selected song.
     - Plays the song using the player.
   - Ensure the tests verify the correct invocation order of these steps.

3. **Implement the Music Player**:
   - Use the TDD process to implement the music player.
   - Refactor as needed while ensuring all tests pass.


## Tips
- Focus on testing interactions between components, not the internal logic of the mocked dependencies.
- Use descriptive names for your test cases to clearly indicate what behavior is being tested.
- Ensure your tests are isolated and do not depend on external systems.

## Deliverables
- For Part 1: A mocked version of the full speaking clock with test cases.
- For Part 2: A music player implementation with test cases demonstrating the correct invocation order and functionality.

Good luck, and enjoy practicing effective mocking!