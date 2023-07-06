package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	log.Print("starting server...")
	http.HandleFunc("/", handler)

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	var releaseBadge rune = '❌'
	release := os.Getenv("RELEASE")

	switch {
	case release == "BLUE":
		releaseBadge = '🔵'
	case release == "GREEN":
		releaseBadge = '🟢'
	}

	fmt.Fprintf(w, "This release is %c !\n", releaseBadge)
	log.Printf("Sent response for release %c\n", releaseBadge)
}
