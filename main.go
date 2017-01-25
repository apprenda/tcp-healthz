package main

import (
	"flag"
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
	"time"
)

var (
	version   string
	buildDate string
	host      string
	ports     commaSepInts
	timeout   time.Duration
)

func main() {
	flag.Var(&ports, "ports", "comma-separated list of TCP ports to check")
	flag.StringVar(&host, "host", "localhost", "the host to connect to")
	flag.DurationVar(&timeout, "timeout", 3*time.Second, "tcp connection timeout")
	flag.Parse()

	if len(ports) == 0 {
		fmt.Fprint(os.Stderr, "error: at least one port must be specified using the --port flag\n")
		os.Exit(1)
	}

	fmt.Println("----------------------")
	fmt.Println("tcp-healthz")
	fmt.Println("Version =", version)
	fmt.Println("Build date =", buildDate)
	fmt.Println("Ports =", ports)
	fmt.Println("TCP connection timeout =", timeout)
	fmt.Println("----------------------")

	for _, p := range ports {
		if !portAccessible(host, p) {
			os.Exit(1)
		}
		fmt.Println("Port", p, "OK")
	}
}

// attempt to open a connection to the given port
// returns true if successful, otherwise returns false
func portAccessible(host string, port int) bool {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:%d", host, port), timeout)
	if err != nil {
		fmt.Printf("port check failed for port %d: %v\n", port, err)
		return false
	}
	conn.Close()
	return true
}

type commaSepInts []int

func (i *commaSepInts) String() string {
	return fmt.Sprintf("%v", *i)
}

func (i *commaSepInts) Set(value string) error {
	l := strings.Split(value, ",")
	if len(l) == 0 {
		return fmt.Errorf("no integers were given")
	}
	for _, maybeInt := range l {
		tmp, err := strconv.Atoi(maybeInt)
		if err != nil {
			return fmt.Errorf("%s is not an integer", maybeInt)
		}
		*i = append(*i, tmp)
	}
	return nil
}
