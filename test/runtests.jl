using HepApi
using HTTP
using Test

# https://inspirehep.net/api/literature?sort=mostcited&page=3&q=a E.Witten.1

@testset "using all fields of Query" begin
	record_type = "literature"
	q = "a E.Witten.1"
	sort = "mostcited"
	size = 10
	page = 1
	fields = ["authors"]
	
	query = HepApi.Query(q, sort, size, page, fields)
	@test true
	@info "Made the Query"

	sch = HepApi.Search(record_type, query)
	@test true
	@info "Made the Search"

	uri = HepApi.URI(sch)
	@test true
	@info "URI: "*string(uri)
	@info "Made a URI"

	resp = HepApi.get(sch)
	@info "Successfully ran through the GET request"
	@info "The status code was $(resp.status)"
	@test true

	HepApi.resptojson(resp)
	@info "Converted a response to JSON"
	@test true
end;
