SOURCES = $(wildcard *.proto) $(wildcard */*.proto)

test: ${SOURCES}
	protoc --ocaml_opt="int64_as_int=false;int32_as_int=false" --ocaml_out=../messaging_test ${SOURCES}