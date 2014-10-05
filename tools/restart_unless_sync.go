package main

import (
	"log"
	"net/http"
	"os/exec"
	"time"
)

func main() {

	// For some reason this does not work unless channel is buffered
	channel := make(chan bool, 1)

	// Start process
	command := exec.Command("/usr/local/bin/task", "sync TASKRC=~/.taskrc-freecinc")
	err := command.Start()

	if err != nil {
		log.Println("Error: ", err.Error())
		return
	}

	// in a separate goroutine, wait for completion
	go writeToChannelWhenProcessDone(command, channel)

	// Allow 10 seconds for completion
	time.Sleep(10000 * time.Millisecond)
	log.Println("Done waiting")

	done := <-channel

	if done {
		log.Println("Sync completed within timeframe")
	} else {
		log.Println("Not finished yet. Killing now")
		command.Process.Kill()

		restartServer()
	}
}

func writeToChannelWhenProcessDone(command *exec.Cmd, channel chan bool) {
	// Write false to channel
	channel <- false

	command.Wait()

	// Remove original value from channel
	<-channel

	// Replace it with true
	channel <- true

	log.Println("SUCCESS")
}

func restartServer() {
	log.Println("Restarting server on freecinc.com")
	http.Get("https://freecinc.com/restart/jeremy")
}
