package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"sync"
)

func printUsage() {
	fmt.Printf("Usage: %s [OPTIONS] COMMAND [args..]\nOptions:\n", os.Args[0])
	flag.PrintDefaults()
}

func readArgs(sleepInterval *int) ([]int, []string) {
	flag.IntVar(sleepInterval, "sleep-interval", 1, "sleep for approximately N seconds between iterations (to check if processes are still alive, tail uses polling). Check \033[97mman tail\033[0m and its \033[97m-s\033[0m and \033[97m--pid\033[0m options for more information")

	// read pids
	var pidStr string
	flag.StringVar(&pidStr, "pid", "", "Id of the process to wait for completion. Multiple values allowed (separated by comma e.g. 1,2,3)")
	flag.Parse()
	pidStr = strings.TrimSpace(pidStr)
	if len(pidStr) == 0 {
		printUsage()
		log.Fatal("at least 1 pid must be given")
	}

	// transform pids
	pidStrArr := strings.Split(pidStr, ",")
	pids := make([]int, len(pidStrArr))
	for i := 0; i < len(pids); i++ {
		pid, err := strconv.ParseInt(strings.TrimSpace(pidStrArr[i]), 0, 32)
		if err != nil {
			log.Fatalf("invalid pid: %s", pidStrArr[i])
		}
		pids[i] = int(pid)
	}

	// read command with arguments
	commandWArgs := flag.Args()
	if len(commandWArgs) < 1 {
		log.Println("no command was provided")
		flag.Usage()
	}

	return pids, commandWArgs
}

func getProcesses(pids []int) []*os.Process {
	processes := make([]*os.Process, len(pids))
	for i, pid := range pids {
		proc, err := os.FindProcess(pids[i])
		if err != nil {
			log.Fatalf("error while finding process %d. %w", pid, err)
		}
		processes[i] = proc
	}

	return processes
}

func waitProc(wg *sync.WaitGroup, pid int, procCmdStr string, sleepInterval int) {
	defer wg.Done()

	// use tail (which implements polling to check if process is still alive)
	// because wait syscall only works for children processes
	// FIXME: polling is not good. What happens if between the sleep call process ended and another one was spawned
	//	  with the same pid?
	//	  However, it's currently the best (and possibly the only) option
	exec.Command("tail",
		"--pid", strconv.Itoa(pid),
		"-f", "/dev/null",
		"-s", strconv.Itoa(sleepInterval),
	).Run()
	fmt.Printf("%s finished ✔\n", procCmdStr)
}

func main() {
	flag.Usage = printUsage
	var sleepInterval int
	pids, commandWArgs := readArgs(&sleepInterval)

	// print processes information
	processes := getProcesses(pids)
	var wg sync.WaitGroup
	fmt.Printf("\033[97m%v\033[0m will run after these processes finish:\n", commandWArgs)
	for i, proc := range processes {
		// get the process' command line
		cmdlineBytes, err := os.ReadFile(fmt.Sprintf("/proc/%d/cmdline", proc.Pid))
		if err != nil && os.IsNotExist(err) {
			log.Printf("[WARNING]: Process with pid %d may already be dead. %s\n", pids[i], err)
		} else {
			// replace weird characters in cmdline
			byte2Remove := byte('\000')
			byteReplacement := byte(' ')
			for i := range cmdlineBytes {
				if cmdlineBytes[i] == byte2Remove {
					cmdlineBytes[i] = byteReplacement
				}
			}
			cmdline := string(cmdlineBytes)

			procCmdStr := fmt.Sprintf("%d -> %s", pids[i], cmdline)
			fmt.Printf("  - %s\n", procCmdStr)

			// wait until process finishes inside goroutine with the help of tail
			wg.Add(1)
			go waitProc(&wg, pids[i], procCmdStr, sleepInterval)
		}
	}

	wg.Wait() // wait until all processes have finished

	// run command
	fmt.Printf("All processes have finished ✅. Executing \033[97m%v\033[0m now\n", commandWArgs)
	cmd := exec.Command(commandWArgs[0], commandWArgs[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		log.Fatalf("Error while executing %v. %s", commandWArgs, err)
	}
}
