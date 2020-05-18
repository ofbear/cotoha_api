package main

import (
	"fmt"

	cotoha "./cotoha"
)

func main() {
	c := cotoha.NewCotoha(
		"clientId",
		"clientSecret",
	)
	result, err := c.Similarity(
		"test",
		"test",
		"default",
		"",
	)
	if err != nil {
		fmt.Printf("%s", err)
	} else {
		fmt.Printf("%g", result.Score)
	}
}
