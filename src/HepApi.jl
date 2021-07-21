module HepApi

import HTTP: URI, HTTP.get
using HTTP

using JSON

export search_inspirehep

const QueryParameterDict = Dict{AbstractString, Union{Integer, AbstractString}}

struct Search
	record_type::AbstractString
	query::QueryParameterDict
end

function URI(sch::Search)
	path = "/api/" * sch.record_type
	uri = HTTP.URI(; 
								 scheme="https", host="inspirehep.net",
								 path=path, 	 query=sch.query
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
`HepApi.search_inspirehep(record_type::AbstractString, qpd::QueryParameterDict)`

Uses the inspirehep REST api to download a JSON from inspirehep.net.
The [Inspirehep Github Page](https://github.com/inspirehep/rest-api-doc) is the reference of this code.

e.g. (json data of the top 5 most cited papers on inpsirehep.net)

```
lit_json = search_inspirehep("literature", Dict("sort"=>"mostcited", "size"=>5))
println(lit)
```

- **record_type** are base categories for a search and can take the following values: **literature**, **authors**, **conferences**, **seminars**, **journals**, **jobs**, **experiments**, and **data**

- **q** is the text to search by inpsirehep's search syntax can be used.

- **sort** is the option by which the JSON is ordered. (allowed sort field TBD)

- **page** the page number returned.

- **fields** a fiter for certain metadata fields.

"""
function search_inspirehep(record_type::AbstractString, qpd)
	sch = Search(record_type, qpd)
	resp = get(sch)
	check_if_successful_resp(resp)
	return resptojson(resp)
end

end # module
