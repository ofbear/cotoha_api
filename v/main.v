module main

import cotoha

fn main() {
	c := cotoha.new_cotoha(client_id:"client_id", client_secret:"client_secret")

	result := c.similarity(
		"test",
		"test",
		"default",
		"",
	)?

	println(result.result.score)
}
