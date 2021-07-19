module HepApi

import Base: Dict

import HTTP: URI, HTTP.get
using HTTP

using JSON

export search_inspirehep

const StringNothing = Union{AbstractString, Nothing}
const IntegerNothing = Union{Integer, Nothing}

struct Query
	q::StringNothing
	sort::StringNothing
	size::IntegerNothing
	page::IntegerNothing
	fields::Union{Vector{String}, Nothing}
end

function Dict(q::Query)
	output = Dict{AbstractString, AbstractString}()

	q.q === nothing || push!(output, "q" => 			q.q)
	q.sort === nothing || push!(output, "sort" => 	q.sort)
	q.size === nothing  || push!(output, "size" => 	string(q.size))
	q.size === nothing || push!(output, "page" => 	string(q.page))
	q.fields === nothing || push!(output, "fields" => join(q.fields, ","))
	
	return output
end

struct Search
	record_type::AbstractString
	query::Query
end

Dict(sch::Search) = Dict(sch.query)

function URI(sch::Search)
	path = "/api/" * sch.record_type
	uri = HTTP.URI(; 
								 scheme="https", host="inspirehep.net",
								 path=path, 	 query=Dict(sch)
								 )
	return uri
end

get(sch::Search) = HTTP.get(URI(sch))

function check_if_successful_resp(resp::HTTP.Messages.Response)
	if resp.status >= 400
		e = ErrorException("Failed to get HEP data. The response code is $(resp.status)")
		throw(e)
	end
end

function resptojson(resp::HTTP.Messages.Response)
	return JSON.parse(String(resp.body))
end

"""
`HepApi.search_inspirehep(record_type; <keyword arguments>)`

Uses the inspirehep REST api to download a JSON from inspirehep.net.
The [Inspirehep Github Page](https://github.com/inspirehep/rest-api-doc) is the reference of this code.

e.g. (json data of the top 5 most cited papers on inpsirehep.net)

```
lit_json = search_inspirehep("literature"; sort_by = "mostcited", number_of_results = 5)
println(lit)
```

- **record_type** are base categories for a search and can take the following values: **literature**, **authors**, **conferences**, **seminars**, **journals**, **jobs**, **experiments**, and **data**

- **query_string** is the text to search by inpsirehep's search syntax can be used.

- **sort_by** is the option by which the JSON is ordered. (allowed sort field TBD)

- **page** the page number returned.

- **fields** a vector of strings that fiter for certain metadata fields.

"""
function search_inspirehep(record_type::AbstractString;
													 query_string=nothing,
													 sort_by=nothing,
													 number_of_results=nothing,
													 page=nothing,
													 fields=nothing
													)
	query = Query(query_string , sort_by, number_of_results, page, fields)
	sch = Search(record_type, query)
	resp = get(sch)
	
	check_if_successful_resp(resp)
	
	return resptojson(resp)
end

end # module
