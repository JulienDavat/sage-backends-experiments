from scripts.utils import list_files, query_name

def list_workload_queries(wildcards):
    return [ query_name(q) for q in list_files(f"workloads/{wildcards.workload}", "rq") ]

def list_hbase_queries(wildcards):
    return [ query_name(q) for q in list_files(f"output/{wildcards.workload}/sage_hbase", "csv") ]

rule prepare_backend_data:
        input:
            "output/{workload}/{backend}/{query}.csv"
        output:
            "output/{workload,[^/]+}/{backend,[^/]+}/{query,[^/]+}-prepared.csv"
        shell:
            "touch {output}; "
            "echo 'backend,query,execution_time,nb_calls,nb_results,loading_time,resume_time' > {output}; "
            "echo -n '{wildcards.backend},{wildcards.query},' >> {output}; "
            "cat {input} >> {output}"


rule merge_backend_data:
    input:
        lambda wildcards: expand("output/{{workload}}/{{backend}}/{query}-prepared.csv", query=list_workload_queries(wildcards))
    output:
        "output/{workload,[^/]+}/{backend,[^/]+}/execution_times.csv"
    shell:
        "bash scripts/merge_csv.sh {input} > {output}"


rule merge_backends_data:
    input:
        sage_psql=ancient("output/{workload}/sage_psql/execution_times.csv"),
        sage_psql_catalog=ancient("output/{workload}/sage_psql_catalog/execution_times.csv"),
        sage_sqlite=ancient("output/{workload}/sage_sqlite/execution_times.csv"),
        sage_sqlite_catalog=ancient("output/{workload}/sage_sqlite_catalog/execution_times.csv"),
        sage_hdt=ancient("output/{workload}/sage_hdt/execution_times.csv"),
        sage_hbase=ancient("output/{workload}/sage_hbase/execution_times.csv"),
    output:
        "output/{workload,[^/]+}/execution_times.csv"
    shell:
        "bash scripts/merge_csv.sh {input.sage_psql} {input.sage_psql_catalog} \
                                   {input.sage_sqlite} {input.sage_sqlite_catalog} \
                                   {input.sage_hdt} {input.sage_hbase} > {output}"


rule plot_execution_times:
    input:
        ancient("output/{workload}/execution_times.csv")
    output:
        "figures/{workload,[^/]+}/execution_times.png"
    shell:
        "python scripts/plots.py execution-times {input} {output}"


rule plot_suspend_resume_times:
    input:
        ancient("output/indexes/execution_times.csv")
    output:
        "figures/suspend_resume_times.png"
    shell:
        "python scripts/plots.py suspend-resume-times {input} {output}"


rule spo_execution_times:
    input:
        ancient("output/spo/execution_times.csv")
    output:
        "figures/spo_execution_times.png"
    shell:
        "python scripts/plots.py spo-execution-times {input} {output}"
