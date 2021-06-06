rule run_sage:
    input:
        ancient("workloads/{workload}/{query}.rq")
    output:
        result="output/{workload,[^/]+}/{backend,sage_[^/]+}/{query,[^/]+}.json",
        stats="output/{workload,[^/]+}/{backend,sage_[^/]+}/{query,[^/]+}.csv",
    params:
        endpoint="http://localhost:8080/sparql",
    shell:
        "python scripts/query_sage.py {input} \
                http://localhost:8080/sparql http://localhost:8080/sparql/{wildcards.backend} \
                --output {output.result} --measures {output.stats}"


rule run_virtuoso:
    input:
        ancient("workloads/{workload}/{query}.rq")
    output:
        result="output/{workload,[^/]+}/virtuoso/{query,[^/]+}.json",
        stats="output/{workload,[^/]+}/virtuoso/{query,[^/]+}.csv",
    params:
        endpoint="http://localhost:8890/sparql",
    shell:
        "python scripts/query_virtuoso.py {input} \
                http://localhost:8890/sparql http://example.org/datasets/watdiv10M \
                --output {output.result} --measures {output.stats}"
