extends Node

const LOSPEC_URL = "https://lospec.com/palette-list/"
const QUERY_STRING = "load?colorNumberFilterType=any&colorNumber=8&page=0&tag=&sortingType=default"

const DEFAULT_URL = LOSPEC_URL + QUERY_STRING

var root_node

var user_data = {
	"lastPalette": null
}
