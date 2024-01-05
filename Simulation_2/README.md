# TinyOS - Communication Simulations 📡

## Simulation 1: Three Motes Communication

Create a Cooja simulation with three TinyOS (sky) motes: 1, 2, and 3. The motes communicate via radio, sending messages composed of a counter and the sender ID. All messages are broadcasted.

### Communication Details

- Mote 1: Messages sent at 1 Hz
- Mote 2: Messages sent at 3 Hz
- Mote 3: Messages sent at 5 Hz

### LED Control Rules

- Mote 1 messages toggle led0
- Mote 2 messages toggle led1
- Mote 3 messages toggle led2

### LED Turn Off Rule

- Messages received with 'counter mod 10' == 0 turn off all LEDs.

### Counter Increment

- The counter is incremented after receiving a new message.

## Simulation 2: Two Motes Communication with ACK

Implement a Cooja simulation with two TinyOS (sky) motes: A and B. This simulation focuses on communication with acknowledgment (ACK).

### Communication Details

- Mote A sends messages to Mote B.
- Mote B acknowledges received messages.

## University Course 📖

This is a project of the exam "Internet of Things" for the Computer Science and Engineering degree at Polytechnic of Milano.

## Authors 👨‍💻

- [TiaSirio](https://www.github.com/TiaSirio)
- [matteovisotto](https://www.github.com/matteovisotto)