# WhyMacNoSleep

> Mac application to illustrate which application is preventing your Mac from sleeping

![Screenshot of WhyMacNoSleep](/WhyMacNoSleep.png)

## This application is WIP

**This application is not ready for use.**

Things to do:

- Include existing assertions from `pmset` output when the app starts
- Listen to system power events like sleep/wake and show them in the list
- Figure out a way to get parent process IDs of the processes involved so the list can show the actual application
- Show application icons in the list


## How it works

The app parses `pmset -g assertionslog` output in real-time and filters relevant assertions (related to system sleep).

## License

MIT
